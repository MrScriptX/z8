const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const app_t = @import("../interface.zig").app_t;
const renderer = struct {
    usingnamespace @import("app.zig");
    usingnamespace @import("window.zig");
    usingnamespace @import("device.zig");
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

    return app;
}

pub fn deinit(app: app_t) void {
    c.vkDestroyDevice(app.device, null);
    c.vkDestroySurfaceKHR(app.instance, app.surface, null);
    c.vkDestroyInstance(app.instance, null);
}
