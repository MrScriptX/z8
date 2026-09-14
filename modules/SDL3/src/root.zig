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
pub const SDL_LogError = c.SDL_LogError;
pub const SDL_CreateWindow = c.SDL_CreateWindow;
pub const SDL_GetError = c.SDL_GetError;
pub const SDL_DestroyWindow = c.SDL_DestroyWindow;
pub const SDL_SetWindowRelativeMouseMode = c.SDL_SetWindowRelativeMouseMode;
pub const SDL_Quit = c.SDL_Quit;
pub const SDL_Window = c.SDL_Window;
pub const SDL_Vulkan_GetInstanceExtensions = c.SDL_Vulkan_GetInstanceExtensions;
