const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    // build vma static lib
    const lib = b.addStaticLibrary(.{
        .name = "vma",
        .target = target,
        .optimize = optimize,
    });

    const env_map = std.process.getEnvMap(b.allocator) catch @panic("Out of Memory !");
    const vk_path = env_map.get("VK_SDK_PATH") orelse @panic("VK_SDK_PATH missing !");

    lib.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{ vk_path })});
    lib.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{ vk_path }) });

    lib.addCSourceFile(.{ 
        .file = b.path("libs/vma/src/vk_mem_alloc.cpp"),
        .flags = &.{ 
            "-Wno-nullability-completeness",
            "-std=c++17"
        }
    });

    lib.linkLibCpp();

    // build vma module
    const module = b.addModule("vma", .{
        .root_source_file = b.path("libs/vma/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.linkLibrary(lib);

    return module;
}
