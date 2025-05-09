pub const compute_builder_t = struct {
    shader_stage: c.VkPipelineShaderStageCreateInfo,
    layout: c.VkPipelineLayout,

    pub fn init() compute_builder_t {
        const builder = compute_builder_t {
            .shader_stage = undefined,
            .layout = undefined,
        };
        return builder;
    }

    pub fn deinit(_: *compute_builder_t) void {
    }

    pub fn set_shaders(self: *compute_builder_t, shader: c.VkShaderModule) void {
        self.shader_stage = create_shader_stage_info(shader, c.VK_SHADER_STAGE_COMPUTE_BIT);
    }

    pub fn build_pipeline(self: *const compute_builder_t, device: c.VkDevice) c.VkPipeline {
        const compute_pipeline_create_info = c.VkComputePipelineCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
	        .pNext = null,
	        .layout = self.layout,
	        .stage = self.shader_stage,
        };

        var pipeline: c.VkPipeline = undefined;
        const success = c.vkCreateComputePipelines(device, null, 1, &compute_pipeline_create_info, null, &pipeline);
        if (success != c.VK_SUCCESS) {
            std.log.warn("Failed to create compute pipeline !", .{});
        }

        return pipeline;
    }
};

pub const builder_t = struct {
    _shader_stages: std.ArrayList(c.VkPipelineShaderStageCreateInfo),

    _input_assembly: c.VkPipelineInputAssemblyStateCreateInfo = undefined,
    _rasterizer: c.VkPipelineRasterizationStateCreateInfo = undefined,
    _color_blend_attachment: c.VkPipelineColorBlendAttachmentState = undefined,
    _multisampling: c.VkPipelineMultisampleStateCreateInfo = undefined,
    _pipeline_layout: c.VkPipelineLayout = undefined,
    _depth_stencil: c.VkPipelineDepthStencilStateCreateInfo = undefined,
    _render_info: c.VkPipelineRenderingCreateInfo = undefined,
    _color_attachment_format: c.VkFormat = undefined,

    pub fn init(allocator: std.mem.Allocator) builder_t {
        var builder = builder_t {
            ._shader_stages = std.ArrayList(c.VkPipelineShaderStageCreateInfo).init(allocator),
        };
        builder.clear();

        return builder;
    }

    pub fn deinit(self: *builder_t) void {
        defer self._shader_stages.deinit();
    }

    pub fn clear(self: *builder_t) void {
        self._input_assembly = .{ .sType = c.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO };
        self._rasterizer = .{ .sType = c.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO };
        self._color_blend_attachment = .{};
        self._multisampling = .{ .sType = c.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO };
        // self._pipeline_layout = c.VK_NULL_HANDLE;
        self._depth_stencil = .{ .sType = c.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO };
        self._render_info = .{ .sType = c.VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO };

        self._shader_stages.clearAndFree();
    }

    pub fn build_pipeline(self: *builder_t, device: c.VkDevice) c.VkPipeline {
        const viewport_state = c.VkPipelineViewportStateCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
            .pNext = null,

            .viewportCount = 1,
            .scissorCount = 1,
        };
        
        const color_blending = c.VkPipelineColorBlendStateCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
            .pNext = null,

            .logicOpEnable = c.VK_FALSE,
            .logicOp = c.VK_LOGIC_OP_COPY,
            .attachmentCount = 1,
            .pAttachments = &self._color_blend_attachment,
        };

        const vertex_input_info = c.VkPipelineVertexInputStateCreateInfo { 
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
            .pNext = null,
            .pVertexAttributeDescriptions = null,
            .vertexAttributeDescriptionCount = 0,
            .pVertexBindingDescriptions = null,
            .vertexBindingDescriptionCount = 0,
            .flags = 0
        };

        const state = [_]c.VkDynamicState{ c.VK_DYNAMIC_STATE_VIEWPORT, c.VK_DYNAMIC_STATE_SCISSOR };

        const dynamic_info = c.VkPipelineDynamicStateCreateInfo { 
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO,
            .pDynamicStates = &state,
            .dynamicStateCount = state.len,
        };

        const pipeline_info = c.VkGraphicsPipelineCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
            .pNext = &self._render_info,

            .stageCount = @intCast(self._shader_stages.items.len),
            .pStages = self._shader_stages.items.ptr,
            .pVertexInputState = &vertex_input_info,
            .pInputAssemblyState = &self._input_assembly,
            .pViewportState = &viewport_state,
            .pRasterizationState = &self._rasterizer,
            .pMultisampleState = &self._multisampling,
            .pColorBlendState = &color_blending,
            .pDepthStencilState = &self._depth_stencil,
            .layout = self._pipeline_layout,
            .pDynamicState = &dynamic_info,
        };

        var pipeline: c.VkPipeline = undefined;
        const result = c.vkCreateGraphicsPipelines(device, null, 1, &pipeline_info, null, &pipeline);
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to create pipeline ! Reason {d}", .{ result });
            return null;
        }

        return pipeline;
    }

    pub fn set_shaders(self: *builder_t, vertex_shader: c.VkShaderModule, fragment_shader: c.VkShaderModule) !void {
        self._shader_stages.clearAndFree();

        try self._shader_stages.append(create_shader_stage_info(vertex_shader, c.VK_SHADER_STAGE_VERTEX_BIT));
        try self._shader_stages.append(create_shader_stage_info(fragment_shader, c.VK_SHADER_STAGE_FRAGMENT_BIT));
    }

    pub fn set_input_topology(self: *builder_t, topology: c.VkPrimitiveTopology) void {
        self._input_assembly.topology = topology;
        self._input_assembly.primitiveRestartEnable = c.VK_FALSE;
    }

    pub fn set_polygon_mode(self: *builder_t, mode: c.VkPolygonMode) void {
        self._rasterizer.polygonMode = mode;
        self._rasterizer.lineWidth = 1.0;
    }

    pub fn set_cull_mode(self: *builder_t, cull_mode: c.VkCullModeFlags, frontFace: c.VkFrontFace) void {
        self._rasterizer.cullMode = cull_mode;
        self._rasterizer.frontFace = frontFace;
    }

    pub fn set_multisampling_none(self: *builder_t) void {
        self._multisampling.sampleShadingEnable = c.VK_FALSE;
        
        // multisampling defaulted to no multisampling (1 sample per pixel)
        self._multisampling.rasterizationSamples = c.VK_SAMPLE_COUNT_1_BIT;
        self._multisampling.minSampleShading = 1.0;
        self._multisampling.pSampleMask = null;
        
        // no alpha to coverage either
        self._multisampling.alphaToCoverageEnable = c.VK_FALSE;
        self._multisampling.alphaToOneEnable = c.VK_FALSE;
    }

    pub fn disable_blending(self: *builder_t) void {
        // default write mask
        self._color_blend_attachment.colorWriteMask = c.VK_COLOR_COMPONENT_R_BIT | c.VK_COLOR_COMPONENT_G_BIT | c.VK_COLOR_COMPONENT_B_BIT | c.VK_COLOR_COMPONENT_A_BIT;
        // no blending
        self._color_blend_attachment.blendEnable = c.VK_FALSE;
    }

    pub fn set_color_attachment_format(self: *builder_t, format: c.VkFormat) void {
        self._color_attachment_format = format;
        // connect the format to the renderInfo  structure
        self._render_info.colorAttachmentCount = 1;
        self._render_info.pColorAttachmentFormats = &self._color_attachment_format;
    }

    pub fn set_depth_format(self: *builder_t, format: c.VkFormat) void {
        self._render_info.depthAttachmentFormat = format;
    }

    pub fn disable_depthtest(self: *builder_t) void {
        self._depth_stencil.depthTestEnable = c.VK_FALSE;
        self._depth_stencil.depthWriteEnable = c.VK_FALSE;
        self._depth_stencil.depthCompareOp = c.VK_COMPARE_OP_NEVER;
        self._depth_stencil.depthBoundsTestEnable = c.VK_FALSE;
        self._depth_stencil.stencilTestEnable = c.VK_FALSE;
        self._depth_stencil.front = std.mem.zeroes(c.VkStencilOpState);
        self._depth_stencil.back = std.mem.zeroes(c.VkStencilOpState);
        self._depth_stencil.minDepthBounds = 0.0;
        self._depth_stencil.maxDepthBounds = 1.0;
    }

    pub fn enable_depthtest(self: *builder_t, depth_write_enable: bool, op: c.VkCompareOp) void {
        self._depth_stencil.depthTestEnable = c.VK_TRUE;
        self._depth_stencil.depthWriteEnable = if (depth_write_enable) c.VK_TRUE else c.VK_FALSE;
        self._depth_stencil.depthCompareOp = op;
        self._depth_stencil.depthBoundsTestEnable = c.VK_FALSE;
        self._depth_stencil.stencilTestEnable = c.VK_FALSE;
        self._depth_stencil.front = std.mem.zeroes(c.VkStencilOpState);
        self._depth_stencil.back = std.mem.zeroes(c.VkStencilOpState);
        self._depth_stencil.minDepthBounds = 0.0;
        self._depth_stencil.maxDepthBounds = 1.0;
    }

    pub fn enable_blending_additive(self: *builder_t) void {
        self._color_blend_attachment.colorWriteMask = c.VK_COLOR_COMPONENT_R_BIT | c.VK_COLOR_COMPONENT_G_BIT | c.VK_COLOR_COMPONENT_B_BIT | c.VK_COLOR_COMPONENT_A_BIT;
        self._color_blend_attachment.blendEnable = c.VK_TRUE;
        self._color_blend_attachment.srcColorBlendFactor = c.VK_BLEND_FACTOR_SRC_ALPHA;
        self._color_blend_attachment.dstColorBlendFactor = c.VK_BLEND_FACTOR_ONE;
        self._color_blend_attachment.colorBlendOp = c.VK_BLEND_OP_ADD;
        self._color_blend_attachment.srcAlphaBlendFactor = c.VK_BLEND_FACTOR_ONE;
        self._color_blend_attachment.dstAlphaBlendFactor = c.VK_BLEND_FACTOR_ZERO;
        self._color_blend_attachment.alphaBlendOp = c.VK_BLEND_OP_ADD;
    }

    pub fn enable_blending_alphablend(self: *builder_t) void {
        self._color_blend_attachment.colorWriteMask = c.VK_COLOR_COMPONENT_R_BIT | c.VK_COLOR_COMPONENT_G_BIT | c.VK_COLOR_COMPONENT_B_BIT | c.VK_COLOR_COMPONENT_A_BIT;
        self._color_blend_attachment.blendEnable = c.VK_TRUE;
        self._color_blend_attachment.srcColorBlendFactor = c.VK_BLEND_FACTOR_SRC_ALPHA;
        self._color_blend_attachment.dstColorBlendFactor = c.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
        self._color_blend_attachment.colorBlendOp = c.VK_BLEND_OP_ADD;
        self._color_blend_attachment.srcAlphaBlendFactor = c.VK_BLEND_FACTOR_ONE;
        self._color_blend_attachment.dstAlphaBlendFactor = c.VK_BLEND_FACTOR_ZERO;
        self._color_blend_attachment.alphaBlendOp = c.VK_BLEND_OP_ADD;
    }
};

