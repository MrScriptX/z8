pub const GLTFMaterial = struct {
    data: mat.MaterialInstance
};

pub const GLTFMetallic_Roughness = struct {
    gpa: std.heap.ArenaAllocator,

    opaque_pipeline: *mat.MaterialPipeline,
    transparent_pipeline: *mat.MaterialPipeline,

    material_layout: c.VkDescriptorSetLayout,

    writer: descriptors.Writer,

    pub const MaterialConstants = struct {
        color_factors: maths.vec4 align(16),
        metal_rough_factors: maths.vec4 align(16),
        extra: [14]maths.vec4,
    };

    pub const MaterialResources = struct {
        color_image: vk_images.image_t,
        color_sampler: c.VkSampler,
        metal_rough_image: vk_images.image_t,
        metal_rough_sampler: c.VkSampler,
        data_buffer: c.VkBuffer,
        data_buffer_offset: u32,
    };

    pub fn init(allocator: std.mem.Allocator) GLTFMetallic_Roughness {
        var instance = GLTFMetallic_Roughness {
            .gpa = std.heap.ArenaAllocator.init(allocator),
            .writer = descriptors.Writer.init(allocator),
            .opaque_pipeline = undefined,
            .transparent_pipeline = undefined,
            .material_layout = undefined,
        };

        instance.opaque_pipeline = instance.gpa.allocator().create(mat.MaterialPipeline) catch @panic("OOM");
        instance.transparent_pipeline = instance.gpa.allocator().create(mat.MaterialPipeline) catch @panic("OOM");

        return instance;
    }

    pub fn deinit(self: *GLTFMetallic_Roughness, device: c.VkDevice) void {
        c.vkDestroyPipeline(device, self.opaque_pipeline.pipeline, null);
        c.vkDestroyPipeline(device, self.transparent_pipeline.pipeline, null);

        c.vkDestroyPipelineLayout(device, self.opaque_pipeline.layout, null); // we only have one layout for both pipelines

        c.vkDestroyDescriptorSetLayout(device, self.material_layout, null);

        self.gpa.deinit();
        self.writer.deinit();
    }

    pub fn build_pipeline(self: *GLTFMetallic_Roughness, allocator: std.mem.Allocator, r: *renderer.renderer_t) !void {
        const frag_shader = try pipeline.load_shader_module(allocator, r._device, "./zig-out/bin/shaders/vkguide/mesh.frag.spv");
        defer c.vkDestroyShaderModule(r._device, frag_shader, null);

        const vertex_shader = try pipeline.load_shader_module(allocator, r._device, "./zig-out/bin/shaders/vkguide/mesh.vert.spv");
        defer c.vkDestroyShaderModule(r._device, vertex_shader, null);

        const matrix_range: c.VkPushConstantRange = .{
            .offset = 0,
            .size = @sizeOf(buffers.GPUDrawPushConstants),
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT,
        };

        var layout_builder = descriptors.DescriptorLayout.init(allocator);
        defer layout_builder.deinit();

        try layout_builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        try layout_builder.add_binding(1, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        try layout_builder.add_binding(2, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.material_layout = layout_builder.build(r._device, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);

        const layouts = [_]c.VkDescriptorSetLayout {
            r.scene_descriptor,
            self.material_layout
        };

        const mesh_layout_info = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            .pNext = null,

            .setLayoutCount = 2,
            .pSetLayouts = &layouts,
            .pPushConstantRanges = &matrix_range,
            .pushConstantRangeCount = 1,
        };

        var new_layout: c.VkPipelineLayout = undefined;
        const result = c.vkCreatePipelineLayout(r._device, &mesh_layout_info, null, &new_layout);
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to create descriptor layout ! Reason {d}", .{ result });
            @panic("Failed to create descriptor layout");
        }

        self.opaque_pipeline.layout = new_layout;
        self.transparent_pipeline.layout = new_layout;

        var builder = pipeline.builder_t.init(allocator);
        defer builder.deinit();

        try builder.set_shaders(vertex_shader, frag_shader);
        builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
        builder.set_polygon_mode(c.VK_POLYGON_MODE_FILL);
        builder.set_cull_mode(c.VK_CULL_MODE_NONE, c.VK_FRONT_FACE_CLOCKWISE);
        builder.set_multisampling_none();
        builder.disable_blending();
        builder.enable_depthtest(true, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

        builder.set_color_attachment_format(r._draw_image.format);
        builder.set_depth_format(r._depth_image.format);

        builder._pipeline_layout = new_layout;

        self.opaque_pipeline.pipeline = builder.build_pipeline(r._device);

        builder.enable_blending_additive();
        builder.enable_depthtest(false, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

        self.transparent_pipeline.pipeline = builder.build_pipeline(r._device);
    }

    pub fn clear_resources(_: *GLTFMetallic_Roughness, _: c.VkDevice) void {

    }

    pub fn write_material(self: *GLTFMetallic_Roughness, allocator: std.mem.Allocator, device: c.VkDevice, pass: mat.MaterialPass, resources: *const MaterialResources, ds_alloc: *descriptors.DescriptorAllocator2) mat.MaterialInstance {
        const mat_data = mat.MaterialInstance {
            .pass_type = pass,
            .pipeline = if (pass == mat.MaterialPass.Transparent) self.transparent_pipeline else self.opaque_pipeline,
            .material_set = ds_alloc.allocate(allocator, device, self.material_layout, null),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.data_buffer, @sizeOf(MaterialConstants), resources.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        self.writer.write_image(1, resources.color_image.view, resources.color_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        self.writer.write_image(2, resources.metal_rough_image.view, resources.metal_rough_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.writer.update_set(device, mat_data.material_set);

        return mat_data;
    }

    pub fn write_material_compat(self: *GLTFMetallic_Roughness, device: c.VkDevice, pass: mat.MaterialPass, resources: *const MaterialResources, ds_alloc: *descriptors.DescriptorAllocator) mat.MaterialInstance {
        const mat_data = mat.MaterialInstance {
            .pass_type = pass,
            .pipeline = if (pass == mat.MaterialPass.Transparent) self.transparent_pipeline else self.opaque_pipeline,
            .material_set = ds_alloc.allocate(device, self.material_layout),
        };

        self.writer.clear();
        self.writer.write_buffer(0, resources.data_buffer, @sizeOf(MaterialConstants), resources.data_buffer_offset, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
        self.writer.write_image(1, resources.color_image.view, resources.color_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
        self.writer.write_image(2, resources.metal_rough_image.view, resources.metal_rough_sampler, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);

        self.writer.update_set(device, mat_data.material_set);

        return mat_data;
    }
};

pub const LoadedGLTF = struct {
    arena: std.heap.ArenaAllocator, // use to allocate resources stored in hash maps

    meshes: std.hash_map.StringHashMap(*assets.MeshAsset),
    nodes: std.hash_map.StringHashMap(*m.Node),
    images: std.hash_map.StringHashMap(*vk_images.image_t),
    materials: std.hash_map.StringHashMap(*mat.MaterialInstance),

    top_nodes: std.ArrayList(*m.Node),
    
    samplers: std.ArrayList(c.VkSampler),
    sampler_linear: c.VkSampler = undefined,
    sampler_nearest: c.VkSampler = undefined,

    error_checker_board_image: vk.image.image_t,
    white_image: vk.image.image_t,

    descriptor_pool: descriptors.DescriptorAllocator2,

    material_data_buffer: buffers.AllocatedBuffer,

    renderer: *renderer.renderer_t,

    pub fn init(allocator: std.mem.Allocator, r: *renderer.renderer_t) LoadedGLTF {
        var gltf = LoadedGLTF {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .meshes = undefined,
            .nodes = undefined,
            .images = undefined,
            .materials = undefined,
            .top_nodes = undefined,
            .samplers = undefined,
            .error_checker_board_image = undefined,
            .white_image = undefined,
            .descriptor_pool = undefined,
            .material_data_buffer = undefined,
            .renderer = r,
        };

        gltf.meshes = std.hash_map.StringHashMap(*assets.MeshAsset).init(allocator);
        gltf.nodes = std.hash_map.StringHashMap(*m.Node).init(allocator);
        gltf.images = std.hash_map.StringHashMap(*vk_images.image_t).init(allocator);
        gltf.materials = std.hash_map.StringHashMap(*mat.MaterialInstance).init(allocator);
        gltf.top_nodes = std.ArrayList(*m.Node).init(allocator);
        gltf.samplers = std.ArrayList(c.VkSampler).init(allocator);

        const white: u32 align(4) = maths.pack_unorm4x8(.{ 1, 1, 1, 1 });
        gltf.white_image = vk.image.create_image_data(r._vma, r._device, @ptrCast(&white), .{ .width = 1, .height = 1, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &r.submit.fence, r.submit.cmd, r._queues.graphics);

        const black: u32 align(4) = maths.pack_unorm4x8(.{ 0, 0, 0, 0 });
        const magenta: u32 align(4) = maths.pack_unorm4x8(.{ 1, 0, 1, 1 });
        var pixels: [16 * 16]u32 = [_]u32 { 0 } ** (16 * 16);
        for (0..16) |x| {
            for (0..16) |y| {
                pixels[(y * 16) + x] = if(((x % 2) ^ (y % 2)) != 0) magenta else black; 
            }
        }

        gltf.error_checker_board_image = vk.image.create_image_data(r._vma, r._device, @ptrCast(&pixels), .{ .width = 16, .height = 16, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &r.submit.fence, r.submit.cmd, r._queues.graphics);

        const nearest_sampler_image = c.VkSamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_NEAREST,
            .minFilter = c.VK_FILTER_NEAREST,
        };

        var result = c.vkCreateSampler(r._device, &nearest_sampler_image, null, &gltf.sampler_nearest);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to create nearest sampler. {d}", .{ result });
        }

        const linear_sampler_image = c.VkSamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_LINEAR,
            .minFilter = c.VK_FILTER_LINEAR,
        };

        result = c.vkCreateSampler(r._device, &linear_sampler_image, null, &gltf.sampler_linear);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to create linear sampler. {d}", .{ result });
        }

        return gltf;
    }

    pub fn deinit(self: *LoadedGLTF, device: c.VkDevice, vma: c.VmaAllocator) void {
        defer self.arena.deinit(); // free data in hash maps
        defer self.samplers.deinit();
        defer self.nodes.deinit();
        defer self.meshes.deinit();
        defer self.images.deinit();
        defer self.materials.deinit();
        defer self.top_nodes.deinit();
        defer self.descriptor_pool.deinit(device);
        defer self.material_data_buffer.deinit(vma);

        var node_it = self.nodes.iterator();
        while (node_it.next()) |*node| {
            node.value_ptr.*.deinit();
        }

        var mesh_it = self.meshes.iterator();
        while (mesh_it.next()) |*mesh| {
            mesh.value_ptr.*.mesh_buffers.deinit(vma);
            mesh.value_ptr.*.deinit();
        }

        var image_it = self.images.iterator();
        while (image_it.next()) |*image| {
            vk.image.destroy_image(device, vma, image.value_ptr.*);
        }

        vk.image.destroy_image(device, vma, &self.white_image);
        vk.image.destroy_image(device, vma, &self.error_checker_board_image);

        for (self.samplers.items) |sampler| {
            c.vkDestroySampler(device, sampler, null);
        }

        c.vkDestroySampler(device, self.sampler_nearest, null);
        c.vkDestroySampler(device, self.sampler_linear, null);
    }

    pub fn draw(self: *LoadedGLTF, top_matrix: [4][4]f32, ctx: *scenes.DrawContext) void {
        for (self.top_nodes.items) |node| {
            node.*.draw(top_matrix, ctx);
        }
    }

    pub fn find_node(self: *LoadedGLTF, name: []const u8) ?*assets.Node {
        for (self.top_nodes.items) |root| {
            const node = root.find(name);
            if (node) |n| {
                return n;
            }
        }

        return null;
    }

    pub fn deactivate_node(self: *LoadedGLTF, name: []const u8) void {
        for (self.top_nodes.items) |root| {
            const node = root.find(name);
            if (node) |n| {
                n.active = false;
                break;
            }
        }
    }
};

pub fn load_gltf(allocator: std.mem.Allocator, path: []const u8, metallic_roughness: *GLTFMetallic_Roughness, r: *renderer.renderer_t) !LoadedGLTF {
    var scene = LoadedGLTF.init(allocator, r);

    var options: cgltf.options = .{};
    var data: *cgltf.data = undefined;
    const result = cgltf.cgltf_parse_file(&options, path.ptr, @ptrCast(&data));
    if (result != cgltf.result_success) {
        std.debug.panic("Failed to parse gltf file", .{});
    }
    defer cgltf.cgltf_free(data);

    const success = cgltf.cgltf_load_buffers(&options, data, path.ptr);
    if (success != cgltf.result_success) {
        std.log.err("Loading buffers from gltf file failed !", .{});
        @panic("Failed to load buffers!");
    }

    const sizes = [_]descriptors.PoolSizeRatio {
        .{ ._type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, ._ratio = 3 },
        .{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 3 },
        .{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 1 }
    };

    scene.descriptor_pool = descriptors.DescriptorAllocator2.init(allocator, r._device, @intCast(data.materials_count), &sizes);

    // load samplers
    if (data.samplers != null) {
        for (data.samplers[0..data.samplers_count]) |*sampler| {
            const mag_filter = if (sampler.*.mag_filter != 0) sampler.*.mag_filter else cgltf.cgltf_filter_type_nearest;
            const min_filter = if (sampler.*.min_filter != 0) sampler.*.min_filter else cgltf.cgltf_filter_type_nearest;

            const sampler_create_info = c.VkSamplerCreateInfo {
                .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
                .pNext = null,

                .maxLod = c.VK_LOD_CLAMP_NONE,
                .minLod = 0,

                .magFilter = extract_filter(mag_filter),
                .minFilter = extract_filter(min_filter),

                .mipmapMode = extract_mipmap_mode(min_filter),
            };

            var new_sampler: c.VkSampler = undefined;
            const create_result = c.vkCreateSampler(r._device, &sampler_create_info, null, &new_sampler);
            if (create_result != c.VK_SUCCESS) {
                std.log.err("Failed to create sampler ! Reason {d}", .{ create_result });
                @panic("Failed to create sampler !");
            }

            try scene.samplers.append(new_sampler);
        }
    }
    else {
        const nearest_sampler_image = c.VkSamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_NEAREST,
            .minFilter = c.VK_FILTER_NEAREST,
        };

        var sampler_nearest: c.VkSampler = undefined;
        var sampler_create = c.vkCreateSampler(r._device, &nearest_sampler_image, null, &sampler_nearest);
        if (sampler_create != c.VK_SUCCESS) {
            std.log.err("Failed to create sampler ! Reason {d}", .{ result });
            @panic("Failed to create sampler !");
        }

        try scene.samplers.append(sampler_nearest);

        const linear_sampler_image = c.VkSamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_LINEAR,
            .minFilter = c.VK_FILTER_LINEAR,
        };

        var sampler_linear: c.VkSampler = undefined;
        sampler_create = c.vkCreateSampler(r._device, &linear_sampler_image, null, &sampler_linear);
        if (sampler_create != c.VK_SUCCESS) {
            std.log.err("Failed to create sampler ! Reason {d}", .{ result });
            @panic("Failed to create sampler !");
        }

        try scene.samplers.append(sampler_linear);
    }
    
    // local allocator
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    // load textures
    var images = std.hash_map.StringHashMap(*vk.image.image_t).init(allocator);
    defer images.deinit();

    if (data.images != null) {
        for (data.images[0..data.images_count]) |*img| {
            const image = load_image(scene.arena.allocator(), img, r);
            if (image) |it| {
                const name = try scene.arena.allocator().dupe(u8, std.mem.span(img.name));

                try images.put(name, it);
                try scene.images.put(name, it);
            }
            else {
                std.log.warn("Missing image {s}", .{ std.mem.span(img.name) });

                const name = try alloc.dupe(u8, std.mem.span(img.name));
                try images.put(name, &scene.error_checker_board_image);
            }
        }
    }

    // buffer to hold material data
    scene.material_data_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(GLTFMetallic_Roughness.MaterialConstants) * data.materials_count, c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU);

    var data_index: u32 = 0;
    const scene_material_const: [*]GLTFMetallic_Roughness.MaterialConstants = @alignCast(@ptrCast(scene.material_data_buffer.info.pMappedData));

    var materials = std.hash_map.StringHashMap(*mat.MaterialInstance).init(allocator);
    defer materials.deinit();

    for (data.materials[0..data.materials_count]) |*material| {
        const new_mat = scene.arena.allocator().create(mat.MaterialInstance) catch @panic("OOM");
        
        const name = scene.arena.allocator().dupe(u8, std.mem.span(material.name)) catch @panic("OOM");
        scene.materials.put(name, new_mat) catch @panic("OOM");

        materials.put(name, new_mat) catch {
            std.log.err("Failed to append material ! OOM !", .{});
            @panic("OOM");
        };

        const constants = GLTFMetallic_Roughness.MaterialConstants {
            .color_factors = material.pbr_metallic_roughness.base_color_factor,
            .metal_rough_factors = .{ material.pbr_metallic_roughness.metallic_factor, material.pbr_metallic_roughness.roughness_factor, 0, 0 },
            .extra = std.mem.zeroes([14][4]f32),
        };

        scene_material_const[data_index] = constants;
 
        const pass_type = if (material.alpha_mode == cgltf.cgltf_alpha_mode_blend) mat.MaterialPass.Transparent else mat.MaterialPass.MainColor;

        var material_ressources = GLTFMetallic_Roughness.MaterialResources {
            .color_image = scene.white_image,
            .color_sampler = scene.sampler_linear,
            .metal_rough_image = scene.white_image,
            .metal_rough_sampler = scene.sampler_linear,

            .data_buffer = scene.material_data_buffer.buffer,
            .data_buffer_offset = data_index * @sizeOf(GLTFMetallic_Roughness.MaterialConstants),
        };

        if (material.pbr_metallic_roughness.base_color_texture.texture != null) {
            const img = material.pbr_metallic_roughness.base_color_texture.texture.*.image.*.name;
            const sampler: usize = @intFromPtr(material.pbr_metallic_roughness.base_color_texture.texture.*.sampler) - @intFromPtr(&data.samplers[0]);

            const image = images.get(std.mem.span(img)) orelse @panic("something went wrong ?");
            material_ressources.color_image = image.*;
            material_ressources.color_sampler = scene.samplers.items[sampler];
        }

        new_mat.* = metallic_roughness.write_material(allocator, r._device, pass_type, &material_ressources, &scene.descriptor_pool);
        data_index += 1;
    }

    // load meshes
    var vertices = std.ArrayList(buffers.Vertex).init(allocator);
    defer vertices.deinit();

    var indices = std.ArrayList(u32).init(allocator);
    defer indices.deinit();

    var meshes = std.ArrayList(*assets.MeshAsset).init(allocator);
    defer meshes.deinit();

    for (data.meshes[0..data.meshes_count]) |mesh| {
        var asset = try scene.arena.allocator().create(assets.MeshAsset);
        asset.* = assets.MeshAsset.init(allocator, std.mem.span(mesh.name));

        // clear the arrays
        vertices.clearAndFree();
        indices.clearAndFree();

        for (mesh.primitives[0..mesh.primitives_count]) |prim| {
            const indices_count: usize = prim.indices.*.count;

            var surface = assets.GeoSurface {
                .startIndex = @intCast(indices.items.len),
                .count = @intCast(indices_count),
            };

            indices.ensureTotalCapacity(indices.items.len + indices_count) catch @panic("OOM");

            // load indexes
            const offset: u32 = @intCast(vertices.items.len);
            for (0..indices_count) |i| {
                const idx: u32 = @intCast(cgltf.cgltf_accessor_read_index(prim.indices, @intCast(i)));
                try indices.append(idx + offset);
            }

            // load vertex positions
            var pos_accessor: *cgltf.accessor = undefined;
            var normal_accessor: *cgltf.accessor = undefined;
            var uv_accessor: ?*cgltf.accessor = null;
            var color_accessor: ?*cgltf.accessor = null;
            for (prim.attributes[0..prim.attributes_count]) |att| {
                if (att.type == cgltf.attribute_type_position) {
                    pos_accessor = att.data;
                    continue;
                }

                if (att.type == cgltf.attribute_type_normal) {
                    normal_accessor = att.data;
                    continue;
                }

                if (att.type == cgltf.attribute_type_texcoord) {
                    uv_accessor = att.data;
                    continue;
                }

                if (att.type == cgltf.attribute_type_color) {
                    color_accessor = att.data;
                    continue;
                }
            }

            const count = pos_accessor.count;
            try vertices.ensureTotalCapacity(vertices.items.len + count);

            for (0..count) |i| {
                var v: buffers.Vertex = buffers.Vertex {
                    .position = std.mem.zeroes(c.vec3),
                    .normal = std.mem.zeroes(c.vec3),
                    .color = c.vec4{ 1, 1, 1, 1},
                    .uv_x = 0,
                    .uv_y = 0
                };

                var pos: [3]f32 = undefined;
                _ = cgltf.cgltf_accessor_read_float(pos_accessor, i, &pos, 3);

                v.position[0] = pos[0];
                v.position[1] = pos[1];
                v.position[2] = pos[2];

                var normal: [3]f32 = undefined;
                _ = cgltf.cgltf_accessor_read_float(normal_accessor, i, &normal, 3);

                v.normal[0] = normal[0];
                v.normal[1] = normal[1];
                v.normal[2] = normal[2];

                if (color_accessor != null) {
                    var color: [4]f32 = undefined;
                    _ = cgltf.cgltf_accessor_read_float(color_accessor, i, &color, 4);

                    v.color[0] = color[0];
                    v.color[1] = color[1];
                    v.color[2] = color[2];
                    v.color[3] = color[3];
                }
                
                // override color
                // v.color = z.Vec4.fromVec3(z.Vec3.fromSlice(&v.normal), 1.0).data;

                if (uv_accessor != null) {
                    var uv: [2]cgltf.cgltf_float = undefined;
                    _ = cgltf.cgltf_accessor_read_float(uv_accessor, i, &uv, 2);

                    v.uv_x = uv[0];
                    v.uv_y = uv[1];
                }

                if (prim.material != null) {
                    surface.material = materials.get(std.mem.span(prim.material.*.name)) orelse @panic("material not found");
                }
                else {
                    var it = materials.iterator();
                    surface.material = materials.get(it.next().?.key_ptr.*) orelse @panic("material not found");
                }

                try vertices.append(v);
            }

            try asset.surfaces.append(surface);
        }

        asset.mesh_buffers = buffers.GPUMeshBuffers.init(r._vma, indices.items, vertices.items, r);
        try meshes.append(asset);

        // find name
        const name: []u8 = scene.arena.allocator().dupe(u8, std.mem.span(mesh.name)) catch @panic("OOM");
        scene.meshes.put(name, asset) catch @panic("OOM");
    }

    // load nodes
    for (data.nodes[0..data.nodes_count]) |*node| {
        var new_node = try scene.arena.allocator().create(m.Node);
        new_node.* = m.Node.init(allocator);

        if (node.mesh != null) {
            new_node.mesh = scene.meshes.get(std.mem.span(node.mesh.*.name)) orelse @panic("mesh not found");
            new_node._type = m.NodeType.MESH_NODE;
        }

        if (node.has_matrix != 0) {
            for (0..4) |row| {
                for (0..4) |col| {
                    new_node.local_transform[row][col] = node.matrix[row * 4 + col];
                }
            }
        }
        else {
            const t = z.Vec3.new(node.translation[0], node.translation[1], node.translation[2]);
            const rot = z.Quat.new(node.rotation[3], node.rotation[0], node.rotation[1], node.rotation[2]);
            const s = z.Vec3.new(node.scale[0], node.scale[1], node.scale[2]);

            const tm = z.Mat4.identity().translate(t);
            const rm = rot.toMat4();
            const sm = z.Mat4.identity().scale(s);

            const tr = z.Mat4.mul(tm, rm);
            const trs = z.Mat4.mul(tr, sm);

            new_node.local_transform = trs.data;
        }

        const name = try scene.arena.allocator().dupe(u8, std.mem.span(node.name));
        try scene.nodes.put(name, new_node);
    }

    // setup node hiearchy
    for (data.nodes[0..data.nodes_count]) |*node| {
        const scene_node = scene.nodes.get(std.mem.span(node.name)) orelse @panic("node not found");

        if (node.children_count != 0) {
            for (node.children[0..node.children_count]) |child| {
                const child_node = scene.nodes.get(std.mem.span(child.*.name)) orelse @panic("child not found");
                try scene_node.children.append(child_node);
                child_node.parent = scene_node;
            }
        }
    }

    // find top nodes
    var it = scene.nodes.valueIterator();
    while (it.next()) |node| {
        if (node.*.parent == null) {
            try scene.top_nodes.append(node.*);
            node.*.refresh_transform(&z.Mat4.identity().data);
        }
    }

    return scene;
}

pub fn load_image(allocator: std.mem.Allocator, image: *cgltf.image, r: *renderer.renderer_t) ?*vk_images.image_t {
    var new_image: ?*vk_images.image_t = null;

    var width: i32 = 0;
    var height: i32 = 0;
    var nr_channels: i32 = 0;

    if (image.uri != null) {
        if (image.buffer_view != null) {
            @panic("offsets not supported");
        }

        const data = stb.stbi_load(std.mem.span(image.uri), &width, &height, &nr_channels, 4);
        if (data == null) {
            return null;
        }
        defer stb.stbi_image_free(data);

        const image_size = c.VkExtent3D {
            .width = @intCast(width),
            .height = @intCast(height),
            .depth = 1,
        };

        new_image = allocator.create(vk_images.image_t) catch @panic("OOM");

        new_image.?.* = vk_images.create_image_data(r._vma, r._device, @ptrCast(data), image_size, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT,
            false, &r.submit.fence, r.submit.cmd, r._queues.graphics);
    }
    else if (image.buffer_view != null) {
        const view = image.buffer_view.?;
        const buffer = view.*.buffer;
        
        const buffer_data = @intFromPtr(buffer.*.data) + view.*.offset;

        const data = stb.stbi_load_from_memory(buffer_data, @intCast(view.*.size), &width, &height, &nr_channels, 4);
        if (data == null) {
            return null;
        }
        defer stb.stbi_image_free(data);

        const image_size = c.VkExtent3D {
            .width = @intCast(width),
            .height = @intCast(height),
            .depth = 1,
        };

        new_image = allocator.create(vk_images.image_t) catch @panic("OOM");

        new_image.?.* = vk_images.create_image_data(r._vma, r._device, @ptrCast(data), image_size, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT,
            false, &r.submit.fence, r.submit.cmd, r._queues.graphics);
    }

    return new_image;
}

pub fn extract_filter(filter: u32) c.VkFilter {
    if (filter == cgltf.cgltf_filter_type_nearest or
        filter == cgltf.cgltf_filter_type_nearest_mipmap_nearest or
        filter == cgltf.cgltf_filter_type_nearest_mipmap_linear) {
            return c.VK_FILTER_NEAREST;
    }

    if (filter == cgltf.cgltf_filter_type_linear or
        filter == cgltf.cgltf_filter_type_linear_mipmap_nearest or
        filter == cgltf.cgltf_filter_type_linear_mipmap_linear) {
            return c.VK_FILTER_LINEAR;
    }

    return c.VK_FILTER_MAX_ENUM;
}

pub fn extract_mipmap_mode(filter: u32) c.VkSamplerMipmapMode {
    if (filter == cgltf.cgltf_filter_type_nearest_mipmap_nearest or filter == cgltf.cgltf_filter_type_linear_mipmap_nearest) {
            return c.VK_SAMPLER_MIPMAP_MODE_NEAREST;
    }

    if (filter == cgltf.cgltf_filter_type_nearest_mipmap_linear or filter == cgltf.cgltf_filter_type_linear_mipmap_linear) {
            return c.VK_SAMPLER_MIPMAP_MODE_LINEAR;
    }

    return c.VK_SAMPLER_MIPMAP_MODE_MAX_ENUM;
}

const std = @import("std");
const c = @import("../../clibs.zig");
const buffers = @import("../graphics/buffers.zig");
const z = @import("zalgebra");
const mat = @import("../graphics/materials.zig");
const m = @import("../graphics/assets.zig");
const descriptors = @import("../descriptor.zig");
const renderer = @import("../renderer.zig");
const vk_images = @import("../vulkan/image.zig");
const vk = @import("../vulkan/vulkan.zig");
const cgltf = @import("cgltf");
const stb = @import("stb");
const pipeline = @import("../pipeline.zig");
const maths = @import("../../utils/maths.zig");
const assets = @import("../graphics/assets.zig");
const scenes = @import("../scene/scene.zig");
