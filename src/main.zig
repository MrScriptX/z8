pub fn main() !u8 {
    const init = c.SDL_Init(c.SDL_INIT_VIDEO);
    if (!init) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize SDL: %s", c.SDL_GetError());
        return 1;
    }
    defer c.SDL_Quit();

    const width = 1280;
    const heigh = 960;

    const window = c.SDL_CreateWindow("Hello World", width, heigh, c.SDL_WINDOW_VULKAN | c.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to create window: %s", c.SDL_GetError());
        return 1;
    }
    defer c.SDL_DestroyWindow(window);

    _ = c.SDL_SetWindowRelativeMouseMode(window, true);

    var main_camera: engine.camera.camera_t = .{
        .position = .{ 0, 0, 75 },
        .speed = 50,
        .sensitivity = 0.02,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer std.log.debug("Memory check : {any}\n", .{ gpa.deinit() });

    var renderer = engine.renderer.renderer_t.init(gpa.allocator(), window, width, heigh, &main_camera) catch {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize Vulkan engine");   
        return 1;
    };
    defer renderer.deinit();

    // create materials
    var voxel_material = vox.VoxelMaterial.init(gpa.allocator(), renderer._device);
    try voxel_material.build_pipeline(gpa.allocator(), &renderer);
    defer voxel_material.deinit(renderer._device);

    // create scenes
    var scene_manager = engine.scene.manager_t.init(gpa.allocator());
    defer scene_manager.deinit(renderer._device, renderer._vma);

    _ = scene_manager.create_scene(gpa.allocator(), engine.scene.type_e.GLTF);
    _ = scene_manager.create_scene(gpa.allocator(), engine.scene.type_e.GLTF);
    _ = scene_manager.create_scene(gpa.allocator(), engine.scene.type_e.MESH);


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
    gradient_effect.build(gpa.allocator(), "./zig-out/bin/shaders/gradiant.spv", &renderer) catch {
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
    sky_shader.build(gpa.allocator(), "./zig-out/bin/shaders/sky.spv", &renderer) catch {
        std.log.err("Failed to create sky shader", .{});
        return 2;
    };
    defer sky_shader.deinit(&renderer);

    try background_effects.append(&sky_shader);

    var current_shader: u32 = 0;
    renderer.bg_shader = background_effects.items[current_shader];

    var current_scene: i32 = 0;
    var render_scene: i32 = -1;

    // main loop
    var quit = false;
    while (!quit) {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                quit = true;
            }
            else if (event.type == c.SDL_EVENT_KEY_DOWN) {
                if (event.key.key == c.SDLK_ESCAPE) {
                    const succeed = c.SDL_SetWindowRelativeMouseMode(window, !main_camera.active);
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

        const current = scene_manager.scene(@intCast(current_scene));

        if (renderer.should_rebuild_sw()) {
            renderer.rebuild_swapchain(gpa.allocator(), window);

            if (current) |s| {
                s.clear(renderer._device, renderer._vma);
            }

            render_scene = -1; // force rebuild of scene
        }

        // check if bg shader needs to be rebuilt
        if (renderer.bg_shader != background_effects.items[current_shader]) {
            renderer.bg_shader = background_effects.items[current_shader];
        }

        // check if scene needs to be rebuilt
        if (render_scene != current_scene) {
            const rendered_scene = scene_manager.scene(@intCast(current_scene));
            if (rendered_scene) |s| {
                s.clear(renderer._device, renderer._vma);
            }

            if (current) |s| {
                if (current_scene == 0) {
                    try s.load_gltf(gpa.allocator(), "assets/models/basicmesh.glb", &renderer);
                    s.deactivate_node("Cube");
                    s.deactivate_node("Sphere");
                }
                else if (current_scene == 1) {
                    try s.load_gltf(gpa.allocator(), "assets/models/structure.glb", &renderer);
                }
                else if (current_scene == 2) {
                    try s.load_mesh(gpa.allocator(), &voxel_material, &renderer);
                }
            }
            else {
                std.log.err("Invalid scene {d}", .{ current_scene });
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

        // render
        imgui.Render();

        if (current) |s| {
            if (current_scene == 0) {
                if (s.find_node("Suzanne")) |node| {
                    const current_transform = za.Mat4.fromSlice(&maths.linearize(node.local_transform));

                    const rotation_speed: f32 = 45.0; // Degrees per second
                    const rotation_angle = rotation_speed * (renderer.stats.frame_time / 1_000_000_000.0);
                    const rot = za.Mat4.identity().rotate(rotation_angle, za.Vec3.new(0, 1, 0)).mul(current_transform).data;

                    node.local_transform = rot;
                    node.refresh_transform(&rot);
                }
            }

            renderer.update_scene(s);
            renderer.draw(s);
        }

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
        const success = c.SDL_ShowSimpleMessageBox(c.SDL_MESSAGEBOX_ERROR, "Error", log_msg.ptr, null);
        if (!success) {
            std.debug.print("Unable to show message box: {s}\n", .{ c.SDL_GetError() });
            c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to show message box: %s", c.SDL_GetError());
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
const engine = @import("engine/engine.zig");
const imgui = @import("imgui");
const za = @import("zalgebra");
const maths = @import("utils/maths.zig");
const vox = @import("voxel.zig");
const compute = @import("engine/compute_effect.zig");
