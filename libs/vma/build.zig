const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const c_translate = b.addTranslateC(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("libs/vma/src/c.h")
    });
    
    const env_map = b.graph.environ_map;
    const vk_path = env_map.get("VK_SDK_PATH") orelse @panic("VK_SDK_PATH missing !");

    c_translate.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{ vk_path }) });

    const vma = c_translate.createModule();

    vma.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{ vk_path }) });
    vma.addCSourceFile(.{ 
        .file = b.path("libs/vma/src/vk_mem_alloc.cpp"),
        .flags = &.{ 
            "-Wno-nullability-completeness",
            "-std=c++17"
        }
    });
    vma.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{ vk_path })});

    // build vma static lib
    const module = b.addModule("vma", .{
        .root_source_file = b.path("libs/vma/src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
        .imports = &.{
            .{
                .name = "vma",
                .module = vma
            }
        }
    });

    return module;
}
