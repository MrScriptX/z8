const std = @import("std");
const c = @import("../../clibs.zig");
const queue = @import("queue_family.zig");
const sw = @import("swapchain.zig");
const opt = @import("../../options.zig");
const sdl = @import("sdl3");

const Error = error{
    Failed,
    VkInstance,
    VkSurface,
    EnumDevice,
    NoDevice,
    DeviceCreation,
    DeviceExtension,
};

pub fn init_instance(allocator: std.mem.Allocator) !c.VkInstance {
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
    const required_extensions = sdl.SDL_Vulkan_GetInstanceExtensions(&extension_count);// VK_EXT_DEBUG_REPORT_EXTENSION_NAME

    var extensions = std.ArrayList([*c]const u8).init(allocator);
    defer extensions.deinit();
    for (0..extension_count) |i| {
        try extensions.append(required_extensions[i]);
    }

    try extensions.append("VK_EXT_debug_utils");
    try extensions.append("VK_EXT_debug_report");

    // validation layer
    var layers = std.ArrayList([*c]const u8).init(allocator);
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
        std.log.err("Unable to create Vulkan instance ! Reason {d}", .{ result });
        return Error.VkInstance;
    }

    return instance;
}

pub fn create_surface(window: ?*sdl.SDL_Window, instance: c.VkInstance) !c.VkSurfaceKHR {
    var surface: c.VkSurfaceKHR = undefined;
    const result = sdl.SDL_Vulkan_CreateSurface(window, @ptrCast(instance), null, @ptrCast(&surface));
    if (result == false) {
        std.log.err("Unable to create Vulkan surface: {s}", .{ sdl.SDL_GetError() });
        return Error.VkSurface;
    }

    return surface;
}

pub fn select_physical_device(alloc: std.mem.Allocator, instance: c.VkInstance, surface: c.VkSurfaceKHR) !c.VkPhysicalDevice {
    var device_count: u32 = 0;
    const enum_device = c.vkEnumeratePhysicalDevices(instance, &device_count, null);
    if (enum_device != c.VK_SUCCESS) {
        std.log.err("Failed to enumerate devices. Reason {d}", .{ enum_device });
        return Error.EnumDevice;
    }

    if (device_count == 0) {
        std.log.err("No Vulkan devices found", .{});
        return Error.NoDevice;
    }

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const allocator = arena.allocator();

    const devices = try allocator.alloc(c.VkPhysicalDevice, device_count);
    const result = c.vkEnumeratePhysicalDevices(instance, &device_count, devices.ptr);
    if (result != c.VK_SUCCESS) {
        std.log.err("Unable to enumerate Vulkan devices: {d}", .{ result });
        return Error.EnumDevice;
    }

    var physical_device: ?c.VkPhysicalDevice = null;
    for (devices) |device| {
        if (try check_device(alloc, surface, device)) {
            physical_device = device;
            break;
        }
    }

    if (physical_device == null) {
        std.log.err("No suitable Vulkan device found", .{});
        return Error.NoDevice;
    }

    return physical_device.?;
}

pub fn create_device_interface(alloc: std.mem.Allocator, physical_device: c.VkPhysicalDevice, indices: queue.indices_t) !c.VkDevice {
    var queue_priority: f32 = 1.0;
    
    var queue_create_infos = std.ArrayList(c.VkDeviceQueueCreateInfo).init(alloc);
    defer queue_create_infos.deinit();

    const graphic_queue_create_info = c.VkDeviceQueueCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = indices.graphics,
        .queueCount = 1,
        .pQueuePriorities = &queue_priority,
    };

    try queue_create_infos.append(graphic_queue_create_info);

    if (indices.graphics != indices.present) {
        const present_qeueu_create_info = c.VkDeviceQueueCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueFamilyIndex = indices.present,
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

    const features_vulkan12 = c.VkPhysicalDeviceVulkan12Features {
        .sType = c.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
        .pNext = null,
        .bufferDeviceAddress = c.VK_TRUE,
        .descriptorIndexing = c.VK_TRUE,
    };

    const features_vulkan13 = c.VkPhysicalDeviceVulkan13Features {
        .sType = c.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES,
        .pNext = @constCast(@ptrCast(&features_vulkan12)),
        .synchronization2 = c.VK_TRUE,
        .dynamicRendering = c.VK_TRUE,
    };

    const device_create_info = c.VkDeviceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .pNext = @ptrCast(&features_vulkan13),
        .queueCreateInfoCount = @intCast(queue_create_infos.items.len),
        .pQueueCreateInfos = queue_create_infos.items.ptr,
        .enabledExtensionCount = 1,
        .ppEnabledExtensionNames = @ptrCast(&opt.extensions),
        .pEnabledFeatures = &device_features,
    };

    var device: c.VkDevice = undefined;
    const result = c.vkCreateDevice(physical_device, &device_create_info, null, &device);
    if (result != c.VK_SUCCESS) {
        std.log.err("Unable to create Vulkan device ! Reason {d}", .{ result });
        return Error.DeviceCreation;
    }

    return device;
}

