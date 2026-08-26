const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.addModule("z8", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
        .link_libc = true,
        .link_libcpp = true
    });

    // vulkan dependency
    const vk_lib_name = if (target.result.os.tag == .windows) "vulkan-1" else "vulkan";
    root_module.linkSystemLibrary(vk_lib_name, .{});

    const vk_path = b.graph.environ_map.get("VULKAN_SDK")
        orelse @panic("VULKAN_SDK missing !");

    root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{ vk_path }) });
    root_module.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{ vk_path }) });

    // add sdl3
    root_module.linkSystemLibrary("SDL3", .{});
    const sdl = @import("libs/sdl/build.zig").build(b, target, optimize);
    root_module.addImport("sdl3", sdl);

    // cglm
    root_module.addIncludePath(.{ .cwd_relative = "common/cglm-0.9.4/include" });

    const exe = b.addExecutable(.{
        .name = "z8",
        .root_module = root_module,
    });

    compile_shaders(b, exe, vk_path) catch @panic("Out of memory !");

    // vma
    const vma = @import("libs/vma/build.zig").build(b, target, optimize);
    exe.root_module.addImport("vma", vma);

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

    b.installArtifact(exe);

    if (target.result.os.tag == .windows) {
        b.installBinFile("common/SDL3/lib/SDL3.dll", "SDL3.dll");
    }

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .name = "test-z8",
        .root_module = root_module,
    });

    // unit_tests.linkSystemLibrary(vk_lib_name);

    // if (b.graph.environ_map.get("VK_SDK_PATH")) |path| {
    //     unit_tests.addLibraryPath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/lib", .{path}) catch @panic("OOM") });
    //     unit_tests.addIncludePath(.{ .cwd_relative = std.fmt.allocPrint(b.allocator, "{s}/include", .{path}) catch @panic("OOM") });
    // }

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

fn compile_shaders(b: *std.Build, exe: *std.Build.Step.Compile, vk_path: []const u8) !void {
    const glslc_path = b.fmt("{s}/Bin/glslc.exe", .{ vk_path });

    for (shaders) |shader| {
        const glslc = b.addSystemCommand(&.{glslc_path});
        glslc.addArg(b.fmt("-fshader-stage={s}", .{ shader.stage_fmt() }));

        const shader_path = b.fmt("assets/shaders/{s}", .{ shader.file });
        glslc.addFileArg(b.path(shader_path));

        glslc.addArg("-o");

        const shader_output = shader.output(b) catch {
            std.log.err("skipping {s} because of error", .{ shader.file });
            continue;
        };

        const output = glslc.addOutputFileArg(shader_output);

        // Add the glslc command as a dependency to the executable
        exe.step.dependOn(&glslc.step);
        
        // Declare vertex.spv as an artefact
        exe.step.dependOn(&b.addInstallFileWithDir(output, .prefix, b.fmt("bin/shaders/{s}", .{shader_output})).step);
    }
}

const Shader = struct {
    const Error = error{
        FileNotFound
    };

    const Stage = enum {
        COMPUTE,
        VERTEX,
        FRAGMENT,
    };

    file: []const u8,
    stage: Stage,

    fn stage_fmt(self: *const Shader) []const u8 {
        switch (self.stage) {
            Stage.COMPUTE => return "compute",
            Stage.VERTEX => return "vertex",
            Stage.FRAGMENT => return "fragment"
        }
    }

    fn output(self: *const Shader, b: *std.Build) Error![]u8 {
        const dot_index = std.mem.lastIndexOf(u8, self.file, ".") orelse {
            std.debug.print("No extension found in filename: {s}\n", .{self.file});
            return Error.FileNotFound;
        };

        const out = b.fmt("{s}.spv", .{ self.file[0..dot_index] });
        return out;
    }
};

const shaders = [_]Shader {
    .{ .stage = Shader.Stage.COMPUTE, .file = "vkguide/default.compute.hlsl" },
    .{ .stage = Shader.Stage.VERTEX, .file = "vkguide/default.vert.hlsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "vkguide/default.frag.hlsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "vkguide/gradiant.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "vkguide/sky.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "vkguide/colored_triangle.frag.glsl" },
    .{ .stage = Shader.Stage.VERTEX, .file = "vkguide/colored_triangle.vert.glsl" },
    .{ .stage = Shader.Stage.VERTEX, .file = "vkguide/colored_triangle_mesh.vert.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "vkguide/image_texture.frag.glsl" },
    .{ .stage = Shader.Stage.VERTEX, .file = "vkguide/mesh.vert.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "vkguide/mesh.frag.glsl" },

    .{ .stage = Shader.Stage.VERTEX, .file = "voxels/voxel.vert.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "voxels/voxel.frag.glsl" },

    .{ .stage = Shader.Stage.VERTEX, .file = "aurora/cube.vert.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "aurora/cube.frag.glsl" },
    .{ .stage = Shader.Stage.VERTEX, .file = "aurora/block.vert.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "aurora/block.frag.glsl" },
    .{ .stage = Shader.Stage.VERTEX, .file = "aurora/water.vert.glsl" },
    .{ .stage = Shader.Stage.FRAGMENT, .file = "aurora/water.frag.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "aurora/meshing.comp.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "aurora/meshing2.comp.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "aurora/meshing3.comp.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "aurora/world.comp.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "aurora/face_culling.comp.glsl" },
    .{ .stage = Shader.Stage.COMPUTE, .file = "aurora/frustrum_culling.comp.glsl" }
};
