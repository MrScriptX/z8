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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var renderer = engine.renderer_t.init(gpa.allocator(), window, width, heigh) catch {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize Vulkan engine");   
        return 1;
    };
    defer renderer.deinit();

    std.debug.print("\nin main\n\n", .{});

    std.debug.print("rough mat pipeline address {*}\n", .{renderer._metal_rough_material.opaque_pipeline.pipeline});
    std.debug.print("opaque pipeline: {*}\n", .{renderer._default_data.pipeline.pipeline});

    for (renderer._loaded_nodes.items) |*node| {
            std.debug.print("key: {s}\n", .{ node.key });
            for (node.value.mesh.surfaces.items) |*s| {
                std.debug.print("pipeline address {*}\n", .{s.material.data.pipeline.pipeline});
                std.debug.print("pass type address {any}\n", .{s.material.data.pass_type});
                std.debug.print("layout address {*}\n", .{s.material.data.pipeline.layout });
                std.debug.print("ptr address {*}\n", .{s.material.data.pipeline });
            }
        }

    // var it = renderer._loaded_nodes.iterator();
    // while (it.next()) |node| {
    //     std.debug.print("key: {s}\n", .{ node.key_ptr.* });
    //     for (renderer._loaded_nodes.get(node.key_ptr.*).?.mesh.surfaces.items) |*s| {
    //         std.debug.print("pipeline address {*}\n", .{s.material.data.pipeline.pipeline});
    //     }
    // }

    // main loop
    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                quit = true;
            }

            _ = imgui.cImGui_ImplSDL3_ProcessEvent(@ptrCast(&event));
        }

        if (engine.renderer_t.should_rebuild_sw()) {
            renderer.rebuild_swapchain(window);
        }


        imgui.cImGui_ImplVulkan_NewFrame();
        imgui.cImGui_ImplSDL3_NewFrame();
        imgui.ImGui_NewFrame();

        if (imgui.ImGui_Begin("background", null, 0)) {
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
		imgui.ImGui_End();

        imgui.ImGui_Render();

        renderer.draw();
    }

    return 0;
}

test "engine test" {
}

const std = @import("std");
const c = @import("clibs.zig");
const engine = @import("renderer/engine.zig");
const imgui = @import("renderer/imgui.zig");
