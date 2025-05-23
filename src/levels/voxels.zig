const MaterialPipelines = struct {
    default: *chunk.Material,
    polygone: *chunk.Material,
};

const State = struct {
    pipeline: i32 = 0,
    loaded_pipeline: i32 = 0,
};

// TODO : implement UI to chose which node to display
pub const VoxelScene = struct {
    arena: std.heap.ArenaAllocator,

    state: State,

    pipelines: MaterialPipelines,

    // compute shaders
    cl_shader: *chunk.ClassificationShader,
    culling_shader: *chunk.FaceCullingShader,
    shader: *chunk.MeshComputeShader,

    model: chunk.Chunk,
    world: std.ArrayList(*chunk.Chunk),
    global_data: scenes.ShaderData,

    background_ctx: scenes.BackgroundContext,
    draw_ctx: scenes.DrawContext,

    pub fn init(allocator: std.mem.Allocator, r: *renderer.renderer_t) !VoxelScene {
        var scene = VoxelScene {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .pipelines = undefined,
            .cl_shader = undefined,
            .culling_shader = undefined,
            .shader = undefined,
            .model = undefined,
            .global_data = .{},
            .draw_ctx = undefined,
            .background_ctx = undefined,
            .state = .{},
            .world = std.ArrayList(*chunk.Chunk).init(allocator)
        };

        scene.cl_shader = try scene.arena.allocator().create(chunk.ClassificationShader);
        scene.cl_shader.* = chunk.ClassificationShader.init(allocator);
        try scene.cl_shader.build(allocator, "./zig-out/bin/shaders/aurora/cl.comp.spv", r);

        scene.culling_shader = try scene.arena.allocator().create(chunk.FaceCullingShader);
        scene.culling_shader.* = chunk.FaceCullingShader.init(allocator);
        try scene.culling_shader.build(allocator, "./zig-out/bin/shaders/aurora/face_culling.comp.spv", r);

        scene.shader = try scene.arena.allocator().create(chunk.MeshComputeShader);
        scene.shader.* = chunk.MeshComputeShader.init(allocator, "voxel");
        try scene.shader.build(allocator, "./zig-out/bin/shaders/aurora/meshing.comp.spv", r);

        std.log.info("Build voxel default pipeline", .{});

        scene.pipelines.default = try scene.arena.allocator().create(chunk.Material);
        scene.pipelines.default.* = chunk.Material.init(allocator);        
        scene.pipelines.default.build(allocator, c.VK_POLYGON_MODE_FILL, r) catch {
            std.log.err("Failed to build pipeline", .{});
        };

        std.log.info("Build voxel debug pipeline", .{});

        scene.pipelines.polygone = try scene.arena.allocator().create(chunk.Material);
        scene.pipelines.polygone.* = chunk.Material.init(allocator);
        scene.pipelines.polygone.build(allocator, c.VK_POLYGON_MODE_LINE, r) catch {
            std.log.err("Failed to build pipeline", .{});
        };

        for (0..8) |x| {
            for (0..8) |z| {
                const obj = try scene.arena.allocator().create(chunk.Chunk);
                obj.* = chunk.Chunk.init(allocator, .{@intCast(x), 0, @intCast(z)}, scene.culling_shader, scene.cl_shader, scene.shader, scene.pipelines.default, r);
                try scene.world.append(obj);
            }
        }

        r.submit.start_recording(r);
        // scene.model.dispatch(r.submit.cmd);
        for (scene.world.items) |obj| {
            obj.dispatch(r.submit.cmd);
        }
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
        
        // self.model.deinit(r._vma, r);
        for (self.world.items) |obj| {
            obj.deinit(r._vma, r);
        }
        self.world.deinit();

        self.pipelines.default.deinit(r._device);
        self.pipelines.polygone.deinit(r._device);

        self.cl_shader.deinit(r);
        self.culling_shader.deinit(r);
        self.shader.deinit(r);

        self.arena.deinit();
    }

    pub fn update(self: *VoxelScene, allocator: std.mem.Allocator, cam: *cameras.camera_t, r: *renderer.renderer_t) void {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        // check if pipeline changed
        if (self.state.loaded_pipeline != self.state.pipeline) {
            switch (self.state.pipeline) {
                0 => self.set_default_pipeline(allocator, r),
                1 => self.set_debug_pipeline(allocator, r),
                else => std.log.warn("Invalid pipeline value", .{})
            }

            self.state.loaded_pipeline = self.state.pipeline;
        }

        cam.update(r.stats.frame_time);
        self.draw(cam, r._draw_extent);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        r.stats.scene_update_time = @floatFromInt(end_time - start_time);
    }

    pub fn update_ui(self: *VoxelScene) void {
        const result = imgui.Begin("Scene", null, 0);
        if (result) {
            defer imgui.End();

            const pipeline_list = [_][*:0]const u8{ "default", "debug" };
            _ = imgui.ImGui_ComboChar("pipeline", &self.state.pipeline, @ptrCast(&pipeline_list), pipeline_list.len);
        }
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
        // self.model.update(&self.draw_ctx);
        for (self.world.items) |obj| {
            obj.update(&self.draw_ctx);
        }
    }

    pub fn set_debug_pipeline(self: *VoxelScene, allocator: std.mem.Allocator, r: *const renderer.renderer_t) void {
        // self.model.swap_pipeline(allocator, self.pipelines.polygone, r);
        for (self.world.items) |obj| {
            obj.swap_pipeline(allocator, self.pipelines.polygone, r);
        }
    }

    pub fn set_default_pipeline(self: *VoxelScene, allocator: std.mem.Allocator, r: *const renderer.renderer_t) void {
        // self.model.swap_pipeline(allocator, self.pipelines.default, r);
        for (self.world.items) |obj| {
            obj.swap_pipeline(allocator, self.pipelines.default, r);
        }
    }
};

const std = @import("std");
const za = @import("zalgebra");
const imgui = @import("imgui");
const c = @import("../clibs.zig");
const renderer = @import("../engine/renderer.zig");
const scenes = @import("../engine/scene/scene.zig");
const cameras = @import("../engine/scene/camera.zig");
const materials = @import("../engine/graphics/materials.zig");
const maths = @import("../utils/maths.zig");
const chunk = @import("../engine/scene/chunk.zig");
const compute = @import("../engine/graphics/compute.zig");