pub fn create_shader_stage_info(shader: c.VkShaderModule, stage: c.VkShaderStageFlagBits) c.VkPipelineShaderStageCreateInfo {
    const shader_stage_info = c.VkPipelineShaderStageCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
	    .stage = stage,
	    .module = shader,
	    .pName = "main",
    };

    return shader_stage_info;
}

pub fn load_shader_module(allocator: std.mem.Allocator, device: c.VkDevice, path: []const u8) !c.VkShaderModule {
    var file = std.fs.cwd().openFile(path, .{}) catch |e| {
        switch (e) {
            error.FileNotFound => {
                std.log.err("Failed to open file {s}.\nReason : File was not found.", .{ path });
            },
            error.AccessDenied => {
                std.log.err("Failed to open file {s}.\nReason : Access was denied.", .{ path });
            },
            else => {
                std.log.err("Failed to open file {s}.\nReason : Unknwon error.", .{ path });
            }
        }
        std.process.exit(1);
    };
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        std.log.err("Failed to read shader file !", .{});
        @panic("Failed to read shader file");
    }
    
    const create_info = c.VkShaderModuleCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .codeSize = buffer.len,
        .pCode = @alignCast(@ptrCast(buffer.ptr)),
    };
    
    var shader_module: c.VkShaderModule = undefined;
    const result = c.vkCreateShaderModule(device, &create_info, null, &shader_module) ;
    if (result != c.VK_SUCCESS) {
        std.log.err("Failed to create shader module ! Reason {d}", .{ result });
        @panic("Failed to create shader module");
    }

    return shader_module;
}

const std = @import("std");
const c = @import("../clibs.zig");
