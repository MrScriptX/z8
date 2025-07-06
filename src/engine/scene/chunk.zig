const CHUNK_SIZE = 32;
const voxel_count: u32 = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE;
const cube_index_count = voxel_count * 36;
const cube_vertex_count: u32 = voxel_count * 12 * 3;

fn seed_perm_table(seed: u32, perm: *[256]u32) void {
    for (0..256) |i| {
        perm[i] = @intCast(i);
    }

    var state: u32 = @intCast(seed);
    var i: u32 = 255;
    while (i > 0) {
        state = state *% 1664525 +% 1013904223;
        const j = state % (i + 1);
        const tmp = perm[i];
        perm[i] = perm[j];
        perm[j] = tmp;

        i -= 1;
    }
}

pub const Shaders = struct {
    classification: *shader.ClassificationShader,
    face_culling: *shader.FaceCullingShader,
    meshing: *shader.MeshComputeShader,
    frustrum_culling: *shader.FrustrumCulling
};

pub const ComputePass = struct {
    classification: *compute.Instance,
    face_culling: *compute.Instance,
    meshing: *compute.Instance,
    frustrum_culling: *compute.Instance,
};

pub const Materials = struct {
    block: *Material,
    water: *Material,
};

pub const GraphicsPass = struct {
    block_pass: *materials.MaterialInstance,
    water_pass: *materials.MaterialInstance
};

