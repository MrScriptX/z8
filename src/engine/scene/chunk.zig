const CHUNK_SIZE = 32;
const voxel_count: u32 = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE;
const cube_index_count = voxel_count * 36;
const cube_vertex_count: u32 = voxel_count * 12 * 3;

pub const Chunk = struct {
    arena: std.heap.ArenaAllocator,

    data_buffer: buffers.AllocatedBuffer,
    buffer: buffers.GPUMeshBuffers,
    indirect_buffer: buffers.AllocatedBuffer,
    
    constants: ClassificationShader.PushConstant,
    data: Data,
    indices: []u32,
    vertices: []buffers.Vertex,

    classification_pass: *compute.Instance,
    face_culling_pass: *compute.Instance,
    compute_shader: *compute.Instance,
    material: *materials.MaterialInstance,

    descriptor_pool: descriptors.DescriptorAllocator2,
    material_buffer: buffers.AllocatedBuffer,

    pub fn init(allocator: std.mem.Allocator, pos: @Vector(3, i32), culling_shader: *FaceCullingShader, cl_shader: *ClassificationShader, shader: *MeshComputeShader, mat: *Material, r: *const renderer.renderer_t) Chunk {
        const sizes = [_]descriptors.PoolSizeRatio {
            .{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 2 },
            .{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 5 }
        };

        var voxel: Chunk = .{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .data_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(Data), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .buffer = undefined,
            .indirect_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(c.VkDrawIndexedIndirectCommand), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .classification_pass = undefined,
            .face_culling_pass = undefined,
            .compute_shader = undefined,
            .material = undefined,
            .descriptor_pool = descriptors.DescriptorAllocator2.init(allocator, r._device, 1, &sizes),
            .material_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(Material.Constants), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU),
            .constants = .{
                .position = pos
            },
            .data = .{},
            .indices = undefined,
            .vertices = undefined,
        };

        voxel.indices = voxel.arena.allocator().alloc(u32, cube_index_count) catch @panic("Out of memory");
        voxel.vertices = voxel.arena.allocator().alloc(buffers.Vertex, cube_index_count) catch @panic("Out of memory");

        voxel.buffer = buffers.GPUMeshBuffers.init(r._vma, voxel.indices[0..cube_index_count], voxel.vertices[0..cube_index_count], r);

        const resources = Material.Resources {
            .data_buffer =  voxel.buffer.vertex_buffer.buffer, 
            .data_buffer_offset = 0,
        };

        voxel.material = voxel.arena.allocator().create(materials.MaterialInstance) catch @panic("OOM");
        voxel.material.* = mat.write_material(allocator, r._device, materials.MaterialPass.MainColor, &resources, &voxel.descriptor_pool);

        const compute_resources: MeshComputeShader.Resource = .{
            .index_buffer = voxel.buffer.index_buffer.buffer,
            .index_buffer_offset = 0,

            .vertex_buffer = voxel.buffer.vertex_buffer.buffer,
            .vertex_buffer_offset = 0,

            .indirect_buffer = voxel.indirect_buffer.buffer,
            .indirect_buffer_offset = 0,

            .chunk_buffer = voxel.data_buffer.buffer,
            .chunk_buffer_offset = 0
        };

        voxel.compute_shader = voxel.arena.allocator().create(compute.Instance) catch @panic("OOM");
        voxel.compute_shader.* = shader.write(allocator, &voxel.descriptor_pool, &compute_resources, r);

        const cl_res = ClassificationShader.Resource {
            .chunk_buffer = voxel.data_buffer.buffer,
            .chunk_buffer_offset = 0
        };

        voxel.classification_pass = voxel.arena.allocator().create(compute.Instance) catch @panic("OOM");
        voxel.classification_pass.* = cl_shader.write(allocator, &voxel.descriptor_pool, &cl_res, r);

        const face_culling_res = FaceCullingShader.Resource {
            .chunk_buffer = voxel.data_buffer.buffer,
            .chunk_buffer_offset = 0
        };

        voxel.face_culling_pass = voxel.arena.allocator().create(compute.Instance) catch @panic("OOM");
        voxel.face_culling_pass.* = culling_shader.write(allocator, &voxel.descriptor_pool, &face_culling_res, r);

        return voxel;
    }

    pub fn deinit(self: *Chunk, vma: c.VmaAllocator, r: *const renderer.renderer_t) void {
        self.data_buffer.deinit(vma);
        self.buffer.deinit(vma);
        self.indirect_buffer.deinit(vma);
        self.material_buffer.deinit(vma);
        self.descriptor_pool.deinit(r._device);
        
        self.arena.deinit();
    }

    pub fn dispatch(self: *Chunk, cmd: c.VkCommandBuffer) void {
        const group_x: u32 = CHUNK_SIZE / 8;
        const group_y: u32 = CHUNK_SIZE / 8;
        const group_z: u32 = CHUNK_SIZE / 8;

        self.dispatch_classification(cmd, group_x, group_y, group_z);
        self.dispatch_face_culling(cmd, group_x, group_y, group_z);
        self.dispatch_meshing(cmd, group_x, group_y, group_z);
    }

    pub fn update(self: *Chunk, ctx: *scenes.DrawContext) void {
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

    pub fn swap_pipeline(self: *Chunk, allocator: std.mem.Allocator, mat: *Material, r: *const renderer.renderer_t) void {
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

    fn dispatch_classification(self: *Chunk, cmd: c.VkCommandBuffer, x: u32, y: u32, z: u32) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.classification_pass.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.classification_pass.pipeline.layout, 0, 1, &self.classification_pass.descriptor, 0, null);
        
        c.vkCmdPushConstants(cmd, self.classification_pass.pipeline.layout, c.VK_SHADER_STAGE_COMPUTE_BIT, 0, @sizeOf(ClassificationShader.PushConstant), &self.constants);

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

    fn dispatch_face_culling(self: *Chunk, cmd: c.VkCommandBuffer, x: u32, y: u32, z: u32) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.face_culling_pass.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.face_culling_pass.pipeline.layout, 0, 1, &self.face_culling_pass.descriptor, 0, null);

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

    fn dispatch_meshing(self: *Chunk, cmd: c.VkCommandBuffer, x: u32, y: u32, z: u32) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_shader.pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_shader.pipeline.layout, 0, 1, &self.compute_shader.descriptor, 0, null);
        
        c.vkCmdDispatch(cmd, x, y, z);

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

    pub const Data = struct { // will be fill by GPU
        active: u32 align(4) = 0,
        position: @Vector(3, i32) = @splat(0),
        voxels: [voxel_count]Voxel = @splat(.{}),
    };

    pub const Voxel = struct {
        data: @Vector(2, u32) = @splat(0), // type
    };
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
        builder.set_cull_mode(c.VK_CULL_MODE_BACK_BIT, c.VK_FRONT_FACE_CLOCKWISE);
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

    pub fn deinit(self: *ClassificationShader, r: *const renderer.renderer_t) void {
        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *ClassificationShader, allocator: std.mem.Allocator, shader: []const u8, r: *const renderer.renderer_t) !void {
        std.log.info("Building voxel classification shader", .{});

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

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

    pub fn write(self: *ClassificationShader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const renderer.renderer_t) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.chunk_buffer, @sizeOf(Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u32 = 0
    };

    pub const PushConstant = struct {
        position: @Vector(3, i32) = @splat(0)
    };
};

