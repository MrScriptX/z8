const std = @import("std");
const c = @import("../clibs.zig");

pub fn print_device_info(device: c.VkPhysicalDevice) void {
    var device_properties: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(device, &device_properties);

    const device_name = device_properties.deviceName;
    const device_type = device_properties.deviceType;
    const device_api_version = device_properties.apiVersion;

    const device_info = "Device: {s}\nType: {}\nAPI Version: {}\n";
    std.debug.print(device_info, .{ device_name, device_type, device_api_version });
}

pub fn transition_image(cmd: c.VkCommandBuffer, image: c.VkImage, currentLayout: c.VkImageLayout, newLayout: c.VkImageLayout) void {
	const aspect_mask: c.VkImageAspectFlags = if (newLayout == c.VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL) c.VK_IMAGE_ASPECT_DEPTH_BIT else c.VK_IMAGE_ASPECT_COLOR_BIT;

	const image_barrier = c.VkImageMemoryBarrier2 {
		.sType = c.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2,
		.srcStageMask = c.VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT,
		.srcAccessMask = c.VK_ACCESS_2_MEMORY_WRITE_BIT,
		.dstStageMask = c.VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT,
		.dstAccessMask = c.VK_ACCESS_2_MEMORY_WRITE_BIT | c.VK_ACCESS_2_MEMORY_READ_BIT,
		.oldLayout = currentLayout,
		.newLayout = newLayout,
		.image = image,
		.subresourceRange = image_subresource_range(aspect_mask),
	};

	const dep_info = c.VkDependencyInfo {
		.sType = c.VK_STRUCTURE_TYPE_DEPENDENCY_INFO,
		.pNext = null,
		.dependencyFlags = 0,
		.memoryBarrierCount = 0,
		.pMemoryBarriers = null,
		.bufferMemoryBarrierCount = 0,
		.pBufferMemoryBarriers = null,
		.imageMemoryBarrierCount = 1,
		.pImageMemoryBarriers = &image_barrier,
	};

    c.vkCmdPipelineBarrier2(cmd, &dep_info);
}

pub fn image_subresource_range(aspect_mask: c.VkImageAspectFlags) c.VkImageSubresourceRange {
    const sub_image = c.VkImageSubresourceRange {
		.aspectMask = aspect_mask,
		.baseMipLevel = 0,
		.levelCount = c.VK_REMAINING_MIP_LEVELS,
		.baseArrayLayer = 0,
		.layerCount = c.VK_REMAINING_ARRAY_LAYERS,
	};

    return sub_image;
}

pub fn semaphore_submit_info(stage_mask: c.VkPipelineStageFlags2, semaphore: c.VkSemaphore) c.VkSemaphoreSubmitInfo {
	const submit_info = c.VkSemaphoreSubmitInfo {
		.sType = c.VK_STRUCTURE_TYPE_SEMAPHORE_SUBMIT_INFO,
		.pNext = null,
		.semaphore = semaphore,
		.stageMask = stage_mask,
		.deviceIndex = 0,
		.value = 1,
	};

	return submit_info;
}
