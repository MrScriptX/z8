const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub fn print_device_info(device: c.VkPhysicalDevice) void {
    var device_properties: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(device, &device_properties);

    const device_name = device_properties.deviceName;
    const device_type = device_properties.deviceType;
    const device_api_version = device_properties.apiVersion;

    const device_info = "Device: {s}\nType: {}\nAPI Version: {}\n";
    std.debug.print(device_info, .{ device_name, device_type, device_api_version });
}