pub const Chunk = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,

    perm_table_buffer: buffers.AllocatedBuffer,
    data_buffer: buffers.AllocatedBuffer,

    constants: shader.ClassificationShader.PushConstant,
    perm_table: [256]u32 = @splat(0),

    solid_mesh: voxel.Mesh,
    water_mesh: voxel.Mesh,

    compute_passes: ComputePass,
    graphics_passes: GraphicsPass,

    descriptor_pool: descriptors.DescriptorAllocator2,
    material_buffer: buffers.AllocatedBuffer,

    ready: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    frame_in_use: [3]bool = .{ false, false, false },

    pub fn init(allocator: std.mem.Allocator, pos: @Vector(3, i32), seed: u32, shaders: Shaders, mat: Materials, r: *const renderer.renderer_t) !Chunk {
        const sizes = [_]descriptors.PoolSizeRatio {
            .{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 2 },
            .{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 8 }
        };

        var chunk: Chunk = .{
            .allocator = allocator,
            .arena = std.heap.ArenaAllocator.init(allocator),
            
            .data_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(Data), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .perm_table_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf([256]u32), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU),
            
            .compute_passes = .{
                .classification = try allocator.create(compute.Instance),
                .face_culling = try allocator.create(compute.Instance),
                .meshing = try allocator.create(compute.Instance),
                .frustrum_culling = try allocator.create(compute.Instance)
            },
            .graphics_passes = .{
                .block_pass = try allocator.create(materials.MaterialInstance),
                .water_pass = try allocator.create(materials.MaterialInstance),
            },
            
            .descriptor_pool = descriptors.DescriptorAllocator2.init(allocator, r._device, 1, &sizes),
            .material_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(Material.Constants), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU),
            .constants = .{
                .position = pos
            },

            .solid_mesh = voxel.Mesh.init(r),
            .water_mesh = voxel.Mesh.init(r),
        };

        seed_perm_table(seed, &chunk.perm_table);

        var data_ptr: []u32 = undefined;
        const result = c.vmaMapMemory(r._vma, chunk.perm_table_buffer.allocation, @ptrCast(&data_ptr));
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to map permutation table", .{});
            @panic("Failed to map perm_table_buffer");
        }
        std.mem.copyForwards(u32, data_ptr, &chunk.perm_table);
        c.vmaUnmapMemory(r._vma, chunk.perm_table_buffer.allocation);

        const block_resources = Material.Resources {
            .data_buffer = chunk.solid_mesh.vertices_buffer.buffer,
            .data_buffer_offset = 0,
        };
        chunk.graphics_passes.block_pass.* = mat.block.write_material(allocator, r._device, materials.MaterialPass.MainColor, &block_resources, &chunk.descriptor_pool);

        const water_resources = Material.Resources {
            .data_buffer = chunk.water_mesh.vertices_buffer.buffer,
            .data_buffer_offset = 0,
        };
        chunk.graphics_passes.water_pass.* = mat.water.write_material(allocator, r._device, materials.MaterialPass.Transparent, &water_resources, &chunk.descriptor_pool);

        // create compute passes
        const cl_res = shader.ClassificationShader.Resource {
            .chunk_buffer = chunk.data_buffer.buffer,
            .chunk_buffer_offset = 0,

            .perm_table_buffer = chunk.perm_table_buffer.buffer,
            .perm_table_buffer_offset = 0,
        };
        chunk.compute_passes.classification.* = shaders.classification.write(allocator, &chunk.descriptor_pool, &cl_res, r);

        const face_culling_res = shader.FaceCullingShader.Resource {
            .chunk_buffer = chunk.data_buffer.buffer,
            .chunk_buffer_offset = 0
        };
        chunk.compute_passes.face_culling.* = shaders.face_culling.write(allocator, &chunk.descriptor_pool, &face_culling_res, r);

         const compute_resources: shader.MeshComputeShader.Resource = .{
            .solid_mesh = .{
                .vertex_buffer = chunk.solid_mesh.vertices_buffer.buffer,
                .index_buffer = chunk.solid_mesh.indices_buffer.buffer,
                .indirect_buffer = chunk.solid_mesh.indirect_buffer.buffer,
            },
            .water_mesh = .{
                .vertex_buffer = chunk.water_mesh.vertices_buffer.buffer,
                .index_buffer = chunk.water_mesh.indices_buffer.buffer,
                .indirect_buffer = chunk.water_mesh.indirect_buffer.buffer,
            },
            .chunk_buffer = chunk.data_buffer.buffer,
            .chunk_buffer_offset = 0
        };
        chunk.compute_passes.meshing.* = shaders.meshing.write(allocator, &chunk.descriptor_pool, &compute_resources, r);

        const frustrum_resources: shader.FrustrumCulling.Resource = .{
            .solid_mesh = .{
                .vertex_buffer = chunk.solid_mesh.vertices_buffer.buffer,
                .index_buffer = chunk.solid_mesh.indices_buffer.buffer,
                .indirect_buffer = chunk.solid_mesh.indirect_buffer.buffer,
            },
            .water_mesh = .{
                .vertex_buffer = chunk.water_mesh.vertices_buffer.buffer,
                .index_buffer = chunk.water_mesh.indices_buffer.buffer,
                .indirect_buffer = chunk.water_mesh.indirect_buffer.buffer,
            },

            .chunk_buffer = chunk.data_buffer.buffer,
            .chunk_buffer_offset = 0
        };
        chunk.compute_passes.frustrum_culling.* = shaders.frustrum_culling.write(allocator, &chunk.descriptor_pool, &frustrum_resources, r);

        return chunk;
    }

    pub fn deinit(self: *Chunk, vma: c.VmaAllocator, r: *const renderer.renderer_t) void {
        self.perm_table_buffer.deinit(vma);
        self.data_buffer.deinit(vma);
        self.solid_mesh.deinit(r);
        self.water_mesh.deinit(r);
        self.material_buffer.deinit(vma);
        self.descriptor_pool.deinit(r._device);

        self.allocator.destroy(self.compute_passes.classification);
        self.allocator.destroy(self.compute_passes.face_culling);
        self.allocator.destroy(self.compute_passes.meshing);
        self.allocator.destroy(self.compute_passes.frustrum_culling);

        self.allocator.destroy(self.graphics_passes.block_pass);
        self.allocator.destroy(self.graphics_passes.water_pass);

        self.arena.deinit();
    }

    pub fn dispatch(self: *const Chunk, cmd: c.VkCommandBuffer, src_queue: u32, dst_queue: u32) void {
        const group_x: u32 = CHUNK_SIZE / 8;
        const group_y: u32 = CHUNK_SIZE / 8;
        const group_z: u32 = CHUNK_SIZE / 8;

        self.dispatch_classification(cmd, group_x, group_y, group_z);
        self.dispatch_face_culling(cmd, group_x, group_y, group_z);
        // self.dispatch_meshing(cmd, group_x, group_y, group_z);
        self.dispatch_meshing(cmd, CHUNK_SIZE, 6, 5, src_queue, dst_queue); // x : chunk slice, y : direction, TODO : z : per voxel type
    }

    pub fn update(self: *Chunk, ctx: *scenes.DrawContext, frame: u32) void {
        const object = materials.RenderObject {
            .index_count = cube_index_count,
            .first_index = 0,
            .index_buffer = self.solid_mesh.indices_buffer.buffer,
            .material = self.graphics_passes.block_pass,
            .transform = za.Mat4.identity().data,
            .vertex_buffer_address = 0,// self.buffer.vertex_buffer_address,
            .vertex_buffer = self.solid_mesh.vertices_buffer.buffer,
            .indirect_buffer = self.solid_mesh.indirect_buffer.buffer,
        };

        ctx.opaque_surfaces.append(object) catch {
            std.log.warn("Failed to register object for draw", .{});
        };

        const water_object = materials.RenderObject {
            .index_count = cube_index_count,
            .first_index = 0,
            .index_buffer = self.water_mesh.indices_buffer.buffer,
            .material = self.graphics_passes.water_pass,
            .transform = za.Mat4.identity().data,
            .vertex_buffer_address = 0,// self.buffer.vertex_buffer_address,
            .vertex_buffer = self.water_mesh.vertices_buffer.buffer,
            .indirect_buffer = self.water_mesh.indirect_buffer.buffer,
        };

        ctx.transparent_surfaces.append(water_object) catch {
            std.log.warn("Failed to register object for draw", .{});
        };

        self.frame_in_use[frame % 2] = true;
    }

    pub fn swap_pipeline(self: *Chunk, mat: *const Materials, r: *const renderer.renderer_t) void {
        // clean old material
        self.allocator.destroy(self.graphics_passes.block_pass);
        self.allocator.destroy(self.graphics_passes.water_pass);

        // create new material
        const block_resources = Material.Resources {
            .data_buffer = self.solid_mesh.vertices_buffer.buffer,
            .data_buffer_offset = 0,
        };

        self.graphics_passes.block_pass = self.allocator.create(materials.MaterialInstance) catch {
            std.log.err("Failed to allocate material instance !", .{});
            @panic("Out of memory !");
        };
        self.graphics_passes.block_pass.* = mat.block.write_material(self.allocator, r._device, materials.MaterialPass.MainColor, &block_resources, &self.descriptor_pool);

        const water_resources = Material.Resources {
            .data_buffer = self.water_mesh.vertices_buffer.buffer,
            .data_buffer_offset = 0,
        };

        self.graphics_passes.water_pass = self.allocator.create(materials.MaterialInstance) catch {
            std.log.err("Failed to allocate water material instance !", .{});
            @panic("Out of memory !");
        };
        self.graphics_passes.water_pass.* = mat.water.write_material(self.allocator, r._device, materials.MaterialPass.Transparent, &water_resources, &self.descriptor_pool);
    }

    fn dispatch_classification(self: *const Chunk, cmd: c.VkCommandBuffer, x: u32, y: u32, z: u32) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_passes.classification.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_passes.classification.pipeline.layout, 0, 1, &self.compute_passes.classification.descriptor, 0, null);
        
        c.vkCmdPushConstants(cmd, self.compute_passes.classification.pipeline.layout, c.VK_SHADER_STAGE_COMPUTE_BIT, 0, @sizeOf(shader.ClassificationShader.PushConstant), &self.constants);

        c.vkCmdDispatch(cmd, x, y, z);

        const chunk_data_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT,
            .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .buffer = self.data_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(Data),
        };

        const cl_pass_barriers = [_]c.VkBufferMemoryBarrier {
            chunk_data_barrier,
        };

        c.vkCmdPipelineBarrier(cmd, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT | c.VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT, 0, 0, null, @intCast(cl_pass_barriers.len), @ptrCast(&cl_pass_barriers), 0, null);
    }

    fn dispatch_face_culling(self: *const Chunk, cmd: c.VkCommandBuffer, x: u32, y: u32, z: u32) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_passes.face_culling.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_passes.face_culling.pipeline.layout, 0, 1, &self.compute_passes.face_culling.descriptor, 0, null);

        c.vkCmdDispatch(cmd, x, y, z);

        const faces_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_SHADER_READ_BIT,
            .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .buffer = self.data_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(Data),
        };

        const culling_barriers = [_]c.VkBufferMemoryBarrier {
            faces_barrier,
        };

        c.vkCmdPipelineBarrier(cmd, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT | c.VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT, 0, 0, null, @intCast(culling_barriers.len), @ptrCast(&culling_barriers), 0, null);
    }

    fn dispatch_meshing(self: *const Chunk, cmd: c.VkCommandBuffer, x: u32, y: u32, z: u32, src_queue: u32, dst_queue: u32) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_passes.meshing.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_passes.meshing.pipeline.layout, 0, 1, &self.compute_passes.meshing.descriptor, 0, null);
        
        c.vkCmdDispatch(cmd, x, y, z);

        const vertex_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT | c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = src_queue,
            .dstQueueFamilyIndex = dst_queue,
            .buffer = self.solid_mesh.vertices_buffer.buffer,
            .offset = 0,
            .size = self.solid_mesh.vertices_buffer.info.size
        };

        const index_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_INDEX_READ_BIT | c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = src_queue,
            .dstQueueFamilyIndex = dst_queue,
            .buffer = self.solid_mesh.indices_buffer.buffer,
            .offset = 0,
            .size = self.solid_mesh.indices_buffer.info.size
        };

        const indirect_barrier = c.VkBufferMemoryBarrier{
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = src_queue,
            .dstQueueFamilyIndex = dst_queue,
            .buffer = self.solid_mesh.indirect_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(c.VkDrawIndexedIndirectCommand),
        };

        const water_vertex_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT | c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = src_queue,
            .dstQueueFamilyIndex = dst_queue,
            .buffer = self.water_mesh.vertices_buffer.buffer,
            .offset = 0,
            .size = self.water_mesh.vertices_buffer.info.size
        };

        const water_index_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_INDEX_READ_BIT | c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = src_queue,
            .dstQueueFamilyIndex = dst_queue,
            .buffer = self.water_mesh.indices_buffer.buffer,
            .offset = 0,
            .size = self.water_mesh.indices_buffer.info.size
        };

        const water_indirect_barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
            .srcQueueFamilyIndex = src_queue,
            .dstQueueFamilyIndex = dst_queue,
            .buffer = self.water_mesh.indirect_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(c.VkDrawIndexedIndirectCommand),
        };


        const barriers = [_]c.VkBufferMemoryBarrier {
            vertex_barrier,
            index_barrier,
            indirect_barrier,
            water_vertex_barrier,
            water_index_barrier,
            water_indirect_barrier
        };

        c.vkCmdPipelineBarrier(cmd, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, c.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT | c.VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT, 0, 0, null, @intCast(barriers.len), @ptrCast(&barriers), 0, null);
    }

    pub const Data = struct { // will be fill by GPU
        active: u32 align(4) = 0,
        position: @Vector(3, i32) = @splat(0),
        voxels: [voxel_count]Voxel = @splat(.{}),
    };

    // pub const MapData = struct {
    //     voxels: [voxel_count]Voxel = @splat(.{}),
    // };

    pub const Voxel = struct {
        data: @Vector(2, u32) = @splat(0), // type
    };

    // pub const Voxel2 = struct {
    //     faces: [6]bool = .{ false, false, false, false, false, false }, // face culling
    //     type: u32 = 0, // type 
    // };
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

    pub fn build(self: *Material, allocator: std.mem.Allocator, vert_path: []const u8, frag_path: []const u8, polygone_mode: c.VkPolygonMode, blend: bool, r: *const renderer.renderer_t) !void {        
        const frag_shader = try p.load_shader_module(allocator, r._device, frag_path);
        defer c.vkDestroyShaderModule(r._device, frag_shader, null);

        const vert_shader = try p.load_shader_module(allocator, r._device, vert_path);
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
        builder.set_cull_mode(c.VK_CULL_MODE_BACK_BIT, c.VK_FRONT_FACE_CLOCKWISE);
        builder.set_multisampling_none();
        if (blend) {
            builder.enable_blending_alphablend();
        }
        else {
            builder.disable_blending();
        }
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

const shader = @import("../../levels/voxel/shaders.zig");
const voxel = @import("../../levels/voxel/voxel.zig");

const buffers = @import("../graphics/buffers.zig");
const materials = @import("../graphics/materials.zig");
const compute = @import("../graphics/compute.zig");
const descriptors = @import("../descriptor.zig");
const p = @import("../pipeline.zig");
const renderer = @import("../renderer.zig");
const assets = @import("../graphics/assets.zig");
const scenes = @import("../scene/scene.zig");
