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
    draw_context: mesh.DrawContext,
    
    gltf: ?*gltf.LoadedGLTF = null,
    path: ?[]const u8 = null,
    
    voxel: ?vox.Voxel = null,

    pub fn init(alloc: std.mem.Allocator, t: type_e) scene_t {
        const scene = scene_t {
            .mem = std.heap.ArenaAllocator.init(alloc),
            .draw_context = mesh.DrawContext.init(alloc),
            ._type = t,
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

    pub fn load(self: *scene_t, alloc: std.mem.Allocator, file: []const u8, r: *renderer.renderer_t) !void {
        self.gltf = try self.allocator().create(gltf.LoadedGLTF);
        self.gltf.?.* = try gltf.load_gltf(alloc, file, r);
    }

    pub fn create_mesh(self: *scene_t, alloc: std.mem.Allocator, material: *vox.VoxelMaterial, r: *renderer.renderer_t) !void {
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
        self.data.ambient_color = [4]f32 { 0.1, 0.1, 0.1, 0.1 };
        self.data.sunlight_color = [4]f32 { 1, 1, 1, 1 };
        self.data.sunlight_dir = [4]f32 { 0, 1, 0.5, 1 };

        self.draw_context.opaque_surfaces.clearRetainingCapacity();
        self.draw_context.transparent_surfaces.clearRetainingCapacity();

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
        for (self.scenes.items) |*scene| {
            scene.deinit(device, vma);
        }

        self.scenes.deinit();
    }

    pub fn create_scene(self: *manager_t, alloc: std.mem.Allocator, t: type_e) *scene_t {
        const scene = scene_t.init(alloc, t);
        self.scenes.append(scene);

        return &self.scenes.getLast();
    }

    // pub fn update(self: *manager_t, alloc: std.mem.Allocator) void {
    //     if (self.render_scene != self.current_scene) {
    //         for (self.scenes.items, 0..) |*scene, i| {
    //             if (i == self.current_scene) {
    //                 scene.load(alloc, "", device: c.VkDevice, fence: *c.VkFence, queue: c.VkQueue, cmd: c.VkCommandBuffer, vma: c.VmaAllocator, r: *renderer.renderer_t)
    //             }
    //         }
    //     }
    // }
};

const std = @import("std");
const za = @import("zalgebra");
const camera = @import("camera.zig");
const c = @import("../clibs.zig");
const mesh = @import("../renderer/assets.zig");
const gltf = @import("../renderer/gltf.zig");
const renderer = @import("../renderer/engine.zig");
const vox = @import("../voxel.zig");
const mat = @import("materials.zig");
