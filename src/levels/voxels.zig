const MaterialPipelines = struct {
    allocator: std.mem.Allocator,

    default: chunk.Materials,
    normals: chunk.Materials,
    polygone: chunk.Materials,

    pub fn init(allocator: std.mem.Allocator) !MaterialPipelines {
        return MaterialPipelines{
            .allocator = allocator,
            .default = .{
                .block = try allocator.create(chunk.Material),
                .water = try allocator.create(chunk.Material),
            },
            .normals = .{
                .block = try allocator.create(chunk.Material),
                .water = try allocator.create(chunk.Material),
            },
            .polygone = .{
                .block = try allocator.create(chunk.Material),
                .water = try allocator.create(chunk.Material),
            },
        };
    }

    pub fn deinit(self: *MaterialPipelines, device: c.VkDevice) void {
        self.default.block.deinit(device);
        self.default.water.deinit(device);
        self.normals.block.deinit(device);
        self.normals.water.deinit(device);
        self.polygone.block.deinit(device);
        self.polygone.water.deinit(device);

        self.allocator.destroy(self.default.block);
        self.allocator.destroy(self.default.water);
        self.allocator.destroy(self.normals.block);
        self.allocator.destroy(self.normals.water);
        self.allocator.destroy(self.polygone.block);
        self.allocator.destroy(self.polygone.water);
    }

    pub fn build(self: *MaterialPipelines, dir: []const u8, r: *const renderer.renderer_t) !void {
        const default_vert = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dir, "shaders/aurora/block.vert.spv" });
        defer self.allocator.free(default_vert);

        const default_frag = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dir, "shaders/aurora/block.frag.spv" });
        defer self.allocator.free(default_frag);

        const normals_vert = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dir, "shaders/aurora/cube.vert.spv" });
        defer self.allocator.free(normals_vert);

        const normals_frag = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dir, "shaders/aurora/cube.frag.spv" });
        defer self.allocator.free(normals_frag);
        
        const water_vert = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dir, "shaders/aurora/water.vert.spv" });
        defer self.allocator.free(water_vert);

        const water_frag = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dir, "shaders/aurora/water.frag.spv" });
        defer self.allocator.free(water_frag);

        self.default.block.* = chunk.Material.init(self.allocator);
        self.default.block.build(self.allocator, default_vert, default_frag, c.VK_POLYGON_MODE_FILL, false, r) catch |err| {
            std.log.err("Failed to build default block pipeline", .{});
            return err;
        };

        self.default.water.* = chunk.Material.init(self.allocator);
        self.default.water.build(self.allocator, water_vert, water_frag, c.VK_POLYGON_MODE_FILL, true, r) catch |err| {
            std.log.err("Failed to build default water pipeline", .{});
            return err;
        };

        self.normals.block.* = chunk.Material.init(self.allocator);
        self.normals.block.build(self.allocator, normals_vert, normals_frag, c.VK_POLYGON_MODE_FILL, false, r) catch |err| {
            std.log.err("Failed to build normals block pipeline", .{});
            return err;
        };

        self.normals.water.* = chunk.Material.init(self.allocator);
        self.normals.water.build(self.allocator, water_vert, water_frag, c.VK_POLYGON_MODE_FILL, true, r) catch |err| {
            std.log.err("Failed to build normals water pipeline", .{});
            return err;
        };

        self.polygone.block.* = chunk.Material.init(self.allocator);
        self.polygone.block.build(self.allocator, default_vert, default_frag, c.VK_POLYGON_MODE_LINE, false, r) catch |err| {
            std.log.err("Failed to build polygone block pipeline", .{});
            return err;
        };

        self.polygone.water.* = chunk.Material.init(self.allocator);
        self.polygone.water.build(self.allocator, water_vert, water_frag, c.VK_POLYGON_MODE_LINE, true, r) catch |err| {
            std.log.err("Failed to build polygone water pipeline", .{});
            return err;
        };
    }
};

const State = struct {
    pipeline: i32 = 0,

    seed: u32 = 0, // world seed
    radius: u8 = 10,
};

