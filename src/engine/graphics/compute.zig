pub const Pipeline = struct {
    pipeline: c.VkPipeline = null,
    layout: c.VkPipelineLayout = null,
};

pub const Instance = struct {
    pipeline: *Pipeline,
    descriptor: c.VkDescriptorSet,
};

const std = @import("std");
const c = @import("../../clibs.zig");
const renderer = @import("../renderer.zig");
const pipelines = @import("../pipeline.zig");
const descriptors = @import("../descriptor.zig");
const buffers = @import("buffers.zig");
