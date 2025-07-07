pub const CHUNK_SIZE = 32;
pub const count: u32 = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE;
pub const index_count = count * 36;
pub const vertex_count: u32 = count * 12 * 3;

pub const Mesh = struct {
    indices_buffer: buffers.AllocatedBuffer,
    vertices_buffer: buffers.AllocatedBuffer,
    indirect_buffer: buffers.AllocatedBuffer,

    pub fn init(r: *const renderer.Renderer) Mesh {
        const mesh: Mesh = .{
            .indices_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(u32) * index_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
            .vertices_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(buffers.Vertex) * index_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
            .indirect_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(c.VkDrawIndexedIndirectCommand), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
        };

        return mesh;
    }

    pub fn deinit(self: *Mesh, r: *const renderer.Renderer) void {
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

const std = @import("std");
const c = @import("../../clibs.zig");
const buffers = @import("../../engine/graphics/buffers.zig");
const renderer = @import("../../engine/renderer.zig");
