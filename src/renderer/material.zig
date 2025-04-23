pub const RenderObject = struct {
    index_count: u32,
    first_index: u32,
    index_buffer: c.VkBuffer,

    material: *MaterialInstance,

    transform: math.mat4 align(16),
    vertex_buffer_address: c.VkDeviceAddress,
};

pub const MaterialPipeline = struct {
    pipeline: c.VkPipeline = null,
    layout: c.VkPipelineLayout = null,
};

pub const MaterialInstance = struct {
    pipeline: *MaterialPipeline,
    material_set: c.VkDescriptorSet,
    pass_type: MaterialPass,
};

pub const MaterialPass = enum(u8) {
    MainColor,
    Transparent,
    Other,
};

pub const Renderable = struct {
    pub fn draw() void {

    }
};

pub const GLTFMetallic_Roughness = struct {
    gpa: std.heap.ArenaAllocator,

    opaque_pipeline: *MaterialPipeline,
    transparent_pipeline: *MaterialPipeline,

    material_layout: c.VkDescriptorSetLayout,

    writer: descriptor.DescriptorWriter,

    pub const MaterialConstants = struct {
        color_factors: math.vec4 align(16),
        metal_rough_factors: math.vec4 align(16),
        extra: [14]math.vec4,
    };

    pub const MaterialResources = struct {
        color_image: images.image_t,
        color_sampler: c.VkSampler,
        metal_rough_image: images.image_t,
        metal_rough_sampler: c.VkSampler,
        data_buffer: c.VkBuffer,
        data_buffer_offset: u32,
    };

    pub fn init(allocator: std.mem.Allocator) GLTFMetallic_Roughness {
        var instance = GLTFMetallic_Roughness {
            .gpa = std.heap.ArenaAllocator.init(allocator),
            .writer = descriptor.DescriptorWriter.init(allocator),
            .opaque_pipeline = undefined,
            .transparent_pipeline = undefined,
            .material_layout = undefined,
        };

        instance.opaque_pipeline = instance.gpa.allocator().create(MaterialPipeline) catch @panic("OOM");
        instance.transparent_pipeline = instance.gpa.allocator().create(MaterialPipeline) catch @panic("OOM");

        return instance;
    }

    pub fn deinit(self: *GLTFMetallic_Roughness, device: c.VkDevice) void {
        c.vkDestroyPipeline(device, self.opaque_pipeline.pipeline, null);
        c.vkDestroyPipeline(device, self.transparent_pipeline.pipeline, null);

        c.vkDestroyPipelineLayout(device, self.opaque_pipeline.layout, null); // we only have one layout for both pipelines

        c.vkDestroyDescriptorSetLayout(device, self.material_layout, null);

        self.gpa.deinit();
        self.writer.deinit();
    }

    pub fn build_pipeline(self: *GLTFMetallic_Roughness, renderer: *engine.renderer_t) !void {
        const frag_shader = try pipeline.load_shader_module(renderer._device, "./zig-out/bin/shaders/mesh.frag.spv");
        defer c.vkDestroyShaderModule(renderer._device, frag_shader, null);

        const vertex_shader = try pipeline.load_shader_module(renderer._device, "./zig-out/bin/shaders/mesh.vert.spv");
        defer c.vkDestroyShaderModule(renderer._device, vertex_shader, null);

        const matrix_range: c.VkPushConstantRange = .{
            .offset = 0,
            .size = @sizeOf(buffers.GPUDrawPushConstants),
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT,
        };

        var layout_builder = descriptor.DescriptorLayout.init();
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        try layout_builder.add_binding(2, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.material_layout = layout_builder.build(renderer._device, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);

        const layouts = [_]c.VkDescriptorSetLayout {
            renderer._gpu_scene_data_descriptor_layout,
            self.material_layout
        };

        const mesh_layout_info = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            .pNext = null,

            .setLayoutCount = 2,
            .pSetLayouts = &layouts,
            .pPushConstantRanges = &matrix_range,
            .pushConstantRangeCount = 1,
        };

        var new_layout: c.VkPipelineLayout = undefined;
        const result = c.vkCreatePipelineLayout(renderer._device, &mesh_layout_info, null, &new_layout);
        if (result != c.VK_SUCCESS) {
            log.write("Failed to create descriptor layout ! Reason {d}", .{ result });
            @panic("Failed to create descriptor layout");
        }

        self.opaque_pipeline.layout = new_layout;
        self.transparent_pipeline.layout = new_layout;

        var builder = pipeline.builder_t.init();
        defer builder.deinit();

        try builder.set_shaders(vertex_shader, frag_shader);
        builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
        builder.set_polygon_mode(c.VK_POLYGON_MODE_FILL);
        builder.set_cull_mode(c.VK_CULL_MODE_NONE, c.VK_FRONT_FACE_CLOCKWISE);
        builder.set_multisampling_none();
        builder.disable_blending();
        builder.enable_depthtest(true, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

        builder.set_color_attachment_format(renderer._draw_image.format);
        builder.set_depth_format(renderer._depth_image.format);

        builder._pipeline_layout = new_layout;

        self.opaque_pipeline.pipeline = builder.build_pipeline(renderer._device);

        builder.enable_blending_additive();
        builder.enable_depthtest(false, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

        self.transparent_pipeline.pipeline = builder.build_pipeline(renderer._device);
    }

    pub fn clear_resources(_: *GLTFMetallic_Roughness, _: c.VkDevice) void {

    }

    pub fn write_material(self: *GLTFMetallic_Roughness, device: c.VkDevice, pass: MaterialPass, resources: *const MaterialResources, ds_alloc: *descriptor.DescriptorAllocator2) MaterialInstance {
        const mat_data = MaterialInstance {
            .pass_type = pass,
            .pipeline = if (pass == MaterialPass.Transparent) self.transparent_pipeline else self.opaque_pipeline,
            .material_set = ds_alloc.allocate(device, self.material_layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.data_buffer, @sizeOf(MaterialConstants), resources.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        self.writer.write_image(1, resources.color_image.view, resources.color_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        self.writer.write_image(2, resources.metal_rough_image.view, resources.metal_rough_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.writer.update_set(device, mat_data.material_set);

        return mat_data;
    }

    pub fn write_material_compat(self: *GLTFMetallic_Roughness, device: c.VkDevice, pass: MaterialPass, resources: *const MaterialResources, ds_alloc: *descriptor.DescriptorAllocator) MaterialInstance {
        const mat_data = MaterialInstance {
            .pass_type = pass,
            .pipeline = if (pass == MaterialPass.Transparent) self.transparent_pipeline else self.opaque_pipeline,
            .material_set = ds_alloc.allocate(device, self.material_layout),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.data_buffer, @sizeOf(MaterialConstants), resources.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        self.writer.write_image(1, resources.color_image.view, resources.color_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        self.writer.write_image(2, resources.metal_rough_image.view, resources.metal_rough_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.writer.update_set(device, mat_data.material_set);

        return mat_data;
    }
};

const std = @import("std");
const c = @import("../clibs.zig");
const engine = @import("engine.zig");
const pipeline = @import("pipeline.zig");
const math = @import("../utils/maths.zig");
const images = @import("vk_images.zig");
const descriptor = @import("descriptor.zig");
const buffers = @import("buffers.zig");
const log = @import("../utils/log.zig");
