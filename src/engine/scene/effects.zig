pub const Effect = struct {
    name: []const u8 = undefined,
    
    pipeline: c.VkPipeline = undefined,
	layout: c.VkPipelineLayout = undefined,

    data: PushConstants = undefined,

    pub fn deinit(self: *Effect, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}", .{ result });
        }

        c.vkDestroyPipeline(r._device, self.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.layout, null);
    }

    pub fn build(self: *Effect, allocator: std.mem.Allocator, shader: []const u8, r: *renderer.renderer_t) !void {
        std.log.info("Building effect {s}", .{ self.name });
        
        const push_constant = c.VkPushConstantRange {
            .offset = 0,
            .size = @sizeOf(PushConstants),
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

    pub fn dispatch(self: *Effect, cmd: c.VkCommandBuffer) void {
        // bind the gradient drawing compute pipeline
	    c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.pipeline);

	    // bind the descriptor set containing the draw image for the compute pipeline
	    c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.layout, 0, 1, &self._draw_image_descriptor_set, 0, null);

	    c.vkCmdPushConstants(cmd, self.layout, c.VK_SHADER_STAGE_COMPUTE_BIT, 0, @sizeOf(PushConstants), &self.data);

        const group_count_x: u32 = @intFromFloat(@as(f32, std.math.ceil(@as(f32, @floatFromInt(self._draw_extent.width)) / 16.0)));
        const group_count_y: u32 = @intFromFloat(@as(f32, std.math.ceil(@as(f32, @floatFromInt(self._draw_extent.height)) / 16.0)));

	    c.vkCmdDispatch(cmd, group_count_x, group_count_y, 1);
    }

    pub const PushConstants = struct {
        data1: @Vector(4, f32) = @splat(0),
        data2: @Vector(4, f32) = @splat(0),
        data3: @Vector(4, f32) = @splat(0),
        data4: @Vector(4, f32) = @splat(0),
    };
};

const std = @import("std");
const c = @import("../../clibs.zig");
const renderer = @import("../renderer.zig");
const pipeline = @import("../pipeline.zig");
