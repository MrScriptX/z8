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

    var main_camera: camera.camera_t = .{
        .position = .{ 0, 0, 75 },
        .speed = 50,
        .sensitivity = 0.02,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer std.log.debug("Memory check : {any}\n", .{ gpa.deinit() });

    var renderer = engine.renderer_t.init(gpa.allocator(), window, width, heigh, &main_camera) catch {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize Vulkan engine");   
        return 1;
    };
    defer renderer.deinit();

    var voxel_material = vox.VoxelMaterial.init(gpa.allocator(), renderer._device);
    try voxel_material.build_pipeline(&renderer);
    defer voxel_material.deinit(renderer._device);

    // load reactor scene
    var reactor_scene = scene.scene_t.init(gpa.allocator(), scene.type_e.GLTF);
    defer reactor_scene.deinit(renderer._device, renderer._vma);

    // load monkey scene
    var monkey_scene = scene.scene_t.init(gpa.allocator(), scene.type_e.GLTF);
    defer monkey_scene.deinit(renderer._device, renderer._vma);

    // rectangle scene
    var rectangle_scene = scene.scene_t.init(gpa.allocator(), scene.type_e.MESH);
    defer rectangle_scene.deinit(renderer._device, renderer._vma);

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
                _ = imgui.cImGui_ImplSDL3_ProcessEvent(@ptrCast(&event));
            }
        }

        if (renderer.should_rebuild_sw()) {
            renderer.rebuild_swapchain(window);

            if (monkey_scene.gltf != null) {
                monkey_scene.clear(renderer._device, renderer._vma);
            }
            
            if (reactor_scene.gltf != null) {
                reactor_scene.clear(renderer._device, renderer._vma);
            }

            if (rectangle_scene.voxel != null) {
                rectangle_scene.clear(renderer._device, renderer._vma);
            }

            render_scene = -1; // force rebuild of scene
        }

        imgui.ImplVulkan_NewFrame();
        imgui.ImplSDL3_NewFrame();
        imgui.NewFrame();

        // stats window
        {
            const win_stats = imgui.Begin("Stats", null, 0);
            if (win_stats) {
                defer imgui.End();

                const frame_time: f32 = renderer.stats.frame_time / 1_000_000;
                imgui.ImGui_Text("frame time : %f ms",  frame_time);

                const draw_time: f32 = renderer.stats.mesh_draw_time / 1_000_000;
                imgui.ImGui_Text("draw time : %f ms",  draw_time);

                const scene_update_time: f32 = renderer.stats.scene_update_time / 1_000_000;
                imgui.ImGui_Text("update time : %f ms",  scene_update_time);

                imgui.ImGui_Text("triangles : %i",  renderer.stats.triangle_count);
                imgui.ImGui_Text("draws : %i",  renderer.stats.drawcall_count);
            }
        }

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

                const scenes_list = [_][*:0]const u8{ "monkey", "reactor", "rectangle" };
                _ = imgui.ImGui_ComboChar("view scene", &current_scene, @ptrCast(&scenes_list), 3);
		    }
        }

        // background window
        {
            const result = imgui.Begin("background", null, 0);
            if (result) {
                defer imgui.End();

                _ = imgui.SliderFloat("Render Scale", engine.renderer_t.render_scale(), 0.3, 1.0);

			    const selected = engine.renderer_t.current_effect();
		
                const name = try std.fmt.allocPrint(std.heap.page_allocator, "Selected effect: {s}", .{ selected.name });
			    imgui.ImGui_Text(@ptrCast(&name));
		
                _ = imgui.SliderUint("Effect Index", engine.renderer_t.effect_index(), 0, engine.renderer_t.max_effect() - 1);

			    _ = imgui.InputFloat4("data1", &selected.data.data1);
			    _ = imgui.InputFloat4("data2", &selected.data.data2);
			    _ = imgui.InputFloat4("data3", &selected.data.data3);
			    _ = imgui.InputFloat4("data4", &selected.data.data4);
		    }
        }

        imgui.Render();

        if (render_scene != current_scene) {
            switch (current_scene) {
                0 => {
                    reactor_scene.clear(renderer._device, renderer._vma);
                    rectangle_scene.clear(renderer._device, renderer._vma);

                    try monkey_scene.load(gpa.allocator(), "assets/models/basicmesh.glb", renderer._device, &renderer._imm_fence, renderer._queues.graphics, renderer._imm_command_buffer, renderer._vma, &renderer);
                    monkey_scene.deactivate_node("Cube");
                    monkey_scene.deactivate_node("Sphere");
                },
                1 => {
                    monkey_scene.clear(renderer._device, renderer._vma);
                    rectangle_scene.clear(renderer._device, renderer._vma);

                    try reactor_scene.load(gpa.allocator(), "assets/models/structure.glb", renderer._device, &renderer._imm_fence, renderer._queues.graphics, renderer._imm_command_buffer, renderer._vma, &renderer);
                },
                2 => {
                    monkey_scene.clear(renderer._device, renderer._vma);
                    reactor_scene.clear(renderer._device, renderer._vma);

                    try rectangle_scene.create_mesh(gpa.allocator(), &voxel_material, &renderer);
                },
                else => {
                    std.log.warn("Invalid selected scene : {d}", .{ current_scene });
                }
            }

            render_scene = current_scene;
        }

        if (current_scene == 0) {
            if (monkey_scene.find_node("Suzanne")) |node| {
                const current_transform = za.Mat4.fromSlice(&maths.linearize(node.local_transform));

                const rotation_speed: f32 = 45.0; // Degrees per second
                const rotation_angle = rotation_speed * (renderer.stats.frame_time / 1_000_000_000.0);
                const rot = za.Mat4.identity().rotate(rotation_angle, za.Vec3.new(0, 1, 0)).mul(current_transform).data;

                node.local_transform = rot;
                node.refresh_transform(&rot);
            }

            renderer.update_scene(&monkey_scene);
            renderer.draw(&monkey_scene);
        }
        else if (current_scene == 2) {
            renderer.update_scene(&rectangle_scene);
            renderer.draw(&rectangle_scene);
        }
        else {
            renderer.update_scene(&reactor_scene);
            renderer.draw(&reactor_scene);
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

    const log_msg = std.fmt.allocPrint(allocator, "{any}\t: {s}\n", .{ level, message }) catch {
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
const engine = @import("renderer/engine.zig");
const camera = @import("engine/camera.zig");
const ui = @import("renderer/imgui.zig");
const imgui = @import("imgui");
const scene = @import("engine/scene.zig");
const za = @import("zalgebra");
const maths = @import("utils/maths.zig");
const vox = @import("voxel.zig");
