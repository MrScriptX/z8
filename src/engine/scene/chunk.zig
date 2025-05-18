const CHUNK_SIZE = 16;
const voxel_count = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE;
const cube_index_count = voxel_count * 36;

pub const Voxel = struct {
    arena: std.heap.ArenaAllocator,

    buffer: buffers.GPUMeshBuffers,
    indirect_buffer: buffers.AllocatedBuffer,
    
    indices: []u32,
    vertices: []buffers.Vertex,

    compute_shader: *compute.Instance,
    material: *materials.MaterialInstance,

    descriptor_pool: descriptors.DescriptorAllocator2,
    material_buffer: buffers.AllocatedBuffer,

    pub fn init(allocator: std.mem.Allocator, vma: c.VmaAllocator, shader: *compute.Shader, mat: *Material, r: *const renderer.renderer_t) Voxel {
        const sizes = [_]descriptors.PoolSizeRatio {
            .{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 2 },
            .{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 3 }
        };

        var voxel: Voxel = .{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .buffer = undefined,
            .indirect_buffer = buffers.AllocatedBuffer.init(vma, @sizeOf(c.VkDrawIndexedIndirectCommand), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .compute_shader = undefined,
            .material = undefined,
            .descriptor_pool = descriptors.DescriptorAllocator2.init(allocator, r._device, 1, &sizes),
            .material_buffer = buffers.AllocatedBuffer.init(vma, @sizeOf(Material.Constants), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU),
            .indices = undefined,
            .vertices = undefined,
        };

        voxel.indices = voxel.arena.allocator().alloc(u32, cube_index_count) catch @panic("Out of memory");
        voxel.vertices = voxel.arena.allocator().alloc(buffers.Vertex, cube_index_count) catch @panic("Out of memory");

        voxel.buffer = buffers.GPUMeshBuffers.init(vma, voxel.indices[0..cube_index_count], voxel.vertices[0..cube_index_count], r);

        const resources = Material.Resources {
            .data_buffer =  voxel.buffer.vertex_buffer.buffer, 
            .data_buffer_offset = 0,
        };

        voxel.material = voxel.arena.allocator().create(materials.MaterialInstance) catch @panic("OOM");
        voxel.material.* = mat.write_material(allocator, r._device, materials.MaterialPass.MainColor, &resources, &voxel.descriptor_pool);

        const compute_resources: compute.Shader.Resource = .{
            .index_buffer = voxel.buffer.index_buffer.buffer,
            .index_buffer_offset = 0,
            .vertex_buffer = voxel.buffer.vertex_buffer.buffer,
            .vertex_buffer_offset = 0,
            .indirect_buffer = voxel.indirect_buffer.buffer,
            .indirect_buffer_offset = 0,
        };

        voxel.compute_shader = voxel.arena.allocator().create(compute.Instance) catch @panic("OOM");
        voxel.compute_shader.* = shader.write(allocator, &voxel.descriptor_pool, &compute_resources, r);

        return voxel;
    }

    pub fn deinit(self: *Voxel, vma: c.VmaAllocator, r: *const renderer.renderer_t) void {
        self.buffer.deinit(vma);
        self.indirect_buffer.deinit(vma);
        self.material_buffer.deinit(vma);
        self.descriptor_pool.deinit(r._device);
        
        self.arena.deinit();
    }

    pub fn dispatch(self: *Voxel, cmd: c.VkCommandBuffer) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_shader.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_shader.pipeline.layout, 0, 1, &self.compute_shader.descriptor, 0, null);

        const group_x: u32 = CHUNK_SIZE / 8;
        const group_y: u32 = CHUNK_SIZE / 8;
        const group_z: u32 = CHUNK_SIZE / 8;
        
        c.vkCmdDispatch(cmd, group_x, group_y, group_z);

        const vertex_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT,
            .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .buffer = self.buffer.vertex_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(buffers.Vertex) * self.vertices.len,
        };

        const index_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT,
            .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .buffer = self.buffer.index_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(u32) * self.indices.len,
        };

        const indirect_barrier = c.VkBufferMemoryBarrier{
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .buffer = self.indirect_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(c.VkDrawIndexedIndirectCommand),
        };


        const barriers = [_]c.VkBufferMemoryBarrier {
            vertex_barrier,
            index_barrier,
            indirect_barrier
        };

        c.vkCmdPipelineBarrier(cmd, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, c.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT | c.VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT, 0, 0, null, @intCast(barriers.len), @ptrCast(&barriers), 0, null);
    }

    pub fn update(self: *Voxel, ctx: *scenes.DrawContext) void {
        const object = materials.RenderObject {
            .index_count = cube_index_count,
            .first_index = 0,
            .index_buffer = self.buffer.index_buffer.buffer,
            .material = self.material,
            .transform = za.Mat4.identity().data,
            .vertex_buffer_address = 0,// self.buffer.vertex_buffer_address,
            .vertex_buffer = self.buffer.vertex_buffer.buffer,
            .indirect_buffer = self.indirect_buffer.buffer,
        };

        ctx.opaque_surfaces.append(object) catch {
            std.log.err("Failed to register object for draw", .{});
        };
    }

    pub fn swap_pipeline(self: *Voxel, allocator: std.mem.Allocator, mat: *Material, r: *const renderer.renderer_t) void {
        // clean old material
        self.arena.allocator().destroy(self.material);
        
        // create new material
        const resources = Material.Resources {
            .data_buffer = self.buffer.vertex_buffer.buffer, 
            .data_buffer_offset = 0,
        };

        self.material = self.arena.allocator().create(materials.MaterialInstance) catch @panic("OOM");
        self.material.* = mat.write_material(allocator, r._device, materials.MaterialPass.MainColor, &resources, &self.descriptor_pool);
    }
};