pub const MeshComputeShader = struct {
    name: []const u8 = undefined,
    
    pipeline: compute.Pipeline = undefined,

    layout: c.VkDescriptorSetLayout = undefined,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) MeshComputeShader {
        std.log.info("Creating compute shader {s}", .{ name });

        return .{
            .name = name,
            .writer = descriptors.Writer.init(allocator),
        };
    }

    pub fn deinit(self: *MeshComputeShader, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}", .{ result });
        }

        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *MeshComputeShader, allocator: std.mem.Allocator, shader: []const u8, r: *renderer.renderer_t) !void { 
        std.log.info("Building compute shader {s}", .{ self.name });

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(2, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        try layout_builder.add_binding(3, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

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

    pub fn write(self: *MeshComputeShader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const renderer.renderer_t) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.vertex_buffer, @sizeOf(buffers.Vertex) * cube_vertex_count, resources.vertex_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(1, resources.index_buffer, @sizeOf(u32) * cube_index_count, resources.index_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(2, resources.indirect_buffer, @sizeOf(c.VkDrawIndexedIndirectCommand), resources.indirect_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);
        self.writer.write_buffer(3, resources.chunk_buffer, @sizeOf(Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

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

        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u32,
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

    pub fn deinit(self: *FaceCullingShader, r: *const renderer.renderer_t) void {
        c.vkDestroyPipeline(r._device, self.pipeline.pipeline, null);
        c.vkDestroyPipelineLayout(r._device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(r._device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *FaceCullingShader, allocator: std.mem.Allocator, shader: []const u8, r: *const renderer.renderer_t) !void {
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

    pub fn write(self: *FaceCullingShader, allocator: std.mem.Allocator, pool: *descriptors.DescriptorAllocator2, resources: *const Resource, r: *const renderer.renderer_t) compute.Instance {
        const data =  compute.Instance {
            .pipeline = &self.pipeline,
            .descriptor = pool.allocate(allocator, r._device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.chunk_buffer, @sizeOf(Chunk.Data), resources.chunk_buffer_offset, c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER);

        self.writer.update_set(r._device, data.descriptor);

        return data;
    }

    pub const Resource = struct {
        chunk_buffer: c.VkBuffer,
        chunk_buffer_offset: u32 = 0
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
