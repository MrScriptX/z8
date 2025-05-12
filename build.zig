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
    // exe.addLibraryPath(.{ .cwd_relative = "common/SDL3/lib" });
    // exe.addIncludePath(.{ .cwd_relative = "common/SDL3/include" });
    // add sdl3
    const sdl = @import("libs/sdl/build.zig").build(b, target, optimize);
    exe.root_module.addImport("sdl3", sdl);

    exe.addIncludePath(.{ .cwd_relative = "common/cglm-0.9.4/include" });

    exe.addCSourceFile(.{ .file = b.path("src/vk_mem_alloc.cpp"), .flags = &.{ "" } });

    // add imgui
    const cimgui = @import("libs/cimgui/build.zig").build(b, target, optimize);
    exe.root_module.addImport("imgui", cimgui);

    // add cgltf
    const gltf = @import("libs/cgltf/build.zig").build(b, target, optimize);
    exe.root_module.addImport("cgltf", gltf);

    // add zalgebra
    const zalgebra = b.addModule("zalgebra", .{
        .root_source_file = b.path("common/zalgebra/src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("zalgebra", zalgebra);

    // add stb
    const stb = @import("libs/stb/build.zig").build(b, target, optimize);
    exe.root_module.addImport("stb", stb);

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

    unit_tests.linkSystemLibrary(vk_lib_name);

    if (env_map.get("VK_SDK_PATH")) |path| {
        unit_tests.addLibraryPath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/lib", .{path}) catch @panic("OOM") });
        unit_tests.addIncludePath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/include", .{path}) catch @panic("OOM") });
    }

    unit_tests.linkSystemLibrary("SDL3");
    unit_tests.addLibraryPath(.{ .cwd_relative = "common/SDL3/lib" });
    unit_tests.addIncludePath(.{ .cwd_relative = "common/SDL3/include" });

    unit_tests.addIncludePath(.{ .cwd_relative = "common/cglm-0.9.4/include" });

    unit_tests.addCSourceFile(.{ .file = b.path("src/vk_mem_alloc.cpp"), .flags = &.{ "" } });

    // add imgui
    unit_tests.addIncludePath(.{ .cwd_relative = "common/imgui-1.91.9b" });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_widgets.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_tables.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_draw.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_impl_sdl3.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_impl_vulkan.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/imgui_demo.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui_internal.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui_impl_sdl3.cpp"), .flags = &.{ "" } });
    unit_tests.addCSourceFile(.{ .file = b.path("common/imgui-1.91.9b/dcimgui_impl_vulkan.cpp"), .flags = &.{ "" } });

    // add cgltf
    unit_tests.addIncludePath(.{ .cwd_relative = "common/cgltf" });
    unit_tests.addCSourceFile(.{ .file = b.path("src/lib/gltf.c"), .flags = &.{ "" } });

    unit_tests.root_module.addImport("zalgebra", zalgebra);

    unit_tests.linkLibC();
    unit_tests.linkLibCpp();

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

const shaders = [_]struct {
    source: []const u8,
    output: []const u8,
    stage: []const u8
} {
    .{
                .source = "assets/shaders/vkguide/default.compute.hlsl",
                .output = "compute.spv",
                .stage = "compute"
            },
            .{
                .source = "assets/shaders/vkguide/default.vert.hlsl",
                .output = "vertex.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/vkguide/default.frag.hlsl",
                .output = "fragment.spv",
                .stage = "fragment"
            },
            .{
                .source = "assets/shaders/vkguide/gradiant.glsl",
                .output = "gradiant.spv",
                .stage = "compute"
            },
            .{
                .source = "assets/shaders/vkguide/sky.glsl",
                .output = "sky.spv",
                .stage = "compute"
            },
            .{
                .source = "assets/shaders/vkguide/colored_triangle.frag.glsl",
                .output = "colored_triangle.frag.spv",
                .stage = "fragment"
            },
            .{
                .source = "assets/shaders/vkguide/colored_triangle.vert.glsl",
                .output = "colored_triangle.vert.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/vkguide/colored_triangle_mesh.vert.glsl",
                .output = "colored_triangle_mesh.vert.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/vkguide/image_texture.frag.glsl",
                .output = "image_texture.frag.spv",
                .stage = "fragment"
            },
            .{
                .source = "assets/shaders/vkguide/mesh.vert.glsl",
                .output = "mesh.vert.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/vkguide/mesh.frag.glsl",
                .output = "mesh.frag.spv",
                .stage = "fragment"
            },
            .{
                .source = "assets/shaders/voxels/voxel.vert.glsl",
                .output = "voxel.vert.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/voxels/voxel.frag.glsl",
                .output = "voxel.frag.spv",
                .stage = "fragment"
            },
            .{
                .source = "assets/shaders/aurora/cube.frag.glsl",
                .output = "cube.frag.spv",
                .stage = "fragment"
            },
            .{
                .source = "assets/shaders/aurora/cube.vert.glsl",
                .output = "cube.vert.spv",
                .stage = "vertex"
            },
            .{
                .source = "assets/shaders/aurora/cube.comp.glsl",
                .output = "cube.comp.spv",
                .stage = "compute"
            },
        };
