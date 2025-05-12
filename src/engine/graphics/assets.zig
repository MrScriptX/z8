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
    active: bool = true,

    parent: ?*Node = null,
    children: std.ArrayList(*Node),

    local_transform: math.mat4 = z.Mat4.identity().data,
    world_transform: math.mat4 = z.Mat4.identity().data,

    mesh: *MeshAsset,

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
        if (!self.active) {
            return;
        }

        if (self._type == NodeType.MESH_NODE) {
            const node_matrix = math.mul(top_matrix, self.world_transform);
            for (self.mesh.surfaces.items) |*surface| {
                const render_object = mat.RenderObject {
                    .index_count = surface.count,
                    .first_index = surface.startIndex,
                    .index_buffer = self.mesh.mesh_buffers.index_buffer.buffer,
                    .material = surface.material,
                    .transform = node_matrix,
                    .vertex_buffer_address = self.mesh.mesh_buffers.vertex_buffer_address,
                };

                if (surface.material.pass_type == mat.MaterialPass.Transparent) {
                    ctx.transparent_surfaces.append(render_object) catch @panic("Failed to append render object ! OOM !");
                }
                else {
                    ctx.opaque_surfaces.append(render_object) catch @panic("Failed to append render object ! OOM");
                }
            }
        }

        for (self.children.items) |child| {
            child.draw(top_matrix, ctx);
        }
    }

    pub fn find(self: * Node, name: []const u8) ?*Node {
        if (std.mem.eql(u8, self.mesh.name, name)) {
            return self;
        }

        for (self.children.items) |child| {
            const node = child.find(name);
            if (node) |n| {
                return n;
            }
        }

        return null;
    }
};

pub const GeoSurface = struct {
    startIndex: u32,
    count: u32,
    material: *mat.MaterialInstance = undefined,
};

pub const MeshAsset = struct {
    arena: std.heap.ArenaAllocator,
    
    name: []const u8,

    surfaces: std.ArrayList(GeoSurface),
    mesh_buffers: buffers.GPUMeshBuffers,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) MeshAsset {
        var asset = MeshAsset {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .name = undefined,
            .surfaces = std.ArrayList(GeoSurface).init(allocator),
            .mesh_buffers = undefined,
        };

        asset.name = asset.arena.allocator().dupe(u8, name) catch @panic("OOM");

        return asset;
    }

    pub fn deinit(self: *MeshAsset) void {
        self.surfaces.deinit();
        self.arena.deinit();
    }
};

const std = @import("std");
const math = @import("../../utils/maths.zig");
const mat = @import("materials.zig");
const z = @import("zalgebra");
const buffers = @import("buffers.zig");
