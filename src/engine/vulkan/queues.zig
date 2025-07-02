pub const SubmitQueue = struct {
    queue: c.VkQueue,
    queue_index: u32,

    command_buffer_pool: vk.CommandPool,
    available_command_buffers: std.fifo.LinearFifo(c.VkCommandBuffer, .Dynamic),

    fence: c.VkFence,
    device: c.VkDevice,

    pub fn init(allocator: std.mem.Allocator, device: c.VkDevice, queue: c.VkQueue, queue_index: u32) SubmitQueue {
        var instance: SubmitQueue = .{
            .queue = queue,
            .queue_index = queue_index,
            .command_buffer_pool = undefined,
            .available_command_buffers = std.fifo.LinearFifo(c.VkCommandBuffer, .Dynamic).init(allocator),
            .fence = undefined,
            .device = device
        };

        instance.command_buffer_pool = try commands.create_command_pool(device, queue_index);
        instance.fence = try commands.create_fence(device);

        return instance;
    }

    pub fn deinit(self: *SubmitQueue, device: c.VkDevice) void {
        c.vkDestroyCommandPool(device, self.command_buffer_pool, null);
        c.vkDestroyFence(device, self.fence, null);

        self.available_command_buffers.deinit();
    }

    pub fn expand(self: *SubmitQueue, size: usize) !void {
        for (0..size) |_| {
            const cmd = try commands.create_command_buffer(1, self.device, self.command_buffer_pool);
            try self.available_command_buffers.writeItem(cmd);
        }
    }

    /// Get the next available VkCommandBuffer for recording
    /// Caller is responsible for destroying the Vk objects until submit
    pub fn next_command_buffer(self: *SubmitQueue) !c.VkCommandBuffer {
        if (self.available_command_buffers.readItem()) |cmd| {
            return cmd;
        }
        else {
            const cmd = try commands.create_command_buffer(1, self.device, self.command_buffer_pool);
            return cmd;
        }
    }

    pub fn start_command(_: *SubmitQueue, cmd: c.VkCommandBuffer) void {
        vk.resetCommandBuffer(cmd, 0) catch |err| {
            std.log.warn("vkResetCommandBuffer failed with error {any}", .{ err });
        };

        const begin_info = vk.CommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        vk.beginCommandBuffer(cmd, &begin_info) catch |err| {
            std.log.warn("vkBeginCommandBuffer failed with error {any}", .{ err });
        };
    }

    pub fn end_command(_: *SubmitQueue, cmd: c.VkCommandBuffer) void {
        const result = c.vkEndCommandBuffer(cmd);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkEndCommandBuffer failed with error {d}", .{ result });
        }
    }

    pub fn submit_command(self: *SubmitQueue, cmd: c.VkCommandBuffer) void {
        var result = c.vkResetFences(self.device, 1, &self.fence);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetFences failed with error {d}", .{ result });
        }

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
            .pNext = null,
            .commandBuffer = cmd,
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

        result = c.vkQueueSubmit2(self.queue, 1, &submit_info, self.fence);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkQueueSubmit2 failed with error {d}", .{ result });
        }

        result = c.vkWaitForFences(self.device, 1, &self.fence, c.VK_TRUE, 9999999999);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkWaitForFences failed with error {d}", .{ result });
        }

        self.available_command_buffers.writeItem(cmd) catch {
            std.log.warn("Failed to set command buffer back to available queue.", .{});
            c.vkFreeCommandBuffers(self.device, self.command_buffer_pool, 1, &cmd);
        };
    }
};

const std = @import("std");
const vk = @import("wrapper.zig");
const c = @import("../../clibs.zig");
const commands = @import("command_buffers.zig");
