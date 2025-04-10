const std = @import("std");
const c = @import("../clibs.zig");
const queue = @import("queue_family.zig");

pub const details_t = struct {
    capabilities: c.VkSurfaceCapabilitiesKHR = undefined,
    formats: []c.VkSurfaceFormatKHR = undefined,
    present_modes: []c.VkPresentModeKHR = undefined,
    arena: std.heap.ArenaAllocator = undefined,

    pub fn init(self: *details_t) void {
        self.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    }

    pub fn resize_formats(self: *details_t, size: usize) !void {
        const allocator = self.arena.allocator();
        self.formats = try allocator.alloc(c.VkSurfaceFormatKHR, size);
    }

    pub fn resize_present_modes(self: *details_t, size: usize) !void {
        const allocator = self.arena.allocator();
        self.present_modes = try allocator.alloc(c.VkPresentModeKHR, size);
    }

    pub fn deinit(self: *const details_t) void {
        self.arena.deinit();
    }
};

pub fn select_surface_format(details: details_t) !c.VkSurfaceFormatKHR {
    if (details.formats.len == 1 and details.formats[0].format == c.VK_FORMAT_UNDEFINED) {
        return c.VkSurfaceFormatKHR{
            .format = c.VK_FORMAT_B8G8R8A8_UNORM,
            .colorSpace = c.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR,
        };
    }

    for (details.formats) |format| {
        if (format.format == c.VK_FORMAT_B8G8R8A8_UNORM and format.colorSpace == c.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) {
            return format;
        }
    }

    return details.formats[0];
}

pub fn select_extent(capabilities: c.VkSurfaceCapabilitiesKHR, current_extent: c.VkExtent2D) !c.VkExtent2D {
    if (capabilities.currentExtent.width != std.math.maxInt(u32)) {
        return capabilities.currentExtent;
    }

    const actual_extent = c.VkExtent2D{
        .width = std.math.clamp(current_extent.width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width),
        .height = std.math.clamp(current_extent.height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
    };

    return actual_extent;
}

pub fn create_swapchain(device: c.VkDevice, surface: c.VkSurfaceKHR, details: details_t, surface_format: c.VkSurfaceFormatKHR,
    extent: c.VkExtent2D, queue_indices: queue.queue_indices_t) !c.VkSwapchainKHR {
    const present_mode = select_present_mode(details);
    
    var image_count: u32 = details.capabilities.minImageCount + 1;
    if (details.capabilities.maxImageCount > 0 and image_count > details.capabilities.maxImageCount) {
        image_count = details.capabilities.maxImageCount;
    }

    var swapchain_info = c.VkSwapchainCreateInfoKHR {
        .sType = c.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = surface,
        .minImageCount = image_count,
        .imageFormat = surface_format.format,
        .imageColorSpace = surface_format.colorSpace,
        .imageExtent = extent,
        .imageArrayLayers = 1,
        .imageUsage = c.VK_IMAGE_USAGE_TRANSFER_DST_BIT | c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .queueFamilyIndexCount = 0,
        .pQueueFamilyIndices = 0,
        .preTransform = details.capabilities.currentTransform,
        .compositeAlpha = c.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = present_mode,
        .clipped = c.VK_TRUE,
        .oldSwapchain = @ptrCast(c.VK_NULL_HANDLE),
    };

    if (queue_indices.graphics_family != queue_indices.present_family) {
        const pqueue_family_indices: []const u32 = &.{ 
            queue_indices.graphics_family,
            queue_indices.present_family
        };

        swapchain_info.imageSharingMode = c.VK_SHARING_MODE_CONCURRENT;
        swapchain_info.queueFamilyIndexCount = 2;
        swapchain_info.pQueueFamilyIndices = pqueue_family_indices.ptr;
    }

    var swapchain: c.VkSwapchainKHR = undefined;
    const result = c.vkCreateSwapchainKHR(device, &swapchain_info, null, &swapchain);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to create swapchain: {}", .{result});
    }

    return swapchain;
}

pub fn query_swapchain_support(gpu: c.VkPhysicalDevice, surface: c.VkSurfaceKHR) !details_t {
    var details: details_t = undefined;
    details.init();

    _ = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(gpu, surface, &details.capabilities);

    var format_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(gpu, surface, &format_count, null);

    if (format_count != 0) {
        try details.resize_formats(format_count);
        _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(gpu, surface, &format_count, details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(gpu, surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        try details.resize_present_modes(present_mode_count);
        _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(gpu, surface, &present_mode_count, details.present_modes.ptr);
    }

    return details;
}

pub fn create_images(allocator: std.mem.Allocator, device: c.VkDevice, swapchain: c.VkSwapchainKHR, image_count: *u32) ![]c.VkImage {
    const images = try allocator.alloc(c.VkImage, image_count.*);
    const result = c.vkGetSwapchainImagesKHR(device, swapchain, image_count, images.ptr);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to create swapchain images: {}", .{result});
    }

    return images;
}

pub fn create_image_views(device: c.VkDevice, images: []c.VkImage, format: c.VkFormat) ![]c.VkImageView {
    var image_views = std.ArrayList(c.VkImageView).init(std.heap.page_allocator);
    for (images) |image| {
        const image_view_info = c.VkImageViewCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = image,
            .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
            .format = format,
            .subresourceRange = c.VkImageSubresourceRange {
                .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
                .baseMipLevel = 0,
		        .levelCount = 1,
		        .baseArrayLayer = 0,
		        .layerCount = 1,
            },
        };

        var image_view: c.VkImageView = undefined;
        const success = c.vkCreateImageView(device, &image_view_info, null, &image_view);
        if (success != c.VK_SUCCESS) {
            return std.debug.panic("Failed to create swapchain image view: {}", .{success});
        }

        try image_views.append(image_view);
    }

    return image_views.items;
}

fn select_present_mode(details: details_t) c.VkPresentModeKHR {
    var best_mode: c.VkPresentModeKHR = c.VK_PRESENT_MODE_FIFO_KHR;

    for (details.present_modes) |mode| {
        if (mode == c.VK_PRESENT_MODE_MAILBOX_KHR) {
            return mode;
        }
        else if (mode == c.VK_PRESENT_MODE_IMMEDIATE_KHR) {
            best_mode = mode;
        }
    }

    return best_mode;
}
