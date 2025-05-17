pub fn main() !u8 {
    const init = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    if (!init) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize SDL: %s", sdl.SDL_GetError());
        return 1;
    }
    defer sdl.SDL_Quit();

    const width = 1280;
    const heigh = 960;

    const window = sdl.SDL_CreateWindow("Hello World", width, heigh, sdl.SDL_WINDOW_VULKAN | sdl.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to create window: %s", sdl.SDL_GetError());
        return 1;
    }
    defer sdl.SDL_DestroyWindow(window);

    _ = sdl.SDL_SetWindowRelativeMouseMode(window, true);

    var main_camera: engine.camera.camera_t = .{
        .position = .{ 0, 0, 75 },
        .speed = 50,
        .sensitivity = 0.02,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer std.log.debug("Memory check : {any}\n", .{ gpa.deinit() });

    var renderer = engine.renderer.renderer_t.init(gpa.allocator(), window, width, heigh, &main_camera) catch {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize Vulkan engine");   
        return 1;
    };
    defer renderer.deinit();

    // create scenes
    var scene_manager = engine.scene.manager_t.init(gpa.allocator());
    defer scene_manager.deinit(renderer._device, renderer._vma);

    // _ = scene_manager.create_scene(gpa.allocator(), engine.scene.type_e.GLTF);
    // _ = scene_manager.create_scene(gpa.allocator(), engine.scene.type_e.GLTF);
    // _ = scene_manager.create_scene(gpa.allocator(), engine.scene.type_e.MESH);


    // create effects
    var background_effects = std.ArrayList(*compute.ComputeEffect).init(gpa.allocator());
    defer background_effects.deinit();

    // gradient shader
    var gradient_effect = compute.ComputeEffect {
        .name = "gradient",
        .data = .{
            .data1 = c.vec4{ 1, 0, 0, 1 },
	        .data2 = c.vec4{ 0, 0, 1, 1 },
            .data3 = c.glms_vec4_zero().raw,
            .data4 = c.glms_vec4_zero().raw 
        },
    };
    gradient_effect.build(gpa.allocator(), "./zig-out/bin/shaders/vkguide/gradiant.spv", &renderer) catch {
        std.log.err("Failed to create gradiant shader", .{});
        return 2;
    };
    defer gradient_effect.deinit(&renderer);

    try background_effects.append(&gradient_effect);

    // sky shader
    var sky_shader = compute.ComputeEffect {
        .name = "sky",
        .data = .{
            .data1 = c.vec4{ 0.1, 0.2, 0.4 , 0.97 },
	        .data2 = c.glms_vec4_zero().raw,
            .data3 = c.glms_vec4_zero().raw,
            .data4 = c.glms_vec4_zero().raw 
        },
    };
    sky_shader.build(gpa.allocator(), "./zig-out/bin/shaders/vkguide/sky.spv", &renderer) catch {
        std.log.err("Failed to create sky shader", .{});
        return 2;
    };
    defer sky_shader.deinit(&renderer);

    try background_effects.append(&sky_shader);

    var current_shader: u32 = 0;
    renderer.bg_shader = background_effects.items[current_shader];

    var current_scene: i32 = 0;
    var render_scene: i32 = -1;

    var reactor_scene: ?levels.ReactorScene = null; 
    defer if (reactor_scene) |*scene| {
        scene.deinit(&renderer);
        reactor_scene = null;
    };

    var monkey_scene: ?levels.MonkeyScene = null;
    defer if (monkey_scene) |*scene| {
        scene.deinit(&renderer);
        monkey_scene = null;
    };

    var voxels_scene: ?levels.VoxelsScene = null;
    defer if (voxels_scene) |*scene| {
        scene.deinit(&renderer);
        voxels_scene = null;
    };

    // main loop
    var quit = false;
    while (!quit) {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                quit = true;
            }
            else if (event.type == sdl.SDL_EVENT_KEY_DOWN) {
                if (event.key.key == sdl.SDLK_ESCAPE) {
                    const succeed = sdl.SDL_SetWindowRelativeMouseMode(window, !main_camera.active);
                    if (succeed) {
                        main_camera.active = !main_camera.active;
                    }
                }
            }

            if (main_camera.active) {
                main_camera.process_sdl_event(&event);
            }
            else {
                _ = imgui.ImplSDL3_ProcessEvent(@ptrCast(&event));
            }
        }

        if (renderer.rebuild) {
            renderer.rebuild_swapchain(gpa.allocator(), window);

            if (reactor_scene) |*scene| {
                scene.deinit(&renderer);
                reactor_scene = null;
            }

            if (monkey_scene) |*scene| {
                scene.deinit(&renderer);
                monkey_scene = null;
            }

            if (voxels_scene) |*scene| {
                scene.deinit(&renderer);
                voxels_scene = null;
            }

            render_scene = -1; // force rebuild of scene
        }

        // check if bg shader needs to be rebuilt
        if (renderer.bg_shader != background_effects.items[current_shader]) {
            renderer.bg_shader = background_effects.items[current_shader];
        }

        // check if scene needs to be rebuilt
        if (render_scene != current_scene) {
            std.log.info("loading new scene", .{});
            
            if (reactor_scene) |*scene| {
                scene.deinit(&renderer);
                reactor_scene = null;
            }

            if (monkey_scene) |*scene| {
                scene.deinit(&renderer);
                monkey_scene = null;
            }

            if (voxels_scene) |*scene| {
                scene.deinit(&renderer);
                voxels_scene = null;
            }

            if (current_scene == 0) {
                monkey_scene = levels.MonkeyScene.init(gpa.allocator(), &renderer) catch {
                    std.log.err("Failed to load monkey scene", .{});
                    @panic("Fatal error");
                };

                renderer._scene = &monkey_scene.?.draw_ctx;
            }
            else if (current_scene == 1) {
                reactor_scene = levels.ReactorScene.init(gpa.allocator(), &renderer) catch {
                    std.log.err("Failed to load rector scene", .{});
                    @panic("Fatal error");
                };

                renderer._scene = &reactor_scene.?.draw_ctx;
            }
            else if (current_scene == 2) {
                voxels_scene = levels.VoxelsScene.init(gpa.allocator(), &renderer) catch {
                    std.log.err("Failed to load rector scene", .{});
                    @panic("Fatal error");
                };

                renderer._scene = &voxels_scene.?.draw_ctx;
            }

            render_scene = current_scene;
        }

        // create new frame for ui
        imgui.ImplVulkan_NewFrame();
        imgui.ImplSDL3_NewFrame();
        imgui.NewFrame();

        // stats window
        engine.gui.show_stats_window(&renderer);

        // player control
        {
            const result = imgui.Begin("controls", null, 0);
            if (result) {
                defer imgui.End();

                _ = imgui.SliderFloat("speed", &main_camera.speed, 0, 100);
                _ = imgui.SliderFloat("sensitivity", &main_camera.sensitivity, 0, 1);

                imgui.ImGui_Text("Camera");
                _ = imgui.InputFloat3("position", &main_camera.position);
                _ = imgui.InputFloat("yaw", &main_camera.yaw);
                _ = imgui.InputFloat("pitch", &main_camera.pitch);
		    }
        }

        // scenes manager
        {
            const result = imgui.Begin("Scenes", null, 0);
            if (result) {
                defer imgui.End();

                const scenes_list = [_][*:0]const u8{ "monkey", "reactor", "cube" };
                _ = imgui.ImGui_ComboChar("view scene", &current_scene, @ptrCast(&scenes_list), 3);

                if (scene_manager.scene(@intCast(render_scene))) |scene| {
                    const data = &scene.data;
                    
                    imgui.ImGui_Text("sun direction");
                    _ = imgui.SliderFloat("x", &data.sunlight_dir[0], -1, 1);
                    _ = imgui.SliderFloat("y", &data.sunlight_dir[1], -1, 1);
                    _ = imgui.SliderFloat("z", &data.sunlight_dir[2], -1, 1);

                    _ = imgui.ImGui_ColorEdit4("sun color", &data.sunlight_color, 0);
                    _ = imgui.ImGui_ColorEdit4("ambient color", &data.ambient_color, 0);
                }
		    }
        }

        // background window
        {
            const result = imgui.Begin("background", null, 0);
            if (result) {
                defer imgui.End();

                _ = imgui.SliderFloat("Render Scale", engine.renderer.renderer_t.render_scale(), 0.3, 1.0);

			    const shader = background_effects.items[current_shader];
		
                _ = imgui.SliderUint("Effect Index", &current_shader, 0, @intCast(background_effects.items.len - 1));

			    _ = imgui.InputFloat4("data1", &shader.data.data1);
			    _ = imgui.InputFloat4("data2", &shader.data.data2);
			    _ = imgui.InputFloat4("data3", &shader.data.data3);
			    _ = imgui.InputFloat4("data4", &shader.data.data4);
		    }
        }

        if (voxels_scene) |*scene| {
            scene.update_ui();
        }

        // render
        imgui.Render();

        if (reactor_scene) |*scene| {
            scene.update(&main_camera, &renderer);
        }
        else if (monkey_scene) |*scene| {
            scene.update(&main_camera, &renderer);
        }
        else if (voxels_scene) |*scene| {
            scene.update(gpa.allocator(), &main_camera, &renderer);
        }
        renderer.draw(gpa.allocator());

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        renderer.stats.frame_time = @floatFromInt(end_time - start_time);
    }

    return 0;
}

