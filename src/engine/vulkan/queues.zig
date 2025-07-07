pub fn find_queues(allocator: std.mem.Allocator, physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) Indices {
    var queue_family_count: u32 = 0;
    vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);

    std.log.debug("{d} queue family found", .{queue_family_count});

    const queue_families = allocator.alloc(vk.QueueFamilyProperties, queue_family_count) catch {
        std.log.err("Failed to allocate Queue Familes array", .{});
        @panic("Out of memory");
    };
    defer allocator.free(queue_families);

    vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families);

    var compute_family: ?usize = null;
    var graphics_family: ?usize = null;
    for (queue_families, 0..) |family, index| {
        // find graphics queue
        if (graphics_family == null) {
            if (family.queueCount > 0 and family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT != 0) {
                var present_support: c.VkBool32 = c.VK_FALSE;
                vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, index, surface, &present_support) catch |err| {
                    std.log.warn("No present support found ! Reason {err}", .{ err });
                    continue;
                };

                if (family.queueCount > 0 and present_support == c.VK_TRUE) {
                    graphics_family = index;
                    continue;
                }
            }
        }

        // find compute family
        if (compute_family == null) {
            if (family.queueCount > 0 and family.queueFlags & c.VK_QUEUE_COMPUTE_BIT != 0) {
                compute_family = index;
            }
        }

        if (graphics_family != null and compute_family != null) {
            break;
        }
    }

    return .{
        .graphic = if (graphics_family) |family| family else 0,
        .compute = if (compute_family) |family| family else 0,
    };
}

pub const Indices = struct {
    graphic: u32 = 0,
    compute: u32 = 0
};

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

    pub fn deinit(self: *SubmitQueue, device: vk.Device) void {
        vk.DestroyCommandPool(device, self.command_buffer_pool, null);
        vk.DestroyFence(device, self.fence, null);

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
    pub fn next_command_buffer(self: *SubmitQueue) !vk.CommandBuffer {
        if (self.available_command_buffers.readItem()) |cmd| {
            return cmd;
        }
        else {
            const cmd = try commands.create_command_buffer(1, self.device, self.command_buffer_pool);
            return cmd;
        }
    }

    pub fn start_command(_: *SubmitQueue, cmd: vk.CommandBuffer) void {
        vk.ResetCommandBuffer(cmd, 0) catch |err| {
            std.log.warn("vkResetCommandBuffer failed with error {any}", .{ err });
        };

        const begin_info = vk.CommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        vk.BeginCommandBuffer(cmd, &begin_info) catch |err| {
            std.log.warn("vkBeginCommandBuffer failed with error {any}", .{ err });
        };
    }

    pub fn end_command(_: *SubmitQueue, cmd: vk.CommandBuffer) void {
        vk.EndCommandBuffer(cmd) catch |err| {
            std.log.warn("vkEndCommandBuffer failed with error {any}", .{ err });
        };
    }

    pub fn submit_command(self: *SubmitQueue, cmd: vk.CommandBuffer) void {
        vk.ResetFences(self.device, 1, &self.fence) catch |err| {
            std.log.warn("vkResetFences failed with error {any}", .{ err });
        };

        const cmd_submit_info = vk.CommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
            .pNext = null,
            .commandBuffer = cmd,
            .deviceMask = 0
        };

        const submit_info = vk.SubmitInfo2 {
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

        vk.QueueSubmit2(self.queue, 1, &submit_info, self.fence) catch |err| {
            std.log.warn("vkQueueSubmit2 failed with error {any}", .{ err });
        };

        vk.WaitForFences(self.device, 1, &self.fence, c.VK_TRUE, 9999999999) catch |err| {
            std.log.warn("vkWaitForFences failed with error {any}", .{ err });
        };

        self.available_command_buffers.writeItem(cmd) catch {
            std.log.warn("Failed to set command buffer back to available queue.", .{});
            vk.FreeCommandBuffers(self.device, self.command_buffer_pool, 1, &cmd);
        };
    }
};

const std = @import("std");
const vk = @import("vk_wrapper.zig");
const c = @import("../../clibs.zig");
const commands = @import("command_buffers.zig");
