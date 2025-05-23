pub const RenderObject = struct {
    index_count: u32,
    first_index: u32,
    index_buffer: c.VkBuffer,
    
    vertex_buffer: c.VkBuffer = null,
    vertex_buffer_offset: c.VkDeviceSize = 0,

    indirect_buffer: c.VkBuffer = null,
    indirect_buffer_offset: u32 = 0,

    material: *MaterialInstance,

    transform: maths.mat4 align(16),
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

const c = @import("../../clibs.zig");
const maths = @import("../../utils/maths.zig");
const images = @import("../vulkan/image.zig");
