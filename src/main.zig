const std = @import("std");
const c = @import("clibs.zig");
const renderer_t = @import("renderer/renderer.zig").renderer_t;

pub fn main() !u8 {
    const init = c.SDL_Init(c.SDL_INIT_VIDEO);
    if (!init) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to initialize SDL: %s", c.SDL_GetError());
        return 1;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Hello World", 800, 600, c.SDL_WINDOW_VULKAN);
    if (window == null) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to create window: %s", c.SDL_GetError());
        return 1;
    }
    defer c.SDL_DestroyWindow(window);

    var renderer = renderer_t{};
    try renderer.init(window, 800, 600);
    defer renderer.deinit();
    
    renderer.draw();

    // main loop
    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                quit = true;
            }
        }
    }

    return 0;
}

test "simple test" {}
