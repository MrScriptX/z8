const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *Build.Module {
    const module = b.addModule("stb", .{
        .root_source_file = b.path("libs/sdl/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // const env_map = std.process.getEnvMap(b.allocator) catch @panic("Out of memory !");
    // if (env_map.get("VK_SDK_PATH")) |path| {
    //     module.addIncludePath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/include", .{path}) catch @panic("OOM") });
    // }
    // else {
    //     @panic("VK_SDK_PATH not found ! Please install Vulkan SDK.");
    // }

    module.addLibraryPath(.{ .cwd_relative = "common/SDL3/lib" });
    module.addIncludePath(.{ .cwd_relative = "common/SDL3/include" });

    return module;
}
