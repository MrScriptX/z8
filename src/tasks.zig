pub const TaskFn = *const fn(ctx: *anyopaque, cmd: c.VkCommandBuffer) void;
pub const OnFinishTaskFn = *const fn(ctx: *anyopaque) void;

pub const Task = struct {
    func: TaskFn,
    on_finish: ?OnFinishTaskFn,
    ctx: *anyopaque,
};

pub const TaskQueue = std.fifo.LinearFifo(Task, .Dynamic);

pub const TaskManager = struct {
    allocator: std.mem.Allocator,
    queue: TaskQueue,
    thread: ?std.Thread = null,
    running: bool = false,
    submit: queues.SubmitQueue,

    pub fn init(allocator: std.mem.Allocator, device: c.VkDevice, queue: c.VkQueue, queue_index: u32) *TaskManager {
        const tm: *TaskManager = allocator.create(TaskManager) catch {
            @panic("Out of memory !");
        };

        tm.* = .{
            .allocator = allocator,
            .queue = TaskQueue.init(allocator),
            .thread = null,
            .running = false,
            .submit = queues.SubmitQueue.init(device, queue, queue_index)
        };
        return tm;
    }

    pub fn deinit(self: *TaskManager) void {
        self.running = false;
        if (self.thread) |t| t.join();
        self.queue.deinit();
        self.submit.deinit(self.submit.device);
        self.allocator.destroy(self); // TODO : handle memory outside ?
    }

    pub fn enqueue(self: *TaskManager, func: TaskFn, on_finish: ?OnFinishTaskFn, ctx: *anyopaque) !void {
        const task: Task = .{ .func = func, .on_finish = on_finish, .ctx = ctx };
        try self.queue.writeItem(task);
    }

    fn worker(self: *TaskManager) void {
        while (self.running) {
            if (self.queue.readItem()) |task| { // TODO : batch task call, make a list of called task, and call their on finish
                self.submit.start_command();
                task.func(task.ctx, self.submit.command_buffer);
                self.submit.submit_command();

                if (task.on_finish) |on_finish| {
                    on_finish(task.ctx);
                }
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
const queues = @import("engine/vulkan/queues.zig");
const c = @import("clibs.zig");
