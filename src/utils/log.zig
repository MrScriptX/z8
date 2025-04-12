const std = @import("std");

pub inline fn write(comptime format: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut();
    stdout.writer().print(format, args) catch {
        std.debug.print("Logging error threw !", .{});
    };
}
