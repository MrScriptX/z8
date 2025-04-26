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

const std = @import("std");
const engine = @import("renderer/engine.zig");
const buffers = @import("renderer/buffers.zig");
const mat = @import("renderer/material.zig");
const c = @import("clibs.zig");
