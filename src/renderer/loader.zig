pub const GLTFMaterial = struct {
    data: mat.MaterialInstance
};

pub const GeoSurface = struct {
    startIndex: u32,
    count: u32,
    material: *GLTFMaterial = undefined,
};

pub const MeshAsset = struct {
    arena: std.heap.ArenaAllocator,
    
    name: []const u8,

    surfaces: std.ArrayList(GeoSurface),
    meshBuffers: buffers.GPUMeshBuffers,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) MeshAsset {
        var asset = MeshAsset {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .name = undefined,
            .surfaces = std.ArrayList(GeoSurface).init(allocator),
            .meshBuffers = undefined,
        };

        asset.name = asset.arena.allocator().dupe(u8, name) catch @panic("OOM");

        return asset;
    }

    pub fn deinit(self: *MeshAsset) void {
        self.surfaces.deinit();
        self.arena.deinit();
    }
};

pub fn load_gltf_meshes(allocator: std.mem.Allocator, path: []const u8, vma: c.VmaAllocator, device: c.VkDevice, fence: *c.VkFence, queue: c.VkQueue, cmd: c.VkCommandBuffer) !std.ArrayList(MeshAsset) {
    var options: cgltf.options = .{};
    var data: *cgltf.data = undefined;
    const result = cgltf.cgltf_parse_file(&options, path.ptr, @ptrCast(&data));
    if (result != cgltf.result_success) {
        std.debug.panic("Failed to parse gltf file", .{});
    }
    defer cgltf.cgltf_free(data);

    const success = cgltf.cgltf_load_buffers(&options, data, path.ptr);
    if (success != cgltf.result_success) {
        std.debug.panic("Failed to load buffers!\n", .{});
    }

    var vertices = std.ArrayList(buffers.Vertex).init(std.heap.page_allocator);
    defer vertices.deinit();

    var indices = std.ArrayList(u32).init(std.heap.page_allocator);
    defer indices.deinit();
        
    var meshes = std.ArrayList(MeshAsset).init(allocator);

    for (data.meshes[0..data.meshes_count]) |mesh| {
        var asset = MeshAsset.init(allocator, std.mem.span(mesh.name));

        vertices.clearAndFree();
        indices.clearAndFree();

        for (mesh.primitives[0..mesh.primitives_count]) |prim| {
            const indices_count: usize = prim.indices.*.count;

            const surface = GeoSurface {
                .startIndex = @intCast(indices.items.len),
                .count = @intCast(indices_count),
            };

            try indices.ensureTotalCapacity(indices.items.len + indices_count);

            // load indexes
            const offset: u32 = @intCast(vertices.items.len);
            for (0..indices_count) |i| {
                const idx: u32 = @intCast(cgltf.cgltf_accessor_read_index(prim.indices, @intCast(i)));
                try indices.append(idx + offset);
            }

            // load vertex positions
            var pos_accessor: *cgltf.accessor = undefined;
            var normal_accessor: *cgltf.accessor = undefined;
            var uv_accessor: *cgltf.accessor = undefined;
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
                

                var uv: [2]f32 = undefined;
                _ = cgltf.cgltf_accessor_read_float(uv_accessor, i, &uv, 2);

                v.uv_x = uv[0];
                v.uv_y = uv[1];

                // override color
                // v.color = z.Vec4.fromVec3(z.Vec3.fromSlice(&v.normal), 1.0).data;

                try vertices.append(v);
            }

            try asset.surfaces.append(surface);
        }

        asset.meshBuffers = buffers.GPUMeshBuffers.init(vma, device, fence, queue, indices.items, vertices.items, cmd);
        try meshes.append(asset);
    }

    return meshes;
}

