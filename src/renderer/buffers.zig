pub const AllocatedBuffer = struct {
    buffer: c.VkBuffer = undefined,
    allocation: c.VmaAllocation = undefined,
    info: c.VmaAllocationInfo = undefined,

    pub fn init(vma: c.VmaAllocator, alloc_size: usize, usage: c.VkBufferUsageFlags, memory_usage: c.VmaMemoryUsage) AllocatedBuffer {
	    const buffer_info = c.VkBufferCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
            .pNext = null,
	        .size = alloc_size,
	        .usage = usage,
        };

	    const vmaalloc_info = c.VmaAllocationCreateInfo {
            .usage = memory_usage,
	        .flags = c.VMA_ALLOCATION_CREATE_MAPPED_BIT,
        };

	    var new_buffer: AllocatedBuffer = .{};
	    const result = c.vmaCreateBuffer(vma, &buffer_info, &vmaalloc_info, &new_buffer.buffer, &new_buffer.allocation, &new_buffer.info);
        if (result != c.VK_SUCCESS) {
            log.write("Failed to create buffer with error {x}", .{ result });
        }

	    return new_buffer;
    }

    pub fn deinit(self: *AllocatedBuffer, vma: c.VmaAllocator) void {
        c.vmaDestroyBuffer(vma, self.buffer, self.allocation);
    }
};

pub const Vertex = struct {
    position: [3]f32 align(@alignOf([3]f32)),
    uv_x: f32 align(@alignOf(f32)),
    normal: [3]f32 align(@alignOf([3]f32)),
    uv_y: f32 align(@alignOf(f32)),
    color: [4]f32 align(@alignOf([4]f32)),
};

pub const GPUMeshBuffers = struct {
    index_buffer: AllocatedBuffer,
    vertex_buffer: AllocatedBuffer,
    vertex_buffer_address: c.VkDeviceAddress,

    pub fn init(vma: c.VmaAllocator, indices: []u32, vertices: []Vertex, r: *const engine.renderer_t) GPUMeshBuffers {
        const vertex_buffer_size = vertices.len * @sizeOf(Vertex);
        
        var new_surface = GPUMeshBuffers{
            .index_buffer = undefined,
            .vertex_buffer = undefined,
            .vertex_buffer_address = undefined,
        };
        new_surface.vertex_buffer = AllocatedBuffer.init(vma, vertex_buffer_size, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT | c.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY);

        const device_adress_info = c.VkBufferDeviceAddressInfo {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
            .pNext = null,
            .buffer = new_surface.vertex_buffer.buffer,
        };
	    new_surface.vertex_buffer_address = c.vkGetBufferDeviceAddress(r._device, &device_adress_info);

        const index_buffer_size = indices.len * @sizeOf(u32);
        new_surface.index_buffer = AllocatedBuffer.init(r._vma, index_buffer_size, c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY);

        var staging = AllocatedBuffer.init(r._vma, vertex_buffer_size + index_buffer_size, c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT, c.VMA_MEMORY_USAGE_CPU_ONLY);
        defer staging.deinit(r._vma);

	    const data = staging.info.pMappedData;

	    // copy vertex buffer
        const vertices_ptr: [*]Vertex = @alignCast(@ptrCast(data));
	    @memcpy(vertices_ptr, vertices);

	    // copy index buffer
        const base_ptr: [*]u8 = @ptrCast(data);
        const index_ptr_u8 = base_ptr + vertex_buffer_size;
        const index_ptr: [*]u32 = @as([*]u32, @alignCast(@ptrCast(index_ptr_u8)));
	    @memcpy(index_ptr, indices);

        // submit immediate
        new_surface.submit(vertex_buffer_size, index_buffer_size, &staging, r);

        return new_surface;
    }

    pub fn deinit(self: *GPUMeshBuffers, vma: c.VmaAllocator) void {
        self.index_buffer.deinit(vma);
        self.vertex_buffer.deinit(vma);
    }

    fn submit(self: *GPUMeshBuffers, vertex_buffer_size: usize, index_buffer_size: usize, buffer: *AllocatedBuffer, r: *const engine.renderer_t) void {
        var result = c.vkResetFences(r._device, 1, &r.submit.fence);
        if (result != c.VK_SUCCESS) {
            log.write("vkResetFences failed with error {x}\n", .{ result });
        }

        result = c.vkResetCommandBuffer(r.submit.cmd, 0);
        if (result != c.VK_SUCCESS) {
            log.write("vkResetCommandBuffer failed with error {x}\n", .{ result });
        }

        const begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        result = c.vkBeginCommandBuffer(r.submit.cmd, &begin_info);
        if (result != c.VK_SUCCESS) {
            log.write("vkBeginCommandBuffer failed with error {x}\n", .{ result });
        }

        const vertex_copy = c.VkBufferCopy { 
            .dstOffset = 0,
		    .srcOffset = 0,
		    .size = vertex_buffer_size,
        };

		c.vkCmdCopyBuffer(r.submit.cmd, buffer.buffer, self.vertex_buffer.buffer, 1, &vertex_copy);

		const index_copy = c.VkBufferCopy{ 
            .dstOffset = 0,
		    .srcOffset = vertex_buffer_size,
		    .size = index_buffer_size,
        };

		c.vkCmdCopyBuffer(r.submit.cmd, buffer.buffer, self.index_buffer.buffer, 1, &index_copy);

        result = c.vkEndCommandBuffer(r.submit.cmd);
        if (result != c.VK_SUCCESS) {
            log.write("vkEndCommandBuffer failed with error {x}\n", .{ result });
        }

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
            .pNext = null,
            .commandBuffer = r.submit.cmd,
            .deviceMask = 0
        };

        const submit_info = c.VkSubmitInfo2 {
            .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO_2,
            .pNext = null,
            .flags = 0,

            .pCommandBufferInfos = &cmd_submit_info,
            .commandBufferInfoCount = 1,

            .pSignalSemaphoreInfos = null,
            .signalSemaphoreInfoCount = 0,
            
            .pWaitSemaphoreInfos = null,
            .waitSemaphoreInfoCount = 0,
        };

        result = c.vkQueueSubmit2(r._queues.graphics, 1, &submit_info, r.submit.fence); // TODO : run it on other queue for multithreading
        if (result != c.VK_SUCCESS) {
            log.write("vkQueueSubmit2 failed with error {x}\n", .{ result });
        }

        result = c.vkWaitForFences(r._device, 1, &r.submit.fence, c.VK_TRUE, 9999999999);
        if (result != c.VK_SUCCESS) {
            log.write("vkWaitForFences failed with error {x}\n", .{ result });
        }
    }
};

pub const GPUDrawPushConstants = struct {
    world_matrix: [4][4]f32 align(16) = undefined,
    vertex_buffer: c.VkDeviceAddress = undefined
};

const c = @import("../clibs.zig");
const log = @import("../utils/log.zig");
const engine = @import("../renderer/engine.zig");
