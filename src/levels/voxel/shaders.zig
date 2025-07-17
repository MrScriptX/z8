pub const ClassificationShader = struct {
    pipeline: compute.Pipeline = undefined,

    layout: c.VkDescriptorSetLayout = undefined,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator) ClassificationShader {
        std.log.info("Creating voxel classification shader", .{});

        return .{
            .writer = descriptors.Writer.init(allocator)
        };
    }

    pub fn deinit(self: *ClassificationShader, r: *const Renderer) void {
        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *ClassificationShader, allocator: std.mem.Allocator, shader: []const u8, r: *const Renderer) !void {
        std.log.info("Building voxel classification shader", .{});

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.layout = layout_builder.build(r._device, c.VK_SHADER_STAGE_COMPUTE_BIT, null, 0);

        const layouts = [_]c.VkDescriptorSetLayout {
            self.layout
        };

        const push_constant = c.VkPushConstantRange {
            .offset = 0,
            .size = @sizeOf(PushConstant),
            .stageFlags = c.VK_SHADER_STAGE_COMPUTE_BIT,
        };

        const compute_layout = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            .pNext = null,

            .pSetLayouts = &layouts,
            .setLayoutCount = 1,

            .pPushConstantRanges = &push_constant,
            .pushConstantRangeCount = 1
        };

        const result = c.vkCreatePipelineLayout(r._device, &compute_layout, null, &self.pipeline.layout);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to create pipeline layout !", .{});
        }

        // shader module
        const compute_shader = try p.load_shader_module(allocator, r._device, shader);
        defer c.vkDestroyShaderModule(r._device, compute_shader, null);

        // compute
        var builder = p.compute_builder_t.init();
        defer builder.deinit();

        builder.layout = self.pipeline.layout;
        builder.set_shaders(compute_shader);
        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write(self: *ClassificationShader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const Renderer) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.chunk_buffer, @sizeOf(chunk.Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(1, resources.perm_table_buffer, @sizeOf([256]u32), resources.perm_table_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u32 = 0,

        perm_table_buffer: c.VkBuffer,
        perm_table_buffer_offset: u32 = 0,
    };

    pub const PushConstant = struct {
        position: @Vector(3, i32) = @splat(0)
    };
};

pub const FaceCullingShader = struct {
    pipeline: compute.Pipeline = undefined,

    layout: c.VkDescriptorSetLayout = undefined,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator) FaceCullingShader {
        std.log.info("Creating face culling shader", .{});

        return .{
            .writer = descriptors.Writer.init(allocator)
        };
    }

    pub fn deinit(self: *FaceCullingShader, r: *const Renderer) void {
        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *FaceCullingShader, allocator: std.mem.Allocator, shader: []const u8, r: *const Renderer) !void {
        std.log.info("Building voxel face culling shader", .{});

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

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
        const compute_shader = try p.load_shader_module(allocator, r._device, shader);
        defer c.vkDestroyShaderModule(r._device, compute_shader, null);

        // compute
        var builder = p.compute_builder_t.init();
        defer builder.deinit();

        builder.layout = self.pipeline.layout;
        builder.set_shaders(compute_shader);
        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write(self: *FaceCullingShader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const Renderer) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.chunk_buffer, @sizeOf(chunk.Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u32 = 0
    };
};

