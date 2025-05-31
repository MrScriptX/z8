const MaterialPipelines = struct {
    default: *chunk.Material,
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
        try scene.cl_shader.build(allocator, "./zig-out/bin/shaders/aurora/cl.comp.spv", r);

        scene.culling_shader = try scene.arena.allocator().create(chunk.FaceCullingShader);
        scene.culling_shader.* = chunk.FaceCullingShader.init(allocator);
        try scene.culling_shader.build(allocator, "./zig-out/bin/shaders/aurora/face_culling.comp.spv", r);

        scene.shader = try scene.arena.allocator().create(chunk.MeshComputeShader);
        scene.shader.* = chunk.MeshComputeShader.init(allocator, "voxel");
        try scene.shader.build(allocator, "./zig-out/bin/shaders/aurora/meshing2.comp.spv", r);

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

        // TODO : sky box should be handled from the scene
        // var sky_shader = compute.ComputeEffect {
        //     .name = "sky",
        //     .data = .{
        //         .data1 = c.vec4{ 0.1, 0.2, 0.4 , 0.97 },
	    //         .data2 = c.glms_vec4_zero().raw,
        //         .data3 = c.glms_vec4_zero().raw,
        //         .data4 = c.glms_vec4_zero().raw 
        //     },
        // };
        // sky_shader.build(allocator, "./zig-out/bin/shaders/vkguide/sky.spv", r) catch {
        //     std.log.err("Failed to create sky shader", .{});
        //     @panic("Failed to build the sky box");
        // };

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
                it.ptr.* = chunk.Chunk.init(allocator, it.pos, self.state.seed, self.culling_shader, self.cl_shader, self.shader, self.pipelines.default, r);
                
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
        self.draw(cam, r._draw_extent);

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

            if (imgui.InputUint("seed", &self.state.seed)) {
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

            const pipeline_list = [_][*:0]const u8{ "default", "debug" };
            if (imgui.ImGui_ComboChar("pipeline", &self.state.pipeline, @ptrCast(&pipeline_list), pipeline_list.len)) {
                switch (self.state.pipeline) {
                    0 => self.set_default_pipeline(allocator, r),
                    1 => self.set_debug_pipeline(allocator, r),
                    else => std.log.warn("Invalid pipeline value", .{})
                }
            }
            
            // TODO : global lighting
            // imgui.ImGui_Text("sun direction");
            // _ = imgui.SliderFloat("x", &data.sunlight_dir[0], -1, 1);
            // _ = imgui.SliderFloat("y", &data.sunlight_dir[1], -1, 1);
            // _ = imgui.SliderFloat("z", &data.sunlight_dir[2], -1, 1);

            // _ = imgui.ImGui_ColorEdit4("sun color", &data.sunlight_color, 0);
            // _ = imgui.ImGui_ColorEdit4("ambient color", &data.ambient_color, 0);
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
