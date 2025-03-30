const std = @import("std");
const c = @import("../clibs.zig");
const queue = @import("queue_family.zig");
const utils = @import("utils.zig");
const app_t = @import("app.zig").app_t;
const swapchain_t = @import("swapchain.zig").swapchain_t;
const frame_t = @import("frames.zig").frame_t;
const renderer = struct {
    usingnamespace @import("swapchain.zig");
};
const inits = @import("inits.zig");

pub const renderer_t = struct {
    app: app_t = undefined,
    queues: queue.queues_t = undefined,
    swapchain: swapchain_t = undefined,
    renderpass: c.VkRenderPass = undefined,
    command_pool: c.VkCommandPool = undefined,
    command_buffers: [3]c.VkCommandBuffer = undefined,
    frames: [3]frame_t = undefined,
    current_frame: u32 = 0,
    last_frame: u32 = 0,

    vertex_buffer: c.VkBuffer = undefined,
    vertex_buffer_mem: c.VkDeviceMemory = undefined,
    index_buffer: c.VkBuffer = undefined,
    index_buffer_mem: c.VkDeviceMemory = undefined, 

    pub fn init(self: *renderer_t, window: ?*c.SDL_Window, width: u32, height: u32) !void {
        try self.app.init(window);

        // print device info
        utils.print_device_info(self.app.physical_device);
    
        self.queues = try queue.get_device_queue(self.app.device, self.app.queue_indices);

        // create swapchain
        try self.swapchain.init(self.app, width, height);

        self.renderpass = try inits.create_render_pass(self.swapchain.format, self.swapchain.depth.format, self.app.device);
        self.command_pool = try utils.create_command_pool(self.app.device, self.app.queue_indices.graphics_family);
        self.command_buffers = try utils.create_command_buffer(3, self.app.device, self.command_pool);

        for (&self.frames, 0..self.frames.len) |*frame, i| {
            try frame.init(self.app.device);

            var attachements = [2]c.VkImageView{ self.swapchain.images.image_views[i], self.swapchain.depth.view };
            frame.buffer = try inits.create_framebuffer(self.app.device, self.renderpass, &attachements, self.swapchain.extent);
        }

        // _ = try utils.create_pipeline(self.app.device, self.swapchain.extent);

        // self.update();
    }

    pub fn deinit(self: *renderer_t) void {
        c.vkDestroyBuffer(self.app.device, self.vertex_buffer, null);
        c.vkFreeMemory(self.app.device, self.vertex_buffer_mem, null);
        
        c.vkDestroyBuffer(self.app.device, self.index_buffer, null);
        c.vkFreeMemory(self.app.device, self.index_buffer_mem, null);

        try self.clean_swapchain();

        for (&self.frames) |*frame| {
            frame.deinit(self.app.device);
        }

        c.vkDestroyDevice(self.app.device, null);
        c.vkDestroySurfaceKHR(self.app.instance, self.app.surface, null);
        c.vkDestroyInstance(self.app.instance, null);
    }

    pub fn clean_swapchain(self: *renderer_t) !void {
        var result = c.vkDeviceWaitIdle(self.app.device);
        if (result != c.VK_SUCCESS) {
            return std.debug.panic("wait for device idle failed : {}", .{result});
        }

        result = c.vkQueueWaitIdle(self.queues.graphics_queue);
        if (result != c.VK_SUCCESS) {
            return std.debug.panic("wait for graphic queue family failed : {}", .{result});
        }

	    result = c.vkQueueWaitIdle(self.queues.present_queue);
        if (result != c.VK_SUCCESS) {
            return std.debug.panic("wait for present queue family failed : {}", .{result});
        }

        for (&self.frames) |*frame| {
            c.vkDestroyFramebuffer(self.app.device, frame.buffer, null);
        }

        c.vkDestroyCommandPool(self.app.device, self.command_pool, null);
        c.vkDestroyRenderPass(self.app.device, self.renderpass, null);

        self.swapchain.deinit(self.app);
    }

    pub fn begin_cmd(self: *renderer_t) !void {
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 
        _ = c.vkResetCommandBuffer(current_cmd_buffer.*, 0);

        const command_buffer_begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .flags = c.VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT,
        };

        _ = c.vkBeginCommandBuffer(current_cmd_buffer.*, &command_buffer_begin_info);
    }

    pub fn begin_renderpass(self: *renderer_t) !void {
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 

        const render_area = c.VkRect2D {
            .offset = c.VkOffset2D {.x = 0, .y = 0},
            .extent = self.swapchain.extent,
        };
        
        const clear_values = [2]c.VkClearValue{
            c.VkClearValue{.color = c.VkClearColorValue { 
                .float32 = [4]f32{ 1.0, 1.0, 0.0, 1.0 }               
            }},
            c.VkClearValue{.depthStencil = c.VkClearDepthStencilValue{.depth = 1.0, .stencil = 0.0}}
        };

        const render_pass_begin_info = c.VkRenderPassBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
            .renderPass = self.renderpass,
            .framebuffer = self.frames[self.current_frame].buffer,
            .renderArea = render_area,
            .clearValueCount = clear_values.len,
            .pClearValues = @ptrCast(&clear_values),
        };

        _ = c.vkCmdBeginRenderPass(current_cmd_buffer.*, &render_pass_begin_info, c.VK_SUBPASS_CONTENTS_INLINE);
    }

    pub fn end_recording(self: *renderer_t) !void {
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 

        _ = c.vkCmdEndRenderPass(current_cmd_buffer.*);
        _ = c.vkEndCommandBuffer(current_cmd_buffer.*);
    }

    pub fn update(self: *renderer_t) void {
        _ = c.vkWaitForFences(self.app.device, 1, &self.frames[self.current_frame].render_fence, c.VK_TRUE, std.math.maxInt(u64));
        _ = c.vkResetFences(self.app.device, 1, &self.frames[self.current_frame].render_fence);

        // acquire next image
        self.last_frame = self.current_frame;
        _ = c.vkAcquireNextImageKHR(self.app.device, self.swapchain.handle, std.math.maxInt(u64), self.frames[self.current_frame].image_available_sem, null, &self.current_frame);

        try self.begin_cmd();

        // record buffer
        try self.record_vertices_buffer();
        try self.record_indices_buffer();

        try self.begin_renderpass();

        try self.end_recording();
    }

    pub fn draw(self: *renderer_t) void {
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 

        // submit queue
        const cmd_buffers_to_submit = [1]c.VkCommandBuffer{ current_cmd_buffer.* };
        const wait_sem = [1]c.VkSemaphore{ self.frames[self.current_frame].image_available_sem };
        const signal_sem = [_]c.VkSemaphore{self.frames[self.current_frame].render_finished_sem};
        const wait_dst_stage = [1]u32{ c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT };
        const submit_info = c.VkSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO,
            .pWaitDstStageMask = @ptrCast(&wait_dst_stage),
            .commandBufferCount = cmd_buffers_to_submit.len,
            .pCommandBuffers = @ptrCast(&cmd_buffers_to_submit),
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = @ptrCast(&wait_sem),
            .signalSemaphoreCount = 1,
            .pSignalSemaphores = @ptrCast(&signal_sem),
        };

        _ = c.vkResetFences(self.app.device, 1, &self.frames[self.current_frame].render_fence);

        const result = c.vkQueueSubmit(self.queues.graphics_queue, 1, &submit_info, self.frames[self.current_frame].render_fence);
        if (result != c.VK_SUCCESS) {
            std.debug.panic("failed to submit draw command buffer !", .{});
        }

        const pswapchain = [1]c.VkSwapchainKHR { self.swapchain.handle };
        const present_info = c.VkPresentInfoKHR {
            .sType = c.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = @ptrCast(&signal_sem),
            .swapchainCount = 1,
            .pSwapchains = @ptrCast(&pswapchain),
            .pImageIndices = &self.current_frame,
        };

        _ = c.vkQueuePresentKHR(self.queues.present_queue, &present_info);
    }

    pub fn record_vertices_buffer(self: *renderer_t) !void {
        const vertices = [_]f32{
            -1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            -1.0, 1.0, -1.0,
            1.0, 1.0, -1.0,
            -1.0, -1.0, 1.0,
            1.0, -1.0, 1.0,
            -1.0, 1.0, 1.0,
            1.0, 1.0, 1.0
        };

        const buffer_size: c.VkDeviceSize = @sizeOf(@TypeOf(vertices)) * 1;

        const staging_buffer = try utils.create_buffer(self.app.device, buffer_size, c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT);
        defer c.vkDestroyBuffer(self.app.device, staging_buffer, null);
        
        const staging_buffer_mem = try utils.allocate_buffer(self.app.device, self.app.physical_device, staging_buffer, c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
        defer c.vkFreeMemory(self.app.device, staging_buffer_mem, null);

        var data: ?*anyopaque = undefined;
	    _ = c.vkMapMemory(self.app.device, staging_buffer_mem, 0, buffer_size, 0, &data);
        defer c.vkUnmapMemory(self.app.device, staging_buffer_mem);

        @memcpy(@as([*]f32, @alignCast(@ptrCast(data))), &vertices);

        self.vertex_buffer = try utils.create_buffer(self.app.device, buffer_size, c.VK_BUFFER_USAGE_TRANSFER_DST_BIT | c.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT);
        self.vertex_buffer_mem = try utils.allocate_buffer(self.app.device, self.app.physical_device, self.vertex_buffer, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);

        // copy buffer into command buffer
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 
        const copy_region = c.VkBufferCopy{
            .size = buffer_size,
        };
	    c.vkCmdCopyBuffer(current_cmd_buffer.*, staging_buffer, self.vertex_buffer, 1, &copy_region);
    }

    pub fn record_indices_buffer(self: *renderer_t) !void {
        const indices = [_]u32{
            0, 2, 1,
            1, 2, 3,
            5, 7, 4,
            4, 7, 6,
            1, 3, 5,
            5, 3, 7,
            4, 6, 0,
            0, 6, 2,
            2, 6, 0,
            0, 6, 2,
            2, 6, 3,
            3, 6, 7,
            4, 0, 5,
            5, 0, 1,
        };

        const buffer_size: c.VkDeviceSize = @sizeOf(@TypeOf(indices)) * 1;

        const staging_buffer = try utils.create_buffer(self.app.device, buffer_size, c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT);
        const staging_buffer_mem = try utils.allocate_buffer(self.app.device, self.app.physical_device, staging_buffer, c.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | c.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);

        var data: ?*anyopaque = undefined;
	    const result = c.vkMapMemory(self.app.device, staging_buffer_mem, 0, buffer_size, 0, &data);
        if (result != c.VK_SUCCESS) {
            std.debug.panic("mapping memory failed !", .{});
        }
        defer c.vkUnmapMemory(self.app.device, staging_buffer_mem);

        @memcpy(@as([*]u32, @alignCast(@ptrCast(data))), &indices);
	    
        self.index_buffer = try utils.create_buffer(self.app.device, buffer_size, c.VK_BUFFER_USAGE_TRANSFER_DST_BIT | c.VK_BUFFER_USAGE_INDEX_BUFFER_BIT);
        self.index_buffer_mem = try utils.allocate_buffer(self.app.device, self.app.physical_device, self.index_buffer, c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);

        // copy buffer into command buffer
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 
        const copy_region = c.VkBufferCopy{
            .size = buffer_size,
        };
	    c.vkCmdCopyBuffer(current_cmd_buffer.*, staging_buffer, self.index_buffer, 1, &copy_region);

        c.vkDestroyBuffer(self.app.device, staging_buffer, null);
        c.vkFreeMemory(self.app.device, staging_buffer_mem, null);
    }
};
