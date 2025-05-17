pub const Pipeline = struct {
    pipeline: c.VkPipeline = null,
    layout: c.VkPipelineLayout = null,
};

pub const Instance = struct {
    pipeline: *Pipeline,
    descriptor: c.VkDescriptorSet,
};

pub const Shader = struct {
    name: []const u8 = undefined,
    
    pipeline: Pipeline = undefined,

    layout: c.VkDescriptorSetLayout = undefined,
    writer: descriptors.Writer,

    const cube_vertex_count: u32 = 16 * 16 * 16 * 12 * 3;
    const cube_index_count: u32 = 16 * 16 * 16 * 36;

    pub fn init(allocator: std.mem.Allocator, name: []const u8) Shader {
        std.log.info("Creating compute shader {s}", .{ name });

        return .{
            .name = name,
            .writer = descriptors.Writer.init(allocator),
        };
    }

    pub fn deinit(self: *Shader, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}", .{ result });
        }

        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *Shader, allocator: std.mem.Allocator, shader: []const u8, r: *renderer.renderer_t) !void { 
        std.log.info("Building compute shader {s}", .{ self.name });

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(2, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.layout = layout_builder.build(r._device, c.VK_SHADER_STAGE_COMPUTE_BIT, null, 0);

        const layouts = [_]c.VkDescriptorSetLayout {
            self.layout
        };

        const compute_layout = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
	        .pNext = null,

	        .pSetLayouts = &layouts,
	        .setLayoutCount = 1,
        };

	    const result = c.vkCreatePipelineLayout(r._device, &compute_layout, null, &self.pipeline.layout);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to create pipeline layout !", .{});
        }

        // shader module
        const compute_shader = try pipelines.load_shader_module(allocator, r._device, shader);
        defer c.vkDestroyShaderModule(r._device, compute_shader, null);

        // compute
        var builder = pipelines.compute_builder_t.init();
        defer builder.deinit();

        builder.layout = self.pipeline.layout;
        builder.set_shaders(compute_shader);
        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write(self: *Shader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const renderer.renderer_t) Instance {
        const data =  Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.vertex_buffer, @sizeOf(buffers.Vertex) * cube_vertex_count, resources.vertex_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(1, resources.index_buffer, @sizeOf(u32) * cube_index_count, resources.index_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(2, resources.index_buffer, @sizeOf(c.VkDrawIndexedIndirectCommand), resources.indirect_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        vertex_buffer: c.VkBuffer,
        vertex_buffer_offset: u32,

        index_buffer: c.VkBuffer,
        index_buffer_offset: u32,

        indirect_buffer: c.VkBuffer,
        indirect_buffer_offset: u32,
    };
};

const std = @import("std");
const c = @import("../../clibs.zig");
const renderer = @import("../renderer.zig");
const pipelines = @import("../pipeline.zig");
const descriptors = @import("../descriptor.zig");
const buffers = @import("buffers.zig");
