const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const app_t = @import("app.zig").app_t;

pub const swapchain_details_t = struct {
    capabilities: c.VkSurfaceCapabilitiesKHR = undefined,
    formats: []c.VkSurfaceFormatKHR = undefined,
    present_modes: []c.VkPresentModeKHR = undefined,
    arena: std.heap.ArenaAllocator = undefined,

    pub fn init(self: *swapchain_details_t) void {
        self.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    }

    pub fn resize_formats(self: *swapchain_details_t, size: usize) !void {
        const allocator = self.arena.allocator();
        self.formats = try allocator.alloc(c.VkSurfaceFormatKHR, size);
    }

    pub fn resize_present_modes(self: *swapchain_details_t, size: usize) !void {
        const allocator = self.arena.allocator();
        self.present_modes = try allocator.alloc(c.VkPresentModeKHR, size);
    }

    pub fn deinit(self: *const swapchain_details_t) void {
        self.arena.deinit();
    }
};

pub const swapchain_t = struct {
    handle: c.VkSwapchainKHR = undefined,
    format: c.VkFormat = undefined,
    extent: c.VkExtent2D = undefined,
    images: swapchain_image_t = undefined,
    depth: depth_resources_t = undefined
};

pub const swapchain_image_t = struct {
    images: []c.VkImage = undefined,
    image_views: []c.VkImageView = undefined,
    arena: std.heap.ArenaAllocator = undefined,

    pub fn init(self: *swapchain_image_t, size: usize) !void {
        self.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        
        const allocator = self.arena.allocator();
        self.images = try allocator.alloc(c.VkImage, size);
        self.image_views = try allocator.alloc(c.VkImageView, size);
    }

    pub fn deinit(self: *const swapchain_image_t) void {
        self.arena.deinit();
    }
};

pub const depth_resources_t = struct {
    image: c.VkImage = undefined,
    mem: c.VkDeviceMemory = undefined,
    view: c.VkImageView = undefined,
    format: c.VkFormat = undefined,
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

    var swapchain_info = c.VkSwapchainCreateInfoKHR {
        .sType = c.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = app.surface,
        .minImageCount = image_count,
        .imageFormat = surface_format.format,
        .imageColorSpace = surface_format.colorSpace,
        .imageExtent = extent,
        .imageArrayLayers = 1,
        .imageUsage = c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
        .queueFamilyIndexCount = 0,
        .pQueueFamilyIndices = null,
        .preTransform = details.capabilities.currentTransform,
        .compositeAlpha = c.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = present_mode,
        .clipped = c.VK_TRUE,
        .oldSwapchain = @ptrCast(c.VK_NULL_HANDLE),
    };

    if (app.queue_indices.graphics_family != app.queue_indices.present_family) {
        const pqueue_family_indices: []const u32 = &.{ 
            app.queue_indices.graphics_family,
            app.queue_indices.present_family
        };

        swapchain_info.imageSharingMode = c.VK_SHARING_MODE_CONCURRENT;
        swapchain_info.queueFamilyIndexCount = 2;
        swapchain_info.pQueueFamilyIndices = pqueue_family_indices.ptr;
    }

    var swapchain: swapchain_t = undefined;
    const result = c.vkCreateSwapchainKHR(app.device, &swapchain_info, null, &swapchain.handle);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to create swapchain: {}", .{result});
    }

    swapchain.format = surface_format.format;
    swapchain.extent = extent;

    return swapchain;
}

pub fn create_swapchain_images(app: app_t, swapchain: swapchain_t) !swapchain_image_t {
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

    // create views
    var image_views = std.ArrayList(c.VkImageView).init(std.heap.page_allocator);
    for (images) |image| {
        const image_view_info = c.VkImageViewCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = image,
            .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
            .format = swapchain.format,
            .subresourceRange = c.VkImageSubresourceRange {
                .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
                .baseMipLevel = 0,
		        .levelCount = 1,
		        .baseArrayLayer = 0,
		        .layerCount = 1,
            },
        };

        var image_view: c.VkImageView = undefined;
        const success = c.vkCreateImageView(app.device, &image_view_info, null, &image_view);
        if (success != c.VK_SUCCESS) {
            return std.debug.panic("Failed to create swapchain image view: {}", .{success});
        }

        try image_views.append(image_view);
    }

    // build result
    var images_obj: swapchain_image_t = undefined;
    try images_obj.init(image_count);
    images_obj.images = images;
    images_obj.image_views = image_views.items;

    return images_obj;
}

fn query_swapchain_support(app: app_t) !swapchain_details_t {
    var details: swapchain_details_t = undefined;
    details.init();

    _ = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(app.physical_device, app.surface, &details.capabilities);

    var format_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(app.physical_device, app.surface, &format_count, null);

    if (format_count != 0) {
        try details.resize_formats(format_count);
        _ = c.vkGetPhysicalDeviceSurfaceFormatsKHR(app.physical_device, app.surface, &format_count, details.formats.ptr);
    }

    var present_mode_count: u32 = 0;
    _ = c.vkGetPhysicalDeviceSurfacePresentModesKHR(app.physical_device, app.surface, &present_mode_count, null);

    if (present_mode_count != 0) {
        try details.resize_present_modes(present_mode_count);
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
