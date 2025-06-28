const MaterialPipelines = struct {
    default: *chunk.Material,
    normals: *chunk.Material,
    water: *chunk.Material,
    polygone: *chunk.Material,
};

const State = struct {
    pipeline: i32 = 0,

    seed: u32 = 0, // world seed
    radius: u8 = 10,
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

    world: std.ArrayList(Chunk),
    deletion_queue: std.ArrayList(Chunk), // use as a garbage collector
    global_data: scenes.ShaderData,

    background_ctx: scenes.BackgroundContext,
    draw_ctx: scenes.DrawContext,

    // task_manager: *tasks.TaskManager,

    const Chunk = struct {
        ptr: *chunk.Chunk,
        update: bool = false,
        pos: @Vector(3, i32)
    };

    pub fn init(allocator: std.mem.Allocator, r: *renderer.renderer_t) !VoxelScene {
        var prng = std.Random.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        const rand = prng.random();
        
        var scene = VoxelScene {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .pipelines = undefined,
            .cl_shader = undefined,
            .culling_shader = undefined,
            .shader = undefined,
            .global_data = .{},
            .draw_ctx = undefined,
            .background_ctx = undefined,
            .state = .{
                .seed = rand.int(u32)
            },
            .world = std.ArrayList(Chunk).init(allocator),
            .deletion_queue = std.ArrayList(Chunk).init(allocator),
        };

        scene.cl_shader = try scene.arena.allocator().create(chunk.ClassificationShader);
        scene.cl_shader.* = chunk.ClassificationShader.init(allocator);
        try scene.cl_shader.build(allocator, "./zig-out/bin/shaders/aurora/world.comp.spv", r);

        scene.culling_shader = try scene.arena.allocator().create(chunk.FaceCullingShader);
        scene.culling_shader.* = chunk.FaceCullingShader.init(allocator);
        try scene.culling_shader.build(allocator, "./zig-out/bin/shaders/aurora/face_culling.comp.spv", r);

        scene.shader = try scene.arena.allocator().create(chunk.MeshComputeShader);
        scene.shader.* = chunk.MeshComputeShader.init(allocator, "voxel");
        try scene.shader.build(allocator, "./zig-out/bin/shaders/aurora/meshing2.comp.spv", r);

        std.log.info("Build voxel default pipeline", .{});

        scene.pipelines.default = try scene.arena.allocator().create(chunk.Material);
        scene.pipelines.default.* = chunk.Material.init(allocator);        
        scene.pipelines.default.build(allocator, "./zig-out/bin/shaders/aurora/block.vert.spv", "./zig-out/bin/shaders/aurora/block.frag.spv", c.VK_POLYGON_MODE_FILL, false, r) catch {
            std.log.err("Failed to build pipeline", .{});
        };

        std.log.info("Build voxel normals debug pipeline", .{});

        scene.pipelines.normals = try scene.arena.allocator().create(chunk.Material);
        scene.pipelines.normals.* = chunk.Material.init(allocator);        
        scene.pipelines.normals.build(allocator, "./zig-out/bin/shaders/aurora/cube.vert.spv", "./zig-out/bin/shaders/aurora/cube.frag.spv", c.VK_POLYGON_MODE_FILL, false, r) catch {
            std.log.err("Failed to build pipeline", .{});
        };

        std.log.info("Build voxel water pipeline", .{});

        scene.pipelines.water = try scene.arena.allocator().create(chunk.Material);
        scene.pipelines.water.* = chunk.Material.init(allocator);        
        scene.pipelines.water.build(allocator, "./zig-out/bin/shaders/aurora/water.vert.spv", "./zig-out/bin/shaders/aurora/water.frag.spv", c.VK_POLYGON_MODE_FILL, true, r) catch {
            std.log.err("Failed to build pipeline", .{});
        };

        std.log.info("Build voxel debug pipeline", .{});

        scene.pipelines.polygone = try scene.arena.allocator().create(chunk.Material);
        scene.pipelines.polygone.* = chunk.Material.init(allocator);
        scene.pipelines.polygone.build(allocator, "./zig-out/bin/shaders/aurora/cube.vert.spv", "./zig-out/bin/shaders/aurora/cube.frag.spv", c.VK_POLYGON_MODE_LINE, false, r) catch {
            std.log.err("Failed to build pipeline", .{});
        };

        // TODO : sky box should be handled from the scene

        scene.draw_ctx.global_data = &scene.global_data;
        scene.draw_ctx.opaque_surfaces = std.ArrayList(materials.RenderObject).init(allocator);
        scene.draw_ctx.transparent_surfaces = std.ArrayList(materials.RenderObject).init(allocator);

        scene.build_world();

        return scene;
    }

    pub fn deinit(self: *VoxelScene, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Wait for device idle failed with error. {d}", .{ result });
        }

        // self.task_manager.stop();
        // self.task_manager.deinit();

        self.draw_ctx.deinit();
        
        for (self.deletion_queue.items) |*it| {
            if (it.ptr.ready.load(std.builtin.AtomicOrder.acquire)) {
                it.ptr.deinit(r._vma, r);
            }
        }
        self.deletion_queue.deinit();

        for (self.world.items) |*it| {
            if (it.ptr.ready.load(std.builtin.AtomicOrder.acquire)) {
                it.ptr.deinit(r._vma, r);
            }
        }
        self.world.deinit();

        self.pipelines.default.deinit(r._device);
        self.pipelines.normals.deinit(r._device);
        self.pipelines.water.deinit(r._device);
        self.pipelines.polygone.deinit(r._device);

        self.cl_shader.deinit(r);
        self.culling_shader.deinit(r);
        self.shader.deinit(r);

        self.arena.deinit();
    }

    pub fn build_world(self: *VoxelScene) void {
        std.log.info("Intializing world. seed {d}, radius {d}", .{ self.state.seed, self.state.radius });

        for (0..self.state.radius) |x| {
            for (0..self.state.radius) |z| {
                const ptr = self.arena.allocator().create(chunk.Chunk) catch {
                    std.log.err("Failed to allocate memory for chunk", .{});
                    @panic("Out of memory !");
                };

                const it = Chunk {
                    .ptr = ptr,
                    .pos = .{ @intCast(x), 0, @intCast(z) }
                };

                self.world.append(it) catch @panic("Out of memory !");
            }
        }
    }

    pub fn clear(self: *VoxelScene, r: *const renderer.renderer_t) void {
        std.log.info("Clearing world", .{});

        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device {d}", .{result});
        }

        for (self.world.items) |it| {
            self.deletion_queue.append(it) catch @panic("OOM");
        }
        self.world.clearRetainingCapacity();
    }

    pub fn update(self: *VoxelScene, allocator: std.mem.Allocator, cam: *cameras.camera_t, r: *renderer.renderer_t) void {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        const to_delete = self.deletion_queue.pop();
        if (to_delete) |*it| {
            if (it.ptr.ready.load(std.builtin.AtomicOrder.acquire)) {
                it.ptr.deinit(r._vma, r);
            }
        }

        for (self.world.items) |*it| {
            if (!it.update) {
                it.update = true; // mark as queued for update (for later use)

                // TODO : enqueue Task in TaskManager and remove the break;
                it.ptr.* = chunk.Chunk.init(allocator, it.pos, self.state.seed, self.culling_shader, self.cl_shader, self.shader, self.pipelines.default, self.pipelines.water, r);
                
                r.submit.start_recording(r);
                it.ptr.dispatch(r.submit.cmd);
                r.submit.submit(r);

                it.ptr.ready.store(true, std.builtin.AtomicOrder.seq_cst);

                break; // only build one at the time for latency

                // const ctx = allocator.create(Ctx) catch {
                //     std.log.warn("Failed to allocate memory for chunk context", .{});
                //     it.update = false;
                //     continue;
                // };
                // ctx.* = .{
                //     .it = it,
                //     .r = r,
                //     .allocator = allocator,
                //     .self = self
                // };
                // r.compute_queue.enqueue(&build_chunk, &on_build_success, @ptrCast(ctx)) catch {
                //     std.log.warn("Queuing chunk for build failed", .{});
                //     it.update = false;
                //     continue;
                // };
            }
        }

        cam.update(r.stats.frame_time);
        self.draw(cam, r._draw_extent, r.stats.frame_time / 1_000_000_000.0);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        r.stats.scene_update_time = @floatFromInt(end_time - start_time);
    }

    const Ctx = struct {
        it: *Chunk,
        r: *renderer.renderer_t,
        allocator: std.mem.Allocator,
        self: *VoxelScene
    };

    pub fn build_chunk(ctx: *anyopaque, cmd: c.VkCommandBuffer) void {
        const unwrap: *Ctx = @alignCast(@ptrCast(ctx));
        var it = unwrap.it;
        const r = unwrap.r;
        const allocator = unwrap.allocator;
        const self = unwrap.self;

        std.log.info("Creating chunk {any}", .{ it.pos });

        it.ptr.* = chunk.Chunk.init(allocator, it.pos, self.state.seed, self.culling_shader, self.cl_shader, self.shader, self.pipelines.default, r);
        it.ptr.dispatch(cmd);
    }

    pub fn on_build_success(ctx: *anyopaque) void {
        const unwrap: *Ctx = @alignCast(@ptrCast(ctx));
        var it = unwrap.it;
        const allocator = unwrap.allocator;

        it.ptr.ready.store(true, std.builtin.AtomicOrder.seq_cst);
        allocator.destroy(unwrap);
    }

    pub fn update_ui(self: *VoxelScene, allocator: std.mem.Allocator, r: *const renderer.renderer_t) void {
        const result = imgui.Begin("Scene", null, 0);
        if (result) {
            defer imgui.End();

            
            if (imgui.InputU32("seed", &self.state.seed)) {
                self.clear(r);
                self.build_world();
            }

            if (imgui.ImGui_Button("random seed")) {
                var prng = std.Random.DefaultPrng.init(blk: {
                    var seed: u64 = undefined;
                    std.posix.getrandom(std.mem.asBytes(&seed)) catch {
                        std.log.warn("Failed to get a random number seed", .{});
                        seed = 751468464;
                    };
                    break :blk seed;
                });
                const rand = prng.random();

                self.state.seed = rand.int(u32);
                std.log.info("New random seed {d}", .{ self.state.seed });

                self.clear(r);
                self.build_world();
            }

            const pipeline_list = [_][*:0]const u8{ "default", "debug", "normals" };
            if (imgui.ImGui_ComboChar("pipeline", &self.state.pipeline, @ptrCast(&pipeline_list), pipeline_list.len)) {
                switch (self.state.pipeline) {
                    0 => self.set_default_pipeline(allocator, r),
                    1 => self.set_debug_pipeline(allocator, r),
                    2 => self.set_debug_normals_pipeline(allocator, r),
                    else => std.log.warn("Invalid pipeline value", .{})
                }
            }
            
            if (imgui.ImGui_ColorEdit4("sun color", &self.global_data.sunlight_color, 0)) {
                std.log.debug("update sun color {any}", self.global_data.sunlight_color);
            }

            if (imgui.ImGui_ColorEdit4("ambient color", &self.global_data.ambient_color, 0)) {
                std.log.debug("update ambient color {any}", self.global_data.sunlight_color);
            }

            if (imgui.ImGui_SliderFloat3("sun dir", &self.global_data.sunlight_dir, -1, 1)) {
                std.log.debug("update sun direction {any}", self.global_data.sunlight_color);
            }
        }
    }

    pub fn draw(self: *VoxelScene, cam: *const cameras.camera_t, draw_extent: c.VkExtent2D, delta_time: f32) void {
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
        self.global_data.time += delta_time;
        self.global_data.time = @mod(self.global_data.time, 120);

        self.draw_ctx.global_data = &self.global_data;

        // fill draw ctx
        for (self.world.items) |*it| {
            if (it.ptr.ready.load(std.builtin.AtomicOrder.seq_cst)) {
                it.ptr.update(&self.draw_ctx);
            }
        }
    }

    pub fn set_debug_pipeline(self: *VoxelScene, allocator: std.mem.Allocator, r: *const renderer.renderer_t) void {
        for (self.world.items) |it| {
            it.ptr.swap_pipeline(allocator, self.pipelines.polygone, r);
        }
    }

    pub fn set_default_pipeline(self: *VoxelScene, allocator: std.mem.Allocator, r: *const renderer.renderer_t) void {
        for (self.world.items) |it| {
            it.ptr.swap_pipeline(allocator, self.pipelines.default, r);
        }
    }

    pub fn set_debug_normals_pipeline(self: *VoxelScene, allocator: std.mem.Allocator, r: *const renderer.renderer_t) void {
        for (self.world.items) |it| {
            it.ptr.swap_pipeline(allocator, self.pipelines.normals, r);
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
const tasks = @import("../tasks.zig");
