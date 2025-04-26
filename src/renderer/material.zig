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

const std = @import("std");
const c = @import("../clibs.zig");
const engine = @import("engine.zig");
const pipeline = @import("pipeline.zig");
const math = @import("../utils/maths.zig");
const images = @import("vk_images.zig");
const descriptor = @import("descriptor.zig");
const buffers = @import("buffers.zig");
const log = @import("../utils/log.zig");