// TODO : implement UI to chose which node to display
pub const VoxelScene = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,

    state: State,

    shaders: chunk.Shaders,
    pipelines: MaterialPipelines,

    world: std.ArrayList(Chunk),
    wait_queue: std.ArrayList(Chunk),
    deletion_queue: std.ArrayList(Chunk), // use as a garbage collector
    global_data: scenes.ShaderData,

    background_ctx: scenes.BackgroundContext,
    draw_ctx: scenes.DrawContext,

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
            .allocator = allocator,
            .arena = std.heap.ArenaAllocator.init(allocator),
            .pipelines = try MaterialPipelines.init(allocator),
            .shaders = .{
                .classification = try allocator.create(shader.ClassificationShader),
                .face_culling = try allocator.create(shader.FaceCullingShader),
                .meshing = try allocator.create(shader.MeshComputeShader),
                .frustrum_culling = try allocator.create(shader.FrustrumCulling)
            },
            .global_data = .{
                .sunlight_color = .{ 1.0, 1.0, 1.0, 1.0 },
                .ambient_color = .{ 0.35, 0.35, 0.5, 1.0 },
            },
            .draw_ctx = undefined,
            .background_ctx = undefined,
            .state = .{
                .seed = rand.int(u32)
            },
            .world = std.ArrayList(Chunk).init(allocator),
            .wait_queue = std.ArrayList(Chunk).init(allocator),
            .deletion_queue = std.ArrayList(Chunk).init(allocator),
        };

        // get local directory (exe)
        const dir = try std.fs.selfExeDirPathAlloc(allocator);
        defer allocator.free(dir);

        // build classification shader
        const world_comp = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/aurora/world.comp.spv" });
        defer allocator.free(world_comp);

        scene.shaders.classification.* = shader.ClassificationShader.init(allocator);
        try scene.shaders.classification.build(allocator, world_comp, r);

        // build face culling shader 
        const face_culling_comp = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/aurora/face_culling.comp.spv" });
        defer allocator.free(face_culling_comp);

        scene.shaders.face_culling.* = shader.FaceCullingShader.init(allocator);
        try scene.shaders.face_culling.build(allocator, face_culling_comp, r);

        // meshing shader
        const meshing_comp = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/aurora/meshing2.comp.spv" });
        defer allocator.free(meshing_comp);

        scene.shaders.meshing.* = shader.MeshComputeShader.init(allocator, "voxel");
        try scene.shaders.meshing.build(allocator, meshing_comp, r);

        // frustrum shader
        const frustrum_comp = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/aurora/frustrum_culling.comp.spv" });
        defer allocator.free(frustrum_comp);

        scene.shaders.frustrum_culling.* = shader.FrustrumCulling.init(allocator);
        try scene.shaders.frustrum_culling.build(allocator, frustrum_comp, r);

        // build material pipelines
        scene.pipelines.build(dir, r) catch |err| {
            std.log.err("Failed to build material pipelines: {any}", .{err});
            return err;
        };

        // TODO : sky box should be handled from the scene

        scene.draw_ctx.global_data = &scene.global_data;
        scene.draw_ctx.opaque_surfaces = std.ArrayList(material.RenderObject).init(allocator);
        scene.draw_ctx.transparent_surfaces = std.ArrayList(material.RenderObject).init(allocator);

        scene.build_world();

        return scene;
    }

    pub fn deinit(self: *VoxelScene, r: *renderer.renderer_t) void {
        const result = c.vkDeviceWaitIdle(r._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Wait for device idle failed with error. {d}", .{ result });
        }

        self.draw_ctx.deinit();
        
        for (self.wait_queue.items) |*it| {
            if (it.ptr.ready.load(std.builtin.AtomicOrder.acquire)) {
                it.ptr.deinit(r._vma, r);
            }
        }
        self.wait_queue.deinit();

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

        self.pipelines.deinit(r._device);

        self.shaders.classification.deinit(r);
        self.shaders.face_culling.deinit(r);
        self.shaders.meshing.deinit(r);
        self.shaders.frustrum_culling.deinit(r);

        self.allocator.destroy(self.shaders.classification);
        self.allocator.destroy(self.shaders.face_culling);
        self.allocator.destroy(self.shaders.meshing);
        self.allocator.destroy(self.shaders.frustrum_culling);

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

        // process wait queue
        // const frame = r._frameNumber % 2;
        // for (self.wait_queue.items, 0..) |*it, i| {
        //     it.in_use[frame] = false;
        //     if (!it.in_use[0] and !it.in_use[1] and !it.in_use[2]) {
        //         self.deletion_queue.append(it.*) catch {
        //             std.log.warn("Memory leak ! Cannot set chunk for deletion.", .{});
        //         };
        //         _ = self.wait_queue.swapRemove(i);
        //     }
        // }

        // process delete queue
        var to_delete = self.deletion_queue.pop();
        if (to_delete) |*it| {
            if (it.ptr.ready.load(std.builtin.AtomicOrder.acquire)) {
                it.ptr.deinit(r._vma, r);
            }
        }

        // process world queue
        for (self.world.items) |*it| {
            if (!it.update) {
                it.update = true; // mark as queued for update (for later use)

                // TODO : enqueue Task in TaskManager and remove the break;
                // it.ptr.* = chunk.Chunk.init(allocator, it.pos, self.state.seed, self.shaders, self.pipelines.default, self.pipelines.water, r) catch {
                //     std.log.err("Failed to create chunk : Out of memory", .{});
                //     @panic("Out Of Memory !");
                // };
                
                // r.submit.start_recording(r);
                // it.ptr.dispatch(r.submit.cmd);
                // r.submit.submit(r);

                // it.ptr.ready.store(true, std.builtin.AtomicOrder.seq_cst);

                // break; // only build one at the time for latency

                const ctx = allocator.create(Ctx) catch {
                    std.log.warn("Failed to allocate memory for chunk context", .{});
                    it.update = false;
                    continue;
                };
                ctx.* = .{
                    .it = it,
                    .r = r,
                    .allocator = allocator,
                    .self = self,
                    .src_queue = r.compute_queue.submit.queue_index,
                    .dst_queue = r._queue_indices.graphics
                };
                r.compute_queue.enqueue(&build_chunk, &on_build_success, @ptrCast(ctx)) catch {
                    std.log.warn("Queuing chunk for build failed", .{});
                    it.update = false;
                    continue;
                };
            }
        }

        cam.update(r.stats.frame_time);
        self.draw(cam, r._draw_extent, r.stats.frame_time / 1_000_000_000.0, r._frameNumber);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        r.stats.scene_update_time = @floatFromInt(end_time - start_time);
    }

    const Ctx = struct {
        it: *Chunk,
        r: *renderer.renderer_t,
        allocator: std.mem.Allocator,
        self: *VoxelScene,
        src_queue: u32,
        dst_queue: u32
    };

    pub fn build_chunk(ctx: *anyopaque, cmd: c.VkCommandBuffer) void {
        const unwrap: *Ctx = @alignCast(@ptrCast(ctx));
        var it = unwrap.it;
        const r = unwrap.r;
        const allocator = unwrap.allocator;
        const self = unwrap.self;

        std.log.info("Creating chunk {any}", .{ it.pos });

        const mat: chunk.Materials = switch(self.state.pipeline) {
            0 => self.pipelines.default,
            1 => self.pipelines.polygone,
            2 => self.pipelines.normals,
            else => self.pipelines.default,
        };

        it.ptr.* = chunk.Chunk.init(allocator, it.pos, self.state.seed, self.shaders, mat, r) catch {
            std.log.err("Failed to create chunk : Out of memory", .{});
            @panic("Out Of Memory !");
        };
        it.ptr.dispatch(cmd, unwrap.src_queue, unwrap.dst_queue);
    }

    pub fn on_build_success(ctx: *anyopaque) void {
        const unwrap: *Ctx = @alignCast(@ptrCast(ctx));
        var it = unwrap.it;
        const allocator = unwrap.allocator;

        it.ptr.ready.store(true, std.builtin.AtomicOrder.seq_cst);
        allocator.destroy(unwrap);
    }

    pub fn update_ui(self: *VoxelScene, r: *const renderer.renderer_t) void {
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
                    0 => self.set_pipelines(r, &self.pipelines.default),
                    1 => self.set_pipelines(r, &self.pipelines.polygone),
                    2 => self.set_pipelines(r, &self.pipelines.normals),
                    else => std.log.warn("Invalid pipeline value", .{})
                }
            }
            
            if (imgui.ImGui_ColorEdit4("sun color", &self.global_data.sunlight_color, 0)) {
                // std.log.debug("update sun color {any}", self.global_data.sunlight_color);
            }

            if (imgui.ImGui_ColorEdit4("ambient color", &self.global_data.ambient_color, 0)) {
                // std.log.debug("update ambient color {any}", self.global_data.ambient_color);
            }

            if (imgui.ImGui_SliderFloat3("sun dir", &self.global_data.sunlight_dir, -1, 1)) {
                // std.log.debug("update sun direction {any}", self.global_data.sunlight_dir);
            }
        }
    }

    pub fn draw(self: *VoxelScene, cam: *const cameras.camera_t, draw_extent: c.VkExtent2D, delta_time: f32, frame: u32) void {
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
                it.ptr.update(&self.draw_ctx, frame);
            }
        }
    }

    pub fn set_pipelines(self: *VoxelScene, r: *const renderer.renderer_t, pipelines: *const chunk.Materials) void {
        for (self.world.items) |it| {
            it.ptr.swap_pipeline(pipelines, r);
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
const material = @import("../engine/graphics/materials.zig");
const maths = @import("../utils/maths.zig");
const chunk = @import("../engine/scene/chunk.zig");
const shader = @import("../levels/voxel/shaders.zig");
const compute = @import("../engine/graphics/compute.zig");
const tasks = @import("../tasks.zig");
