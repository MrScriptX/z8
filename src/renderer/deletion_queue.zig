const std = @import("std");

const Deletor = @TypeOf(*const fn() void);

pub const DeletionQueue = struct {
    deletors: std.ArrayList(*const fn() void),

    pub fn init(allocator: std.mem.Allocator) DeletionQueue {
        const dq = DeletionQueue {
            .deletors = std.ArrayList(*const fn() void).init(allocator),
        };
        return dq;
    }

    pub fn flush(self: *DeletionQueue) void {
        for (self.deletors.items) |deletor| {
            deletor();
        }

        self.deletors.clearAndFree();
    }

    pub fn deinit(self: *DeletionQueue) void {
        self.deletors.deinit();
    }
};
