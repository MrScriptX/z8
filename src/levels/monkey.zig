// TODO : implement UI to chose which node to display
pub const MonkeyScene = struct {
    arena: std.heap.ArenaAllocator,
    
    model: *gltf.LoadedGLTF,
    global_data: scenes.ShaderData,

    draw_ctx: scenes.DrawContext,

    metallic_roughness: gltf.GLTFMetallic_Roughness,

    pub fn init(allocator: std.mem.Allocator, r: *renderer.renderer_t) !MonkeyScene {
        var scene = MonkeyScene {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .model = undefined,
            .global_data = .{},
            .draw_ctx = undefined,
            .metallic_roughness = gltf.GLTFMetallic_Roughness.init(allocator)
        };

        try scene.metallic_roughness.build_pipeline(allocator, r);

        scene.model = try scene.arena.allocator().create(gltf.LoadedGLTF);
        scene.model.* = try gltf.load_gltf(allocator, "assets/models/basicmesh.glb", &scene.metallic_roughness, r);
        scene.model.deactivate_node("Cube");
        scene.model.deactivate_node("Sphere");

        scene.draw_ctx.global_data = &scene.global_data;
        scene.draw_ctx.opaque_surfaces = std.ArrayList(materials.RenderObject).init(allocator);
        scene.draw_ctx.transparent_surfaces = std.ArrayList(materials.RenderObject).init(allocator);

        return scene;
    }

    pub fn deinit(self: *MonkeyScene, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Wait for device idle failed with error. {d}", .{ result });
        }

        self.metallic_roughness.deinit(r._device);

        self.draw_ctx.deinit();
        
        self.model.deinit(r._device, r._vma);
        self.arena.deinit();
    }

    pub fn update(self: *MonkeyScene, cam: *cameras.camera_t, r: *renderer.renderer_t) void {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        if (self.model.find_node("Suzanne")) |node| {
            const current_transform = za.Mat4.fromSlice(&maths.linearize(node.local_transform));

            const rotation_speed: f32 = 45.0; // Degrees per second
            const rotation_angle = rotation_speed * (r.stats.frame_time / 1_000_000_000.0);
            const rot = za.Mat4.identity().rotate(rotation_angle, za.Vec3.new(0, 1, 0)).mul(current_transform).data;

            node.local_transform = rot;
            node.refresh_transform(&rot);
        }

        cam.update(r.stats.frame_time);
        self.draw(cam, r._draw_extent);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        r.stats.scene_update_time = @floatFromInt(end_time - start_time);
    }

    pub fn draw(self: *MonkeyScene, cam: *const cameras.camera_t, draw_extent: c.VkExtent2D) void {
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

        // fill draw ctx with gltf model
        const top: [4][4]f32 align(16) = za.Mat4.identity().data;
        self.model.draw(top, &self.draw_ctx);
    }
};

const std = @import("std");
const za = @import("zalgebra");
const c = @import("../clibs.zig");
const gltf = @import("../engine/scene/gltf.zig");
const renderer = @import("../engine/renderer.zig");
const scenes = @import("../engine/scene/scene.zig");
const cameras = @import("../engine/scene/camera.zig");
const materials = @import("../engine/graphics/materials.zig");
const maths = @import("../utils/maths.zig");
