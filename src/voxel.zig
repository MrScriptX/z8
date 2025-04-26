pub const Voxel = struct {
    mesh: buffers.GPUMeshBuffers,
    material: mat.MaterialInstance,
    index_count: u32,

    pub fn init(alloc: std.mem.Allocator, renderer: *engine.renderer_t) !Voxel {
        var rect_vertices =  std.ArrayList(buffers.Vertex).init(alloc);
        defer rect_vertices.deinit();

        try rect_vertices.append(.{
            .position = .{ 0.5, -0.5, 0.0 },
            .color = .{ 0, 0, 0, 1},
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        try rect_vertices.append(.{
            .position = .{ 0.5, 0.5, 0 },
            .color = .{ 0.5, 0.5, 0.5 ,1},
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        try rect_vertices.append(.{
            .position = .{ -0.5, -0.5, 0 },
            .color = .{ 1, 0, 0, 1 },
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        try rect_vertices.append(.{
            .position = .{ -0.5, 0.5, 0 },
            .color = .{ 0, 1, 0, 1 },
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        var rect_indices = std.ArrayList(u32).init(alloc);
        defer rect_indices.deinit();

        try rect_indices.append(0);
        try rect_indices.append(1);
        try rect_indices.append(2);

        try rect_indices.append(2);
        try rect_indices.append(1);
        try rect_indices.append(3);

        // const mat_instance = renderer.

        const voxel = Voxel {
            .mesh = buffers.GPUMeshBuffers.init(renderer._vma, renderer._device, &renderer._imm_fence, renderer._queues.graphics, rect_indices.items, rect_vertices.items, renderer._imm_command_buffer),
            .material = undefined,
            .index_count = @intCast(rect_indices.items.len),
        };

        return voxel;
    }

    pub fn deinit(self: *Voxel, vma: c.VmaAllocator) void {
        self.mesh.deinit(vma);
    }
};

pub const VoxelMaterial = struct {
    mem: std.heap.ArenaAllocator,

    default_pipeline: *mat.MaterialPipeline,
    layout: c.VkDescriptorSetLayout,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator) VoxelMaterial {
        var instance = VoxelMaterial {
            .mem = std.heap.ArenaAllocator.init(allocator),
            .writer = descriptors.Writer.init(allocator),
            .layout = undefined,
        };

        instance.default_pipeline = instance.gpa.allocator().create(mat.MaterialPipeline) catch {
            std.log.err("Failed to allocate memory for MaterialPipeline !", .{});
            @panic("Out Of Memory !");
        };

        return instance;
    }

    pub fn deinit(self: *VoxelMaterial, device: c.VkDevice) void {
        c.vkDestroyPipeline(device, self.default_pipeline.pipeline, null);

        c.vkDestroyPipelineLayout(device, self.default_pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(device, self.layout, null);

        self.mem.deinit();
        self.writer.deinit();
    }

    pub fn write_material(self: *VoxelMaterial, device: c.VkDevice, pass: mat.MaterialPass, ds_alloc: *descriptors.DescriptorAllocator2) mat.MaterialInstance {
        const data = mat.MaterialInstance {
            .pass_type = pass,
            .pipeline = self.default_pipeline,
            .material_set = ds_alloc.allocate(device, self.material_layout, null),
        };

        self.writer.clear();
        // self.writer.write_buffer(0, resources.data_buffer, @sizeOf(MaterialConstants), resources.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        // self.writer.write_image(1, resources.color_image.view, resources.color_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        // self.writer.write_image(2, resources.metal_rough_image.view, resources.metal_rough_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.writer.update_set(device, data.material_set);

        return data;
    }
};

const std = @import("std");
const engine = @import("renderer/engine.zig");
const buffers = @import("renderer/buffers.zig");
const mat = @import("engine/materials.zig");
const descriptors = @import("renderer/descriptor.zig");
const c = @import("clibs.zig");
