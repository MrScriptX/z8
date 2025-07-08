pub const ShadowMap = struct {
    pipeline: engine.materials.MaterialPipeline,
    layout: vk.DescriptorSetLayout,
    writer: descriptors.Writer,

    pub fn init(allocator: std.mem.Allocator) ShadowMap {
        return .{
            .writer = descriptors.Writer.init(allocator),
            .layout = undefined,
            .pipeline = undefined,
        };
    }

    pub fn deinit(self: *ShadowMap, device: c.VkDevice) void {
        c.vkDestroyPipeline(device, self.pipeline.pipeline , null);
        c.vkDestroyPipelineLayout(device, self.pipeline.layout, null);

        c.vkDestroyDescriptorSetLayout(device, self.layout, null);

        self.writer.deinit();
    }

    pub fn build(self: *ShadowMap, allocator: std.mem.Allocator, vert_path: []const u8, r: *const Renderer) !void {
        const vert_shader = try pipelines.load_shader_module(allocator, r._device, vert_path);
        defer vk.DestroyShaderModule(r._device, vert_shader, null);

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER | c.VK_SHADER_STAGE_VERTEX_BIT, c.VK_SHADER_STAGE_VERTEX_BIT);
        self.layout = layout_builder.build(r._device, null, 0);

        const layouts = [_]vk.DescriptorSetLayout {
            // r.scene_descriptor,
            self.layout
        };

        const cascade_constant: vk.PushConstantRange = .{
            .offset = 0,
            .size = @sizeOf(Constants),
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT,
        };

        const mesh_layout_info = vk.PipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            .pNext = null,

            .setLayoutCount = 1,
            .pSetLayouts = &layouts,

            .pPushConstantRanges = &cascade_constant,
            .pushConstantRangeCount = 1,
        };

        var new_layout: vk.PipelineLayout = undefined;
        vk.CreatePipelineLayout(r._device, &mesh_layout_info, null, &new_layout) catch |err| {
            std.log.err("Failed to create descriptor layout ! Reason {any}", .{ err });
            @panic("Failed to create descriptor layout");
        };

        self.pipeline.layout = new_layout;

        var builder = pipelines.builder_t.init(allocator);
        defer builder.deinit();

        try builder.set_vertex_shader(vert_shader);
        builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
        builder.set_cull_mode(c.VK_CULL_MODE_BACK_BIT, c.VK_FRONT_FACE_CLOCKWISE);
        builder.set_multisampling_none();
        builder.enable_depthtest(true, c.VK_COMPARE_OP_GREATER_OR_EQUAL);
        builder.set_depth_format(c.VK_FORMAT_D32_SFLOAT);

        builder._pipeline_layout = new_layout;

        self.pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn write_material(self: *ShadowMap, allocator: std.mem.Allocator, device: c.VkDevice, res: *const Resources, ds_alloc: *descriptors.DescriptorAllocator2)  engine.materials.MaterialInstance {
        const data = engine.materials.MaterialInstance {
            .pass_type = engine.materials.MaterialPass.Other,
            .pipeline = &self.pipeline,
            .material_set = ds_alloc.allocate(allocator, device, self.layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, res.viewproj, @sizeOf(Resources), 0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);

        self.writer.update_set(device, data.material_set);

        return data;
    }

    pub const Constants = struct {
        cascade_index: u32
    };

    pub const Resources = struct {
        viewproj: [4][4]f32 align(16), // light view proj
    };
};

const std = @import("std");
const vk = @import("../../engine/vulkan/vk_wrapper.zig");
const c = @import("../../clibs.zig");
const engine = @import("../../engine/engine.zig");
const Renderer = engine.renderer.Renderer;
const descriptors = @import("../../engine/descriptor.zig");
const pipelines = @import("../../engine/pipeline.zig");
const buffers = @import("../../engine/graphics/buffers.zig");
