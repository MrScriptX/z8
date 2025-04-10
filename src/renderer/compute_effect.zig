const c = @import("../clibs.zig");
const constants = @import("compute_push_constants.zig");

pub const ComputeEffect = struct {
    name: []const u8 = undefined,
    
    pipeline: c.VkPipeline = undefined,
	layout: c.VkPipelineLayout = undefined,

    data: constants.ComputePushConstants = undefined
};
