const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

pub fn init_instance() !vk.VkInstance {
    const app_info = vk.VkApplicationInfo{
        .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pNext = null,
        .pApplicationName = "vzig",
        .applicationVersion = vk.VK_MAKE_VERSION(1, 0, 0),
        .pEngineName = "vzig",
        .engineVersion = vk.VK_MAKE_VERSION(1, 0, 0),
        .apiVersion = vk.VK_API_VERSION_1_0,
    };

    // get required extensions
    var extension_count: u32 = 0;
    const required_extensions = sdl.SDL_Vulkan_GetInstanceExtensions(&extension_count);// VK_EXT_DEBUG_REPORT_EXTENSION_NAME

    const instance_info = vk.VkInstanceCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &app_info,
        .enabledLayerCount = 0,
        .ppEnabledLayerNames = null,
        .enabledExtensionCount = extension_count,
        .ppEnabledExtensionNames = required_extensions,
    };

    var instance: vk.VkInstance = undefined;
    const result = vk.vkCreateInstance(&instance_info, null, &instance);
    if (result != vk.VK_SUCCESS) {
        return std.debug.panic("Unable to create Vulkan instance: {}", .{result});
    }

    return instance;
}
