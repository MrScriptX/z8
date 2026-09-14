const c = @import("c");

pub fn Init(flags: c.SDL_InitFlags) bool {
    return c.SDL_Init(flags);
}

pub fn Vulkan_CreateSurface(window: ?*c.SDL_Window, instance: c.VkInstance, allocator: ?*const c.VkAllocationCallbacks, surface: *c.VkSurfaceKHR) bool
{
    return c.SDL_Vulkan_CreateSurface(window, instance, allocator, @ptrCast(surface));
}

pub const SDL_INIT_VIDEO = c.SDL_INIT_VIDEO;
pub const SDL_WINDOW_VULKAN = c.SDL_WINDOW_VULKAN;
pub const SDL_WINDOW_RESIZABLE = c.SDL_WINDOW_RESIZABLE;
pub const SDL_LOG_CATEGORY_APPLICATION = c.SDL_LOG_CATEGORY_APPLICATION;
pub const SDL_EVENT_QUIT = c.SDL_EVENT_QUIT;
pub const SDL_EVENT_KEY_DOWN = c.SDL_EVENT_KEY_DOWN;
pub const SDL_EVENT_KEY_UP = c.SDL_EVENT_KEY_UP;
pub const SDL_EVENT_MOUSE_MOTION = c.SDL_EVENT_MOUSE_MOTION;
pub const SDLK_ESCAPE = c.SDLK_ESCAPE;
pub const SDLK_Z = c.SDLK_Z;
pub const SDLK_S = c.SDLK_S;
pub const SDLK_Q = c.SDLK_Q;
pub const SDLK_D = c.SDLK_D;
pub const SDLK_SPACE = c.SDLK_SPACE;
pub const SDLK_LSHIFT = c.SDLK_LSHIFT;
pub const SDL_LogError = c.SDL_LogError;
pub const SDL_CreateWindow = c.SDL_CreateWindow;
pub const SDL_GetError = c.SDL_GetError;
pub const SDL_DestroyWindow = c.SDL_DestroyWindow;
pub const SDL_SetWindowRelativeMouseMode = c.SDL_SetWindowRelativeMouseMode;
pub const SDL_Quit = c.SDL_Quit;
pub const SDL_Window = c.SDL_Window;
pub const SDL_Vulkan_GetInstanceExtensions = c.SDL_Vulkan_GetInstanceExtensions;
pub const SDL_Event = c.SDL_Event;
pub const SDL_PollEvent = c.SDL_PollEvent;
pub const SDL_GetWindowSize = c.SDL_GetWindowSize;
