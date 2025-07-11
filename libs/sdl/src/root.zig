pub usingnamespace @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

pub fn Vulkan_CreateSurface(window: ?*c.SDL_Window, instance: c.VkInstance, allocator: ?*const c.VkAllocationCallbacks, surface: *c.VkSurfaceKHR) bool
{
    return c.SDL_Vulkan_CreateSurface(window, instance, allocator, @ptrCast(surface));
}

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
