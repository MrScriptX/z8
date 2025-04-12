const c = @import("../clibs.zig");
const log = @import("../utils/log.zig");

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

    pub fn init(vma: c.VmaAllocator, device: c.VkDevice, fence: *c.VkFence, queue: c.VkQueue, indices: []u32, vertices: []Vertex, cmd: c.VkCommandBuffer) GPUMeshBuffers {
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
	    new_surface.vertex_buffer_address = c.vkGetBufferDeviceAddress(device, &device_adress_info);

        const index_buffer_size = indices.len * @sizeOf(u32);
        new_surface.index_buffer = AllocatedBuffer.init(vma, index_buffer_size, c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT | c.VK_BUFFER_USAGE_TRANSFER_DST_BIT, c.VMA_MEMORY_USAGE_GPU_ONLY);

        var staging = AllocatedBuffer.init(vma, vertex_buffer_size + index_buffer_size, c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT, c.VMA_MEMORY_USAGE_CPU_ONLY);
        defer staging.deinit(vma);

	    const data = staging.info.pMappedData;

	    // copy vertex buffer
        const vertices_ptr: [*]Vertex = @alignCast(@ptrCast(data));
	    @memcpy(vertices_ptr, vertices);

        // for (0..vertices.len) |i| {
        //     log.write("vtx[{d}] = ({d}, {d}, {d})\n", .{ i, vertices_ptr[i].position[0], vertices_ptr[i].position[1], vertices_ptr[i].position[2] });
        // }

	    // copy index buffer
        const base_ptr: [*]u8 = @ptrCast(data);
        const index_ptr_u8 = base_ptr + vertex_buffer_size;
        const index_ptr: [*]u32 = @as([*]u32, @alignCast(@ptrCast(index_ptr_u8)));
	    @memcpy(index_ptr, indices);

        // for (0..indices.len) |i| {
        //     log.write("idx[{x}] = {x}\n", .{ i, index_ptr[i] });
        // }

        // submit immediate
        new_surface.submit(device, fence, queue, cmd, vertex_buffer_size, index_buffer_size, &staging);

        return new_surface;
    }

    pub fn deinit(self: *GPUMeshBuffers, vma: c.VmaAllocator) void {
        self.index_buffer.deinit(vma);
        self.vertex_buffer.deinit(vma);
    }

    fn submit(self: *GPUMeshBuffers, device: c.VkDevice, fence: *c.VkFence, queue: c.VkQueue, cmd: c.VkCommandBuffer, vertex_buffer_size: usize, index_buffer_size: usize, buffer: *AllocatedBuffer) void {
        var result = c.vkResetFences(device, 1, fence);
        if (result != c.VK_SUCCESS) {
            log.write("vkResetFences failed with error {x}\n", .{ result });
        }

        result = c.vkResetCommandBuffer(cmd, 0);
        if (result != c.VK_SUCCESS) {
            log.write("vkResetCommandBuffer failed with error {x}\n", .{ result });
        }

        const begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        result = c.vkBeginCommandBuffer(cmd, &begin_info);
        if (result != c.VK_SUCCESS) {
            log.write("vkBeginCommandBuffer failed with error {x}\n", .{ result });
        }

        const vertex_copy = c.VkBufferCopy { 
            .dstOffset = 0,
		    .srcOffset = 0,
		    .size = vertex_buffer_size,
        };

		c.vkCmdCopyBuffer(cmd, buffer.buffer, self.vertex_buffer.buffer, 1, &vertex_copy);

		const index_copy = c.VkBufferCopy{ 
            .dstOffset = 0,
		    .srcOffset = vertex_buffer_size,
		    .size = index_buffer_size,
        };

		c.vkCmdCopyBuffer(cmd, buffer.buffer, self.index_buffer.buffer, 1, &index_copy);

        result = c.vkEndCommandBuffer(cmd);
        if (result != c.VK_SUCCESS) {
            log.write("vkEndCommandBuffer failed with error {x}\n", .{ result });
        }

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
            .signalSemaphoreInfoCount = 0,
            
            .pWaitSemaphoreInfos = null,
            .waitSemaphoreInfoCount = 0,
        };

        result = c.vkQueueSubmit2(queue, 1, &submit_info, fence.*); // TODO : run it on other queue
        if (result != c.VK_SUCCESS) {
            log.write("vkQueueSubmit2 failed with error {x}\n", .{ result });
        }

        result = c.vkWaitForFences(device, 1, fence, c.VK_TRUE, 9999999999);
        if (result != c.VK_SUCCESS) {
            log.write("vkWaitForFences failed with error {x}\n", .{ result });
        }
    }
};

pub const GPUDrawPushConstants = struct {
    world_matrix: [4][4]f32 align(16) = undefined,
    vertex_buffer: c.VkDeviceAddress = undefined
};
