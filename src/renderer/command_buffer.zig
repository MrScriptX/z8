const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

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

pub fn create_command_buffer(count: u32, device: c.VkDevice, command_pool: c.VkCommandPool) ![]c.VkCommandBuffer {
    const command_buffer_info = c.VkCommandBufferAllocateInfo {
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = command_pool,
        .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = count,
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const command_buffers = try allocator.alloc(c.VkCommandBuffer, count);
    const result = c.vkAllocateCommandBuffers(device, &command_buffer_info, command_buffers.ptr);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to allocate command buffers", .{});
    }

    return command_buffers;
}
