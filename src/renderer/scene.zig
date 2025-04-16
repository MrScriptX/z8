const c = @import("../clibs.zig");
const math = @import("../utils/maths.zig");
const images = @import("vk_images.zig");
const descriptor = @import("descriptor.zig");

pub const GPUData = struct {
    view: [4][4]f32 align(16),
    proj: [4][4]f32 align(16),
    viewproj: [4][4]f32 align(16),
    ambient_color: [4]f32 align(4),
    sunlight_dir: [4]f32 align(4),
    sunlight_color: [4]f32 align(4)
};

pub const RenderObject = struct {
    index_count: u32,
    first_index: u32,
    index_buffer: c.VkBuffer,

    material: *MaterialInstance,

    transform: math.mat4,
    vertex_buffer_address: c.VkDeviceAddress,
};

pub const MaterialPipeline = struct {
    pipeline: c.VkPipeline,
    layout: c.VkPipelineLayout
};

pub const MaterialInstance = struct {
    pipeline: *MaterialPipeline,
    material_set: c.VkDescriptorSet,
    pass_type: MaterialPass,
};

const MaterialPass = enum(u8) {
    MainColor,
    Transparent,
    Other,
};

pub const Renderable = struct {
    pub fn draw() void {

    }
};

pub const GLTFMetallic_Roughness = struct {
    opaque_pipeline: MaterialPipeline,
    transparent_pipeline: MaterialPipeline,

    material_layout: c.VkDescriptorSet,

    writer: descriptor.DescriptorWriter,

    pub const MaterialConstants = struct {
        color_factors: math.vec4 align(4),
        metal_rough_factors: math.vec4 align(4),
        extra: [14]math.vec4 align(4*14),
    };

    pub const MaterialResources = struct {
        color_image: images.image_t,
        color_sampler: c.VkSampler,
        metal_rough_material: c.VkSampler,
        metal_rough_sampler: c.VkSampler,
        data_buffer: c.VkBuffer,
        data_buffer_offset: u32,
    };

    // pub fn build_pipeline(engine: *Engine)
    pub fn clear_resources(device: c.VkDevice) void {
        _ = device;
    }

    pub fn write_material(device: c.VkDevice, pass: MaterialPass, resources: *const MaterialResources, ds_alloc: *descriptor.DescriptorAllocator2) MaterialInstance {
        _ = device;
        _ = pass;
        _ = resources;
        _ = ds_alloc;
    }
};
