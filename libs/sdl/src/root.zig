pub fn Vulkan_CreateSurface(window: ?*c.SDL_Window, instance: c.VkInstance, allocator: ?*const c.VkAllocationCallbacks, surface: *c.VkSurfaceKHR) bool
{
    return c.SDL_Vulkan_CreateSurface(window, instance, allocator, @ptrCast(surface));
}

const c = @import("sdl");
