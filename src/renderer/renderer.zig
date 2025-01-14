const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const queue = @import("queue_family.zig");
const utils = @import("utils.zig");
const app_t = @import("app.zig").app_t;
const swapchain_t = @import("swapchain.zig").swapchain_t;
const frame_t = @import("frames.zig").frame_t;
const renderer = struct {
    usingnamespace @import("swapchain.zig");
    usingnamespace @import("depth.zig");
    usingnamespace @import("command_buffer.zig");
};
const inits = struct {
    usingnamespace @import("inits.zig");
};

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

    pub fn init(self: *renderer_t, window: ?*sdl.SDL_Window) !void {
        try self.app.init(window);

        // print device info
        utils.print_device_info(self.app.physical_device);
    
        self.queues = try queue.get_device_queue(self.app.device, self.app.queue_indices);

        // create swapchain
        const window_extent = c.VkExtent2D{
            .width = 800,
            .height = 600,
        };
        self.swapchain = try renderer.create_swapchain(self.app, window_extent);    
        self.swapchain.images = try renderer.create_swapchain_images(self.app, self.swapchain);
        self.swapchain.depth = try renderer.create_depth_ressources(self.app, self.swapchain);

        self.renderpass = try inits.create_render_pass(self.swapchain.format, self.swapchain.depth.format, self.app.device);

        self.command_pool = try renderer.create_command_pool(self.app.device, self.app.queue_indices.graphics_family);
        self.command_buffers = try renderer.create_command_buffer(3, self.app.device, self.command_pool);

        for (&self.frames, 0..self.frames.len) |*frame, i| {
            try frame.init(self.app.device);

            var attachements = [2]c.VkImageView{ self.swapchain.images.image_views[i], self.swapchain.depth.view };
            frame.buffer = try inits.create_framebuffer(self.app.device, self.renderpass, &attachements, self.swapchain.extent);
        }
    }

    pub fn deinit(self: *renderer_t) void {
        self.clean_swapchain();

        for (&self.frames) |*frame| {
            frame.deinit(self.app.device);
        }

        c.vkDestroyDevice(self.app.device, null);
        c.vkDestroySurfaceKHR(self.app.instance, self.app.surface, null);
        c.vkDestroyInstance(self.app.instance, null);
    }

    pub fn clean_swapchain(self: *renderer_t) void {
        _ = c.vkDeviceWaitIdle(self.app.device);
        _ = c.vkQueueWaitIdle(self.queues.graphics_queue);
	    _ = c.vkQueueWaitIdle(self.queues.present_queue);

        c.vkDestroyImageView(self.app.device, self.swapchain.depth.view, null);
	    c.vkDestroyImage(self.app.device, self.swapchain.depth.image, null);
	    c.vkFreeMemory(self.app.device, self.swapchain.depth.mem, null);

        for (&self.frames) |*frame| {
            c.vkDestroyFramebuffer(self.app.device, frame.buffer, null);
        }

        for (self.swapchain.images.image_views) |image_view| {
            c.vkDestroyImageView(self.app.device, image_view, null);
        }

        c.vkDestroyCommandPool(self.app.device, self.command_pool, null);

        c.vkDestroyRenderPass(self.app.device, self.renderpass, null);

        c.vkDestroySwapchainKHR(self.app.device, self.swapchain.handle, null);
    }

    pub fn draw(self: *renderer_t) void {
        _ = c.vkWaitForFences(self.app.device, 1, &self.frames[self.current_frame].render_fence, c.VK_TRUE, 1000);
        _ = c.vkResetFences(self.app.device, 1, &self.frames[self.current_frame].render_fence);

        // acquire next image
        self.last_frame = self.current_frame;
        _ = c.vkAcquireNextImageKHR(self.app.device, self.swapchain.handle, 1000, self.frames[self.current_frame].image_available_sem, null, &self.current_frame);

        // begin command buffer
        const current_cmd_buffer = &self.command_buffers[self.current_frame]; 
        _ = c.vkResetCommandBuffer(current_cmd_buffer.*, 0);

        const command_buffer_begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .flags = c.VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT,
        };

        _ = c.vkBeginCommandBuffer(current_cmd_buffer.*, &command_buffer_begin_info);


        // begin render pass
        const render_area = c.VkRect2D {
            .offset = c.VkOffset2D {.x = 0, .y = 0},
            .extent = self.swapchain.extent,
        };
        
        const clear_values = [2]c.VkClearValue{
            c.VkClearValue{.color = c.VkClearColorValue { 
                .float32 = [4]f32{1.0,0.0,0.0,1.0}               
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

        _ = c.vkCmdEndRenderPass(current_cmd_buffer.*);
        _ = c.vkEndCommandBuffer(current_cmd_buffer.*);


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

        _ = c.vkQueueSubmit(self.queues.graphics_queue, 1, &submit_info, self.frames[self.current_frame].render_fence);

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
};
