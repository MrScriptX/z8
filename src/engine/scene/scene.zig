pub const ShaderData = struct {
    view: [4][4]f32 align(16) = za.Mat4.identity().data,
    proj: [4][4]f32 align(16) = za.Mat4.identity().data,
    viewproj: [4][4]f32 align(16) = za.Mat4.identity().data,
    ambient_color: [4]f32 align(4) = .{ 0.1, 0.1, 0.1, 0.1 },
    sunlight_dir: [4]f32 align(4) = .{ 1, 1, 1, 1 },
    sunlight_color: [4]f32 align(4) = .{ 0, 1, 0.5, 1 },
    time: f32 align(4) = 0
};

pub const Manager = struct {
    alloc: std.mem.Allocator,

    current_scene: i32 = 0,
    scenes: [3][*:0]const u8 = [_][*:0]const u8{ "reactor", "monkey", "voxels" },

    reactor_scene: ?levels.ReactorScene = null,
    monkey_scene: ?levels.MonkeyScene = null,
    voxels_scene: ?levels.VoxelsScene = null,

    pub fn init(allocator: std.mem.Allocator, default_scene: u32) Manager {
        return .{
            .alloc = allocator,
            .current_scene = @intCast(default_scene)
        };
    }

    pub fn deinit(self: *Manager, r: *renderer.renderer_t) void {
        self.clear(r);
    }

    pub fn update(self: *Manager, cam: *camera.camera_t, r: *renderer.renderer_t) void {
        if (self.reactor_scene) |*scene| {
            scene.update(cam, r);
        }
        else if (self.monkey_scene) |*scene| {
            scene.update(cam, r);
        }
        else if (self.voxels_scene) |*scene| {
            scene.update(self.alloc, cam, r);
        }
    }

    pub fn update_ui(self: *Manager, r: *renderer.renderer_t) void {
        const result = imgui.Begin("Scenes Manager", null, 0);
        if (result) {
            defer imgui.End();

            if (imgui.ImGui_ComboChar("scene", &self.current_scene, @ptrCast(&self.scenes), @intCast(self.scenes.len))) {
                std.log.info("Loading new scene", .{});
            
                self.clear(r);
                self.build_scene(r);                
            }
		}

        if (self.voxels_scene) |*scene| {
            scene.update_ui(r);
        }
    }

    pub fn build_scene(self: *Manager, r: *renderer.renderer_t) void {
        if (self.current_scene == 0) {
            self.monkey_scene = levels.MonkeyScene.init(self.alloc, r) catch {
                std.log.err("Failed to load monkey scene", .{});
                @panic("Fatal error");
            };

            r._scene = &self.monkey_scene.?.draw_ctx;
        }
        else if (self.current_scene == 1) {
            self.reactor_scene = levels.ReactorScene.init(self.alloc, r) catch {
                std.log.err("Failed to load rector scene", .{});
                @panic("Fatal error");
            };

            r._scene = &self.reactor_scene.?.draw_ctx;
        }
        else if (self.current_scene == 2) {
            self.voxels_scene = levels.VoxelsScene.init(self.alloc, r) catch {
                std.log.err("Failed to load rector scene", .{});
                @panic("Fatal error");
            };

            r._scene = &self.voxels_scene.?.draw_ctx;
        }
    }

    pub fn clear(self: *Manager, r: *renderer.renderer_t) void {
        if (self.voxels_scene) |*scene| {
            scene.deinit(r);
            self.voxels_scene = null;
        }

        if (self.monkey_scene) |*scene| {
            scene.deinit(r);
            self.monkey_scene = null;
        }

        if (self.reactor_scene) |*scene| {
            scene.deinit(r);
            self.reactor_scene = null;
        }
    }
};

pub const BackgroundContext = struct {
    shader: ?*compute.ComputeEffect
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

            if (obj.vertex_buffer) |buffer| {
                c.vkCmdBindVertexBuffers(cmd, 0, 1, &buffer, &obj.vertex_buffer_offset);
            }

            if (obj.indirect_buffer) |buffer| {
                c.vkCmdDrawIndexedIndirect(cmd, buffer, 0, 1,  @sizeOf(c.VkDrawIndexedIndirectCommand));
            }
            else {
                c.vkCmdDrawIndexed(cmd, obj.index_count, 1, obj.first_index, 0, 0);
            }

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

            if (obj.vertex_buffer) |buffer| {
                c.vkCmdBindVertexBuffers(cmd, 0, 1, &buffer, &obj.vertex_buffer_offset);
            }

            if (obj.indirect_buffer) |buffer| {
                c.vkCmdDrawIndexedIndirect(cmd, buffer, 0, 1,  @sizeOf(c.VkDrawIndexedIndirectCommand));
            }
            else {
                c.vkCmdDrawIndexed(cmd, obj.index_count, 1, obj.first_index, 0, 0);
            }

            stats.drawcall_count += 1;
            stats.triangle_count += obj.index_count / 3;
        }
    }
};

const std = @import("std");
const za = @import("zalgebra");
const imgui = @import("imgui");
const camera = @import("camera.zig");
const c = @import("../../clibs.zig");
const mesh = @import("../graphics/assets.zig");
const gltf = @import("gltf.zig");
const renderer = @import("../renderer.zig");
const mat = @import("../graphics/materials.zig"); // TODO : use only one import
const materials = @import("../graphics/materials.zig");
const buffers = @import("../graphics/buffers.zig");
const descriptors = @import("../descriptor.zig");
const compute = @import("../compute_effect.zig");
const levels = @import("../../levels/levels.zig");
