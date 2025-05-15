pub const ShaderData = struct {
    view: [4][4]f32 align(16),
    proj: [4][4]f32 align(16),
    viewproj: [4][4]f32 align(16),
    ambient_color: [4]f32 align(4),
    sunlight_dir: [4]f32 align(4),
    sunlight_color: [4]f32 align(4)
};

pub const type_e = enum {
    GLTF,
    MESH,
};

pub const scene_t = struct {
    mem: std.heap.ArenaAllocator,
    _type: type_e,

    data: ShaderData = undefined,
    draw_context: DrawContext,
    
    gltf: ?*gltf.LoadedGLTF = null,    
    voxel: ?vox.Voxel = null,

    pub fn init(alloc: std.mem.Allocator, t: type_e) scene_t {
        const scene = scene_t {
            .mem = std.heap.ArenaAllocator.init(alloc),
            .draw_context = DrawContext.init(alloc),
            ._type = t,
            .data = .{
                .view = za.Mat4.identity().data,
                .proj = za.Mat4.identity().data,
                .viewproj = za.Mat4.identity().data,
                .ambient_color = [4]f32 { 0.1, 0.1, 0.1, 0.1 },
                .sunlight_color = [4]f32 { 1, 1, 1, 1 },
                .sunlight_dir = [4]f32 { 0, 1, 0.5, 1 },
            }
        };

        return scene;
    }

    pub fn deinit(self: *scene_t, device: c.VkDevice, vma: c.VmaAllocator) void {
        self.clear(device, vma);

        self.draw_context.deinit();
        self.mem.deinit();
    }

    pub fn clear(self: *scene_t, device: c.VkDevice, vma: c.VmaAllocator) void {
        const result = c.vkDeviceWaitIdle(device);
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to wait for device idle ! Reason {d}.", .{ result });
        }

        if (self.gltf) |obj| {
            obj.deinit(device, vma);
            self.allocator().destroy(obj);
        }

        self.gltf = null;

        self.draw_context.opaque_surfaces.clearAndFree();
        self.draw_context.transparent_surfaces.clearAndFree();

        if (self.voxel) |*voxel| {
            voxel.deinit(vma);
        }

        self.voxel = null;
    }

    pub fn load_gltf(self: *scene_t, alloc: std.mem.Allocator, file: []const u8, r: *renderer.renderer_t) !void {
        self.gltf = try self.allocator().create(gltf.LoadedGLTF);
        self.gltf.?.* = try gltf.load_gltf(alloc, file, r);
    }

    pub fn load_mesh(self: *scene_t, alloc: std.mem.Allocator, material: *vox.VoxelMaterial, r: *renderer.renderer_t) !void {
        self.voxel = try vox.Voxel.init(alloc, material, r);
    }

    pub fn update(self: *scene_t, cam: *const camera.camera_t, extent: c.VkExtent2D) void {
        const view = cam.view_matrix();
        
        const deg: f32 = 70.0;
        var proj = za.perspectiveReversedZ(deg, @as(f32, @floatFromInt(extent.width)) / @as(f32, @floatFromInt(extent.height)), 0.1);
        proj.data[1][1] *= -1.0;

        self.data.view = view.data;
        self.data.proj = proj.data;
        self.data.viewproj = za.Mat4.mul(proj, view).data;

        self.draw_context.opaque_surfaces.clearRetainingCapacity();
        self.draw_context.transparent_surfaces.clearRetainingCapacity();

        self.draw_context.global_data = &self.data;

        switch (self._type) {
            type_e.GLTF => {
                self.update_gltf();
            },
            type_e.MESH => {
                self.update_mesh();
            }
        }
    }

    pub fn update_gltf(self: *scene_t) void {
        const top: [4][4]f32 align(16) = za.Mat4.identity().data;
        if (self.gltf) |obj| {
            obj.draw(top, &self.draw_context);
        }
    }

    pub fn update_mesh(self: *scene_t) void {
        if (self.voxel) |*voxel| {
            for (voxel.meshes.surfaces.items) |*surface| {
                const render_object = mat.RenderObject {
                    .index_count = surface.count,
                    .first_index = surface.startIndex,
                    .index_buffer = voxel.meshes.mesh_buffers.index_buffer.buffer,
                    .material = surface.material,
                    .transform = za.Mat4.identity().data,
                    .vertex_buffer_address = voxel.meshes.mesh_buffers.vertex_buffer_address,
                };

                self.draw_context.opaque_surfaces.append(render_object) catch @panic("OOM");
            }
        }
    }

    pub fn find_node(self: *scene_t, name: []const u8) ?*mesh.Node {
        if (self.gltf) |obj| {
            for (obj.top_nodes.items) |root| {
                const node = root.find(name);
                if (node) |n| {
                    return n;
                }
            }
        }

        return null;
    }

    pub fn deactivate_node(self: *scene_t, name: []const u8) void {
        if (self.gltf) |obj| {
            for (obj.top_nodes.items) |root| {
                const node = root.find(name);
                if (node) |n| {
                    n.active = false;
                    break;
                }
            }
        }
    }

    fn allocator(self: *scene_t) std.mem.Allocator {
        return self.mem.allocator();
    }
};

pub const manager_t = struct {
    scenes: std.ArrayList(scene_t),

    render_scene: i32 = -1,
    current_scene: i32 = -1,

    pub fn init(alloc: std.mem.Allocator) manager_t {
        const manager = manager_t {
            .scenes = std.ArrayList(scene_t).init(alloc)
        };

        return manager;
    }

    pub fn deinit(self: *manager_t, device: c.VkDevice, vma: c.VmaAllocator) void {
        for (self.scenes.items) |*s| {
            s.deinit(device, vma);
        }

        self.scenes.deinit();
    }

    pub fn create_scene(self: *manager_t, alloc: std.mem.Allocator, t: type_e) *const scene_t {
        const s = scene_t.init(alloc, t);
        self.scenes.append(s) catch @panic("Out of memory");

        return &self.scenes.getLast();
    }

    pub fn scene(self: *manager_t, index: usize) ?*scene_t {
        for (self.scenes.items, 0..) |*s, i| {
            if (i == index) return s;
        }

        return null;
    }
};

pub const DrawContext = struct {
    global_data: *ShaderData,
    opaque_surfaces: std.ArrayList(materials.RenderObject),
    transparent_surfaces: std.ArrayList(materials.RenderObject),

    pub fn init(allocator: std.mem.Allocator) DrawContext {
        const ctx = DrawContext {
            .global_data = undefined, // TODO : should not even be a pointer
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

const std = @import("std");
const za = @import("zalgebra");
const camera = @import("camera.zig");
const c = @import("../../clibs.zig");
const mesh = @import("../graphics/assets.zig");
const gltf = @import("gltf.zig");
const renderer = @import("../renderer.zig");
const vox = @import("../../voxel.zig");
const mat = @import("../graphics/materials.zig"); // TODO : use only one import
const materials = @import("../graphics/materials.zig");
const buffers = @import("../graphics/buffers.zig");
const descriptors = @import("../descriptor.zig");
