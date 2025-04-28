const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const module = b.addModule("stb", .{
        .root_source_file = b.path("libs/cimgui/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const env_map = std.process.getEnvMap(b.allocator) catch @panic("Out of memory !");
    if (env_map.get("VK_SDK_PATH")) |path| {
        module.addIncludePath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/include", .{path}) catch @panic("OOM") });
    }
    else {
        @panic("VK_SDK_PATH not found ! Please install Vulkan SDK.");
    }

    module.addIncludePath(.{ .cwd_relative = "common/SDL3/include" });

    module.addIncludePath(.{ .cwd_relative = "common/imgui-1.91.9b" });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_widgets.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_tables.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_draw.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_impl_sdl3.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_impl_vulkan.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_demo.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui_internal.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui_impl_sdl3.cpp"), .flags = &.{ "" } });
    module.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui_impl_vulkan.cpp"), .flags = &.{ "" } });

    return module;
}