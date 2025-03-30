const std = @import("std");
const c = @import("../clibs.zig");
const shader_inputs = @import("shader_inputs.zig");

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

pub fn create_shader_module(device: c.VkDevice, path: []const u8) !c.VkShaderModule {
	const file = try std.fs.cwd().createFile(path, .{ .read = true });
	defer file.close();
	
	var buf_reader = std.io.bufferedReader(file.reader());
	var in_stream = buf_reader.reader();

	const arena = std.heap.ArenaAllocator(std.heap.page_allocator);
	defer arena.deinit();

	var contents = std.ArrayList(u8).init(arena.allocator());
	var buf: [1024]u8 = undefined;
	while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    	contents.appendSlice(line);
	}

	const shader_module_info = c.VkShaderModuleCreateInfo{
		.sType = c.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
		.codeSize = contents.items.len,
		.pCode = contents.items.ptr,
	};

	var shader_module: c.VkShaderModule = undefined;
	const create_shader_module_result = c.vkCreateShaderModule(device, &shader_module_info, null, &shader_module);
	if (create_shader_module_result != c.VK_SUCCESS)
		std.debug.panic("failed to create shader module!");

	return shader_module;
}

pub fn create_pipeline(device: c.VkDevice, extent: c.VkExtent2D) !c.VkPipeline {
	
	const vertex_shader_module = create_shader_module(device, "default.vert");
	
	const vertex_shader_stage_info = c.VkPipelineShaderStageCreateInfo {
		.sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
		.stage = c.VK_SHADER_STAGE_VERTEX_BIT,
		.module = vertex_shader_module,
		.pName = "main",
	};

	const fragment_shader_module = create_shader_module(device, "default.frag");

	const fragment_shader_stage_info = c.VkPipelineShaderStageCreateInfo {
		.sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
		.stage = c.VK_SHADER_STAGE_FRAGMENT_BIT,
		.module = fragment_shader_module,
		.pName = "main",
	};

	const shader_stages = []c.VkPipelineShaderStageCreateInfo{ vertex_shader_stage_info, fragment_shader_stage_info };

	const binding_description = shader_inputs.get_binding_description();
	const attribute_descriptions = shader_inputs.get_attributes_description();
	const vertex_input_info = c.VkPipelineVertexInputStateCreateInfo {
		.sType = c.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
		.pNext = null,
		.vertexBindingDescriptionCount = 1,
		.vertexAttributeDescriptionCount = attribute_descriptions.len,
		.pVertexBindingDescriptions = &binding_description,
		.pVertexAttributeDescriptions = &attribute_descriptions
	};

	const input_assembly = c.VkPipelineInputAssemblyStateCreateInfo {
		.sType = c.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
		.topology = c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
		.primitiveRestartEnable = c.VK_FALSE,
	};

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
		.stageCount = 2,
		.pStages = shader_stages.ptr,
		.pVertexInputState = &vertex_input_info,
		.pInputAssemblyState = &input_assembly,
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

pub fn create_buffer(device: c.VkDevice, size: c.VkDeviceSize, usage: c.VkBufferUsageFlagBits) !c.VkBuffer {
	const buffer_info = c.VkBufferCreateInfo{
		.sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = size,
		.usage = usage,
		.sharingMode = c.VK_SHARING_MODE_EXCLUSIVE,
	};

	var buffer: c.VkBuffer = undefined;
	const result = c.vkCreateBuffer(device, &buffer_info, null, &buffer);
	if (result != c.VK_SUCCESS)
		return std.debug.panic("failed to create buffer !", .{});
	
	return buffer;
}

pub fn allocate_buffer(device: c.VkDevice, physical_device: c.VkPhysicalDevice, buffer: c.VkBuffer, properties: c.VkMemoryAllocateFlags) !c.VkDeviceMemory {
	var mem_requirements: c.VkMemoryRequirements = undefined;
	c.vkGetBufferMemoryRequirements(device, buffer, &mem_requirements);

	const alloc_info = c.VkMemoryAllocateInfo{
		.sType = c.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
		.allocationSize = mem_requirements.size,
		.memoryTypeIndex = try find_memory_type(physical_device, mem_requirements.memoryTypeBits, properties),
	};
	

	var buffer_memory: c.VkDeviceMemory = undefined;
	if (c.vkAllocateMemory(device, &alloc_info, null, &buffer_memory) != c.VK_SUCCESS)
		return std.debug.panic("Failed to allocate buffer memory !", .{});

	if (c.vkBindBufferMemory(device, buffer, buffer_memory, 0) != c.VK_SUCCESS)
		return std.debug.panic("Failed to bind buffer !", .{});

	return buffer_memory;
}
