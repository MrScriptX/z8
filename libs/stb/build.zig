const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const module = b.addModule("stb", .{
        .root_source_file = b.path("libs/stb/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.addIncludePath(.{ .cwd_relative = "common/stb" });
    module.addCSourceFile(.{ .file = b.path("libs/stb/src/stb_image.c"), .flags = &.{ "" } });

    return module;
}