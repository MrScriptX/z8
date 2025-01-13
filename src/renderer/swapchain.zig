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
const swapchain_image_t = types.swapchain_image_t;
const depth_resources_t = types.depth_resources_t;


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

    if (app.queues.queue_family_indices.graphics_family != app.queues.queue_family_indices.present_family) {
        const pqueue_family_indices: []const u32 = &.{ 
            app.queues.queue_family_indices.graphics_family,
            app.queues.queue_family_indices.present_family
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

pub fn create_depth_ressources(app: app_t, swapchain: swapchain_t) !depth_resources_t {
    const extent = c.VkExtent3D{
        .depth = 1,
        .height = swapchain.extent.height,
        .width = swapchain.extent.width
    };

    const candidates = [_]c.VkFormat {
        c.VK_FORMAT_D32_SFLOAT,
        c.VK_FORMAT_D32_SFLOAT_S8_UINT,
        c.VK_FORMAT_D24_UNORM_S8_UINT
    };
    const format = try find_supported_format(app.physical_device, &candidates, c.VK_IMAGE_TILING_OPTIMAL, c.VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT);

    const image = try create_image(app.device, extent, format, c.VK_IMAGE_TILING_OPTIMAL, c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
    const image_mem = try create_image_memory(app.device, app.physical_device, image, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    const image_view = try create_image_view(app.device, image, format, c.VK_IMAGE_ASPECT_DEPTH_BIT);

    const depth_resources = depth_resources_t{
        .image = image,
        .mem = image_mem,
        .view = image_view,
    };
    return depth_resources;
}

fn create_image(device: c.VkDevice, extent: c.VkExtent3D, format: c.VkFormat, tiling: c.VkImageTiling, usage: c.VkImageUsageFlags) !c.VkImage {
    const image_info = c.VkImageCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
	    .imageType = c.VK_IMAGE_TYPE_2D,
	    .extent = extent,
	    .mipLevels = 1,
	    .arrayLayers = 1,
	    .format = format,
	    .tiling = tiling,
	    .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
	    .usage = usage,
	    .sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
	    .samples = c.VK_SAMPLE_COUNT_1_BIT,
	    .flags = 0,
    };
	
	var image: c.VkImage = undefined;
	if (c.vkCreateImage(device, &image_info, null, &image) != c.VK_SUCCESS)
		return std.debug.panic("failed to create image !", .{});

	return image;
}

fn create_image_view(device: c.VkDevice, image: c.VkImage, format: c.VkFormat, flags: c.VkImageAspectFlags) !c.VkImageView {
    const view_info = c.VkImageViewCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
	    .image = image,
	    .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
	    .format = format,
	    .subresourceRange = c.VkImageSubresourceRange{
            .aspectMask = flags,
	        .baseMipLevel = 0,
	        .levelCount = 1,
	        .baseArrayLayer = 0,
	        .layerCount = 1,
        },
    };

	var image_view: c.VkImageView = undefined;
	if (c.vkCreateImageView(device, &view_info, null, &image_view) != c.VK_SUCCESS)
		return std.debug.panic("failed to create texture image view!", .{});

	return image_view;
}

fn create_image_memory(device: c.VkDevice, physical_device: c.VkPhysicalDevice, image: c.VkImage, properties: c.VkMemoryPropertyFlags) !c.VkDeviceMemory {
    var requirements: c.VkMemoryRequirements = undefined;
	c.vkGetImageMemoryRequirements(device, image, &requirements);

	const alloc_info = c.VkMemoryAllocateInfo{
        .sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
	    .allocationSize = requirements.size,
	    .memoryTypeIndex = try find_memory_type(physical_device, requirements.memoryTypeBits, properties),
    };

	var memory: c.VkDeviceMemory = undefined;
	if (c.vkAllocateMemory(device, &alloc_info, null, &memory) != c.VK_SUCCESS)
		return std.debug.panic("failed to allocate image memory !", .{});

	_ = c.vkBindImageMemory(device, image, memory, 0);

	return memory;
}

fn find_memory_type(physical_device: c.VkPhysicalDevice, type_filter: u32, properties: c.VkMemoryPropertyFlags) !u32 {
    var mem_properties: c.VkPhysicalDeviceMemoryProperties = undefined;
	c.vkGetPhysicalDeviceMemoryProperties(physical_device, &mem_properties);

	for (0..mem_properties.memoryTypeCount) |i| {
        const v: u32 = 1;
		if (type_filter & (v << @intCast(i)) > 0 and (mem_properties.memoryTypes[i].propertyFlags & properties) == properties) {
			return @intCast(i);
		}
	}

	return std.debug.panic("failed to find suitable memory type!", .{});
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

fn find_supported_format(device: c.VkPhysicalDevice, candidates: []const c.VkFormat, tiling: c.VkImageTiling, flags: c.VkFormatFeatureFlags) !c.VkFormat {
    for (candidates) |format| {
        var properties: c.VkFormatProperties = undefined;
        c.vkGetPhysicalDeviceFormatProperties(device, format, &properties);
        if (tiling == c.VK_IMAGE_TILING_LINEAR and (properties.linearTilingFeatures & flags) == flags) {
            return format;
        }
        else if (tiling == c.VK_IMAGE_TILING_OPTIMAL and (properties.optimalTilingFeatures & flags) == flags) {
			return format;
		}
    }

    std.debug.panic("No supported format !", .{});
}
