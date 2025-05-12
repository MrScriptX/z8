pub const Pipeline = struct {
    pipeline: c.VkPipeline = null,
    layout: c.VkPipelineLayout = null,
};

pub const Instance = struct {
    pipeline: *Shader,
    descriptor: c.VkDescriptorSet,
};

pub const Shader = struct {
    name: []const u8 = undefined,
    
    pipeline: c.VkPipeline = undefined,
	layout: c.VkPipelineLayout = undefined,

    pub fn init(name: []const u8) Shader {
        return .{
            .name = name,
        };
    }

    pub fn deinit(self: *Shader, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}", .{ result });
        }

        c.vkDestroyPipeline(r._device, self.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.layout, null);
    }

    pub fn build(self: *Shader, allocator: std.mem.Allocator, shader: []const u8, r: *renderer.renderer_t) !void {
        // const push_constant = c.VkPushConstantRange {
        //     .offset = 0,
        //     .size = @sizeOf(void),
        //     .stageFlags = c.VK_SHADER_STAGE_COMPUTE_BIT,
        // };
    
        const compute_layout = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
	        .pNext = null,

	        .pSetLayouts = &r._draw_image_descriptor,
	        .setLayoutCount = 1,

            // .pPushConstantRanges = &push_constant,
            // .pushConstantRangeCount = 1,
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
        defer builder.deinit();

        builder.layout = self.layout;
        builder.set_shaders(compute_shader);
        self.pipeline = builder.build_pipeline(r._device);
    }
};

const std = @import("std");
const c = @import("../../clibs.zig");
const renderer = @import("../renderer.zig");
const pipeline = @import("../pipeline.zig");
