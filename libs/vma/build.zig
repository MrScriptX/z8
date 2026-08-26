const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    // build vma static lib
    const module = b.addModule("vma", .{
        .root_source_file = b.path("libs/vma/src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true
    });

    const env_map = b.graph.environ_map;
    const vk_path = env_map.get("VK_SDK_PATH") orelse @panic("VK_SDK_PATH missing !");

    module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{ vk_path })});
    module.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{ vk_path }) });

    module.addCSourceFile(.{ 
        .file = b.path("libs/vma/src/vk_mem_alloc.cpp"),
        .flags = &.{ 
            "-Wno-nullability-completeness",
            "-std=c++17"
        }
    });

    // const lib = b.addLibrary(.{
    //     .name = "vma",
    //     .linkage = .static,
    //     .root_module = module,
    // });

    // build vma module
    // module.linkLibrary(lib);

    return module;
}
