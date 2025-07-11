pub const TaskFn = *const fn(ctx: *anyopaque, cmd: c.VkCommandBuffer) void;
pub const OnFinishTaskFn = *const fn(ctx: *anyopaque) void;

pub const Task = struct {
    record: TaskFn,
    on_finish: ?OnFinishTaskFn,
    ctx: *anyopaque,
    cmd: c.VkCommandBuffer
};

pub const TaskQueue = std.fifo.LinearFifo(Task, .Dynamic);

pub const TaskManager = struct {
    allocator: std.mem.Allocator,
    
    record_queue: TaskQueue,
    submit_queue: TaskQueue,

    record_thread: ?std.Thread = null,
    submit_thread: ?std.Thread = null,
    running: bool = false,
    submit: queues.SubmitQueue,

    pub fn init(allocator: std.mem.Allocator, device: c.VkDevice, queue: c.VkQueue, queue_index: u32) *TaskManager {
        const tm: *TaskManager = allocator.create(TaskManager) catch {
            std.log.err("Failed to create TaskManager !", .{});
            @panic("Out of memory !");
        };

        tm.* = .{
            .allocator = allocator,
            .record_queue = TaskQueue.init(allocator),
            .submit_queue = TaskQueue.init(allocator),
            .running = false,
            .submit = queues.SubmitQueue.init(allocator, device, queue, queue_index)
        };
        return tm;
    }

    pub fn deinit(self: *TaskManager) void {
        self.stop();

        self.record_queue.deinit();
        self.submit_queue.deinit();

        self.submit.deinit(self.submit.device);

        self.allocator.destroy(self); // TODO : handle memory outside ?
    }

    pub fn enqueue(self: *TaskManager, func: TaskFn, on_finish: ?OnFinishTaskFn, ctx: *anyopaque) !void {
        const cmd = self.submit.next_command_buffer() catch |err| {
            std.log.warn("Failed to get a command buffer for recording", .{});
            return err;
        };
        
        const task: Task = .{ 
            .record = func,
            .on_finish = on_finish,
            .ctx = ctx,
            .cmd = cmd,
        };
        try self.record_queue.writeItem(task);
    }

    /// Record a command buffer, then set it to the submit queue
    fn recording_worker(self: *TaskManager) void {
        while (self.running) {
            if (self.record_queue.readItem()) |task| {
                self.submit.start_command(task.cmd);
                task.record(task.ctx, task.cmd);
                self.submit.end_command(task.cmd);

                // set it to the submit queue
                self.submit_queue.writeItem(task) catch { // TODO : handle failed submission better ?
                    std.log.err("Failed to submit command buffer", .{});
                    @panic("Out of memory !");
                };
            }
            else {
                std.time.sleep(1_000_000); // 1ms
            }
        }
    }

    fn submitting_worker(self: *TaskManager) void {
        while (self.running) {
            if (self.submit_queue.readItem()) |task| {
                self.submit.submit_command(task.cmd);

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
        self.submit_thread = try std.Thread.spawn(.{}, TaskManager.submitting_worker, .{ self });
        self.record_thread = try std.Thread.spawn(.{}, TaskManager.recording_worker, .{ self });
    }

    /// Stops all the threads
    pub fn stop(self: *TaskManager) void {
        self.running = false;

        if (self.submit_thread) |t| t.join();
        self.submit_thread = null;
        
        if (self.record_thread) |t| t.join();
        self.record_thread = null;
    }
};

const std = @import("std");
const queues = @import("engine/vulkan/queues.zig");
const c = @import("clibs.zig");
