const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const app_t = @import("types.zig").app_t;
const renderer = struct {
    usingnamespace @import("app.zig");
    usingnamespace @import("window.zig");
    usingnamespace @import("device.zig");
    usingnamespace @import("swapchain.zig");
};

pub fn init(window: ?*sdl.SDL_Window) !app_t {
    var app: app_t = undefined;

    app.instance = try renderer.init_instance();
    app.surface = try renderer.create_surface(window, app.instance);

    app.physical_device = try renderer.select_physical_device(app);

    // print device info
    renderer.print_device_info(app.physical_device);

    app.queues.queue_family_indices = try renderer.find_queue_family(app.surface, app.physical_device);
    app.device = try renderer.create_device_interface(app);
    
    app.queues = try renderer.get_device_queue(app);

    const window_extent = c.VkExtent2D{
        .width = 800,
        .height = 600,
    };
    var swapchain = try renderer.create_swapchain(app, window_extent);    
    swapchain.images = try renderer.create_swapchain_images(app, swapchain);

    return app;
}

pub fn deinit(app: app_t) void {
    // clean_swapchain(app);

    c.vkDestroyDevice(app.device, null);
    c.vkDestroySurfaceKHR(app.instance, app.surface, null);
    c.vkDestroyInstance(app.instance, null);
}

// pub fn clean_swapchain(app: *app_t, swapchain: *swapchain_t) void {
//     c.vkDeviceWaitIdle(app.device);
//     c.vkQueueWaitIdle(app.queues.graphics_queue);
// 	c.vkQueueWaitIdle(app.queues.present_queue);
// }
