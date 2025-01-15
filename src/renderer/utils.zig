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

pub fn create_command_buffer(count: u32, device: c.VkDevice, command_pool: c.VkCommandPool) ![3]c.VkCommandBuffer {
    const command_buffer_info = c.VkCommandBufferAllocateInfo {
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = command_pool,
        .level = c.VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = count,
    };

    var command_buffers: [3]c.VkCommandBuffer = undefined;
    const result = c.vkAllocateCommandBuffers(device, &command_buffer_info, @ptrCast(&command_buffers));
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("Failed to allocate command buffers", .{});
    }

    return command_buffers;
}

pub fn create_pipeline(device: c.VkDevice, extent: c.VkExtent2D) !c.VkPipeline {
    const viewport = c.VkViewport {
        .x = 0.0,
	    .y = 0.0,
	    .width = @floatFromInt(extent.width),
	    .height = @floatFromInt(extent.height),
	    .minDepth = 0.0,
	    .maxDepth = 1.0,
    };

	const scissor = c.VkRect2D {
        .offset = c.VkOffset2D{ .x = 0, .y = 0 },
	    .extent = extent,
    };
	
	const viewport_state = c.VkPipelineViewportStateCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
	    .viewportCount = 1,
	    .pViewports = &viewport,
	    .scissorCount = 1,
	    .pScissors = &scissor,
    };
    
    const rasterizer = c.VkPipelineRasterizationStateCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
	    .depthClampEnable = c.VK_FALSE,
	    .rasterizerDiscardEnable = c.VK_FALSE,
	    .polygonMode = c.VK_POLYGON_MODE_FILL,
	    .lineWidth = 1.0,
	    .cullMode = c.VK_CULL_MODE_BACK_BIT,
	    .frontFace = c.VK_FRONT_FACE_COUNTER_CLOCKWISE,
	    .depthBiasEnable = c.VK_FALSE,
    };

	const multisampling = c.VkPipelineMultisampleStateCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
	    .sampleShadingEnable = c.VK_FALSE,
	    .rasterizationSamples = c.VK_SAMPLE_COUNT_1_BIT,
    };

    const depth_stencil = c.VkPipelineDepthStencilStateCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
	    .depthTestEnable = c.VK_TRUE,
	    .depthWriteEnable = c.VK_TRUE,
	    .depthCompareOp = c.VK_COMPARE_OP_LESS,
	    .depthBoundsTestEnable = c.VK_FALSE,
	    .stencilTestEnable = c.VK_FALSE,
    };

	const color_blend_attachment = c.VkPipelineColorBlendAttachmentState {
        .colorWriteMask = c.VK_COLOR_COMPONENT_R_BIT | c.VK_COLOR_COMPONENT_G_BIT | c.VK_COLOR_COMPONENT_B_BIT | c.VK_COLOR_COMPONENT_A_BIT,
	    .blendEnable = c.VK_FALSE,
    };

	const color_blending = c.VkPipelineColorBlendStateCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
	    .logicOpEnable = c.VK_FALSE,
	    .logicOp = c.VK_LOGIC_OP_COPY,
	    .attachmentCount = 1,
	    .pAttachments = &color_blend_attachment,
	    .blendConstants = [_]f32{ 0.0, 0.0, 0.0, 0.0 },
    };
    
    const pipeline_create_info = c.VkGraphicsPipelineCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
        .pViewportState = &viewport_state,
        .pRasterizationState = &rasterizer,
        .pMultisampleState = &multisampling,
        .pDepthStencilState = &depth_stencil,
        .pColorBlendState = &color_blending,
    };

    var pipeline: c.VkPipeline = undefined;
    const result = c.vkCreateGraphicsPipelines(device, null, 1, &pipeline_create_info, null, &pipeline);
    if (result != c.VK_SUCCESS) {
        return std.debug.panic("failed to create pipeline !", .{});
    }

    return pipeline;
}
