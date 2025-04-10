const c = @import("../clibs.zig");

pub const ComputePushConstants = struct {
    data1: c.vec4 = undefined,
    data2: c.vec4 = undefined,
    data3: c.vec4 = undefined,
    data4: c.vec4 = undefined,
};
