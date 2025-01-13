const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub fn create_fence(device: c.VkDevice) !c.VkFence {
    const create_fence_info = c.VkFenceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .flags = c.VK_FENCE_CREATE_SIGNALED_BIT,
    };

    var fence: c.VkFence = undefined;
    const result = c.vkCreateFence(device, &create_fence_info, null, &fence);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("failed to create Fence", .{});
    }

    return fence;
}

pub fn create_semaphore(device: c.VkDevice) !c.VkSemaphore {
    const create_semaphore_info = c.VkSemaphoreCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
	    .flags = 0,
    };

	var semaphore: c.VkSemaphore = undefined;
    const result = c.vkCreateSemaphore(device, &create_semaphore_info, null, &semaphore);
	if (result != c.VK_SUCCESS) {
		return std.debug.panic("failed to create semaphore !", .{});
	}

	return semaphore;
}
