const std = @import("std");

const DeleteFn = fn(ctx: *anyopaque) void;

const DeleteJob = struct {
    func: DeleteFn,
    ctx: *anyopaque,
};

pub const DeleteQueue = struct {
    allocator: std.mem.Allocator,
    jobs: std.ArrayList(DeleteJob),

    pub fn init(allocator: std.mem.Allocator) DeleteQueue {
        return DeleteQueue{
            .allocator = allocator,
            .jobs = std.ArrayList(DeleteJob).init(allocator),
        };
    }

    pub fn deinit(self: *DeleteQueue) void {
        self.jobs.deinit();
    }

    pub fn enqueue(self: *DeleteQueue, func: DeleteFn, ctx: *anyopaque) !void {
        try self.jobs.append(.{
            .func = func,
            .ctx = ctx,
        });
    }

    pub fn flush(self: *DeleteQueue) void {
        for (self.jobs.items) |job| {
            job.func(job.ctx);
        }

        self.jobs.clearRetainingCapacity();
    }
};
