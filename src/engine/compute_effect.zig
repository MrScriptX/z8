pub const ComputePushConstants = struct {
    data1: c.vec4 = undefined,
    data2: c.vec4 = undefined,
    data3: c.vec4 = undefined,
    data4: c.vec4 = undefined,
};

pub const ComputeEffect = struct {
    name: []const u8 = undefined,
    
    pipeline: c.VkPipeline = undefined,
	layout: c.VkPipelineLayout = undefined,

    data: ComputePushConstants = undefined,

    pub fn deinit(self: *ComputeEffect, r: *renderer.renderer_t) void {
        c.vkDestroyPipeline(r._device, self.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.layout, null);
    }

    pub fn build(self: *ComputeEffect, allocator: std.mem.Allocator, shader: []const u8, r: *renderer.renderer_t) !void {
        const push_constant = c.VkPushConstantRange {
            .offset = 0,
            .size = @sizeOf(ComputePushConstants),
            .stageFlags = c.VK_SHADER_STAGE_COMPUTE_BIT,
        };
    
        const compute_layout = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
	        .pNext = null,

	        .pSetLayouts = &r._draw_image_descriptor,
	        .setLayoutCount = 1,

            .pPushConstantRanges = &push_constant,
            .pushConstantRangeCount = 1,
        };

	    const result = c.vkCreatePipelineLayout(r._device, &compute_layout, null, &self.layout);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to create pipeline layout !", .{});
        }

        // shader module
        const compute_shader = try pipeline.load_shader_module(allocator, r._device, shader);
        defer c.vkDestroyShaderModule(r._device, compute_shader, null);

        // compute
        var builder = pipeline.compute_builder_t.init();
        builder.layout = self.layout;
        builder.set_shaders(compute_shader);
        self.pipeline = builder.build_pipeline(r._device);
    }
};

const std = @import("std");
const c = @import("../clibs.zig");
const renderer = @import("renderer.zig");
const pipeline = @import("pipeline.zig");
