const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const c_translate = b.addTranslateC(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("modules/SDL3/src/c.h")
    });
    c_translate.addIncludePath(.{ .cwd_relative = "common/SDL3/include" });
    const c_mod = c_translate.createModule();
    
    const module = b.addModule("sdl", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("modules/SDL3/src/root.zig"),
        .imports = &.{
            .{ .name = "c", .module = c_mod }
        }
    });

    module.addLibraryPath(.{ .cwd_relative = "common/SDL3/lib" });

    return module;
}
