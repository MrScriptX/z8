pub const RenderObject = struct {
    index_count: u32,
    first_index: u32,
    index_buffer: c.VkBuffer,
    
    vertex_buffer: c.VkBuffer = null,
    vertex_buffer_offset: c.VkDeviceSize = 0,

    indirect_buffer: c.VkBuffer = null,
    indirect_buffer_offset: u32 = 0,

    material: *MaterialInstance,

    transform: maths.mat4 align(16),
    vertex_buffer_address: c.VkDeviceAddress,
};

pub const IndirectDrawObject = struct {
    max_draw: u32,
    draw_commands: buffers.AllocatedBuffer,
    draw_count: buffers.AllocatedBuffer,

    indices_buffer: buffers.AllocatedBuffer,
    vertices_buffer: buffers.AllocatedBuffer,

    pub fn init(r: *const renderer.Renderer, max_cmd_count: usize) IndirectDrawObject {
        return .{
            .max_draw = @intCast(max_cmd_count),
            .draw_commands = buffers.AllocatedBuffer.init(r._vma, @sizeOf(c.VkDrawIndexedIndirectCommand) * max_cmd_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .draw_count = buffers.AllocatedBuffer.init(r._vma, @sizeOf(u32), c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .indices_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(u32) * max_cmd_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
            .vertices_buffer = buffers.AllocatedBuffer.init(r._vma, @sizeOf(buffers.Vertex) * max_cmd_count, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY),
        };
    }

    pub fn deinit(self: *IndirectDrawObject, vma: c.VmaAllocator) void {
        self.draw_commands.deinit(vma);
        self.draw_count.deinit(vma);
        self.indices_buffer.deinit(vma);
        self.vertices_buffer.deinit(vma);
    }
};

pub const MaterialPipeline = struct {
    pipeline: c.VkPipeline = null,
    layout: c.VkPipelineLayout = null,
};

pub const MaterialInstance = struct {
    pipeline: *MaterialPipeline,
    material_set: c.VkDescriptorSet,
    pass_type: MaterialPass,
};

pub const MaterialPass = enum(u8) {
    MainColor,
    Transparent,
    Other,
};

const renderer = @import("../renderer.zig");
const c = @import("../../clibs.zig");
const maths = @import("../../utils/maths.zig");
const images = @import("../vulkan/image.zig");
const buffers = @import("../graphics/buffers.zig");
