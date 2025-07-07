pub const FRAME_OVERLAP = 2;

pub const data_t = struct {
    _cmd_pool: c.VkCommandPool = undefined,
    _main_buffer: c.VkCommandBuffer = undefined,
    _sw_semaphore: c.VkSemaphore = undefined,
    _render_semaphore: c.VkSemaphore = undefined,
	_render_fence: c.VkFence = undefined,

    _frame_descriptors: descriptors.DescriptorAllocator2 = undefined,

    _buffers: std.ArrayList(buffers.AllocatedBuffer) = undefined,

    pub fn init(self: *data_t, allocator: std.mem.Allocator, device: c.VkDevice, queue_family_index: u32) !void {
        self._cmd_pool = try commands.create_command_pool(device, queue_family_index);
        self._main_buffer = try commands.create_command_buffer(1, device, self._cmd_pool);
        self._sw_semaphore = try commands.create_semaphore(device);
        self._render_semaphore = try commands.create_semaphore(device);
        self._render_fence = try commands.create_fence(device);
        self._buffers = std.ArrayList(buffers.AllocatedBuffer).init(allocator);
    }

    pub fn deinit(self: *data_t, device: c.VkDevice, vma: c.VmaAllocator) void {
        c.vkDestroyCommandPool(device, self._cmd_pool, null);

        c.vkDestroySemaphore(device, self._render_semaphore, null);
        c.vkDestroyFence(device, self._render_fence, null);

        self.flush(vma);
        self._buffers.deinit();
    }

    pub fn flush(self: *data_t, vma: c.VmaAllocator) void {
        for (self._buffers.items) |*buffer| {
            buffer.deinit(vma);
        }

        self._buffers.clearRetainingCapacity();
    }
};

const std = @import("std");
const c = @import("../clibs.zig");
const commands = @import("vulkan/command_buffers.zig");
const descriptors = @import("descriptor.zig"); 
const buffers = @import("graphics/buffers.zig");
