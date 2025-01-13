const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const app_t = @import("types.zig").app_t;
const swapchain_t = @import("types.zig").swapchain_t;
const renderer = struct {
    usingnamespace @import("app.zig");
    usingnamespace @import("window.zig");
    usingnamespace @import("device.zig");
    usingnamespace @import("swapchain.zig");
};

pub const renderer_t = struct {
    app: app_t = undefined,
    swapchain: swapchain_t = undefined,

    pub fn init(self: *renderer_t, window: ?*sdl.SDL_Window) !void {
        self.app.instance = try renderer.init_instance();
        self.app.surface = try renderer.create_surface(window, self.app.instance);

        self.app.physical_device = try renderer.select_physical_device(self.app);

        // print device info
        renderer.print_device_info(self.app.physical_device);

        self.app.queues.queue_family_indices = try renderer.find_queue_family(self.app.surface, self.app.physical_device);
        self.app.device = try renderer.create_device_interface(self.app);
    
        self.app.queues = try renderer.get_device_queue(self.app);

        // create swapchain
        const window_extent = c.VkExtent2D{
            .width = 800,
            .height = 600,
        };
        self.swapchain = try renderer.create_swapchain(self.app, window_extent);    
        self.swapchain.images = try renderer.create_swapchain_images(self.app, self.swapchain);
        self.swapchain.depth = try renderer.create_depth_ressources(self.app, self.swapchain);
    }

    pub fn deinit(self: *renderer_t) void {
        self.clean_swapchain();

        c.vkDestroyDevice(self.app.device, null);
        c.vkDestroySurfaceKHR(self.app.instance, self.app.surface, null);
        c.vkDestroyInstance(self.app.instance, null);
    }

    pub fn clean_swapchain(self: *renderer_t) void {
        _ = c.vkDeviceWaitIdle(self.app.device);
        _ = c.vkQueueWaitIdle(self.app.queues.graphics_queue);
	    _ = c.vkQueueWaitIdle(self.app.queues.present_queue);

        c.vkDestroyImageView(self.app.device, self.swapchain.depth.view, null);
	    c.vkDestroyImage(self.app.device, self.swapchain.depth.image, null);
	    c.vkFreeMemory(self.app.device, self.swapchain.depth.mem, null);

        for (self.swapchain.images.image_views) |image_view| {
            c.vkDestroyImageView(self.app.device, image_view, null);
        }

        c.vkDestroySwapchainKHR(self.app.device, self.swapchain.handle, null);
    }
};
