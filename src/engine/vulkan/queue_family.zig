const std = @import("std");
const c = @import("../../clibs.zig");

pub const queues_t = struct {
    graphics: c.VkQueue = undefined,
    present: c.VkQueue = undefined,
    indices: indices_t = undefined,
};

pub const indices_t = struct {
    graphics: u32 = std.math.maxInt(u32),
    present: u32 = std.math.maxInt(u32),

    pub fn is_complete(self: *const indices_t) bool {
        return self.graphics != std.math.maxInt(u32) and self.present != std.math.maxInt(u32);
    }
};
