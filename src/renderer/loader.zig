const std = @import("std");
const c = @import("../clibs.zig");
const buffers = @import("buffers.zig");
const log = @import("../utils/log.zig");

pub const GeoSurface = struct {
    startIndex: u32,
    count: u32,
};

pub const MeshAsset = struct {
    name: []const u8,

    surfaces: std.ArrayList(GeoSurface),
    meshBuffers: buffers.GPUMeshBuffers,
};

pub fn load_gltf_meshes(allocator: std.mem.Allocator, path: []const u8, vma: c.VmaAllocator, device: c.VkDevice, fence: *c.VkFence, queue: c.VkQueue,cmd: c.VkCommandBuffer) ![]MeshAsset {
    var options = std.mem.zeroes(c.cgltf_options);
    var data: *c.cgltf_data = undefined;
    const result = c.cgltf_parse_file(&options, path.ptr, @ptrCast(&data));
    if (result != c.cgltf_result_success) {
        std.debug.panic("Failed to parse gltf file", .{});
    }
    defer c.cgltf_free(data);

    const success = c.cgltf_load_buffers(&options, data, path.ptr);
    if (success != c.cgltf_result_success) {
        std.debug.panic("Failed to load buffers!\n", .{});
    }

    var vertices = std.ArrayList(buffers.Vertex).init(allocator);
    // defer vertices.deinit();

    var indices = std.ArrayList(u32).init(allocator);
    // defer indices.deinit();
        
    var meshes = std.ArrayList(MeshAsset).init(allocator);
    // defer meshes.deinit();

    for (data.meshes[0..data.meshes_count]) |mesh| {
        var asset = MeshAsset {
            .name = std.mem.span(mesh.name),
            .surfaces = std.ArrayList(GeoSurface).init(allocator),
            .meshBuffers = undefined,
        };

        vertices.clearAndFree();
        indices.clearAndFree();

        for (mesh.primitives[0..mesh.primitives_count]) |prim| {
            const indices_count: usize = prim.indices.*.count;

            const surface = GeoSurface {
                .startIndex = @intCast(indices.items.len),
                .count = @intCast(indices_count),
            };

            try indices.ensureTotalCapacity(indices.items.len + indices_count);

            // load indexes
            const offset: u32 = @intCast(vertices.items.len);
            for (0..indices_count) |i| {
                const idx: u32 = @intCast(c.cgltf_accessor_read_index(prim.indices, @intCast(i)));
                try indices.append(idx + offset);
            }

            // load vertex positions
            var pos_accessor: *c.cgltf_accessor = undefined;
            var normal_accessor: *c.cgltf_accessor = undefined;
            var uv_accessor: *c.cgltf_accessor = undefined;
            var color_accessor: ?*c.cgltf_accessor = null;
            for (prim.attributes[0..prim.attributes_count]) |att| {
                if (att.type == c.cgltf_attribute_type_position) {
                    pos_accessor = att.data;
                    continue;
                }

                if (att.type == c.cgltf_attribute_type_normal) {
                    normal_accessor = att.data;
                    continue;
                }

                if (att.type == c.cgltf_attribute_type_texcoord) {
                    uv_accessor = att.data;
                    continue;
                }

                if (att.type == c.cgltf_attribute_type_color) {
                    color_accessor = att.data;
                    continue;
                }
            }

            const count = pos_accessor.count;
            try vertices.ensureTotalCapacity(vertices.items.len + count);

            for (0..count) |i| {
                var v: buffers.Vertex = buffers.Vertex {
                    .position = std.mem.zeroes(c.vec3),
                    .normal = std.mem.zeroes(c.vec3),
                    .color = std.mem.zeroes(c.vec4),
                    .uv_x = 0,
                    .uv_y = 0
                };

                var pos: [3]c.cgltf_float = undefined;
                _ = c.cgltf_accessor_read_float(pos_accessor, i, &pos, 3);

                v.position[0] = pos[0];
                v.position[1] = pos[1];
                v.position[2] = pos[2];

                var normal: [3]c.cgltf_float = undefined;
                _ = c.cgltf_accessor_read_float(normal_accessor, i, &normal, 3);

                v.normal[0] = normal[0];
                v.normal[1] = normal[1];
                v.normal[2] = normal[2];

                if (color_accessor != null) {
                    var color: [4]c.cgltf_float = undefined;
                    _ = c.cgltf_accessor_read_float(color_accessor, i, &color, 4);

                    v.color[0] = color[0];
                    v.color[1] = color[1];
                    v.color[2] = color[2];
                    v.color[3] = color[3];
                }
                

                var uv: [2]c.cgltf_float = undefined;
                _ = c.cgltf_accessor_read_float(uv_accessor, i, &uv, 2);

                v.uv_x = uv[0];
                v.uv_y = uv[1];

                try vertices.append(v);
            }

            try asset.surfaces.append(surface);
        }

        asset.meshBuffers = buffers.GPUMeshBuffers.init(vma, device, fence, queue, indices.items, vertices.items, cmd);
        try meshes.append(asset);
    }

    return meshes.items;
}
