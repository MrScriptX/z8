pub const Voxel = struct {
    allocator: std.mem.Allocator,

    meshes: assets.MeshAsset,
    material: *mat.MaterialInstance,

    pub fn init(alloc: std.mem.Allocator, material: *VoxelMaterial, renderer: *engine.renderer_t) !Voxel {
        var rect_vertices =  std.ArrayList(buffers.Vertex).init(alloc);
        defer rect_vertices.deinit();

        for (cube_vertices) |v| {
            try rect_vertices.append(v);
        }

        var rect_indices = std.ArrayList(u32).init(alloc);
        defer rect_indices.deinit();

        // Fill index buffer
        for (cube_indices) |i| {
            try rect_indices.append(i);
        }

        const mat_resources = VoxelMaterial.Resources {
            .color_image = engine.renderer_t._white_image,
            .color_sampler = engine.renderer_t._default_sampler_linear,
            .data_buffer =  renderer._mat_constants.buffer,
            .data_buffer_offset = 0,
        };

        var voxel = Voxel {
            .allocator = alloc,
            .meshes = assets.MeshAsset.init(alloc, "rectangle"),
            .material = undefined,
        };

        voxel.material = try voxel.allocator.create(mat.MaterialInstance);
        voxel.material.* = material.write_material(alloc, renderer._device, mat.MaterialPass.MainColor, &mat_resources, &material.pool);

        voxel.meshes.surfaces.append(.{
            .startIndex = 0,
            .count = @intCast(rect_indices.items.len),
            .material = voxel.material
        }) catch @panic("Out of memory !");

        voxel.meshes.mesh_buffers = buffers.GPUMeshBuffers.init(renderer._vma, rect_indices.items, rect_vertices.items, renderer);

        return voxel;
    }

    pub fn deinit(self: *Voxel, vma: c.VmaAllocator) void {
        self.meshes.mesh_buffers.deinit(vma);
        self.meshes.deinit();

        self.allocator.destroy(self.material);
    }
};

