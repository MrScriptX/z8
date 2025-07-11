pub fn create_command_pool(device: c.VkDevice, queue_family_index: u32) !c.VkCommandPool {
    const command_pool_info = c.VkCommandPoolCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .queueFamilyIndex = queue_family_index,
        .flags = c.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
    };

    var command_pool: c.VkCommandPool = undefined;
    const result = c.vkCreateCommandPool(device, &command_pool_info, null, &command_pool);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to create command pool", .{});
    }

    return command_pool;
}

pub fn create_command_buffer(count: u32, device: c.VkDevice, cmd_pool: c.VkCommandPool) !c.VkCommandBuffer {
    const cmd_buffer_info = c.VkCommandBufferAllocateInfo {
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = cmd_pool,
        .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = count,
    };

    var command_buffers: c.VkCommandBuffer = undefined;
    const result = c.vkAllocateCommandBuffers(device, &cmd_buffer_info, @ptrCast(&command_buffers));
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to allocate command buffers", .{});
    }

    return command_buffers;
}

pub fn create_fence(device: c.VkDevice) !c.VkFence {
    const create_fence_info = c.VkFenceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .pNext = null,
        .flags = c.VK_FENCE_CREATE_SIGNALED_BIT,
    };

    var fence: c.VkFence = undefined;
    const result = c.vkCreateFence(device, &create_fence_info, null, &fence);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("failed to create fence", .{});
    }

    return fence;
}

pub fn create_semaphore(device: c.VkDevice) !c.VkSemaphore {
    const create_semaphore_info = c.VkSemaphoreCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
        .pNext = null,
	    .flags = 0,
    };

	var semaphore: c.VkSemaphore = undefined;
    const result = c.vkCreateSemaphore(device, &create_semaphore_info, null, &semaphore);
	if (result != c.VK_SUCCESS) {
		return std.debug.panic("failed to create semaphore !", .{});
	}

	return semaphore;
}

const std = @import("std");
const c = @import("../../clibs.zig");
