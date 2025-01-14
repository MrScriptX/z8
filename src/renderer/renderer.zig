const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});
const c = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const app_t = @import("types.zig").app_t;
const swapchain_t = @import("types.zig").swapchain_t;
const renderer = struct {
    usingnamespace @import("app.zig");
    usingnamespace @import("window.zig");
    usingnamespace @import("device.zig");
    usingnamespace @import("swapchain.zig");
    usingnamespace @import("depth.zig");
    usingnamespace @import("command_buffer.zig");
    usingnamespace @import("syncs.zig");
};

const frame_t = struct {
    render_fence: c.VkFence = undefined,
    render_finished_sem: c.VkSemaphore = undefined,
    image_available_sem: c.VkSemaphore = undefined,

    pub fn init(self: *frame_t, device: c.VkDevice) !void {
        self.render_fence = try renderer.create_fence(device);
        self.render_finished_sem = try renderer.create_semaphore(device);
        self.image_available_sem = try renderer.create_semaphore(device);
    }

    pub fn deinit(self: *frame_t, device: c.VkDevice) void {
        c.vkDestroySemaphore(device, self.image_available_sem, null);
        self.image_available_sem = undefined;

        c.vkDestroySemaphore(device, self.render_finished_sem, null);
        self.render_finished_sem = undefined;

        c.vkDestroyFence(device, self.render_fence, null);
        self.image_available_sem = undefined;
    }
};

pub const renderer_t = struct {
    app: app_t = undefined,
    swapchain: swapchain_t = undefined,
    command_pool: c.VkCommandPool = undefined,
    command_buffers: [3]c.VkCommandBuffer = undefined,
    frames: [3]frame_t = undefined,
    current_frame: u8 = 0,

    pub fn init(self: *renderer_t, window: ?*sdl.SDL_Window) !void {
        self.app.instance = try renderer.init_instance();
        self.app.surface = try renderer.create_surface(window, self.app.instance);

        self.app.physical_device = try renderer.select_physical_device(self.app);

        // print device info
        renderer.print_device_info(self.app.physical_device);

        self.app.queues.queue_family_indices = try renderer.find_queue_family(self.app.surface, self.app.physical_device);
        self.app.device = try renderer.create_device_interface(self.app);
    
        self.app.queues = try renderer.get_device_queue(self.app);

        // create swapchain
        const window_extent = c.VkExtent2D{
            .width = 800,
            .height = 600,
        };
        self.swapchain = try renderer.create_swapchain(self.app, window_extent);    
        self.swapchain.images = try renderer.create_swapchain_images(self.app, self.swapchain);
        self.swapchain.depth = try renderer.create_depth_ressources(self.app, self.swapchain);

        self.command_pool = try renderer.create_command_pool(self.app.device, self.app.queues.queue_family_indices.graphics_family);
        self.command_buffers = try renderer.create_command_buffer(3, self.app.device, self.command_pool);

        for (&self.frames) |*frame| {
            try frame.init(self.app.device);
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
        _ = c.vkQueueWaitIdle(self.app.queues.graphics_queue);
	    _ = c.vkQueueWaitIdle(self.app.queues.present_queue);

        c.vkDestroyImageView(self.app.device, self.swapchain.depth.view, null);
	    c.vkDestroyImage(self.app.device, self.swapchain.depth.image, null);
	    c.vkFreeMemory(self.app.device, self.swapchain.depth.mem, null);

        for (self.swapchain.images.image_views) |image_view| {
            c.vkDestroyImageView(self.app.device, image_view, null);
        }

        c.vkDestroyCommandPool(self.app.device, self.command_pool, null);

        c.vkDestroySwapchainKHR(self.app.device, self.swapchain.handle, null);
    }

    pub fn draw(self: *renderer_t) void {
        _ = c.vkWaitForFences(self.app.device, 1, &self.frames[self.current_frame].render_fence, c.VK_TRUE, 1000);
        _ = c.vkResetFences(self.app.device, 1, &self.frames[self.current_frame].render_fence);

        var image_index: u32 = 0;
        _ = c.vkAcquireNextImageKHR(self.app.device, self.swapchain.handle, 1000, self.frames[self.current_frame].image_available_sem, null, &image_index);

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
            .renderArea = render_area,
            .clearValueCount = clear_values.len,
            .pClearValues = @ptrCast(&clear_values)
        };

        _ = c.vkCmdBeginRenderPass(current_cmd_buffer.*, &render_pass_begin_info, c.VK_SUBPASS_CONTENTS_INLINE);

        _ = c.vkCmdEndRenderPass(current_cmd_buffer.*);
        _ = c.vkEndCommandBuffer(current_cmd_buffer.*);


        // submit queue
        const cmd_buffers_to_submit = [1]c.VkCommandBuffer{ current_cmd_buffer.* };
        const wait_sem = [1]c.VkSemaphore{ self.frames[self.current_frame].image_available_sem };
        const wait_dst_stage = [1]u32{ c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT };
        const submit_info = c.VkSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO,
            .pWaitDstStageMask = @ptrCast(&wait_dst_stage),
            .commandBufferCount = cmd_buffers_to_submit.len,
            .pCommandBuffers = @ptrCast(&cmd_buffers_to_submit),
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = @ptrCast(&wait_sem),
        };

        _ = c.vkQueueSubmit(self.app.queues.graphics_queue, 1, &submit_info, self.frames[self.current_frame].render_fence);

        const pswapchain = [1]c.VkSwapchainKHR { self.swapchain.handle };
        const present_info = c.VkPresentInfoKHR {
            .sType = c.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = @ptrCast(&wait_sem),
            .swapchainCount = 1,
            .pSwapchains = @ptrCast(&pswapchain),
            .pImageIndices = self.current_frame,
        };

        _ = c.vkQueuePresentKHR(self.app.queues.present_queue, &present_info);
    }
};