pub const GreedyMeshingShader = struct {
    name: []const u8 = undefined,
    
    pipeline: compute.Pipeline = undefined,

    layout: c.VkDescriptorSetLayout = undefined,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) GreedyMeshingShader {
        std.log.info("Creating compute shader {s}", .{ name });

        return .{
            .name = name,
            .writer = descriptors.Writer.init(allocator),
        };
    }

    pub fn deinit(self: *GreedyMeshingShader, r: *Renderer) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}", .{ result });
        }

        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *GreedyMeshingShader, allocator: std.mem.Allocator, shader: []const u8, r: *Renderer) !void { 
        std.log.info("Building compute shader {s}", .{ self.name });

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(2, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(3, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(4, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

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
        const compute_shader = try p.load_shader_module(allocator, r._device, shader);
        defer c.vkDestroyShaderModule(r._device, compute_shader, null);

        // compute
        var builder = p.compute_builder_t.init();
        defer builder.deinit();

        builder.layout = self.pipeline.layout;
        builder.set_shaders(compute_shader);
        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write(self: *GreedyMeshingShader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const Renderer) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.vertex_buffer, @sizeOf(buffers.Vertex) * voxel.vertex_count, resources.vertex_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(1, resources.index_buffer, @sizeOf(u32) * voxel.index_count, resources.index_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(2, resources.solid_indirect_buffer, @sizeOf(c.VkDrawIndexedIndirectCommand), resources.solid_indirect_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(3, resources.water_indirect_buffer, @sizeOf(c.VkDrawIndexedIndirectCommand), resources.water_indirect_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(4, resources.chunk_buffer, @sizeOf(chunk.Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        vertex_buffer: c.VkBuffer,
        vertex_buffer_offset: u64 = 0,

        index_buffer: c.VkBuffer,
        index_buffer_offset: u64 = 0,

        solid_indirect_buffer: c.VkBuffer,
        solid_indirect_buffer_offset: u64 = 0,

        water_indirect_buffer: c.VkBuffer,
        water_indirect_buffer_offset: u64 = 0,

        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u64,
    };
};

pub const FrustrumCulling = struct {
    pipeline: compute.Pipeline = undefined,

    layout: c.VkDescriptorSetLayout = undefined,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator) FrustrumCulling {
        std.log.info("Creating frustrum culling shader", .{ });

        return .{
            .writer = descriptors.Writer.init(allocator),
        };
    }

    pub fn deinit(self: *FrustrumCulling, r: *const Renderer) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}", .{ result });
        }

        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *FrustrumCulling, allocator: std.mem.Allocator, shader: []const u8, r: *Renderer) !void { 
        std.log.info("Building frustrum culling shader", .{ });

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(2, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(3, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(4, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(5, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(6, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

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
        const compute_shader = try p.load_shader_module(allocator, r._device, shader);
        defer c.vkDestroyShaderModule(r._device, compute_shader, null);

        // compute
        var builder = p.compute_builder_t.init();
        defer builder.deinit();

        builder.layout = self.pipeline.layout;
        builder.set_shaders(compute_shader);
        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write(self: *FrustrumCulling, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const Renderer) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.solid_mesh.vertex_buffer, @sizeOf(buffers.Vertex) * voxel.vertex_count, resources.solid_mesh.vertex_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(1, resources.solid_mesh.index_buffer, @sizeOf(u32) * voxel.index_count, resources.solid_mesh.index_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(2, resources.solid_mesh.indirect_buffer, @sizeOf(c.VkDrawIndexedIndirectCommand), resources.solid_mesh.indirect_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.write_buffer(3, resources.water_mesh.vertex_buffer, @sizeOf(buffers.Vertex) * voxel.vertex_count, resources.water_mesh.vertex_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(4, resources.water_mesh.index_buffer, @sizeOf(u32) * voxel.index_count, resources.water_mesh.index_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(5, resources.water_mesh.indirect_buffer, @sizeOf(c.VkDrawIndexedIndirectCommand), resources.water_mesh.indirect_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        
        self.writer.write_buffer(6, resources.chunk_buffer, @sizeOf(chunk.Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        solid_mesh: voxel.Mesh.Resource,
        water_mesh: voxel.Mesh.Resource,

        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u32,
    };
};

const std = @import("std");
const c = @import("../../clibs.zig");
const voxel = @import("voxel.zig");
const chunk = @import("chunk.zig");
const engine = @import("../../engine/engine.zig");

const Renderer = engine.renderer.Renderer;
const compute = engine.compute;

const p = @import("../../engine/pipeline.zig");
const buffers = @import("../../engine/graphics/buffers.zig");
const descriptors = @import("../../engine/descriptor.zig");
