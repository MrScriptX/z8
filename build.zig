const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "vzig",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const env_map = try std.process.getEnvMap(b.allocator);

    if (env_map.get("VULKAN_SDK")) |path| {
        const glslc_path = std.fmt.allocPrint(b.allocator, "{s}/Bin/glslc.exe", .{path}) catch @panic("OOM");
        
        const shaders = [_]struct {
            source: []const u8,
            output: []const u8,
            stage: []const u8
        } {
            .{
                .source = "assets/shaders/default.vert.hlsl",
                .output = "vertex.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/default.frag.hlsl",
                .output = "fragment.spv",
                .stage = "fragment"
            }
        };

        for (shaders) |shader| {
            const glslc = b.addSystemCommand(&.{glslc_path});
            glslc.addArg(b.fmt("-fshader-stage={s}", .{shader.stage}));
            glslc.addFileArg(b.path(shader.source));
            glslc.addArg("-o");
            const output = glslc.addOutputFileArg(shader.output);

            // Add the glslc command as a dependency to the executable
            exe.step.dependOn(&glslc.step);
        
            // Declare vertex.spv as an artefact
            exe.step.dependOn(&b.addInstallFileWithDir(output, .prefix, b.fmt("bin/shaders/{s}", .{shader.output})).step);
        }
    }

    const vk_lib_name = if (target.result.os.tag == .windows) "vulkan-1" else "vulkan";
    exe.linkSystemLibrary(vk_lib_name);

    if (env_map.get("VK_SDK_PATH")) |path| {
        exe.addLibraryPath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/lib", .{path}) catch @panic("OOM") });
        exe.addIncludePath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/include", .{path}) catch @panic("OOM") });
    }

    exe.linkSystemLibrary("SDL3");
    exe.addLibraryPath(.{ .cwd_relative = "common/SDL3/lib" });
    exe.addIncludePath(.{ .cwd_relative = "common/SDL3/include" });

    exe.addIncludePath(.{ .cwd_relative = "common/cglm-0.9.4/include" });

    exe.addCSourceFile(.{ .file = b.path("src/vk_mem_alloc.cpp"), .flags = &.{ "" } });

    exe.linkLibC();
    exe.linkLibCpp();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    if (target.result.os.tag == .windows) {
        b.installBinFile("common/SDL3/lib/SDL3.dll", "SDL3.dll");
    }

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
