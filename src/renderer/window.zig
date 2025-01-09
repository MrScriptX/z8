const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

pub fn create_surface(window: ?*sdl.SDL_Window, instance: vk.VkInstance) !vk.VkSurfaceKHR {
    var surface: vk.VkSurfaceKHR = undefined;
    const result = sdl.SDL_Vulkan_CreateSurface(window, @ptrCast(instance), null, @ptrCast(&surface));
    if (result == false) {
        return std.debug.panic("Unable to create Vulkan surface: {s}", .{sdl.SDL_GetError()});
    }

    return surface;
}
