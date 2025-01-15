const std = @import("std");
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub fn print_device_info(device: c.VkPhysicalDevice) void {
    var device_properties: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(device, &device_properties);

    const device_name = device_properties.deviceName;
    const device_type = device_properties.deviceType;
    const device_api_version = device_properties.apiVersion;

    const device_info = "Device: {s}\nType: {}\nAPI Version: {}\n";
    std.debug.print(device_info, .{ device_name, device_type, device_api_version });
}

pub fn create_image(device: c.VkDevice, extent: c.VkExtent3D, format: c.VkFormat, tiling: c.VkImageTiling, usage: c.VkImageUsageFlags) !c.VkImage {
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

pub fn create_image_view(device: c.VkDevice, image: c.VkImage, format: c.VkFormat, flags: c.VkImageAspectFlags) !c.VkImageView {
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

pub fn create_image_memory(device: c.VkDevice, physical_device: c.VkPhysicalDevice, image: c.VkImage, properties: c.VkMemoryPropertyFlags) !c.VkDeviceMemory {
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
