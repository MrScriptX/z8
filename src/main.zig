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
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer std.log.debug("Memory check : {any}\n", .{ gpa.deinit() });

    var renderer = engine.renderer_t.init(gpa.allocator(), window, width, heigh, &main_camera) catch {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize Vulkan engine");   
        return 1;
    };
    defer renderer.deinit();

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
                    _ = c.SDL_SetWindowRelativeMouseMode(window, false);
                }
            }

            main_camera.process_sdl_event(&event);

            _ = imgui.cImGui_ImplSDL3_ProcessEvent(@ptrCast(&event));
        }

        if (renderer.should_rebuild_sw()) {
            renderer.rebuild_swapchain(window);
        }


        imgui.cImGui_ImplVulkan_NewFrame();
        imgui.cImGui_ImplSDL3_NewFrame();
        imgui.ImGui_NewFrame();

        // stats window
        {
            const win_stats = imgui.ImGui_Begin("Stats", null, 0);
            if (win_stats) {
                defer imgui.ImGui_End();

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

        // background window
        {
            const result = imgui.ImGui_Begin("background", null, 0);
            if (result) {
                defer imgui.ImGui_End();

                _ = imgui.ImGui_SliderFloat("Render Scale", @ptrCast(engine.renderer_t.render_scale()), 0.3, 1.0);

			    const selected = engine.renderer_t.current_effect();
		
                const name = try std.fmt.allocPrint(std.heap.page_allocator, "Selected effect: {s}", .{ selected.name });
			    imgui.ImGui_Text(@ptrCast(&name));
		
			    _ = imgui.ImGui_SliderInt("Effect Index", @ptrCast(engine.renderer_t.effect_index()), 0, @intCast(engine.renderer_t.max_effect() - 1));
		
			    _ = imgui.ImGui_InputFloat4("data1", &selected.data.data1);
			    _ = imgui.ImGui_InputFloat4("data2", &selected.data.data2);
			    _ = imgui.ImGui_InputFloat4("data3", &selected.data.data3);
			    _ = imgui.ImGui_InputFloat4("data4", &selected.data.data4);
		    }
        }

        imgui.ImGui_Render();

        renderer.draw();

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
const imgui = @import("renderer/imgui.zig");
// const log = @import("utils/log.zig");
