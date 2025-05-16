const Error = error{
    Failed,
    VulkanInit,
    SwapchainInit,
    SkipImage,
    OutOfDate,
};

pub const stats_t = struct {
    frame_time: f32 = 0,
    triangle_count: u32 = 0,
    drawcall_count: u32 = 0,
    scene_update_time: f32 = 0,
    mesh_draw_time: f32 = 0,
};

const submit_t = struct {
    fence: c.VkFence = undefined,
    cmd: c.VkCommandBuffer = undefined,
    pool: c.VkCommandPool = undefined,

    pub fn start_recording(self: *submit_t, r: *const renderer_t) void {
        var result = c.vkResetFences(r._device, 1, &self.fence);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetFences failed with error {d}", .{ result });
        }

        result = c.vkResetCommandBuffer(self.cmd, 0);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetCommandBuffer failed with error {d}", .{ result });
        }

        const begin_info = c.VkCommandBufferBeginInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        result = c.vkBeginCommandBuffer(self.cmd, &begin_info);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkBeginCommandBuffer failed with error {d}", .{ result });
        }
    }

    pub fn submit(self: *submit_t, r: *const renderer_t) void {
        var result = c.vkEndCommandBuffer(self.cmd);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkEndCommandBuffer failed with error {d}", .{ result });
        }

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
            .pNext = null,
            .commandBuffer = self.cmd,
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

        result = c.vkQueueSubmit2(r._queues.graphics, 1, &submit_info, self.fence); // TODO : run it on other queue for multithreading
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkQueueSubmit2 failed with error {d}", .{ result });
        }

        result = c.vkWaitForFences(r._device, 1, &self.fence, c.VK_TRUE, 9999999999);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkWaitForFences failed with error {d}", .{ result });
        }
    }
};

