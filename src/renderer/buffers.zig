const c = @import("../clibs.zig");

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
	    _ = c.vmaCreateBuffer(vma, &buffer_info, &vmaalloc_info, &new_buffer.buffer, &new_buffer.allocation, &new_buffer.info);

	    return new_buffer;
    }

    pub fn deinit(self: *AllocatedBuffer, vma: c.VmaAllocator) void {
        c.vmaDestroyBuffer(vma, self.buffer, self.allocation);
    }
};

pub const Vertex = struct {
    position: c.vec3,
    uv_x: f32,
    normal: c.vec3,
    uv_y: f32,
    color: c.vec4,
};

pub const GPUMeshBuffers = struct {
    index_buffer: AllocatedBuffer,
    vertex_buffer: AllocatedBuffer,
    vertex_buffer_address: c.VkDeviceAddress,

    pub fn init(vma: c.VmaAllocator, device: c.VkDevice, fence: c.VkFence, queue: c.VkQueue, indices: []u32, vertices: []Vertex, cmd: c.VkCommandBuffer) GPUMeshBuffers {
        const vertex_buffer_size = vertices.len * @sizeOf(Vertex);
        
        var new_surface = GPUMeshBuffers{
            .index_buffer = undefined,
            .vertex_buffer = undefined,
            .vertex_buffer_address = undefined,
        };
        new_surface.vertex_buffer = AllocatedBuffer.init(vma, vertex_buffer_size, c.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT | c.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY);

        const device_adress_info = c.VkBufferDeviceAddressInfo {
            .sType = c.VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
            .buffer = new_surface.vertex_buffer.buffer
        };
	    new_surface.vertex_buffer_address = c.vkGetBufferDeviceAddress(device, &device_adress_info);

        const index_buffer_size = indices.len * @sizeOf(u32);
        new_surface.index_buffer = AllocatedBuffer.init(vma, index_buffer_size, c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY);

        var staging = AllocatedBuffer.init(vma, vertex_buffer_size + index_buffer_size, c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT, c.VMA_MEMORY_USAGE_CPU_ONLY);
        defer staging.deinit(vma);

	    const data = staging.info.pMappedData;

	    // copy vertex buffer
	    @memcpy(@as([*]Vertex, @alignCast(@ptrCast(data))), vertices.ptr[0..vertices.len]);

	    // copy index buffer
	    @memcpy(@as([*]u32, @alignCast(@ptrCast(data))) + vertices.len, indices.ptr[0..indices.len]); // @as([*]u32, @alignCast(@ptrCast(data[vertex_buffer_size])))
	    
        // submit immediate
        _ = c.vkResetFences(device, 1, &fence);
        _ = c.vkResetCommandBuffer(cmd, 0);

        const begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        _ = c.vkBeginCommandBuffer(cmd, &begin_info);

        const vertex_copy = c.VkBufferCopy { 
            .dstOffset = 0,
		    .srcOffset = 0,
		    .size = vertex_buffer_size,
        };

		c.vkCmdCopyBuffer(cmd, staging.buffer, new_surface.vertex_buffer.buffer, 1, &vertex_copy);

		const index_copy = c.VkBufferCopy{ 
            .dstOffset = 0,
		    .srcOffset = vertex_buffer_size,
		    .size = index_buffer_size,
        };

		c.vkCmdCopyBuffer(cmd, staging.buffer, new_surface.index_buffer.buffer, 1, &index_copy);

        _ = c.vkEndCommandBuffer(cmd);

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
            .pNext = null,
            .commandBuffer = cmd,
            .deviceMask = 0
        };

        const submit_info = c.VkSubmitInfo2 {
            .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO_2,
            .pNext = null,
            .flags = 0,

            .pCommandBufferInfos = &cmd_submit_info,
            .commandBufferInfoCount = 1,

            .pSignalSemaphoreInfos = null,
            .pWaitSemaphoreInfos = null,
            .signalSemaphoreInfoCount = 0,
            .waitSemaphoreInfoCount = 0,
        };

        _ = c.vkQueueSubmit2(queue, 1, &submit_info, fence); // TODO : run it on other queue
        _ = c.vkWaitForFences(device, 1, &fence, c.VK_TRUE, 9999999999);

        return new_surface;
    }

    pub fn deinit(self: *GPUMeshBuffers, vma: c.VmaAllocator) void {
        self.index_buffer.deinit(vma);
        self.vertex_buffer.deinit(vma);
    }
};

pub const GPUDrawPushConstants = struct {
    world_matrix: c.mat4 = undefined,
    vertex_buffer: c.VkDeviceAddress = undefined
};
