const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const swapchain_details_t = @import("swapchain.zig").swapchain_details_t;
const queue = @import("queue_family.zig");
const queues_t = queue.queues_t;
const opt = @import("../options.zig");

pub const app_t = struct {
    instance: vk.VkInstance = undefined,
    surface: vk.VkSurfaceKHR = undefined,
    physical_device: vk.VkPhysicalDevice = undefined,
    device: vk.VkDevice = undefined,
    queue_indices: queue.queue_indices_t = undefined,

    pub fn init(self: *app_t, window: ?*sdl.SDL_Window) !void {
        self.instance = try init_instance();
        self.surface = try create_surface(window, self.instance);
        self.physical_device = try select_physical_device(self.instance, self.surface);
        self.queue_indices = try queue.find_queue_family(self.surface, self.physical_device);
        self.device = try create_device_interface(self.physical_device, self.queue_indices);
    }

    pub fn deinit(_: *app_t) void {
    }
};

fn init_instance() !vk.VkInstance {
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

    var extensions = std.ArrayList([*c]const u8).init(std.heap.page_allocator);
    for (0..extension_count) |i| {
        try extensions.append(required_extensions[i]);
    }

    try extensions.append("VK_EXT_debug_utils");
    extension_count += 1;

    // validation layer
    const layers = [_][]const u8{
        "VK_LAYER_KHRONOS_validation"
    };

    const instance_info = vk.VkInstanceCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &app_info,
        .enabledLayerCount = 1,
        .ppEnabledLayerNames = @ptrCast(&layers),
        .enabledExtensionCount = extension_count,
        .ppEnabledExtensionNames = extensions.items.ptr,
    };

    var instance: vk.VkInstance = undefined;
    const result = vk.vkCreateInstance(&instance_info, null, &instance);
    if (result != vk.VK_SUCCESS) {
        return std.debug.panic("Unable to create Vulkan instance: {}", .{result});
    }

    return instance;
}

fn create_surface(window: ?*sdl.SDL_Window, instance: vk.VkInstance) !vk.VkSurfaceKHR {
    var surface: vk.VkSurfaceKHR = undefined;
    const result = sdl.SDL_Vulkan_CreateSurface(window, @ptrCast(instance), null, @ptrCast(&surface));
    if (result == false) {
        return std.debug.panic("Unable to create Vulkan surface: {s}", .{sdl.SDL_GetError()});
    }

    return surface;
}

fn select_physical_device(instance: vk.VkInstance, surface: vk.VkSurfaceKHR) !vk.VkPhysicalDevice {
    var device_count: u32 = 0;
    _ = vk.vkEnumeratePhysicalDevices(instance, &device_count, null);

    if (device_count == 0) {
        return std.debug.panic("No Vulkan devices found", .{});
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const devices = try allocator.alloc(vk.VkPhysicalDevice, device_count);
    const result = vk.vkEnumeratePhysicalDevices(instance, &device_count, devices.ptr);
    if (result != vk.VK_SUCCESS) {
        return std.debug.panic("Unable to enumerate Vulkan devices: {}", .{result});
    }

    var physical_device: ?vk.VkPhysicalDevice = null;
    for (devices) |device| {
        if (try check_device(surface, device)) {
            physical_device = device;
            break;
        }
    }

    if (physical_device == null) {
        return std.debug.panic("No suitable Vulkan device found", .{});
    }

    return physical_device.?;
}

fn create_device_interface(physical_device: vk.VkPhysicalDevice, queues: queue.queue_indices_t) !vk.VkDevice {
    var queue_priority: f32 = 1.0;
    
    var queue_create_infos = std.ArrayList(vk.VkDeviceQueueCreateInfo).init(std.heap.page_allocator);

    const graphic_queue_create_info = vk.VkDeviceQueueCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = queues.graphics_family,
        .queueCount = 1,
        .pQueuePriorities = &queue_priority,
    };

    try queue_create_infos.append(graphic_queue_create_info);

    if (queues.graphics_family != queues.present_family) {
        const present_qeueu_create_info = vk.VkDeviceQueueCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueFamilyIndex = queues.present_family,
            .queueCount = 1,
            .pQueuePriorities = &queue_priority,
        };

        try queue_create_infos.append(present_qeueu_create_info);
    }

    // create device info
    const device_features = vk.VkPhysicalDeviceFeatures{
        .samplerAnisotropy = vk.VK_TRUE,
        .fillModeNonSolid = vk.VK_TRUE,
    };

    const device_create_info = vk.VkDeviceCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = @intCast(queue_create_infos.items.len),
        .pQueueCreateInfos = queue_create_infos.items.ptr,
        .enabledExtensionCount = 1,
        .ppEnabledExtensionNames = @ptrCast(&opt.extensions),
        .pEnabledFeatures = &device_features,
    };

    var device: vk.VkDevice = undefined;
    const result = vk.vkCreateDevice(physical_device, &device_create_info, null, &device);
    if (result != vk.VK_SUCCESS) {
        return std.debug.panic("Unable to create Vulkan device: {}", .{result});
    }

    return device;
}

