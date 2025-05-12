pub const Pipeline = struct {
    pipeline: c.VkPipeline = null,
    layout: c.VkPipelineLayout = null,
};

pub const Instance = struct {
    pipeline: *Pipeline,
    descriptor: c.VkDescriptorSet,
};

const c = @import("../../clibs.zig");
