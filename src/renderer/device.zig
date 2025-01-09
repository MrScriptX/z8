const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const app_t = @import("../interface.zig").app_t;
const queue_family_indices_t = @import("../interface.zig").queue_family_indices_t;
const swapchain_details_t = @import("../interface.zig").swapchain_details_t;
const queues_t = @import("../interface.zig").queues_t;
const opt = @import("../options.zig");

pub fn select_physical_device(app: app_t) !vk.VkPhysicalDevice {
    var device_count: u32 = 0;
    _ = vk.vkEnumeratePhysicalDevices(app.instance, &device_count, null);

    if (device_count == 0) {
        return std.debug.panic("No Vulkan devices found", .{});
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const devices = try allocator.alloc(vk.VkPhysicalDevice, device_count);
    const result = vk.vkEnumeratePhysicalDevices(app.instance, &device_count, devices.ptr);
    if (result != vk.VK_SUCCESS) {
        return std.debug.panic("Unable to enumerate Vulkan devices: {}", .{result});
    }

    var physical_device: ?vk.VkPhysicalDevice = null;
    for (devices) |device| {
        if (try check_device(app, device)) {
            physical_device = device;
            break;
        }
    }

    if (physical_device == null) {
        return std.debug.panic("No suitable Vulkan device found", .{});
    }

    return physical_device.?;
}

pub fn print_device_info(device: vk.VkPhysicalDevice) void {
    var device_properties: vk.VkPhysicalDeviceProperties = undefined;
    vk.vkGetPhysicalDeviceProperties(device, &device_properties);

    const device_name = device_properties.deviceName;
    const device_type = device_properties.deviceType;
    const device_api_version = device_properties.apiVersion;

    const device_info = "Device: {s}\nType: {}\nAPI Version: {}\n";
    std.debug.print(device_info, .{ device_name, device_type, device_api_version });
}

pub fn create_device_interface(app: app_t) !vk.VkDevice {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var queue_priority: f32 = 1.0;

    const queue_create_infos = try allocator.alloc(vk.VkDeviceQueueCreateInfo, 2);
    queue_create_infos[0] = vk.VkDeviceQueueCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = app.queues.queue_family_indices.graphics_family,
        .queueCount = 1,
        .pQueuePriorities = &queue_priority,
    };

    queue_create_infos[1] = vk.VkDeviceQueueCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = app.queues.queue_family_indices.present_family,
        .queueCount = 1,
        .pQueuePriorities = &queue_priority,
    };

    // create device info
    const device_features = vk.VkPhysicalDeviceFeatures{
        .samplerAnisotropy = vk.VK_TRUE,
        .fillModeNonSolid = vk.VK_TRUE,
    };

    const device_create_info = vk.VkDeviceCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = 2,
        .pQueueCreateInfos = queue_create_infos.ptr,
        .enabledExtensionCount = 1,
        .ppEnabledExtensionNames = @ptrCast(&opt.extensions),
        .pEnabledFeatures = &device_features,
    };

    var device: vk.VkDevice = undefined;
    const result = vk.vkCreateDevice(app.physical_device, &device_create_info, null, &device);
    if (result != vk.VK_SUCCESS) {
        return std.debug.panic("Unable to create Vulkan device: {}", .{result});
    }

    return device;
}

pub fn get_device_queue(app: app_t) !queues_t {
    var queues = queues_t{ .queue_family_indices = app.queues.queue_family_indices };

    vk.vkGetDeviceQueue(app.device, queues.queue_family_indices.graphics_family, 0, &queues.graphics_queue);
    vk.vkGetDeviceQueue(app.device, queues.queue_family_indices.present_family, 0, &queues.present_queue);

    return queues;
}

fn check_device(app: app_t, device: vk.VkPhysicalDevice) !bool {
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

    const queue_family_indices = try find_queue_family(app.surface, device);
    const extensions_supported = try check_device_extensions_support(device);
    if (!extensions_supported) {
        std.debug.print("Unsupported extensions\n", .{});
        return false;
    }

    var swapchain_supported: bool = false;
    if (extensions_supported) {
        const swapchain_details = try query_swapchain_support(device, app);
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

pub fn find_queue_family(surface: vk.VkSurfaceKHR, physical_device: vk.VkPhysicalDevice) !queue_family_indices_t {
    var queue_family_count: u32 = 0;
    vk.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const queue_families = try allocator.alloc(vk.VkQueueFamilyProperties, queue_family_count);
    vk.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families.ptr);

    var graphics_family: usize = undefined;
    var present_family: usize = undefined;
    for (queue_families, 0..) |family, index| {
        if (family.queueCount > 0 and family.queueFlags & vk.VK_QUEUE_GRAPHICS_BIT != 0) {
            graphics_family = index;
        }

        var present_support: vk.VkBool32 = vk.VK_FALSE;
        _ = vk.vkGetPhysicalDeviceSurfaceSupportKHR(physical_device, @intCast(index), surface, &present_support);

        if (family.queueCount > 0 and present_support == vk.VK_TRUE) {
            present_family = index;
        }

        if (graphics_family != undefined and present_family != undefined) {
            break;
        }
    }

    const family_indices = queue_family_indices_t{
        .graphics_family = @intCast(graphics_family),
        .present_family = @intCast(present_family),
    };

    return family_indices;
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

fn query_swapchain_support(device: vk.VkPhysicalDevice, app: app_t) !swapchain_details_t {
    var swapchain_details = swapchain_details_t{};
    swapchain_details.init();

    _ = vk.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, app.surface, &swapchain_details.capabilities);

    var format_count: u32 = 0;
    _ = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(device, app.surface, &format_count, null);

    if (format_count != 0) {
        try swapchain_details.resize_formats(@intCast(format_count));
        _ = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(device, app.surface, &format_count, swapchain_details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(device, app.surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        try swapchain_details.resize_present_modes(@intCast(present_mode_count));
        _ = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(device, app.surface, &present_mode_count, swapchain_details.present_modes.ptr);
    }

    return swapchain_details;
}
