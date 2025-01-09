const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub const app_t = struct {
    instance: vk.VkInstance = undefined,
    surface: vk.VkSurfaceKHR = undefined,
    physical_device: vk.VkPhysicalDevice = undefined,
    device: vk.VkDevice = undefined,
    queues: queues_t = undefined,
};

pub const queues_t = struct {
    graphics_queue: vk.VkQueue = undefined,
    present_queue: vk.VkQueue = undefined,
    queue_family_indices: queue_family_indices_t = undefined,
};

pub const queue_family_indices_t = struct {
    graphics_family: u32 = undefined,
    present_family: u32 = undefined,

    pub fn is_complete(self: *const queue_family_indices_t) bool {
        return self.graphics_family != undefined and self.present_family != undefined;
    }
};

pub const swapchain_details_t = struct {
    capabilities: vk.VkSurfaceCapabilitiesKHR = undefined,
    formats: []vk.VkSurfaceFormatKHR = undefined,
    present_modes: []vk.VkPresentModeKHR = undefined,
    arena: std.heap.ArenaAllocator = undefined,

    pub fn init(self: *swapchain_details_t) void {
        self.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    }

    pub fn resize_formats(self: *swapchain_details_t, size: usize) !void {
        const allocator = self.arena.allocator();
        self.formats = try allocator.alloc(vk.VkSurfaceFormatKHR, size);
    }

    pub fn resize_present_modes(self: *swapchain_details_t, size: usize) !void {
        const allocator = self.arena.allocator();
        self.present_modes = try allocator.alloc(vk.VkPresentModeKHR, size);
    }

    pub fn deinit(self: *const swapchain_details_t) void {
        self.arena.deinit();
    }
};
