const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const module = b.addModule("cgltf", .{
        .root_source_file = b.path("libs/cgltf/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.addIncludePath(.{ .cwd_relative = "common/cgltf" });
    module.addCSourceFile(.{ .file = b.path("libs/cgltf/src/gltf.c"), .flags = &.{ "" } });

    return module;
}
