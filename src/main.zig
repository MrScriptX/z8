const std = @import("std");
const app_t = @import("interface.zig").app_t;
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const renderer = struct {
    usingnamespace @import("renderer/app.zig");
    usingnamespace @import("renderer/window.zig");
    usingnamespace @import("renderer/device.zig");
};

pub fn main() !u8 {
    const init = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    if (!init) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize SDL: %s", sdl.SDL_GetError());
        return 1;
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow("Hello World", 800, 600, sdl.SDL_WINDOW_VULKAN);
    if (window == null) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Unable to create window: %s", sdl.SDL_GetError());
        return 1;
    }
    defer sdl.SDL_DestroyWindow(window);

    var app: app_t = undefined;

    app.instance = try renderer.init_instance();
    app.surface = try renderer.create_surface(window, app.instance);
    app.physical_device = try renderer.select_physical_device(app);

    // print device info
    renderer.print_device_info(app.physical_device);

    app.queues.queue_family_indices = try renderer.find_queue_family(app.surface, app.physical_device);
    app.device = try renderer.create_device_interface(app);
    app.queues = try renderer.get_device_queue(app);

    // main loop
    var quit = false;
    while (!quit) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                quit = true;
            }
        }
    }

    return 0;
}

test "simple test" {}
