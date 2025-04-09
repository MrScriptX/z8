const std = @import("std");
const c = @import("../clibs.zig");
const err = @import("../errors.zig");
const queue = @import("queue_family.zig");
const details_t = @import("swapchain.zig").details_t;
const opt = @import("../options.zig");

pub fn init_instance() !c.VkInstance {
    const app_info = c.VkApplicationInfo{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pNext = null,
        .pApplicationName = "vzig",
        .applicationVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .pEngineName = "z8",
        .engineVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_3,
    };

    // get required extensions
    var extension_count: u32 = 0;
    const required_extensions = c.SDL_Vulkan_GetInstanceExtensions(&extension_count);// VK_EXT_DEBUG_REPORT_EXTENSION_NAME

    var extensions = std.ArrayList([*c]const u8).init(std.heap.page_allocator);
    for (0..extension_count) |i| {
        try extensions.append(required_extensions[i]);
    }

    try extensions.append("VK_EXT_debug_utils");
    try extensions.append("VK_EXT_debug_report");

    // validation layer
    var layers = std.ArrayList([*c]const u8).init(std.heap.page_allocator);
    defer layers.deinit();

    try layers.append("VK_LAYER_KHRONOS_validation");
    try layers.append("VK_LAYER_KHRONOS_synchronization2");

    const instance_info = c.VkInstanceCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &app_info,
        .enabledLayerCount = @intCast(layers.items.len),
        .ppEnabledLayerNames = layers.items.ptr,
        .enabledExtensionCount = @intCast(extensions.items.len),
        .ppEnabledExtensionNames = extensions.items.ptr,
    };

    var instance: c.VkInstance = undefined;
    const result = c.vkCreateInstance(&instance_info, null, &instance);
    if (result != c.VK_SUCCESS) {
        err.display_error("Unable to create Vulkan instance");
    }

    return instance;
}

pub fn create_surface(window: ?*c.SDL_Window, instance: c.VkInstance) !c.VkSurfaceKHR {
    var surface: c.VkSurfaceKHR = undefined;
    const result = c.SDL_Vulkan_CreateSurface(window, @ptrCast(instance), null, @ptrCast(&surface));
    if (result == false) {
        return std.debug.panic("Unable to create Vulkan surface: {s}", .{c.SDL_GetError()});
    }

    return surface;
}

pub fn select_physical_device(instance: c.VkInstance, surface: c.VkSurfaceKHR) !c.VkPhysicalDevice {
    var device_count: u32 = 0;
    _ = c.vkEnumeratePhysicalDevices(instance, &device_count, null);

    if (device_count == 0) {
        return std.debug.panic("No Vulkan devices found", .{});
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const devices = try allocator.alloc(c.VkPhysicalDevice, device_count);
    const result = c.vkEnumeratePhysicalDevices(instance, &device_count, devices.ptr);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Unable to enumerate Vulkan devices: {}", .{result});
    }

    var physical_device: ?c.VkPhysicalDevice = null;
    for (devices) |device| {
        if (try check_device(surface, device)) {
            physical_device = device;
            break;
        }
    }

    if (physical_device == null) {
        err.display_error("No suitable Vulkan device found");
    }

    return physical_device.?;
}

pub fn create_device_interface(physical_device: c.VkPhysicalDevice, queues: queue.queue_indices_t) !c.VkDevice {
    var queue_priority: f32 = 1.0;
    
    var queue_create_infos = std.ArrayList(c.VkDeviceQueueCreateInfo).init(std.heap.page_allocator);

    const graphic_queue_create_info = c.VkDeviceQueueCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = queues.graphics_family,
        .queueCount = 1,
        .pQueuePriorities = &queue_priority,
    };

    try queue_create_infos.append(graphic_queue_create_info);

    if (queues.graphics_family != queues.present_family) {
        const present_qeueu_create_info = c.VkDeviceQueueCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueFamilyIndex = queues.present_family,
            .queueCount = 1,
            .pQueuePriorities = &queue_priority,
        };

        try queue_create_infos.append(present_qeueu_create_info);
    }

    // create device info
    const device_features = c.VkPhysicalDeviceFeatures{
        .samplerAnisotropy = c.VK_TRUE,
        .fillModeNonSolid = c.VK_TRUE,
    };

    const device_create_info = c.VkDeviceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = @intCast(queue_create_infos.items.len),
        .pQueueCreateInfos = queue_create_infos.items.ptr,
        .enabledExtensionCount = 1,
        .ppEnabledExtensionNames = @ptrCast(&opt.extensions),
        .pEnabledFeatures = &device_features,
    };

    var device: c.VkDevice = undefined;
    const result = c.vkCreateDevice(physical_device, &device_create_info, null, &device);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Unable to create Vulkan device: {}", .{result});
    }

    return device;
}

fn check_device(surface: c.VkSurfaceKHR, device: c.VkPhysicalDevice) !bool {
    var device_properties: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(device, &device_properties);

    var device_features: c.VkPhysicalDeviceFeatures = undefined;
    c.vkGetPhysicalDeviceFeatures(device, &device_features);

    if (device_properties.deviceType != c.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU and device_properties.deviceType != c.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) {
        std.debug.print("Wrong device type\n", .{});
        return false;
    }

    if (device_features.geometryShader == c.VK_FALSE) {
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

    var supportedFeatures: c.VkPhysicalDeviceFeatures = undefined;
    c.vkGetPhysicalDeviceFeatures(device, &supportedFeatures);

    if (supportedFeatures.samplerAnisotropy != c.VK_TRUE) {
        std.debug.print("No sampler anisotropy\n", .{});
        return false;
    }

    if (!queue_family_indices.is_complete()) {
        std.debug.print("Incomplete queue family indices\n", .{});
        return false;
    }

    return true;
}

fn check_device_extensions_support(device: c.VkPhysicalDevice) !bool {
    var extension_count: u32 = 0;
    _ = c.vkEnumerateDeviceExtensionProperties(device, null, &extension_count, null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const available_extensions = try allocator.alloc(c.VkExtensionProperties, extension_count);
    _ = c.vkEnumerateDeviceExtensionProperties(device, null, &extension_count, available_extensions.ptr);

    const required_extensions = [_][]const u8{
        "VK_KHR_swapchain",
        "VK_KHR_synchronization2"
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

fn query_swapchain_support(device: c.VkPhysicalDevice, surface: c.VkSurfaceKHR) !details_t {
    var swapchain_details = details_t{};
    swapchain_details.init();

    _ = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &swapchain_details.capabilities);

    var format_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, null);

    if (format_count != 0) {
        try swapchain_details.resize_formats(@intCast(format_count));
        _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, swapchain_details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        try swapchain_details.resize_present_modes(@intCast(present_mode_count));
        _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, swapchain_details.present_modes.ptr);
    }

    return swapchain_details;
}