pub const LoadedGLTF = struct {
    arena: std.heap.ArenaAllocator,

    meshes: std.hash_map.StringHashMap(*MeshAsset),
    nodes: std.hash_map.StringHashMap(*m.Node),
    images: std.hash_map.StringHashMap(buffers.AllocatedBuffer),
    materials: std.hash_map.StringHashMap(*GLTFMaterial),

    top_nodes: std.ArrayList(*m.Node),
    
    samplers: std.hash_map.StringHashMap(c.VkSampler),

    descriptor_pool: descriptors.DescriptorAllocator2,

    material_data_buffer: buffers.AllocatedBuffer,

    renderer: *engine.renderer_t,

    pub fn init(allocator: std.mem.Allocator, renderer: *engine.renderer_t) LoadedGLTF {
        var gltf = LoadedGLTF {
            .arena = std.heap.ArenaAllocator.init(allocator),
            .meshes = undefined,
            .nodes = undefined,
            .images = undefined,
            .materials = undefined,
            .top_nodes = undefined,
            .samplers = undefined,
            .descriptor_pool = undefined,
            .material_data_buffer = undefined,
            .renderer = renderer,
        };

        gltf.meshes = std.hash_map.StringHashMap(*MeshAsset).init(gltf.arena.allocator());
        gltf.nodes = std.hash_map.StringHashMap(*m.Node).init(gltf.arena.allocator());
        gltf.images = std.hash_map.StringHashMap(buffers.AllocatedBuffer).init(gltf.arena.allocator());
        gltf.materials = std.hash_map.StringHashMap(*GLTFMaterial).init(gltf.arena.allocator());
        gltf.top_nodes = std.ArrayList(*m.Node).init(gltf.arena.allocator());
        gltf.samplers = std.hash_map.StringHashMap(c.VkSampler).init(gltf.arena.allocator());

        return gltf;
    }

    pub fn deinit(_: *LoadedGLTF) void {

    }

    pub fn draw(self: *LoadedGLTF, top_matrix: *const c.mat4s, ctx: *m.DrawContext) void {
        for (self.top_nodes) |node| {
            node.draw(top_matrix, ctx);
        }
    }

    pub fn clear(_: *LoadedGLTF) void {

    }
};

