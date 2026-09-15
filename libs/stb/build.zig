const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const c_translate = b.addTranslateC(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("libs/stb/src/c.h"),
    });
    c_translate.addIncludePath(.{ .cwd_relative = "common/stb" });
    const stb = c_translate.createModule();
    stb.addCSourceFile(.{ .file = b.path("libs/stb/src/stb_image.c"), .flags = &.{ "" } });
    
    const module = b.addModule("stb", .{
        .root_source_file = b.path("libs/stb/src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "stb",
                .module = c_translate.createModule()
            }
        }
    });

    module.addIncludePath(.{ .cwd_relative = "common/stb" });
    module.addCSourceFile(.{ .file = b.path("libs/stb/src/stb_image.c"), .flags = &.{ "" } });

    return module;
}