pub const std_options: std.Options = .{
    .logFn = log,
};

pub fn log(comptime level: std.log.Level, comptime _: @TypeOf(.EnumLiteral), comptime format: []const u8, args: anytype) void {
    const allocator = std.heap.page_allocator;

    const message = std.fmt.allocPrint(allocator, format, args) catch {
        std.debug.print("Failed to allocate logging message\n", .{});
        return;
    };
    defer allocator.free(message);

    var str_level: []const u8 = undefined; 
    switch (level) {
        std.log.Level.err => str_level = "ERROR",
        std.log.Level.warn => str_level = "WARN",
        std.log.Level.info => str_level = "INFO",
        std.log.Level.debug => str_level = "DEBUG",
    }

    const log_msg = std.fmt.allocPrint(allocator, "{s}\t: {s}\n", .{ str_level, message }) catch {
        std.debug.print("Failed to allocate final log message\n", .{});
        return;
    };
    defer allocator.free(log_msg);

    if (level == std.log.Level.err) {
        const success = sdl.SDL_ShowSimpleMessageBox(sdl.SDL_MESSAGEBOX_ERROR, "Error", log_msg.ptr, null);
        if (!success) {
            std.debug.print("Unable to show message box: {s}\n", .{ sdl.SDL_GetError() });
            sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to show message box: %s", sdl.SDL_GetError());
        }
    }

    // TODO : print to log file
    const stdout = std.io.getStdOut();
    stdout.writer().print("{s}", .{ log_msg }) catch {
        std.debug.print("Fail to write to out stream !\n", .{});
    };

    // if (builtin.mode == .Debug) {
    //     std.debug.print("{s}\n", .{ log_msg });
    // }
}

test "engine test" {
}

const std = @import("std");
const builtin = @import("builtin");
const c = @import("clibs.zig");
const sdl = @import("sdl3");
const engine = @import("engine/engine.zig");
const imgui = @import("imgui");
const za = @import("zalgebra");
const maths = @import("utils/maths.zig");
const compute = @import("engine/compute_effect.zig");
const levels = @import("levels/levels.zig");
