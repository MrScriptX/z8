pub const TaskFn = fn(ctx: *anyopaque) void;

pub const Task = struct {
    func: TaskFn,
    ctx: *anyopaque,
};

pub const TaskManager = struct {
    allocator: std.mem.Allocator,
    queue: std.fifo.LinearFifo(Task, .Dynamic),
    thread: ?std.Thread = null,
    running: bool = false,

    pub fn init(allocator: std.mem.Allocator, queue_capacity: usize) !*TaskManager {
        const tm = try allocator.create(TaskManager);
        tm.* = TaskManager{
            .allocator = allocator,
            .queue = try std.fifo.LinearFifo(Task, .Dynamic).init(allocator, queue_capacity),
            .thread = null,
            .running = false,
        };
        return tm;
    }

    pub fn deinit(self: *TaskManager) void {
        self.running = false;
        if (self.thread) |t| t.join();
        self.queue.deinit();
        self.allocator.destroy(self);
    }

    pub fn enqueue(self: *TaskManager, func: TaskFn, ctx: *anyopaque) !void {
        try self.queue.write(.{ .func = func, .ctx = ctx });
    }

    fn worker(self: *TaskManager) void {
        while (self.running) {
            if (self.queue.readItem()) |task| {
                task.func(task.ctx);
            } else {
                std.time.sleep(1_000_000); // 1ms
            }
        }
    }

    pub fn start(self: *TaskManager) !void {
        if (self.running) return;
        self.running = true;
        self.thread = try std.Thread.spawn(.{}, TaskManager.worker, .{self});
    }

    pub fn stop(self: *TaskManager) void {
        self.running = false;
        if (self.thread) |t| t.join();
        self.thread = null;
    }
};

const std = @import("std");
