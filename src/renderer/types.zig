const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});

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

pub const swapchain_t = struct {
    handle: vk.VkSwapchainKHR = undefined,
    format: vk.VkFormat = undefined,
    extent: vk.VkExtent2D = undefined,
    images: swapchain_image_t = undefined,
    depth: depth_resources_t = undefined
};

pub const swapchain_image_t = struct {
    images: []vk.VkImage = undefined,
    image_views: []vk.VkImageView = undefined,
    arena: std.heap.ArenaAllocator = undefined,

    pub fn init(self: *swapchain_image_t, size: usize) !void {
        self.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        
        const allocator = self.arena.allocator();
        self.images = try allocator.alloc(vk.VkImage, size);
        self.image_views = try allocator.alloc(vk.VkImageView, size);
    }

    pub fn deinit(self: *const swapchain_image_t) void {
        self.arena.deinit();
    }
};

pub const depth_resources_t = struct {
    image: vk.VkImage = undefined,
    mem: vk.VkDeviceMemory = undefined,
    view: vk.VkImageView = undefined,
    format: vk.VkFormat = undefined,
};
