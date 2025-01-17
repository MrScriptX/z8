const std = @import("std");
const c = @import("../clibs.zig");

pub const frame_t = struct {
    render_fence: c.VkFence = undefined,
    render_finished_sem: c.VkSemaphore = undefined,
    image_available_sem: c.VkSemaphore = undefined,
    buffer: c.VkFramebuffer = undefined,

    pub fn init(self: *frame_t, device: c.VkDevice) !void {
        self.render_fence = try create_fence(device);
        self.render_finished_sem = try create_semaphore(device);
        self.image_available_sem = try create_semaphore(device);
    }

    pub fn deinit(self: *frame_t, device: c.VkDevice) void {
        c.vkDestroySemaphore(device, self.image_available_sem, null);
        self.image_available_sem = undefined;

        c.vkDestroySemaphore(device, self.render_finished_sem, null);
        self.render_finished_sem = undefined;

        c.vkDestroyFence(device, self.render_fence, null);
        self.image_available_sem = undefined;
    }
};

fn create_fence(device: c.VkDevice) !c.VkFence {
    const create_fence_info = c.VkFenceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .flags = c.VK_FENCE_CREATE_SIGNALED_BIT,
    };

    var fence: c.VkFence = undefined;
    const result = c.vkCreateFence(device, &create_fence_info, null, &fence);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("failed to create fence", .{});
    }

    return fence;
}

fn create_semaphore(device: c.VkDevice) !c.VkSemaphore {
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