pub const Material = struct {
    pipeline: materials.MaterialPipeline,
    layout: c.VkDescriptorSetLayout,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator) Material {
        return .{
            .writer = descriptors.Writer.init(allocator),
            .layout = undefined,
            .pipeline = undefined,
        };
    }

    pub fn deinit(self: *Material, device: c.VkDevice) void {
        c.vkDestroyPipeline(device, self.pipeline.pipeline , null);
        c.vkDestroyPipelineLayout(device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *Material, allocator: std.mem.Allocator, polygone_mode: c.VkPolygonMode, r: *const renderer.renderer_t) !void {
        const frag_shader = try p.load_shader_module(allocator, r._device, "./zig-out/bin/shaders/aurora/cube.frag.spv");
        defer c.vkDestroyShaderModule(r._device, frag_shader, null);

        const vert_shader = try p.load_shader_module(allocator, r._device, "./zig-out/bin/shaders/aurora/cube.vert.spv");
        defer c.vkDestroyShaderModule(r._device, vert_shader, null);

        const matrix_range: c.VkPushConstantRange = .{
            .offset = 0,
            .size = @sizeOf(buffers.GPUDrawPushConstants),
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT,
        };

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER | c.VK_SHADER_STAGE_VERTEX_BIT);

        self.layout = layout_builder.build(r._device, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);

        const layouts = [_]c.VkDescriptorSetLayout {
            r.scene_descriptor,
            self.layout
        };

        const mesh_layout_info = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            .pNext = null,

            .setLayoutCount = 2,
            .pSetLayouts = &layouts,
            .pPushConstantRanges = &matrix_range,
            .pushConstantRangeCount = 1,
        };

        var new_layout: c.VkPipelineLayout = undefined;
        const result = c.vkCreatePipelineLayout(r._device, &mesh_layout_info, null, &new_layout);
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to create descriptor layout ! Reason {d}", .{ result });
            @panic("Failed to create descriptor layout");
        }

        self.pipeline.layout = new_layout;

        var builder = p.builder_t.init(allocator);
        defer builder.deinit();

        try builder.set_shaders(vert_shader, frag_shader);
        builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
        builder.set_polygon_mode(polygone_mode);
        builder.set_cull_mode(c.VK_CULL_MODE_NONE, c.VK_FRONT_FACE_CLOCKWISE);
        builder.set_multisampling_none();
        builder.disable_blending();
        builder.enable_depthtest(true, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

        builder.set_color_attachment_format(r._draw_image.format);
        builder.set_depth_format(r._depth_image.format);

        builder._pipeline_layout = new_layout;

        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write_material(self: *Material, allocator: std.mem.Allocator, device: c.VkDevice, pass: materials.MaterialPass, res: *const Resources, ds_alloc: *descriptors.DescriptorAllocator2)  materials.MaterialInstance {
        const data =  materials.MaterialInstance {
            .pass_type = pass,
            .pipeline = &self.pipeline,
            .material_set = ds_alloc.allocate(allocator, device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, res.data_buffer, @sizeOf(buffers.Vertex) * cube_index_count, res.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        
        self.writer.update_set(device, data.material_set);

        return data;
    }

    pub const Constants = struct {
        color_factors: @Vector(4, f32) align(16),
    };

    pub const Resources = struct {
        data_buffer: c.VkBuffer,
        data_buffer_offset: u32,
    };
};

const std = @import("std");
const za = @import("zalgebra");
const c = @import("../../clibs.zig");
const buffers = @import("../graphics/buffers.zig");
const materials = @import("../graphics/materials.zig");
const compute = @import("../graphics/compute.zig");
const descriptors = @import("../descriptor.zig");
const p = @import("../pipeline.zig");
const renderer = @import("../renderer.zig");
const assets = @import("../graphics/assets.zig");
const scenes = @import("../scene/scene.zig");
