// TODO : implement UI to chose which node to display
pub const VoxelScene = struct {
    arena: std.heap.ArenaAllocator,
    
    material: *chunk.Material,
    shader: *compute.Shader,
    model: chunk.Voxel,
    global_data: scenes.ShaderData,

    draw_ctx: scenes.DrawContext,

    pub fn init(allocator: std.mem.Allocator, r: *renderer.renderer_t) !VoxelScene {
        var scene = VoxelScene {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .material = undefined,
            .shader = undefined,
            .model = undefined,
            .global_data = .{},
            .draw_ctx = undefined
        };

        scene.shader = try scene.arena.allocator().create(compute.Shader);
        scene.shader.* = compute.Shader.init(allocator, "voxel");
        try scene.shader.build(allocator, "./zig-out/bin/shaders/aurora/cube.comp.spv", r);

        scene.material = try scene.arena.allocator().create(chunk.Material);
        scene.material.* = chunk.Material.init(allocator, r);

        scene.model = chunk.Voxel.init(allocator, r._vma, scene.shader, scene.material, r);

        r.submit.start_recording(r);
        scene.model.dispatch(r.submit.cmd);
        r.submit.submit(r);

        scene.draw_ctx.global_data = &scene.global_data;
        scene.draw_ctx.opaque_surfaces = std.ArrayList(materials.RenderObject).init(allocator);
        scene.draw_ctx.transparent_surfaces = std.ArrayList(materials.RenderObject).init(allocator);

        return scene;
    }

    pub fn deinit(self: *VoxelScene, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Wait for device idle failed with error. {d}", .{ result });
        }

        self.draw_ctx.deinit();
        
        self.model.deinit(r._vma, r);

        self.material.deinit(r._device);
        self.shader.deinit(r);

        self.arena.deinit();
    }

    pub fn update(self: *VoxelScene, cam: *cameras.camera_t, r: *renderer.renderer_t) void {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        cam.update(r.stats.frame_time);
        self.draw(cam, r._draw_extent);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        r.stats.scene_update_time = @floatFromInt(end_time - start_time);
    }

    pub fn draw(self: *VoxelScene, cam: *const cameras.camera_t, draw_extent: c.VkExtent2D) void {
        // reset draw ctx
        // TODO : this should be done by the renderer
        self.draw_ctx.opaque_surfaces.clearRetainingCapacity();
        self.draw_ctx.transparent_surfaces.clearRetainingCapacity();

        // update global data
        const view = cam.view_matrix();
        
        const deg: f32 = 70.0;
        const aspect_ratio: f32 = @as(f32, @floatFromInt(draw_extent.width)) / @as(f32, @floatFromInt(draw_extent.height));
        var proj = za.perspectiveReversedZ(deg, aspect_ratio, 0.1);
        proj.data[1][1] *= -1.0;

        self.global_data.view = view.data;
        self.global_data.proj = proj.data;
        self.global_data.viewproj = za.Mat4.mul(proj, view).data;

        self.draw_ctx.global_data = &self.global_data;

        // fill draw ctx
        self.model.update(&self.draw_ctx);
    }
};

const std = @import("std");
const za = @import("zalgebra");
const c = @import("../clibs.zig");
const renderer = @import("../engine/renderer.zig");
const scenes = @import("../engine/scene/scene.zig");
const cameras = @import("../engine/scene/camera.zig");
const materials = @import("../engine/graphics/materials.zig");
const maths = @import("../utils/maths.zig");
const chunk = @import("../engine/scene/chunk.zig");
const compute = @import("../engine/graphics/compute.zig");
