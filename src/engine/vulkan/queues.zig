pub const SubmitQueue = struct {
    queue: c.VkQueue,
    command_buffer_pool: c.VkCommandPool,
    command_buffer: c.VkCommandBuffer,
    fence: c.VkFence,
    device: c.VkDevice,

    pub fn init(device: c.VkDevice, queue: c.VkQueue, queue_index: u32) SubmitQueue {
        var instance: SubmitQueue = .{
            .queue = queue,
            .command_buffer_pool = undefined,
            .command_buffer = undefined,
            .fence = undefined,
            .device = device
        };

        instance.command_buffer_pool = try commands.create_command_pool(device, queue_index);
        instance.command_buffer = try commands.create_command_buffer(1, device, instance.command_buffer_pool);
        instance.fence = try commands.create_fence(device);

        return instance;
    }

    pub fn deinit(self: *SubmitQueue, device: c.VkDevice) void {
        c.vkDestroyCommandPool(device, self.command_buffer_pool, null);
        c.vkDestroyFence(device, self.fence, null);
    }

    pub fn start_command(self: *SubmitQueue) void {
        var result = c.vkResetFences(self.device, 1, &self.fence);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetFences failed with error {d}", .{ result });
        }

        result = c.vkResetCommandBuffer(self.command_buffer, 0);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetCommandBuffer failed with error {d}", .{ result });
        }

        const begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        result = c.vkBeginCommandBuffer(self.command_buffer, &begin_info);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkBeginCommandBuffer failed with error {d}", .{ result });
        }
    }

    pub fn submit_command(self: *SubmitQueue) void {
        var result = c.vkEndCommandBuffer(self.command_buffer);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkEndCommandBuffer failed with error {d}", .{ result });
        }

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
            .pNext = null,
            .commandBuffer = self.command_buffer,
            .deviceMask = 0
        };

        const submit_info = c.VkSubmitInfo2 {
            .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO_2,
            .pNext = null,
            .flags = 0,

            .pCommandBufferInfos = &cmd_submit_info,
            .commandBufferInfoCount = 1,

            .pSignalSemaphoreInfos = null,
            .signalSemaphoreInfoCount = 0,
            
            .pWaitSemaphoreInfos = null,
            .waitSemaphoreInfoCount = 0,
        };

        result = c.vkQueueSubmit2(self.queue, 1, &submit_info, self.fence); // TODO : run it on other queue for multithreading
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkQueueSubmit2 failed with error {d}", .{ result });
        }

        result = c.vkWaitForFences(self.device, 1, &self.fence, c.VK_TRUE, 9999999999);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkWaitForFences failed with error {d}", .{ result });
        }
    }
};

const std = @import("std");
const c = @import("../../clibs.zig");
const commands = @import("command_buffers.zig");
