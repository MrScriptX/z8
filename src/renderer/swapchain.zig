const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const types = @import("types.zig");
const app_t = types.app_t;
const swapchain_t = types.swapchain_t;


const swapchain_details_t = struct {
    capabilities: c.VkSurfaceCapabilitiesKHR,
    formats: []c.VkSurfaceFormatKHR,
    present_modes: []c.VkPresentModeKHR,
    arena: std.heap.ArenaAllocator,

    pub fn init(self: *swapchain_details_t) void {
        self.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    }

    pub fn init_formats(self: *swapchain_details_t, size: u32) !void {
        const allocator = self.arena.allocator();
        self.formats = try allocator.alloc(c.VkSurfaceFormatKHR, size);
    }

    pub fn init_present_modes(self: *swapchain_details_t, size: u32) !void {
        const allocator = self.arena.allocator();
        self.present_modes = try allocator.alloc(c.VkPresentModeKHR, size);
    }

    pub fn deinit(self: *const swapchain_details_t) void {
        self.arena.deinit();
    }
};

pub fn create_swapchain(app: app_t, window_extent: c.VkExtent2D) !swapchain_t {
    const details = try query_swapchain_support(app);
    defer details.deinit();

    const present_mode = select_present_mode(details);
    const surface_format = select_surface_format(details);
    const extent = select_extent(details.capabilities, window_extent);


    var image_count: u32 = details.capabilities.minImageCount + 1;
    if (details.capabilities.maxImageCount > 0 and image_count > details.capabilities.maxImageCount)
    {
        image_count = details.capabilities.maxImageCount;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var image_sharing_mode = c.VK_SHARING_MODE_EXCLUSIVE;
    var queue_family_index_count: u32 = 0;
    var pqueue_family_indices: ?[]u32 = null;
    if (app.queues.queue_family_indices.graphics_family != app.queues.queue_family_indices.present_family)
    {
        image_sharing_mode = c.VK_SHARING_MODE_CONCURRENT;
        queue_family_index_count = 2;
        pqueue_family_indices = try allocator.alloc(u32, 2);
        const unwrapped_indices = pqueue_family_indices orelse unreachable;
        unwrapped_indices[0] = app.queues.queue_family_indices.graphics_family;
        unwrapped_indices[1] = app.queues.queue_family_indices.present_family;
    }

    const swapchain_info = c.VkSwapchainCreateInfoKHR {
        .sType = c.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = app.surface,
        .minImageCount = image_count,
        .imageFormat = surface_format.format,
        .imageColorSpace = surface_format.colorSpace,
        .imageExtent = extent,
        .imageArrayLayers = 1,
        .imageUsage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .queueFamilyIndexCount = queue_family_index_count,
        .pQueueFamilyIndices = pqueue_family_indices.?.ptr,
        .preTransform = details.capabilities.currentTransform,
        .compositeAlpha = c.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = present_mode,
        .clipped = c.VK_TRUE,
        .oldSwapchain = @ptrCast(c.VK_NULL_HANDLE),
    };

    var swapchain: swapchain_t = undefined;
    swapchain.init();

    const result = c.vkCreateSwapchainKHR(app.device, &swapchain_info, null, &swapchain.handle);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to create swapchain: {}", .{result});
    }

    swapchain.format = surface_format.format;
    swapchain.extent = extent;

    return swapchain;
}

pub fn create_swapchain_images(app: app_t, swapchain: swapchain_t) ![]c.VkImage {
    var image_count: u32 = 0;
    _ = c.vkGetSwapchainImagesKHR(app.device, swapchain.handle, &image_count, null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const images = try allocator.alloc(c.VkImage, image_count);
    const result = c.vkGetSwapchainImagesKHR(app.device, swapchain.handle, &image_count, images.ptr);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to create swapchain images: {}", .{result});
    }

    return images;
}

fn query_swapchain_support(app: app_t) !swapchain_details_t {
    var details: swapchain_details_t = undefined;
    details.init();

    _ = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(app.physical_device, app.surface, &details.capabilities);

    var format_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(app.physical_device, app.surface, &format_count, null);

    if (format_count != 0) {
        try details.init_formats(format_count);
        _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(app.physical_device, app.surface, &format_count, details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(app.physical_device, app.surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        try details.init_present_modes(present_mode_count);
        _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(app.physical_device, app.surface, &present_mode_count, details.present_modes.ptr);
    }

    return details;
}

fn select_present_mode(details: swapchain_details_t) c.VkPresentModeKHR {
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

fn select_surface_format(details: swapchain_details_t) c.VkSurfaceFormatKHR {
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

fn select_extent(capabilities: c.VkSurfaceCapabilitiesKHR, current_extent: c.VkExtent2D) c.VkExtent2D {
    if (capabilities.currentExtent.width != std.math.maxInt(u32)) {
        return capabilities.currentExtent;
    }

    const actual_extent = c.VkExtent2D{
        .width = std.math.clamp(current_extent.width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width),
        .height = std.math.clamp(current_extent.height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
    };

    return actual_extent;
}
