const std = @import("std");
const c = @import("../clibs.zig");

pub inline fn write(comptime format: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut();
    stdout.writer().print(format, args) catch {
        std.debug.print("Logging error threw !", .{});
    };
}

pub fn err(comptime format: []const u8, args: anytype) void {
    const message = std.fmt.allocPrint(std.heap.page_allocator, format, args) catch @panic("Out Of Memory !");
    defer std.heap.page_allocator.free(message);

    const stdout = std.io.getStdOut();
    stdout.writer().print(format, args) catch {
        std.debug.print("Logging error threw !", .{});
    };

    const success = c.SDL_ShowSimpleMessageBox(c.SDL_MESSAGEBOX_ERROR, "Error", message.ptr, null);
    if (!success) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to show message box: %s", c.SDL_GetError());
    }
}
