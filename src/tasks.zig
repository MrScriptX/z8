pub const TaskFn = *const fn(ctx: *anyopaque) void;

pub const Task = struct {
    func: TaskFn,
    ctx: *anyopaque,
};

pub const TaskQueue = std.fifo.LinearFifo(Task, .Dynamic);

pub const TaskManager = struct {
    allocator: std.mem.Allocator,
    queue: TaskQueue,
    thread: ?std.Thread = null,
    running: bool = false,

    pub fn init(allocator: std.mem.Allocator) *TaskManager {
        const tm: *TaskManager = allocator.create(TaskManager) catch {
            @panic("Out of memory !");
        };

        tm.* = .{
            .allocator = allocator,
            .queue = TaskQueue.init(allocator),
            .thread = null,
            .running = false
        };
        return tm;
    }

    pub fn deinit(self: *TaskManager) void {
        self.running = false;
        if (self.thread) |t| t.join();
        self.queue.deinit();
        self.allocator.destroy(self); // TODO : handle memory outside ?
    }

    pub fn enqueue(self: *TaskManager, func: TaskFn, ctx: *anyopaque) !void {
        const task: Task = .{ .func = func, .ctx = ctx };
        try self.queue.writeItem(task);
    }

    fn worker(self: *TaskManager) void {
        while (self.running) {
            if (self.queue.readItem()) |task| {
                task.func(task.ctx);
            }
            else {
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
