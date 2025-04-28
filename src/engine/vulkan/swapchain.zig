const std = @import("std");
const c = @import("../../clibs.zig");
const queue = @import("queue_family.zig");
const log = @import("../../utils/log.zig");

const SWError = error{
    SwapchainCreationFailed,
    GetCapabilitiesFailed,
    NoFormat,
    NoPresentMode,
};

// swapchain data
pub const swapchain_t = struct {
    _sw: c.VkSwapchainKHR = undefined,
    _extent: c.VkExtent2D = undefined,
    _image_format: c.VkSurfaceFormatKHR = undefined,

    _images: []c.VkImage = undefined,
    _image_views: []c.VkImageView = undefined,

    pub fn init(alloc: std.mem.Allocator, device: c.VkDevice, gpu: c.VkPhysicalDevice, surface: c.VkSurfaceKHR, window_extent: c.VkExtent2D, queue_indices: queue.indices_t) !swapchain_t {
        const details = try query_swapchain_support(gpu, surface);
        defer details.deinit();

        // create swapchain
        var sw: swapchain_t = swapchain_t{};
        sw._image_format = try select_surface_format(details);
        sw._extent = try select_extent(details.capabilities, window_extent);
        sw._sw = try sw.create_swapchain(device, surface, details, queue_indices);

        // create swapchain images
        var image_count: u32 = 0;
        const result = c.vkGetSwapchainImagesKHR(device, sw._sw, &image_count, null);
        if (result != c.VK_SUCCESS) {
            log.write("Failed to retrive swapchain image count ! reason {d}", .{result});
            std.debug.panic("Failed to retrive swapchain image count !", .{});
        }
    
        sw._images = try create_images(alloc, device, sw._sw, &image_count);
        sw._image_views = try create_image_views(device, sw._images, sw._image_format.format);

        return sw;
    }

    pub fn deinit(self: *swapchain_t, device: c.VkDevice) void {
        c.vkDestroySwapchainKHR(device, self._sw, null);

         // destroy sw images
        for (self._image_views) |image_view| {
            c.vkDestroyImageView(device, image_view, null);
        }
    }

    fn create_swapchain(self: *const swapchain_t, device: c.VkDevice, surface: c.VkSurfaceKHR, details: details_t, queue_indices: queue.indices_t) SWError!c.VkSwapchainKHR {
        const present_mode = select_present_mode(details);
    
        var image_count: u32 = details.capabilities.minImageCount + 1;
        if (details.capabilities.maxImageCount > 0 and image_count > details.capabilities.maxImageCount) {
            image_count = details.capabilities.maxImageCount;
        }

        var swapchain_info = c.VkSwapchainCreateInfoKHR {
            .sType = c.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
            .surface = surface,
            .minImageCount = image_count,
            .imageFormat = self._image_format.format,
            .imageColorSpace = self._image_format.colorSpace,
            .imageExtent = self._extent,
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

        if (queue_indices.graphics != queue_indices.present) {
            const pqueue_family_indices: []const u32 = &.{ 
                queue_indices.graphics,
                queue_indices.present
            };

            swapchain_info.imageSharingMode = c.VK_SHARING_MODE_CONCURRENT;
            swapchain_info.queueFamilyIndexCount = 2;
            swapchain_info.pQueueFamilyIndices = pqueue_family_indices.ptr;
        }

        var swapchain: c.VkSwapchainKHR = undefined;
        const result = c.vkCreateSwapchainKHR(device, &swapchain_info, null, &swapchain);
        if (result != c.VK_SUCCESS) {
            return SWError.SwapchainCreationFailed;
        }

        return swapchain;
    }
};

pub const details_t = struct {
    capabilities: c.VkSurfaceCapabilitiesKHR = undefined,
    formats: []c.VkSurfaceFormatKHR = undefined,
    present_modes: []c.VkPresentModeKHR = undefined,
    arena: std.heap.ArenaAllocator = undefined,

    pub fn init() details_t {
        const details = details_t {
            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        };

        return details;
    }

    pub fn resize_formats(self: *details_t, size: usize) void {
        const allocator = self.arena.allocator();
        self.formats = allocator.alloc(c.VkSurfaceFormatKHR, size) catch {
            log.err("VkSurfaceFormatKHR : Out of memory", .{});
            @panic("Out of memory");
        };
    }

    pub fn resize_present_modes(self: *details_t, size: usize) void {
        const allocator = self.arena.allocator();
        self.present_modes = allocator.alloc(c.VkPresentModeKHR, size) catch {
            log.err("VkPresentModeKHR : Out of memory", .{});
            @panic("Out of memory");
        };
    }

    pub fn deinit(self: *const details_t) void {
        self.arena.deinit();
    }
};

fn select_surface_format(details: details_t) !c.VkSurfaceFormatKHR {
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

fn select_extent(capabilities: c.VkSurfaceCapabilitiesKHR, current_extent: c.VkExtent2D) !c.VkExtent2D {
    if (capabilities.currentExtent.width != std.math.maxInt(u32)) {
        return capabilities.currentExtent;
    }

    const actual_extent = c.VkExtent2D{
        .width = std.math.clamp(current_extent.width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width),
        .height = std.math.clamp(current_extent.height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
    };

    return actual_extent;
}

pub fn query_swapchain_support(gpu: c.VkPhysicalDevice, surface: c.VkSurfaceKHR) SWError!details_t {
    var details: details_t = details_t.init();

    var result = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(gpu, surface, &details.capabilities);
    if (result != c.VK_SUCCESS) {
        return SWError.GetCapabilitiesFailed;
    }

    var format_count: u32 = 0;
    result = c.vkGetPhysicalDeviceSurfaceFormatsKHR(gpu, surface, &format_count, null);
    if (result != c.VK_SUCCESS) {
        return SWError.NoFormat;
    }

    if (format_count != 0) {
        details.resize_formats(format_count);
        result = c.vkGetPhysicalDeviceSurfaceFormatsKHR(gpu, surface, &format_count, details.formats.ptr);
        if (result != c.VK_SUCCESS) {
            return SWError.NoFormat;
        }
    }

    var present_mode_count: u32 = 0;
    result = c.vkGetPhysicalDeviceSurfacePresentModesKHR(gpu, surface, &present_mode_count, null);
    if (result != c.VK_SUCCESS) {
        return SWError.NoPresentMode;
    }

    if (present_mode_count != 0) {
        details.resize_present_modes(present_mode_count);
        result = c.vkGetPhysicalDeviceSurfacePresentModesKHR(gpu, surface, &present_mode_count, details.present_modes.ptr);
        if (result != c.VK_SUCCESS) {
            return SWError.NoPresentMode;
        }
    }

    return details;
}

pub fn create_images(allocator: std.mem.Allocator, device: c.VkDevice, swapchain: c.VkSwapchainKHR, image_count: *u32) ![]c.VkImage {
    const images = try allocator.alloc(c.VkImage, image_count.*);
    const result = c.vkGetSwapchainImagesKHR(device, swapchain, image_count, images.ptr);
    if (result != c.VK_SUCCESS) {
        allocator.free(images);
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
