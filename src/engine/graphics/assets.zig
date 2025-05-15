pub const DrawContext = struct {
    opaque_surfaces: std.ArrayList(materials.RenderObject),
    transparent_surfaces: std.ArrayList(materials.RenderObject),

    pub fn init(allocator: std.mem.Allocator) DrawContext {
        const ctx = DrawContext {
            .opaque_surfaces = std.ArrayList(materials.RenderObject).init(allocator),
            .transparent_surfaces = std.ArrayList(materials.RenderObject).init(allocator),
        };

        return ctx;
    }

    pub fn deinit(self: *DrawContext) void {
        self.opaque_surfaces.deinit();
        self.transparent_surfaces.deinit();
    }

    pub fn draw(self: *DrawContext, cmd: c.VkCommandBuffer, global_descriptor: c.VkDescriptorSet, extent: c.VkExtent2D, stats: *renderer.stats_t) void {
        //set dynamic viewport and scissor
	    const viewport = c.VkViewport {
            .x = 0,
	        .y = 0,
	        .width = @floatFromInt(extent.width),
	        .height = @floatFromInt(extent.height),
	        .minDepth = 0.0,
	        .maxDepth = 1.0,
        };

	    const scissor = c.VkRect2D {
            .offset = .{ .x = 0, .y = 0 },
	        .extent = extent,
        };
        
        var last_pipeline: ?*materials.MaterialPipeline = null;
        var last_material: ?*materials.MaterialInstance = null;
        var last_index_buffer: c.VkBuffer = null;

        for (self.opaque_surfaces.items) |*obj| {
            if (last_material != obj.material) {
                last_material = obj.material;

                if (last_pipeline != obj.material.pipeline) {
                    last_pipeline = obj.material.pipeline;

                    c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.pipeline);
                    c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.layout, 0, 1, &global_descriptor, 0, null);

                    c.vkCmdSetViewport(cmd, 0, 1, &viewport);
                    c.vkCmdSetScissor(cmd, 0, 1, &scissor);
                }

                c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.layout, 1, 1, &obj.material.material_set, 0, null);
            }

            if (last_index_buffer != obj.index_buffer) {
                last_index_buffer = obj.index_buffer;

                c.vkCmdBindIndexBuffer(cmd, obj.index_buffer, 0, c.VK_INDEX_TYPE_UINT32);
            }

            const push_constants_mesh = buffers.GPUDrawPushConstants {
                .world_matrix = obj.transform,
                .vertex_buffer = obj.vertex_buffer_address,
            };

            c.vkCmdPushConstants(cmd, obj.material.pipeline.layout, c.VK_SHADER_STAGE_VERTEX_BIT, 0, @sizeOf(buffers.GPUDrawPushConstants), &push_constants_mesh);

            c.vkCmdDrawIndexed(cmd, obj.index_count, 1, obj.first_index, 0, 0);

            stats.drawcall_count += 1;
            stats.triangle_count += obj.index_count / 3;
        }

        for (self.transparent_surfaces.items) |*obj| {
            if (last_material != obj.material) {
                last_material = obj.material;

                if (last_pipeline != obj.material.pipeline) {
                    last_pipeline = obj.material.pipeline;

                    c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.pipeline);
                    c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.layout, 0, 1, &global_descriptor, 0, null);

                    c.vkCmdSetViewport(cmd, 0, 1, &viewport);
                    c.vkCmdSetScissor(cmd, 0, 1, &scissor);
                }

                c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.layout, 1, 1, &obj.material.material_set, 0, null);
            }

            if (last_index_buffer != obj.index_buffer) {
                last_index_buffer = obj.index_buffer;
                
                c.vkCmdBindIndexBuffer(cmd, obj.index_buffer, 0, c.VK_INDEX_TYPE_UINT32);
            }

            const push_constants_mesh = buffers.GPUDrawPushConstants {
                .world_matrix = obj.transform,
                .vertex_buffer = obj.vertex_buffer_address,
            };

            c.vkCmdPushConstants(cmd, obj.material.pipeline.layout, c.VK_SHADER_STAGE_VERTEX_BIT, 0, @sizeOf(buffers.GPUDrawPushConstants), &push_constants_mesh);

            c.vkCmdDrawIndexed(cmd, obj.index_count, 1, obj.first_index, 0, 0);

            stats.drawcall_count += 1;
            stats.triangle_count += obj.index_count / 3;
        }
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
                const render_object = materials.RenderObject {
                    .index_count = surface.count,
                    .first_index = surface.startIndex,
                    .index_buffer = self.mesh.mesh_buffers.index_buffer.buffer,
                    .material = surface.material,
                    .transform = node_matrix,
                    .vertex_buffer_address = self.mesh.mesh_buffers.vertex_buffer_address,
                };

                if (surface.material.pass_type == materials.MaterialPass.Transparent) {
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
    material: *materials.MaterialInstance = undefined,
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
const materials = @import("materials.zig");
const z = @import("zalgebra");
const buffers = @import("buffers.zig");
const c = @import("../../clibs.zig");
const renderer = @import("../renderer.zig");