pub const renderer_t = struct {
    var _render_scale: f32 = 1.0;

    // pipelines
    var _gui_context: gui.GuiContext = undefined;

    pub var _black_image: vk.image.image_t = undefined;
    pub var _grey_image: vk.image.image_t = undefined;

    var _single_image_descriptor_layout: c.VkDescriptorSetLayout = undefined;

    var _loaded_scenes: std.hash_map.StringHashMap(*loader.LoadedGLTF) = undefined;

    // memory allocators
    _arena: std.heap.ArenaAllocator = undefined,
    _vma: c.VmaAllocator = undefined,

    // vulkan instance objects
    _instance: c.VkInstance = undefined,
    _surface: c.VkSurfaceKHR = undefined,
    _debug_messenger: c.VkDebugUtilsMessengerEXT = null,
    _gpu: c.VkPhysicalDevice = undefined,
    _device: c.VkDevice = undefined,
    _queues: vk.queue.queues_t = undefined,
    _queue_indices: vk.queue.indices_t = undefined,

    // swapchain
    _sw: vk.sw.swapchain_t = undefined,
    rebuild: bool = false,

    // frames
    _frames: [frames.FRAME_OVERLAP]frames.data_t = undefined,
    _frameNumber: u32 = 0,

    // draw objects
    _draw_image: vk.image.image_t = vk.image.image_t{},
    _depth_image: vk.image.image_t = vk.image.image_t{},
    _draw_extent: c.VkExtent2D = .{},
    _descriptor_pool: descriptor.DescriptorAllocator = undefined,
    _draw_image_descriptor: c.VkDescriptorSetLayout = undefined,
    _draw_image_descriptor_set: c.VkDescriptorSet = undefined,

    // immediate submit structures
    submit: submit_t,

    // scene
    scene_descriptor: c.VkDescriptorSetLayout = undefined,
    _scene: ?*scenes.DrawContext = null, 

    camera: *cam.camera_t,
    stats: stats_t,
    bg_shader: ?*effects.ComputeEffect,

    pub fn init(allocator: std.mem.Allocator, window: ?*sdl.SDL_Window, width: u32, height: u32, camera: *cam.camera_t) !renderer_t {
        var renderer = renderer_t{
            ._arena = std.heap.ArenaAllocator.init(allocator),

            .camera = camera,
            .stats = stats_t{},
            .submit = submit_t{},
            .bg_shader = null,
        };

        std.log.info("Initiliazing vulkan instance...", .{});
        try renderer.init_vulkan(allocator, window);

        std.log.info("Initiliazing the swapchain, res {d}x{d}...", .{ width, height });
        try renderer.init_swapchain(width, height);

        try renderer.init_commands(allocator);
        try renderer.init_descriptors(allocator);

        std.log.info("Initiliazing GUI...", .{});
        _gui_context = gui.GuiContext.init(window, renderer._device, renderer._instance, renderer._gpu, renderer._queues.graphics, &renderer._sw._image_format.format) catch |e| {
            switch (e) {
                gui.Error.PoolAllocFailed => {
                    std.log.err("Failed to create pool for ImGui !", .{});
                    std.process.exit(1);
                },
                gui.Error.ImGuiInitFailed => {
                    std.log.err("Failed to initialize ImGui !", .{});
                    std.process.exit(1);
                },
            }
        };

        renderer.init_default_data(allocator) catch {
            std.log.err("Failed to initialize data !", .{});
            std.process.exit(1);
        };

        return renderer;
    }

    pub fn deinit(self: *renderer_t) void {
        defer self._arena.deinit();

        const result = c.vkDeviceWaitIdle(self._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device idle ! Reason {d}.", .{result});
        }

        vk.image.destroy_image(self._device, self._vma, &_grey_image);
        vk.image.destroy_image(self._device, self._vma, &_black_image);

        for (&self._frames) |*frame| {
            frame.deinit(self._device, self._vma);
        }

        // destroy imgui context
        _gui_context.deinit(self._device);

        c.vkDestroyFence(self._device, self.submit.fence, null);
        c.vkDestroyCommandPool(self._device, self.submit.pool, null);

        self.destroy_swapchain();

        c.vmaDestroyAllocator(self._vma);

        c.vkDestroySurfaceKHR(self._instance, self._surface, null);
        c.vkDestroyDevice(self._device, null);

        // if (_debug_messenger != undefined) {
        //     vk.destroy_debug_messenger(_instance, _debug_messenger);
        // }

        c.vkDestroyInstance(self._instance, null);
    }

    fn init_vulkan(self: *renderer_t, allocator: std.mem.Allocator, window: ?*sdl.SDL_Window) !void {
        self._instance = try vk.init.init_instance(allocator);
        self._surface = try vk.init.create_surface(window, self._instance);
        self._gpu = try vk.init.select_physical_device(allocator, self._instance, self._surface);
        self._device = try vk.init.create_device_interface(allocator, self._gpu, self._queue_indices);
        self._queues = try vk.init.get_device_queue(self._device, self._queue_indices);

        const allocator_info = c.VmaAllocatorCreateInfo {
            .physicalDevice = self._gpu,
            .device = self._device,
            .instance = self._instance,
            .vulkanApiVersion = c.VK_API_VERSION_1_3,
            .flags = c.VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT,
        };
    
        const result = c.vmaCreateAllocator(&allocator_info, &self._vma);
        if (result != c.VK_SUCCESS) {
            std.log.err("Failed to create allocator ! Reason {d}", .{ result });
            return Error.VulkanInit;
        }
    }

    fn init_swapchain(self: *renderer_t, width: u32, height: u32) !void {
        const window_extent = c.VkExtent2D{
            .width = width,
            .height = height,
        };

        self._sw = try vk.sw.swapchain_t.init(self._arena.allocator(),self._device, self._gpu, self._surface, window_extent, self._queue_indices);

        //draw image size will match the window
	    const draw_image_extent = c.VkExtent3D {
		    .width = width,
		    .height = height,
		    .depth = 1
	    };

        self._draw_image.format = c.VK_FORMAT_R16G16B16A16_SFLOAT;
        self._draw_image.extent = draw_image_extent;

        var draw_image_usages: c.VkImageUsageFlags = 0;
	    draw_image_usages |= c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
	    draw_image_usages |= c.VK_IMAGE_USAGE_STORAGE_BIT;
	    draw_image_usages |= c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

        const image_create_info = vk.image.create_image_info(self._draw_image.format, draw_image_usages, draw_image_extent);

        const rimg_allocinfo = c.VmaAllocationCreateInfo {
            .usage = c.VMA_MEMORY_USAGE_GPU_ONLY,
            .requiredFlags = c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        };

        _ = c.vmaCreateImage(self._vma, &image_create_info, &rimg_allocinfo, &self._draw_image.image, &self._draw_image.allocation, null);

        const image_view_info = vk.image.create_imageview_info(self._draw_image.format, self._draw_image.image, c.VK_IMAGE_ASPECT_COLOR_BIT);
        _ = c.vkCreateImageView(self._device, &image_view_info, null, &self._draw_image.view);

        // depth image
        self._depth_image.format = c.VK_FORMAT_D32_SFLOAT;
        self._depth_image.extent = draw_image_extent;

        var depth_image_usages: c.VkImageUsageFlags = 0;
	    depth_image_usages |= c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;

        const depth_create_info = vk.image.create_image_info(self._depth_image.format, depth_image_usages, self._depth_image.extent);

        _ = c.vmaCreateImage(self._vma, &depth_create_info, &rimg_allocinfo, &self._depth_image.image, &self._depth_image.allocation, null);

        const depth_view_info = vk.image.create_imageview_info(self._depth_image.format, self._depth_image.image, c.VK_IMAGE_ASPECT_DEPTH_BIT);
        _ = c.vkCreateImageView(self._device, &depth_view_info, null, &self._depth_image.view);
    }

    fn init_commands(self: *renderer_t, allocator: std.mem.Allocator,) !void {
        self._frames = [_]frames.data_t{
            frames.data_t{},
            frames.data_t{},
        };

        for (&self._frames) |*frame| {
            try frame.init(allocator, self._device, self._queue_indices.graphics);
        }

        self.submit.pool = try frames.create_command_pool(self._device, self._queue_indices.graphics);
        self.submit.cmd = try frames.create_command_buffer(1, self._device, self.submit.pool);
        self.submit.fence = try frames.create_fence(self._device);
    }

    fn init_descriptors(self: *renderer_t, allocator: std.mem.Allocator) !void {
        const sizes = [_]descriptor.PoolSizeRatio{
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, ._ratio = 3 },
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 3 },
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 3 },
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, ._ratio = 4 },
        };

	    self._descriptor_pool = try descriptor.DescriptorAllocator.init(allocator, self._device, 10, &sizes);

	    //make the descriptor set layout for our compute draw
	    {
		    var builder = descriptor.DescriptorLayout.init(allocator);
            defer builder.deinit();

		    try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE);
		    self._draw_image_descriptor = builder.build(self._device, c.VK_SHADER_STAGE_COMPUTE_BIT, null, 0);
	    }

        self._draw_image_descriptor_set = self._descriptor_pool.allocate(self._device, self._draw_image_descriptor);

        var writer = descriptor.Writer.init(allocator);
        defer writer.deinit();
    
        writer.write_image(0, self._draw_image.view, null, c.VK_IMAGE_LAYOUT_GENERAL, c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE);
        writer.update_set(self._device, self._draw_image_descriptor_set);


        for (&self._frames) |*frame| {
            const frame_size = [_]descriptor.PoolSizeRatio {
                descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, ._ratio = 3 },
                descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 3 },
                descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 3 },
                descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, ._ratio = 4 },
            };
            frame._frame_descriptors = descriptor.DescriptorAllocator2.init(allocator, self._device, 1000, &frame_size);
        }

        // make descriptor for gpu scene data
        {
            var builder = descriptor.DescriptorLayout.init(allocator);
            defer builder.deinit();

		    try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
		    self.scene_descriptor = builder.build(self._device, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);
        }

        {
            var builder = descriptor.DescriptorLayout.init(allocator);
            defer builder.deinit();

		    try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
		    _single_image_descriptor_layout = builder.build(self._device, c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);
        }
    }

    fn current_frame(self: *renderer_t) *frames.data_t {
        return &self._frames[self._frameNumber % frames.FRAME_OVERLAP];
    }

    fn abs(n: f32) f32 {
        return @max(-n, n);
    }

    fn next_image(self: *renderer_t) Error!u32 {
        var result = c.vkWaitForFences(self._device, 1, &self.current_frame()._render_fence, c.VK_TRUE, 1000000000);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkWaitForFences failed with error {d}\n", .{ result });
            self._frameNumber += 1;
            return Error.SkipImage;
        }

        self.current_frame().flush(self._vma);
        self.current_frame()._frame_descriptors.clear(self._device);

        // compute draw extent
        const min_width: f32 = @floatFromInt(@min(self._sw._extent.width, self._draw_image.extent.width));
        const min_height: f32 = @floatFromInt(@min(self._sw._extent.height, self._draw_image.extent.height));

        self._draw_extent.width = @intFromFloat(min_width * _render_scale); // TODO : convert render_scale to int and divide to scale back
        self._draw_extent.height = @intFromFloat(min_height * _render_scale);

        var image_index: u32 = 0;
        result = c.vkAcquireNextImageKHR(self._device, self._sw._sw, 1000000000, self.current_frame()._sw_semaphore, null, &image_index);
        switch(result) {
            c.VK_SUCCESS => {},
            c.VK_ERROR_OUT_OF_DATE_KHR => {
                std.log.info("VK_ERROR_OUT_OF_DATE_KHR - rebuilding swapchain...", .{});
                return Error.OutOfDate;
            },
            c.VK_SUBOPTIMAL_KHR => {
                std.log.info("VK_SUBOPTIMAL_KHR - rebuilding swapchain...", .{});
                return Error.OutOfDate;
            },
            else => {
                std.log.warn("vkAcquireNextImageKHR failed with error {d}\n", .{ result });
                return Error.SkipImage;
            }
        }

        return image_index;
    }

    fn begin_draw(self: *renderer_t) Error!c.VkCommandBuffer {
        var result = c.vkResetFences(self._device, 1, &self.current_frame()._render_fence);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetFences failed with error {x}\n", .{ result });
            return Error.SkipImage;
        }

        result = c.vkResetCommandBuffer(self.current_frame()._main_buffer, 0);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkResetCommandBuffer failed with error {x}\n", .{ result });
            return Error.SkipImage;
        }

        const cmd: c.VkCommandBuffer = self.current_frame()._main_buffer;
        const cmd_buffer_begin_info = c.VkCommandBufferBeginInfo{
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .pInheritanceInfo = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        result = c.vkBeginCommandBuffer(cmd, &cmd_buffer_begin_info);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkBeginCommandBuffer failed with error {d}\n", .{ result });
            return Error.SkipImage;
        }

        return cmd;
    }

    fn submit_cmd(self: *renderer_t, cmd: c.VkCommandBuffer, image_index: u32) void {
        var result = c.vkEndCommandBuffer(cmd);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkEndCommandBuffer failed with error {x}\n", .{ result });
        }

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
	        .pNext = null,
	        .commandBuffer = cmd,
	        .deviceMask = 0,
        };

        const wait_info = utils.semaphore_submit_info(c.VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT_KHR, self.current_frame()._sw_semaphore);
        const signal_info = utils.semaphore_submit_info(c.VK_PIPELINE_STAGE_2_ALL_GRAPHICS_BIT, self.current_frame()._render_semaphore);

        const submit_info = c.VkSubmitInfo2 {
            .sType = c.VK_STRUCTURE_TYPE_SUBMIT_INFO_2,
            .pNext = null,
            .waitSemaphoreInfoCount = 1,
            .pWaitSemaphoreInfos = &wait_info,
            .signalSemaphoreInfoCount = 1,
            .pSignalSemaphoreInfos = &signal_info,
            .commandBufferInfoCount = 1,
            .pCommandBufferInfos = &cmd_submit_info,
        };

        result = c.vkQueueSubmit2(self._queues.graphics, 1, &submit_info, self.current_frame()._render_fence);
        if (result != c.VK_SUCCESS) {
            std.log.warn("vkQueueSubmit2 failed with error {x}\n", .{ result });
        }

        const present_info = c.VkPresentInfoKHR {
            .sType = c.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
	        .pNext = null,
	        .pSwapchains = &self._sw._sw,
	        .swapchainCount = 1,

	        .pWaitSemaphores = &self.current_frame()._render_semaphore,
	        .waitSemaphoreCount = 1,

	        .pImageIndices = &image_index,
        };
	

	    result = c.vkQueuePresentKHR(self._queues.graphics, &present_info);
        switch(result) {
            c.VK_SUCCESS => {},
            c.VK_ERROR_OUT_OF_DATE_KHR => {
                self.rebuild = true;
                return;
            },
            else => {
                std.log.warn("vkQueuePresentKHR failed with error {x}\n", .{ result });
            }
        }
    }

    pub fn draw(self: *renderer_t, allocator: std.mem.Allocator) void {
        const image_index = self.next_image() catch |err| {
            if (err == Error.OutOfDate) {
                self.rebuild = true;
            }
            return;
        };

        // reset stats
        self.stats.drawcall_count = 0;
        self.stats.triangle_count = 0;

        const cmd = self.begin_draw() catch {
            return; // we skip for now
        };

        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        utils.transition_image(cmd, self._draw_image.image, c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_GENERAL);

        self.draw_background(cmd);

        utils.transition_image(cmd, self._draw_image.image, c.VK_IMAGE_LAYOUT_GENERAL, c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
        utils.transition_image(cmd, self._depth_image.image, c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL);

        if (self._scene) |scene| {
            self.draw_scene(allocator, scene, cmd);
        }
        // self.draw_voxel(allocator, cmd, scene);

        utils.transition_image(cmd, self._draw_image.image, c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
        utils.transition_image(cmd, self._sw._images[image_index], c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
    
        vk.image.copy_image_to_image(cmd, self._draw_image.image, self._sw._images[image_index], self._draw_extent, self._sw._extent);

        utils.transition_image(cmd, self._sw._images[image_index], c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);

        _gui_context.draw(cmd, self._sw._image_views[image_index], self._sw._extent);

        utils.transition_image(cmd, self._sw._images[image_index], c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, c.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR);

        self.submit_cmd(cmd, image_index);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        self.stats.mesh_draw_time = @floatFromInt(end_time - start_time);

        self._frameNumber += 1;
    }

    pub fn draw_background(self: *renderer_t, cmd: c.VkCommandBuffer) void {
        const effect = self.bg_shader.?;

        // bind the gradient drawing compute pipeline
	    c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, effect.pipeline);

	    // bind the descriptor set containing the draw image for the compute pipeline
	    c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, effect.layout, 0, 1, &self._draw_image_descriptor_set, 0, null);

	    c.vkCmdPushConstants(cmd, effect.layout, c.VK_SHADER_STAGE_COMPUTE_BIT, 0, @sizeOf(effects.ComputePushConstants), &effect.data);

        const group_count_x: u32 = @intFromFloat(@as(f32, std.math.ceil(@as(f32, @floatFromInt(self._draw_extent.width)) / 16.0)));
        const group_count_y: u32 = @intFromFloat(@as(f32, std.math.ceil(@as(f32, @floatFromInt(self._draw_extent.height)) / 16.0)));

	    c.vkCmdDispatch(cmd, group_count_x, group_count_y, 1);
    }

    fn draw_scene(self: *renderer_t, allocator: std.mem.Allocator, scene: *scenes.DrawContext, cmd: c.VkCommandBuffer) void {
        //begin a render pass  connected to our draw image
	    const color_attachment = c.VkRenderingAttachmentInfo {
            .sType = c.VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO,
            .pNext = null,

            .imageView = self._draw_image.view,
            .imageLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,

            .loadOp = c.VK_ATTACHMENT_LOAD_OP_LOAD,
            .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,

            .clearValue = std.mem.zeroes(c.VkClearValue),
        };

        const depth_attachment = c.VkRenderingAttachmentInfo {
            .sType = c.VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO,
            .pNext = null,

            .imageView = self._depth_image.view,
            .imageLayout = c.VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL,

            .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
            .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,

            .clearValue = .{
                .depthStencil = .{
                    .depth = 0.0,
                    .stencil = 0
                }
            }
        };

        const render_info = c.VkRenderingInfo {
            .sType = c.VK_STRUCTURE_TYPE_RENDERING_INFO,
            .pNext = null,
            .pColorAttachments = &color_attachment,
            .colorAttachmentCount = 1,
            .pDepthAttachment = &depth_attachment,
            .renderArea = .{
            .extent = self._draw_extent,
            .offset = .{
                    .x = 0,
                    .y = 0
                }
            },
            .flags = 0,
            .layerCount = 1,
            .pStencilAttachment = null,
            .viewMask = 0,
        };

	    c.vkCmdBeginRendering(cmd, &render_info);

        // draw meshes
        
        // allocate new uniform buffer for the scene
        const gpu_scene_data_buffer = buffers.AllocatedBuffer.init(self._vma, @sizeOf(scenes.ShaderData), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU);

        self.current_frame()._buffers.append(gpu_scene_data_buffer) catch {
            std.log.err("Failed to add buffer to the buffer list of the frame ! OOM !", .{});
            @panic("OOM");
        };

        const scene_uniform_data: *scenes.ShaderData = @alignCast(@ptrCast(gpu_scene_data_buffer.info.pMappedData));
        scene_uniform_data.* = scene.global_data.*;
    
        const global_descriptor = self.current_frame()._frame_descriptors.allocate(allocator, self._device, self.scene_descriptor, null);
        {
            var writer = descriptor.Writer.init(allocator);
            defer writer.deinit();

            writer.write_buffer(0, gpu_scene_data_buffer.buffer, @sizeOf(scenes.ShaderData), 0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
            writer.update_set(self._device, global_descriptor);
        }
        
        scene.draw(cmd, global_descriptor, self._draw_extent, &self.stats);

	    c.vkCmdEndRendering(cmd);
    }

    fn init_default_data(self: *renderer_t, _: std.mem.Allocator) !void {
        // initialize textures
        const grey: u32 align(4) = maths.pack_unorm4x8(.{ 0.66, 0.66, 0, 0.66 });
        _grey_image = vk.image.create_image_data(self._vma, self._device, @ptrCast(&grey), .{ .width = 1, .height = 1, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &self.submit.fence, self.submit.cmd, self._queues.graphics);

        const black: u32 align(4) = maths.pack_unorm4x8(.{ 0, 0, 0, 0 });
        _black_image = vk.image.create_image_data(self._vma, self._device, @ptrCast(&black), .{ .width = 1, .height = 1, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &self.submit.fence, self.submit.cmd, self._queues.graphics);

        const magenta: u32 align(4) = maths.pack_unorm4x8(.{ 1, 0, 1, 1 });
        var pixels: [16 * 16]u32 = [_]u32 { 0 } ** (16 * 16);
        for (0..16) |x| {
            for (0..16) |y| {
                pixels[(y * 16) + x] = if(((x % 2) ^ (y % 2)) != 0) magenta else black; 
            }
        }
    }

    pub fn render_scale() *f32 {
        return &_render_scale;
    }

    pub fn rebuild_swapchain(self: *renderer_t, allocator: std.mem.Allocator, window: ?*sdl.SDL_Window) void {
        const result = c.vkDeviceWaitIdle(self._device);
        if (result != c.VK_SUCCESS) {
            std.log.warn("Failed to wait for device with error {d}", .{ result });
        }

        std.log.info("destroying swapchain", .{});
        self.destroy_swapchain();

        var width: i32 = 0;
        var height: i32 = 0;
        const succeed = sdl.SDL_GetWindowSize(window, &width, &height);
        if (!succeed) {
            std.log.warn("Failed to get window current size", .{});
        }

        std.log.info("initializaing swapchain", .{});
        self.init_swapchain(@intCast(width), @intCast(height)) catch {
            std.log.err("Failed to build swapchain !", .{});
            return;
        };

        self.init_descriptors(allocator) catch {
            std.log.err("Failed to build descriptors !", .{});
            return;
        };

        for (&self._frames) |*frame| {
            frame._sw_semaphore = try frames.create_semaphore(self._device);
        }

        std.log.info("swapchain rebuilt", .{});
        self.rebuild = false;
    }

    fn destroy_swapchain(self: *renderer_t) void {
        self._sw.deinit(self._device);

        // destroy draw images
        c.vkDestroyImageView(self._device, self._draw_image.view, null);
        c.vmaDestroyImage(self._vma, self._draw_image.image, self._draw_image.allocation);

        c.vkDestroyImageView(self._device, self._depth_image.view, null);
        c.vmaDestroyImage(self._vma, self._depth_image.image, self._depth_image.allocation);

        // destroy descriptors
        self._descriptor_pool.deinit(self._device);
	    c.vkDestroyDescriptorSetLayout(self._device, self._draw_image_descriptor, null);

        c.vkDestroyDescriptorSetLayout(self._device, self.scene_descriptor, null);

        c.vkDestroyDescriptorSetLayout(self._device, _single_image_descriptor_layout, null);

        for (&self._frames) |*frame| {
            frame._frame_descriptors.deinit(self._device);
            c.vkDestroySemaphore(self._device, frame._sw_semaphore, null);
        }
    }

    pub fn update_scene(self: *renderer_t, scene: *scenes.scene_t) void {
        const start_time: u128 = @intCast(std.time.nanoTimestamp());

        self.camera.update(self.stats.frame_time);

        scene.update(self.camera, self._draw_extent);

        const end_time: u128 = @intCast(std.time.nanoTimestamp());
        self.stats.scene_update_time = @floatFromInt(end_time - start_time);
    }
};

const std = @import("std");
const c = @import("../clibs.zig");
const sdl = @import("sdl3");
const gui = @import("graphics/gui.zig");
const z = @import("zalgebra");
const vk = @import("vulkan/vulkan.zig");
const frames = @import("frame.zig");
const utils = @import("utils.zig");
const descriptor = @import("descriptor.zig");
const effects = @import("compute_effect.zig");
const pipelines = @import("pipeline.zig");
const buffers = @import("graphics/buffers.zig");
const loader = @import("scene/gltf.zig");
const scenes = @import("scene/scene.zig");
const maths = @import("../utils/maths.zig");
const material = @import("graphics/materials.zig");
const m = @import("graphics/assets.zig");
const cam = @import("scene/camera.zig");
const assets = @import("graphics/assets.zig");

const voxel = @import("scene/chunk.zig");
const compute = @import("graphics/compute.zig");