fn check_device(surface: vk.VkSurfaceKHR, device: vk.VkPhysicalDevice) !bool {
    var device_properties: vk.VkPhysicalDeviceProperties = undefined;
    vk.vkGetPhysicalDeviceProperties(device, &device_properties);

    var device_features: vk.VkPhysicalDeviceFeatures = undefined;
    vk.vkGetPhysicalDeviceFeatures(device, &device_features);

    if (device_properties.deviceType != vk.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU and device_properties.deviceType != vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) {
        std.debug.print("Wrong device type\n", .{});
        return false;
    }

    if (device_features.geometryShader == vk.VK_FALSE) {
        std.debug.print("No geometry shader\n", .{});
        return false;
    }

    const queue_family_indices = try queue.find_queue_family(surface, device);
    const extensions_supported = try check_device_extensions_support(device);
    if (!extensions_supported) {
        std.debug.print("Unsupported extensions\n", .{});
        return false;
    }

    var swapchain_supported: bool = false;
    if (extensions_supported) {
        const swapchain_details = try query_swapchain_support(device, surface);
        defer swapchain_details.deinit();

        swapchain_supported = swapchain_details.formats.len != 0 and swapchain_details.present_modes.len != 0;
        if (!swapchain_supported) {
            std.debug.print("Unsupported swapchain\n", .{});
            return false;
        }
    }

    var supportedFeatures: vk.VkPhysicalDeviceFeatures = undefined;
    vk.vkGetPhysicalDeviceFeatures(device, &supportedFeatures);

    if (supportedFeatures.samplerAnisotropy != vk.VK_TRUE) {
        std.debug.print("No sampler anisotropy\n", .{});
        return false;
    }

    if (!queue_family_indices.is_complete()) {
        std.debug.print("Incomplete queue family indices\n", .{});
        return false;
    }

    return true;
}

fn check_device_extensions_support(device: vk.VkPhysicalDevice) !bool {
    var extension_count: u32 = 0;
    _ = vk.vkEnumerateDeviceExtensionProperties(device, null, &extension_count, null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const available_extensions = try allocator.alloc(vk.VkExtensionProperties, extension_count);
    _ = vk.vkEnumerateDeviceExtensionProperties(device, null, &extension_count, available_extensions.ptr);

    const required_extensions = [_][]const u8{
        "VK_KHR_swapchain",
    };

    var match_extensions: u32 = 0;

    for (available_extensions) |extension| {
        for (required_extensions) |required_extension| {
            const ext_name: [*c]const u8 = @ptrCast(extension.extensionName[0..]);

            const match = std.mem.eql(u8, required_extension, std.mem.span(ext_name));
            if (match) {
                match_extensions += 1;
                break;
            }
        }
    }

    return match_extensions == required_extensions.len;
}

fn query_swapchain_support(device: vk.VkPhysicalDevice, surface: vk.VkSurfaceKHR) !swapchain_details_t {
    var swapchain_details = swapchain_details_t{};
    swapchain_details.init();

    _ = vk.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &swapchain_details.capabilities);

    var format_count: u32 = 0;
    _ = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, null);

    if (format_count != 0) {
        try swapchain_details.resize_formats(@intCast(format_count));
        _ = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, swapchain_details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        try swapchain_details.resize_present_modes(@intCast(present_mode_count));
        _ = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, swapchain_details.present_modes.ptr);
    }

    return swapchain_details;
}