pub fn load_gltf(allocator: std.mem.Allocator, path: []const u8, device: c.VkDevice, fence: *c.VkFence, queue: c.VkQueue, cmd: c.VkCommandBuffer, vma: c.VmaAllocator, renderer: *engine.renderer_t) LoadedGLTF {
    var scene = LoadedGLTF.init(allocator, renderer);

    var options: c.cgltf_options = .{};
    var data: *c.cgltf_data = undefined;
    const result = c.cgltf_parse_file(&options, path.ptr, @ptrCast(&data));
    if (result != c.cgltf_result_success) {
        std.debug.panic("Failed to parse gltf file", .{});
    }
    defer c.cgltf_free(data);

    const success = c.cgltf_load_buffers(&options, data, path.ptr);
    if (success != c.cgltf_result_success) {
        std.debug.panic("Failed to load buffers!\n", .{});
    }

    const sizes = [_]descriptors.PoolSizeRatio {
        .{ c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 3 },
        .{ c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 3 },
        .{ c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1 }
    };

    scene.descriptor_pool.init(device, data.materials_count, sizes);
    
    for (data.samplers[0..data.samplers_count]) |*sampler| {
        const mag_filter = if (sampler.*.mag_filter != 0) sampler.*.mag_filter else c.cgltf_filter_type_nearest;
        const min_filter = if (sampler.*.min_filter != 0) sampler.*.min_filter else c.cgltf_filter_type_nearest;

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
        const create_result = c.vkCreateSampler(device, &sampler_create_info, null, &new_sampler);
        if (create_result != c.VK_SUCCESS) {
            log.err("Failed to create sampler ! Reason {d}", .{ create_result });
            @panic("Failed to create sampler !");
        }

        const name = scene.arena.allocator().dupe(u8, sampler.*.name);
        scene.samplers.put(name, new_sampler) catch {
            log.err("Failed to append new sampler ! OOM !", .{});
            @panic("OOM");
        };
    }

    // local allocator
    const arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    // load textures
    var images = std.hash_map.StringHashMap(vk_images.image_t).init(allocator);
    defer images.deinit();

    for (data.images[0..data.images_count]) |img| {
        const name = alloc.dupe(u8, img.name);
        images.put(name, engine.renderer_t._error_checker_board_image) catch {
            log.err("Failed to append image ! OOM !", .{});
            @panic("OOM");
        };
    }

    // buffer to hold material data
    scene.material_data_buffer = buffers.AllocatedBuffer.init(vma, @sizeOf(mat.GLTFMetallic_Roughness.MaterialConstants) * data.materials_count, c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU);

    var data_index: i32 = 0;
    const scene_material_const: *mat.GLTFMetallic_Roughness.MaterialConstants = @alignCast(@ptrCast(scene.material_data_buffer.info.pMappedData));

    var materials = std.hash_map.StringHashMap(GLTFMaterial).init(allocator);
    defer materials.deinit();

    for (data.materials[0..data.materials_count]) |*material| {
        var new_mat = allocator.create(GLTFMaterial);
        
        const name = scene.arena.allocator().dupe(u8, std.mem.span(material.name));
        scene.materials.put(name, new_mat);

        materials.put(name, new_mat) catch {
            log.err("Failed to append material ! OOM !", .{});
            @panic("OOM");
        };

        const constants = mat.GLTFMetallic_Roughness.MaterialConstants {
            .color_factors = material.pbr_metallic_roughness.base_color_factor,
            .metal_rough_factors = .{ material.pbr_metallic_roughness.metallic_factor, material.pbr_metallic_roughness.roughness_factor, 0, 0 },
        };

        scene_material_const[data_index] = constants;
 
        const pass_type = if (material.alpha_mode == c.cgltf_alpha_mode_blend) mat.MaterialPass.Transparent else mat.MaterialPass.MainColor;

        var material_ressources = mat.GLTFMetallic_Roughness.MaterialResources {
            .color_image = engine.renderer_t._white_image,
            .color_sampler = engine.renderer_t._default_sampler_linear,
            .metal_rough_image = engine.renderer_t._white_image,
            .metal_rough_sampler = engine.renderer_t._default_sampler_linear,

            .data_buffer = scene.material_data_buffer.buffer,
            .data_buffer_offset = data_index * @sizeOf(mat.GLTFMetallic_Roughness.MaterialConstants),
        };

        if (material.pbr_metallic_roughness.base_color_texture.texture != null) {
            const img = material.pbr_metallic_roughness.base_color_texture.texture.*.image.*.name;
            const sampler = material.pbr_metallic_roughness.base_color_texture.texture.*.sampler.*.name;

            material_ressources.color_image = images.get(img);
            material_ressources.color_sampler = scene.samplers.get(sampler);
        }

        new_mat.data = renderer._metal_rough_material.write_material(device, pass_type, material_ressources, scene.descriptor_pool);
        data_index += 1;
    }

    // load meshes
    var vertices = std.ArrayList(buffers.Vertex).init(allocator);
    defer vertices.deinit();

    var indices = std.ArrayList(u32).init(allocator);
    defer indices.deinit();

    var meshes = std.ArrayList(*MeshAsset).init(allocator);
    defer meshes.deinit();

    for (data.meshes[0..data.meshes_count]) |mesh| {
        var asset = MeshAsset.init(scene.arena.allocator(), std.mem.span(mesh.name));
        meshes.append(mesh) catch @panic("OOM");

        const name = scene.arena.allocator().dupe(u8, mesh.name);
        scene.meshes.put(name, asset);

        // clear the arrays
        vertices.clearAndFree();
        indices.clearAndFree();

        for (mesh.primitives[0..mesh.primitives_count]) |prim| {
            const indices_count: usize = prim.indices.*.count;

            const surface = GeoSurface {
                .startIndex = @intCast(indices.items.len),
                .count = @intCast(indices_count),
            };

            try indices.ensureTotalCapacity(indices.items.len + indices_count);

            // load indexes
            const offset: u32 = @intCast(vertices.items.len);
            for (0..indices_count) |i| {
                const idx: u32 = @intCast(c.cgltf_accessor_read_index(prim.indices, @intCast(i)));
                try indices.append(idx + offset);
            }

            // load vertex positions
            var pos_accessor: *c.cgltf_accessor = undefined;
            var normal_accessor: *c.cgltf_accessor = undefined;
            var uv_accessor: *c.cgltf_accessor = undefined;
            var color_accessor: ?*c.cgltf_accessor = null;
            for (prim.attributes[0..prim.attributes_count]) |att| {
                if (att.type == c.cgltf_attribute_type_position) {
                    pos_accessor = att.data;
                    continue;
                }

                if (att.type == c.cgltf_attribute_type_normal) {
                    normal_accessor = att.data;
                    continue;
                }

                if (att.type == c.cgltf_attribute_type_texcoord) {
                    uv_accessor = att.data;
                    continue;
                }

                if (att.type == c.cgltf_attribute_type_color) {
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

                var pos: [3]c.cgltf_float = undefined;
                _ = c.cgltf_accessor_read_float(pos_accessor, i, &pos, 3);

                v.position[0] = pos[0];
                v.position[1] = pos[1];
                v.position[2] = pos[2];

                var normal: [3]c.cgltf_float = undefined;
                _ = c.cgltf_accessor_read_float(normal_accessor, i, &normal, 3);

                v.normal[0] = normal[0];
                v.normal[1] = normal[1];
                v.normal[2] = normal[2];

                if (color_accessor != null) {
                    var color: [4]c.cgltf_float = undefined;
                    _ = c.cgltf_accessor_read_float(color_accessor, i, &color, 4);

                    v.color[0] = color[0];
                    v.color[1] = color[1];
                    v.color[2] = color[2];
                    v.color[3] = color[3];
                }
                
                // override color
                // v.color = z.Vec4.fromVec3(z.Vec3.fromSlice(&v.normal), 1.0).data;

                var uv: [2]c.cgltf_float = undefined;
                _ = c.cgltf_accessor_read_float(uv_accessor, i, &uv, 2);

                v.uv_x = uv[0];
                v.uv_y = uv[1];

                if (prim.material != null) {
                    surface.material = materials.get(prim.material.*.name);
                }
                else {
                    surface.material = materials.iterator().next().?.value_ptr.*;
                }

                try vertices.append(v);
            }

            try asset.surfaces.append(surface);
        }

        asset.meshBuffers = buffers.GPUMeshBuffers.init(vma, device, fence, queue, indices.items, vertices.items, cmd);
        try meshes.append(asset);
    }

    // load nodes
    for (data.nodes[0..data.nodes_count]) |*node| {
        var new_node = scene.arena.allocator().create(m.Node);

        if (node.mesh != null) {
            new_node.mesh = scene.meshes.get(node.mesh.*.name);
            new_node._type = m.NodeType.MESH_NODE;
        }

        const name = scene.arena.allocator().dupe(u8, node.name);
        scene.nodes.put(name, new_node);

        if (node.has_matrix) {
            @memcpy(new_node.local_transform, node.matrix);
        }
        else {
            const t = z.Vec3.new(node.translation[0], node.translation[1], node.translation[2]);
            const r = z.Quat.new(node.rotation[3], node.rotation[0], node.rotation[1], node.rotation[2]);
            const s = z.Vec3.new(node.scale[0], node.scale[1], node.scale[2]);

            const tm = z.Mat4.identity().translate(t);
            const rm = r.toMat4();
            const sm = z.Mat4.identity().scale(s);

            new_node.local_transform = z.Mat4.mul(tm, rm).mul(sm).data;
        }
    }

    // setup node hiearchy
    for (data.nodes[0..data.nodes_count]) |*node| {
        const scene_node = scene.nodes.get(node.name);

        for (node.children) |child| {
            const child_node = scene.nodes.get(child.*.name);
            scene_node.?.children.append(child_node);
            child_node.?.parent = scene_node;
        }
    }

    // find top nodes
    const it = scene.nodes.iterator();
    while (it.next()) |node| {
        if (node.value_ptr.parent == null) {
            scene.top_nodes.append(node);
            node.value_ptr.refresh_transform(z.Mat4.identity().data);
        }
    }

    return scene;
}

pub fn extract_filter(filter: i32) c.VkFilter {
    if (filter == c.cgltf_filter_type_nearest or
        filter == c.cgltf_filter_type_nearest_mipmap_nearest or
        filter == c.cgltf_filter_type_nearest_mipmap_linear) {
            return c.VK_FILTER_NEAREST;
    }

    if (filter == c.cgltf_filter_type_linear or
        filter == c.cgltf_filter_type_linear_mipmap_nearest or
        filter == c.cgltf_filter_type_linear_mipmap_linear) {
            return c.VK_FILTER_LINEAR;
    }
}

pub fn extract_mipmap_mode(filter: i32) c.VkSamplerMipmapMode {
    if (filter == c.cgltf_filter_type_nearest_mipmap_nearest or filter == c.cgltf_filter_type_linear_mipmap_nearest) {
            return c.VK_SAMPLER_MIPMAP_MODE_NEAREST;
    }

    if (filter == c.cgltf_filter_type_nearest_mipmap_linear or filter == c.cgltf_filter_type_linear_mipmap_linear) {
            return c.VK_SAMPLER_MIPMAP_MODE_LINEAR;
    }
}

const std = @import("std");
const c = @import("../clibs.zig");
const buffers = @import("buffers.zig");
const log = @import("../utils/log.zig");
const z = @import("zalgebra");
const mat = @import("material.zig");
const m = @import("mesh.zig");
const descriptors = @import("descriptor.zig");
const engine = @import("engine.zig");
const vk_images = @import("vk_images.zig");
const cgltf = @import("cgltf");
