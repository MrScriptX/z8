const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const renderer = @import("renderer/renderer.zig");

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

    const app = try renderer.init(window);
    defer renderer.deinit(app);

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
