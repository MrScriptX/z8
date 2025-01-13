const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const vkimage = @import("vkimage.zig");
const types = @import("types.zig");
const app_t = types.app_t;
const swapchain_t = types.swapchain_t;
const depth_resources_t = types.depth_resources_t;

pub fn create_depth_ressources(app: app_t, swapchain: swapchain_t) !depth_resources_t {
    const extent = c.VkExtent3D{
        .depth = 1,
        .height = swapchain.extent.height,
        .width = swapchain.extent.width
    };

    const candidates = [_]c.VkFormat {
        c.VK_FORMAT_D32_SFLOAT,
        c.VK_FORMAT_D32_SFLOAT_S8_UINT,
        c.VK_FORMAT_D24_UNORM_S8_UINT
    };
    const format = try find_supported_format(app.physical_device, &candidates, c.VK_IMAGE_TILING_OPTIMAL, c.VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT);

    const image = try vkimage.create_image(app.device, extent, format, c.VK_IMAGE_TILING_OPTIMAL, c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
    const image_mem = try vkimage.create_image_memory(app.device, app.physical_device, image, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    const image_view = try vkimage.create_image_view(app.device, image, format, c.VK_IMAGE_ASPECT_DEPTH_BIT);

    const depth_resources = depth_resources_t{
        .image = image,
        .mem = image_mem,
        .view = image_view,
    };
    return depth_resources;
}

fn find_supported_format(device: c.VkPhysicalDevice, candidates: []const c.VkFormat, tiling: c.VkImageTiling, flags: c.VkFormatFeatureFlags) !c.VkFormat {
    for (candidates) |format| {
        var properties: c.VkFormatProperties = undefined;
        c.vkGetPhysicalDeviceFormatProperties(device, format, &properties);
        if (tiling == c.VK_IMAGE_TILING_LINEAR and (properties.linearTilingFeatures & flags) == flags) {
            return format;
        }
        else if (tiling == c.VK_IMAGE_TILING_OPTIMAL and (properties.optimalTilingFeatures & flags) == flags) {
			return format;
		}
    }

    std.debug.panic("No supported format !", .{});
}