pub fn get_device_queue(device: c.VkDevice, indices: queue.indices_t) !queue.queues_t {
    var queues: queue.queues_t = undefined;

    c.vkGetDeviceQueue(device, indices.graphics, 0, &queues.graphics);
    c.vkGetDeviceQueue(device, indices.present, 0, &queues.present);

    return queues;
}

fn check_device(alloc: std.mem.Allocator, surface: c.VkSurfaceKHR, device: c.VkPhysicalDevice) !bool {
    var device_properties: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(device, &device_properties);

    var device_features: c.VkPhysicalDeviceFeatures = undefined;
    c.vkGetPhysicalDeviceFeatures(device, &device_features);

    if (device_properties.deviceType != c.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU and device_properties.deviceType != c.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) {
        std.log.warn("Wrong device type", .{});
        return false;
    }

    if (device_features.geometryShader == c.VK_FALSE) {
        std.log.warn("No geometry shader", .{});
        return false;
    }

    if (device_features.samplerAnisotropy != c.VK_TRUE) {
        std.log.warn("No sampler anisotropy", .{});
        return false;
    }

    const queue_family_indices = try find_queue_family(alloc, surface, device);
    const extensions_supported = try check_device_extensions_support(alloc, device);
    if (!extensions_supported) {
        std.log.warn("Unsupported extensions", .{});
        return false;
    }

    var swapchain_supported: bool = false;
    if (extensions_supported) {
        const swapchain_details = try query_swapchain_support(alloc, device, surface);
        defer swapchain_details.deinit();

        swapchain_supported = swapchain_details.formats.len != 0 and swapchain_details.present_modes.len != 0;
        if (!swapchain_supported) {
            std.log.warn("Unsupported swapchain", .{});
            return false;
        }
    }

    if (!queue_family_indices.is_complete()) {
        std.log.warn("Incomplete queue family indices", .{});
        return false;
    }

    std.log.info("Device : {s}, API Version {d}", .{ device_properties.deviceName, device_properties.apiVersion });
    std.log.info("driver {d}", .{ device_properties.driverVersion });

    return true;
}

fn check_device_extensions_support(alloc: std.mem.Allocator, device: c.VkPhysicalDevice) !bool {
    var extension_count: u32 = 0;
    const count = c.vkEnumerateDeviceExtensionProperties(device, null, &extension_count, null);
    if (count != c.VK_SUCCESS) {
        std.log.err("Failed to enumerate device extensions. Reason {d}", .{ count });
        return Error.DeviceExtension;
    }

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const allocator = arena.allocator();

    const available_extensions = try allocator.alloc(c.VkExtensionProperties, extension_count);
    const result = c.vkEnumerateDeviceExtensionProperties(device, null, &extension_count, available_extensions.ptr);
    if (result != c.VK_SUCCESS) {
        std.log.err("Failed to get device extensions. Reason {d}", .{ result });
        return Error.DeviceExtension;
    }

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

fn query_swapchain_support(alloc: std.mem.Allocator, device: c.VkPhysicalDevice, surface: c.VkSurfaceKHR) !sw.details_t {
    var sw_details = sw.details_t.init(alloc);

    const capabilities = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &sw_details.capabilities);
    if (capabilities != c.VK_SUCCESS) {
        std.log.err("Failed to get surface capabilities. Reason {d}", .{ capabilities });
    }

    var format_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, null);

    if (format_count != 0) {
        sw_details.resize_formats(@intCast(format_count));
        _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, sw_details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        sw_details.resize_present_modes(@intCast(present_mode_count));
        _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, sw_details.present_modes.ptr);
    }

    return sw_details;
}

fn find_queue_family(alloc: std.mem.Allocator, surface: c.VkSurfaceKHR, physical_device: c.VkPhysicalDevice) !queue.indices_t {
    var queue_family_count: u32 = 0;
    c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const allocator = arena.allocator();

    const queue_families = try allocator.alloc(c.VkQueueFamilyProperties, queue_family_count);
    c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families.ptr);

    var graphics_family: ?usize = null;
    var present_family: ?usize = null;
    for (queue_families, 0..) |family, index| {
        if (family.queueCount > 0 and family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT != 0) {
            graphics_family = index;
        }

        var present_support: c.VkBool32 = c.VK_FALSE;
        const result = c.vkGetPhysicalDeviceSurfaceSupportKHR(physical_device, @intCast(index), surface, &present_support);
        if (result != c.VK_SUCCESS) {
            std.log.warn("No present support found ! Reason {d}", .{ result });
        }

        if (family.queueCount > 0 and present_support == c.VK_TRUE) {
            present_family = index;
        }

        if (graphics_family != null and present_family != null) {
            break;
        }
    }

    const family_indices = queue.indices_t {
        .graphics = @intCast(graphics_family.?),
        .present = @intCast(present_family.?),
    };

    return family_indices;
}