pub const VoxelMaterial = struct {
    mem: std.heap.ArenaAllocator,

    default_pipeline: *mat.MaterialPipeline,
    layout: c.VkDescriptorSetLayout,
    writer: descriptors.Writer,

    pool: descriptors.DescriptorAllocator2,

    pub fn init(allocator: std.mem.Allocator, device: c.VkDevice) VoxelMaterial {
        const sizes = [_]descriptors.PoolSizeRatio {
            .{ ._type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, ._ratio = 3 },
            .{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 3 },
            .{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 1 }
        };

        var instance = VoxelMaterial {
            .mem = std.heap.ArenaAllocator.init(allocator),
            .writer = descriptors.Writer.init(allocator),
            .layout = undefined,
            .default_pipeline = undefined,
            .pool = descriptors.DescriptorAllocator2.init(allocator, device, @intCast(1), &sizes)
        };

        instance.default_pipeline = instance.mem.allocator().create(mat.MaterialPipeline) catch {
            std.log.err("Failed to allocate memory for MaterialPipeline !", .{});
            @panic("Out Of Memory !");
        };

        return instance;
    }

    pub fn deinit(self: *VoxelMaterial, device: c.VkDevice) void {
        c.vkDestroyPipeline(device, self.default_pipeline.pipeline, null);

        c.vkDestroyPipelineLayout(device, self.default_pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(device, self.layout, null);

        self.pool.deinit(device);

        self.mem.deinit();
        self.writer.deinit();
    }

    pub fn write_material(self: *VoxelMaterial, allocator: std.mem.Allocator, device: c.VkDevice, pass: mat.MaterialPass, resources: *const Resources, ds_alloc: *descriptors.DescriptorAllocator2) mat.MaterialInstance {
        const data = mat.MaterialInstance {
            .pass_type = pass,
            .pipeline = self.default_pipeline,
            .material_set = ds_alloc.allocate(allocator, device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.data_buffer, @sizeOf(Constants), resources.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        self.writer.write_image(1, resources.color_image.view, resources.color_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.writer.update_set(device, data.material_set);

        return data;
    }

    pub fn build_pipeline(self: *VoxelMaterial, allocator: std.mem.Allocator, renderer: *engine.renderer_t) !void {
        const frag_shader = try pipelines.load_shader_module(allocator, renderer._device, "./zig-out/bin/shaders/voxel.frag.spv");
        defer c.vkDestroyShaderModule(renderer._device, frag_shader, null);

        const vert_shader = try pipelines.load_shader_module(allocator, renderer._device, "./zig-out/bin/shaders/voxel.vert.spv");
        defer c.vkDestroyShaderModule(renderer._device, vert_shader, null);

        const matrix_range: c.VkPushConstantRange = .{
            .offset = 0,
            .size = @sizeOf(buffers.GPUDrawPushConstants),
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT,
        };

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.layout = layout_builder.build(renderer._device, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);

        const layouts = [_]c.VkDescriptorSetLayout {
            renderer._gpu_scene_data_descriptor_layout,
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
        const result = c.vkCreatePipelineLayout(renderer._device, &mesh_layout_info, null, &new_layout);
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to create descriptor layout ! Reason {d}", .{ result });
            @panic("Failed to create descriptor layout");
        }

        self.default_pipeline.layout = new_layout;

        var builder = pipelines.builder_t.init(allocator);
        defer builder.deinit();

        try builder.set_shaders(vert_shader, frag_shader);
        builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
        builder.set_polygon_mode(c.VK_POLYGON_MODE_FILL);
        builder.set_cull_mode(c.VK_CULL_MODE_NONE, c.VK_FRONT_FACE_CLOCKWISE);
        builder.set_multisampling_none();
        builder.disable_blending();
        builder.enable_depthtest(true, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

        builder.set_color_attachment_format(renderer._draw_image.format);
        builder.set_depth_format(renderer._depth_image.format);

        builder._pipeline_layout = new_layout;

        self.default_pipeline.pipeline = builder.build_pipeline(renderer._device);
    }

    pub const Constants = struct {
        color_factors: maths.vec4 align(16),
    };

    pub const Resources = struct {
        color_image: images.image_t,
        color_sampler: c.VkSampler,
        data_buffer: c.VkBuffer,
        data_buffer_offset: u32,
    };
};

// Cube vertices (24: 4 per face, for unique normals/colors/UVs)
const cube_vertices = [_]buffers.Vertex{
    // Front face (z = 0.5)
    .{ .position = .{ -0.5, -0.5,  0.5 }, .color = .{ 1, 0, 0, 1 }, .uv_x = 0, .uv_y = 0, .normal = .{ 0, 0, 1 } },
    .{ .position = .{  0.5, -0.5,  0.5 }, .color = .{ 1, 0, 0, 1 }, .uv_x = 1, .uv_y = 0, .normal = .{ 0, 0, 1 } },
    .{ .position = .{  0.5,  0.5,  0.5 }, .color = .{ 1, 0, 0, 1 }, .uv_x = 1, .uv_y = 1, .normal = .{ 0, 0, 1 } },
    .{ .position = .{ -0.5,  0.5,  0.5 }, .color = .{ 1, 0, 0, 1 }, .uv_x = 0, .uv_y = 1, .normal = .{ 0, 0, 1 } },

    // Back face (z = -0.5)
    .{ .position = .{  0.5, -0.5, -0.5 }, .color = .{ 0, 1, 0, 1 }, .uv_x = 0, .uv_y = 0, .normal = .{ 0, 0, -1 } },
    .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 0, 1, 0, 1 }, .uv_x = 1, .uv_y = 0, .normal = .{ 0, 0, -1 } },
    .{ .position = .{ -0.5,  0.5, -0.5 }, .color = .{ 0, 1, 0, 1 }, .uv_x = 1, .uv_y = 1, .normal = .{ 0, 0, -1 } },
    .{ .position = .{  0.5,  0.5, -0.5 }, .color = .{ 0, 1, 0, 1 }, .uv_x = 0, .uv_y = 1, .normal = .{ 0, 0, -1 } },

    // Left face (x = -0.5)
    .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 0, 0, 1, 1 }, .uv_x = 0, .uv_y = 0, .normal = .{ -1, 0, 0 } },
    .{ .position = .{ -0.5, -0.5,  0.5 }, .color = .{ 0, 0, 1, 1 }, .uv_x = 1, .uv_y = 0, .normal = .{ -1, 0, 0 } },
    .{ .position = .{ -0.5,  0.5,  0.5 }, .color = .{ 0, 0, 1, 1 }, .uv_x = 1, .uv_y = 1, .normal = .{ -1, 0, 0 } },
    .{ .position = .{ -0.5,  0.5, -0.5 }, .color = .{ 0, 0, 1, 1 }, .uv_x = 0, .uv_y = 1, .normal = .{ -1, 0, 0 } },

    // Right face (x = 0.5)
    .{ .position = .{ 0.5, -0.5,  0.5 }, .color = .{ 1, 1, 0, 1 }, .uv_x = 0, .uv_y = 0, .normal = .{ 1, 0, 0 } },
    .{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 1, 1, 0, 1 }, .uv_x = 1, .uv_y = 0, .normal = .{ 1, 0, 0 } },
    .{ .position = .{ 0.5,  0.5, -0.5 }, .color = .{ 1, 1, 0, 1 }, .uv_x = 1, .uv_y = 1, .normal = .{ 1, 0, 0 } },
    .{ .position = .{ 0.5,  0.5,  0.5 }, .color = .{ 1, 1, 0, 1 }, .uv_x = 0, .uv_y = 1, .normal = .{ 1, 0, 0 } },

    // Top face (y = 0.5)
    .{ .position = .{ -0.5, 0.5,  0.5 }, .color = .{ 1, 0, 1, 1 }, .uv_x = 0, .uv_y = 0, .normal = .{ 0, 1, 0 } },
    .{ .position = .{  0.5, 0.5,  0.5 }, .color = .{ 1, 0, 1, 1 }, .uv_x = 1, .uv_y = 0, .normal = .{ 0, 1, 0 } },
    .{ .position = .{  0.5, 0.5, -0.5 }, .color = .{ 1, 0, 1, 1 }, .uv_x = 1, .uv_y = 1, .normal = .{ 0, 1, 0 } },
    .{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 1, 0, 1, 1 }, .uv_x = 0, .uv_y = 1, .normal = .{ 0, 1, 0 } },

    // Bottom face (y = -0.5)
    .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 0, 1, 1, 1 }, .uv_x = 0, .uv_y = 0, .normal = .{ 0, -1, 0 } },
    .{ .position = .{  0.5, -0.5, -0.5 }, .color = .{ 0, 1, 1, 1 }, .uv_x = 1, .uv_y = 0, .normal = .{ 0, -1, 0 } },
    .{ .position = .{  0.5, -0.5,  0.5 }, .color = .{ 0, 1, 1, 1 }, .uv_x = 1, .uv_y = 1, .normal = .{ 0, -1, 0 } },
    .{ .position = .{ -0.5, -0.5,  0.5 }, .color = .{ 0, 1, 1, 1 }, .uv_x = 0, .uv_y = 1, .normal = .{ 0, -1, 0 } },
};

// Cube indices (6 faces × 2 triangles × 3 indices)
const cube_indices = [_]u32{
    // Front
    0, 1, 2, 0, 2, 3,
    // Back
    4, 5, 6, 4, 6, 7,
    // Left
    8, 9,10, 8,10,11,
    // Right
   12,13,14,12,14,15,
    // Top
   16,17,18,16,18,19,
    // Bottom
   20,21,22,20,22,23,
};

const std = @import("std");
const engine = @import("engine/renderer.zig");
const buffers = @import("engine/buffers.zig");
const mat = @import("engine/materials.zig");
const descriptors = @import("engine/descriptor.zig");
const c = @import("clibs.zig");
const maths = @import("utils/maths.zig");
const images = @import("engine/vulkan/image.zig");
const pipelines = @import("engine/pipeline.zig");
const assets = @import("engine/assets.zig");
