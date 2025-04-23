pub const DrawContext = struct {
    opaque_surfaces: std.ArrayList(mat.RenderObject),
    transparent_surfaces: std.ArrayList(mat.RenderObject),

    pub fn init(allocator: std.mem.Allocator) DrawContext {
        const ctx = DrawContext {
            .opaque_surfaces = std.ArrayList(mat.RenderObject).init(allocator),
            .transparent_surfaces = std.ArrayList(mat.RenderObject).init(allocator),
        };

        return ctx;
    }

    pub fn deinit(self: *DrawContext) void {
        self.opaque_surfaces.deinit();
        self.transparent_surfaces.deinit();
    }
};

pub const NodeType = enum {
    BASE_NODE,
    MESH_NODE,
};

pub const Node = struct {
    _type: NodeType = undefined,

    parent: ?*Node = null,
    children: std.ArrayList(*Node),

    local_transform: math.mat4 = std.mem.zeroes(math.mat4),
    world_transform: math.mat4 = std.mem.zeroes(math.mat4),

    mesh: *loader.MeshAsset,

    pub fn init(allocator: std.mem.Allocator) Node {
        const node = Node {
            .children = std.ArrayList(*Node).init(allocator),
            .mesh = undefined,
            ._type = NodeType.BASE_NODE
        };

        return node;
    }

    pub fn deinit(self: *Node) void {
        self.children.deinit();
    }

    pub fn refresh_transform(self: *Node, parent_matrix: *const math.mat4) void {
        self.world_transform = math.mul(parent_matrix.*, self.local_transform);// parent_matrix * self.local_transform;
        for (self.children.items) |child| {
            child.refresh_transform(&self.world_transform);
        }
    }

    pub fn draw(self: *Node, top_matrix: math.mat4, ctx: *DrawContext) void {
        const node_matrix = math.mul(top_matrix, self.world_transform);
        for (self.mesh.surfaces.items) |*surface| {
            const render_object = mat.RenderObject {
                .index_count = surface.count,
                .first_index = surface.startIndex,
                .index_buffer = self.mesh.meshBuffers.index_buffer.buffer,
                .material = &surface.material.data,
                .transform = node_matrix,
                .vertex_buffer_address = self.mesh.meshBuffers.vertex_buffer_address,
            };

            ctx.opaque_surfaces.append(render_object) catch {
                @panic("Failed to append render object ! OOM");
            };
        }

        for (self.children.items) |child| {
            child.draw(top_matrix, ctx);
        }
    }
};

const std = @import("std");
const math = @import("../utils/maths.zig");
const loader = @import("loader.zig");
const mat = @import("material.zig");
const z = @import("zalgebra");
