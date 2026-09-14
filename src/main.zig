pub fn main(process: std.process.Init) !u8 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer std.log.debug("Memory check : {any}\n", .{ gpa.deinit() });

    const allocator = gpa.allocator();

    // const init_sdl = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    const init_sdl = sdl.Init(sdl.SDL_INIT_VIDEO);
    if (!init_sdl) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize SDL: %s", sdl.SDL_GetError());
        return 1;
    }
    defer sdl.SDL_Quit();

    const width = 1920;
    const heigh = 1080;

    const window = sdl.SDL_CreateWindow("Z8 Engine", width, heigh, sdl.SDL_WINDOW_VULKAN | sdl.SDL_WINDOW_RESIZABLE);
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

    var renderer = engine.renderer.Renderer.init(gpa.allocator(), window, width, heigh, &main_camera) catch {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize Vulkan engine");   
        return 1;
    };
    defer renderer.deinit();

    // create effects
    var background_effects = std.ArrayList(*compute.ComputeEffect).empty;
    defer background_effects.deinit(allocator);

    // const dir = try std.fs.selfExeDirPathAlloc(allocator);
    const dir = try std.process.executableDirPathAlloc(process.io, allocator);
    defer allocator.free(dir);

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

    const gradiant_file = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/vkguide/gradiant.spv" });
    defer allocator.free(gradiant_file);

    gradient_effect.build(allocator, process.io, gradiant_file, &renderer) catch {
        std.log.err("Failed to create gradiant shader", .{});
        return 2;
    };
    defer gradient_effect.deinit(&renderer);

    try background_effects.append(allocator, &gradient_effect);

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
    const sky_shader_file = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/vkguide/sky.spv" });
    defer allocator.free(sky_shader_file);

    sky_shader.build(allocator, process.io, sky_shader_file, &renderer) catch {
        std.log.err("Failed to create sky shader", .{});
        return 2;
    };
    defer sky_shader.deinit(&renderer);

    try background_effects.append(allocator, &sky_shader);

    var current_shader: u32 = 0;
    renderer.bg_shader = background_effects.items[current_shader];

    var scene_manager = engine.scene.Manager.init(allocator, 2);
    defer scene_manager.deinit(&renderer);

    scene_manager.build_scene(process.io, &renderer);

    // main loop
    var quit = false;
    while (!quit) {
        const now = std.Io.Clock.now(.awake, process.io);
        const start_time: u128 = @intCast(now.toNanoseconds());

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

            scene_manager.clear(&renderer);
            scene_manager.build_scene(process.io, &renderer);
        }

        // check if bg shader needs to be rebuilt
        if (renderer.bg_shader != background_effects.items[current_shader]) {
            renderer.bg_shader = background_effects.items[current_shader];
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

                var position: [3]f32 = .{
                    main_camera.position[0],
                    main_camera.position[1],
                    main_camera.position[2]
                };

                _ = imgui.InputFloat3("position", &position);
                _ = imgui.InputFloat("yaw", &main_camera.yaw);
                _ = imgui.InputFloat("pitch", &main_camera.pitch);
		    }
        }

        // background window
        {
            const result = imgui.Begin("background", null, 0);
            if (result) {
                defer imgui.End();

                _ = imgui.SliderFloat("Render Scale", engine.renderer.Renderer.render_scale(), 0.3, 1.0);

			    const shader = background_effects.items[current_shader];
		
                _ = imgui.SliderUint("Effect Index", &current_shader, 0, @intCast(background_effects.items.len - 1));

			    _ = imgui.InputFloat4("data1", &shader.data.data1);
			    _ = imgui.InputFloat4("data2", &shader.data.data2);
			    _ = imgui.InputFloat4("data3", &shader.data.data3);
			    _ = imgui.InputFloat4("data4", &shader.data.data4);
		    }
        }

        scene_manager.update_ui(process.io, &renderer);

        // render
        imgui.Render();

        scene_manager.update(process.io, &main_camera, &renderer);
        renderer.draw(gpa.allocator(), process.io);

        const end_now = std.Io.Clock.now(.awake, process.io);
        const end_time: u128 = @intCast(end_now.toNanoseconds());
        renderer.stats.frame_time = @floatFromInt(end_time - start_time);
    }

    return 0;
}

// pub const std_options: std.Options = .{
//     .logFn = log,
// };

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

    // Use C interop for timestamp (strftime + time)
    const c_time = @cImport({
        @cInclude("time.h");
        @cInclude("stdio.h");
    });

    var t: c_time.time_t = c_time.time(null);
    const tm = c_time.localtime(&t);
    var timestamp_buf: [32]u8 = undefined;
    _ = c_time.strftime(&timestamp_buf, timestamp_buf.len, "%Y-%m-%dT%H:%M:%S", tm);
    const timestamp = std.mem.sliceTo(&timestamp_buf, 0);

    // Get PID
    const pid = getpid();

    // POSIX log format: <timestamp> <level> [PID]: <message>\n
    const log_msg = std.fmt.allocPrint(allocator, "{s} {s} [{d}]: {s}\n", .{ timestamp, str_level, pid, message }) catch {
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
    // var threaded: std.Io.Threaded = .init_single_threaded;
    // const io = threaded.io();

    // const stdout = io.getStdOut();
    // stdout.writer().print("{s}", .{ log_msg }) catch {
    //     std.debug.print("Fail to write to out stream !\n", .{});
    // };

    // if (builtin.mode == .Debug) {
    //     std.debug.print("{s}\n", .{ log_msg });
    // }
}

const getpid = if (builtin.os.tag == .windows) std.os.windows.GetCurrentProcessId else std.os.linux.getpid;

test "engine test" {
}

const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");
const sdl = @import("sdl3");
const engine = @import("engine/engine.zig");
const imgui = @import("imgui");
const za = @import("zalgebra");
const maths = @import("utils/maths.zig");
const compute = @import("engine/compute_effect.zig");
const levels = @import("levels/levels.zig");
