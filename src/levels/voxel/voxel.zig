pub const CHUNK_SIZE = 32;
pub const count: u32 = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE;
pub const index_count = count * 36;
pub const vertex_count: u32 = count * 12 * 3;

pub const Mesh = struct {
    indices_buffer: buffers.AllocatedBuffer,
    vertices_buffer: buffers.AllocatedBuffer,
    indirect_buffer: buffers.AllocatedBuffer,

    pub fn init(r: *const Renderer) Mesh {
        const mesh: Mesh = .{
            .indices_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(u32) * index_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
            .vertices_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(buffers.Vertex) * index_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
            .indirect_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(c.VkDrawIndexedIndirectCommand), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
        };

        return mesh;
    }

    pub fn deinit(self: *Mesh, r: *const Renderer) void {
        self.indices_buffer.deinit(r._vma);
        self.vertices_buffer.deinit(r._vma);
        self.indirect_buffer.deinit(r._vma);
    }

    /// This is a template for the mesh resource.
    pub const Resource = struct {
        vertex_buffer: c.VkBuffer,
        vertex_buffer_offset: u32 = 0,

        index_buffer: c.VkBuffer,
        index_buffer_offset: u32 = 0,

        indirect_buffer: c.VkBuffer,
        indirect_buffer_offset: u32 = 0,
    };
};

pub const ShadowMap = struct {
    pub const Map = struct {
        view: vk.ImageView = undefined,
        split: f16,
        buffer: buffers.AllocatedBuffer,
    };

    pub const DIM = 2048; // can be 4096 ? Make it dynamic maybe ?

    allocator: std.mem.Allocator,
    image: vk.Image,
    allocation: c.VmaAllocation,
    sampler: vk.Sampler,
    cascade: [4]Map,
    material: mats.ShadowMap,

    pub fn init(allocator: std.mem.Allocator, r: *const Renderer) !ShadowMap {
        var shadow_image: vk.Image = undefined;
        const image_info = vk.ImageCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            .pNext = null,

            .imageType = c.VK_IMAGE_TYPE_2D,
            .extent = .{
                .width = DIM,
                .height = DIM,
                .depth = 1
            },
            .mipLevels = 1,
            .arrayLayers = 4,
            .samples = c.VK_SAMPLE_COUNT_1_BIT,
            .tiling = c.VK_IMAGE_TILING_OPTIMAL,
            .format = c.VK_FORMAT_D32_SFLOAT, // find optimal depth format : https://github.com/SaschaWillems/Vulkan/blob/master/base/VulkanDevice.cpp#L567
            .usage = c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT | c.VK_IMAGE_USAGE_SAMPLED_BIT
        };

        var shadow_image_alloc: c.VmaAllocation = undefined;
        const img_alloc_info = c.VmaAllocationCreateInfo {
            .usage = c.VMA_MEMORY_USAGE_GPU_ONLY,
            .requiredFlags = c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        };

        const result = c.vmaCreateImage(r._vma, &image_info, &img_alloc_info, &shadow_image, &shadow_image_alloc, null);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to allocate shadow map image {d}", .{ result });
            return vk.Error.ERROR_UNKNOWN; // TODO : port the vkresult of vma
        }
        errdefer c.vmaDestroyImage(r._vma, shadow_image, shadow_image_alloc);

        const sampler_create_info = vk.SamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_LINEAR,
            .minFilter = c.VK_FILTER_LINEAR,
            .mipmapMode = c.VK_SAMPLER_MIPMAP_MODE_LINEAR,
            .addressModeU = c.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            .addressModeV = c.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            .addressModeW = c.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            .mipLodBias = 0,
            .maxAnisotropy = 1,
            .minLod = 0,
            .maxLod = 1,
            .borderColor = c.VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE
        };

        var sampler: vk.Sampler = undefined;
        vk.CreateSampler(r._device, &sampler_create_info, null, &sampler) catch |err| {
            std.log.warn("Failed to create sampler", .{});
            return err;
        };
        errdefer vk.DestroySampler(r._device, sampler, null);

        var shadow_map = ShadowMap {
            .allocator = allocator,
            .image = shadow_image,
            .allocation = shadow_image_alloc,
            .sampler = sampler,
            .cascade = .{
                .{ .split = 0.02, .buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf([4][4]f32), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) },
                .{ .split = 0.1, .buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf([4][4]f32), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) },
                .{ .split = 0.3, .buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf([4][4]f32), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) },
                .{ .split = 1.0, .buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf([4][4]f32), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) }
            },
            .material = mats.ShadowMap.init(allocator)
        };

        for (&shadow_map.cascade, 0..) |*map, i| {
            const image_view_info = vk.ImageViewCreateInfo {
                .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
                .viewType = c.VK_IMAGE_VIEW_TYPE_2D_ARRAY,
                .format = c.VK_FORMAT_D32_SFLOAT,
                .subresourceRange = .{
                    .aspectMask = c.VK_IMAGE_ASPECT_DEPTH_BIT,
                    .baseMipLevel = 0,
                    .levelCount = 1,
                    .baseArrayLayer = @intCast(i),
                    .layerCount = 1
                },
                .image = shadow_image
            };

            vk.CreateImageView(r._device, &image_view_info, null, &map.view) catch |err| {
                return err;
            };
            errdefer vk.DestroyImageView(r._device, map.view, null);
        }

        const dir = try std.fs.selfExeDirPathAlloc(allocator);
        defer allocator.free(dir);

        const shadowmap_shader = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, "shaders/aurora/shadowmap.vert.spv" });
        defer allocator.free(shadowmap_shader);

        try shadow_map.material.build(allocator, shadowmap_shader, r);

        return shadow_map;
    }

    pub fn deinit(self: *ShadowMap, r: *const Renderer) void {
        self.material.deinit(r._device);

        for (self.cascade) |map| {
            vk.DestroyImageView(r._device, map.view, null);
        }

        vk.DestroySampler(r._device, self.sampler, null);
        c.vmaDestroyImage(r._vma, self.image, self.allocation);
    }
};

const std = @import("std");
const c = @import("../../clibs.zig");
const mats = @import("materials.zig");
const vk = @import("../../engine/vulkan/vk_wrapper.zig");
const buffers = @import("../../engine/graphics/buffers.zig");
const Renderer = @import("../../engine/renderer.zig").Renderer;
