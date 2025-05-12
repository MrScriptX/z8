const cube_vertex_count = 36;

pub const Voxel = struct {
    vertex_buffer: buffers.AllocatedBuffer,
    compute_pipeline: *shader.ComputeEffect,
    graphic_pipeline: *materials.MaterialPipeline,

    pub fn init(vma: c.VmaAllocator, p: *shader.ComputeEffect) Voxel {
        const buffer_size = @sizeOf(buffers.Vertex) * cube_vertex_count;

        return .{
            .vertex_buffer = buffers.AllocatedBuffer.init(vma, buffer_size, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
            .pipeline = p,
        };
    }

    pub fn deinit(self: *Voxel, vma: c.VmaAllocator) void {
        self.vertex_buffer.deinit(vma);
    }

    pub fn compute(self: *Voxel, cmd: c.VkCommandBuffer, descriptor_set: c.VkDescriptorSet) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_pipeline.pipeline);
        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, self.compute_pipeline.layout, 0, 1, &descriptor_set, 0, null);
        c.vkCmdDispatch(cmd, cube_vertex_count, 1, 1);

        const barrier = c.VkBufferMemoryBarrier {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask = c.VK_ACCESS_SHADER_WRITE_BIT,
            .dstAccessMask = c.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT,
            .srcQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = c.VK_QUEUE_FAMILY_IGNORED,
            .buffer = self.vertex_buffer.buffer,
            .offset = 0,
            .size = @sizeOf(buffers.Vertex) * cube_vertex_count,
        };

        c.vkCmdPipelineBarrier(cmd, c.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, c.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT, 0, 0, null, 0, null, 1, &barrier);
    }

    pub fn draw(self: *Voxel, cmd: c.VkCommandBuffer) void {
        c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, self.graphic_pipeline.pipeline);
        c.vkCmdBindVertexBuffers(cmd, 0, 1, &self.vertex_buffer.buffer, 0);
        c.vkCmdDraw(cmd, cube_vertex_count, 1, 0, 0);
    }
};

const std = @import("std");
const c = @import("clibs.zig");
const buffers = @import("engine/graphics/buffers.zig");
const shader = @import("engine/compute_effect.zig");
const materials = @import("engine/graphics/materials.zig");
