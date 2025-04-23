const Error = error{
    Failed,
    VulkanInit,
    SwapchainInit,
};

pub const renderer_t = struct {
    var _render_scale: f32 = 1.0;

    // pipelines
    var _gradiant_pipeline: c.VkPipeline = undefined;
    var _gradiant_pipeline_layout: c.VkPipelineLayout = undefined;

    var _trianglePipelineLayout: c.VkPipelineLayout = undefined;
    var _trianglePipeline: c.VkPipeline = undefined;

    var _meshPipelineLayout: c.VkPipelineLayout = undefined;
    var _meshPipeline: c.VkPipeline = undefined;

    var _background_effects: std.ArrayList(effects.ComputeEffect) = undefined;
    var _current_effect: u32 = 0;

    var _test_meshes: std.ArrayList(loader.MeshAsset) = undefined;

    var _gui_context: imgui.GuiContext = undefined;

    var rectangle: buffers.GPUMeshBuffers = undefined;

    var _scene_data: scene.GPUData = undefined;

    pub var _white_image: vk_images.image_t = undefined;
    pub var _black_image: vk_images.image_t = undefined;
    pub var _grey_image: vk_images.image_t = undefined;
    pub var _error_checker_board_image: vk_images.image_t = undefined;

    pub var _default_sampler_linear: c.VkSampler = undefined;
    pub var _default_sampler_nearest: c.VkSampler = undefined;

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
    _rebuild_swapchain: bool = false,

    // frames
    _frames: [frames.FRAME_OVERLAP]frames.data_t = undefined,
    _frameNumber: u32 = 0,

    // draw objects
    _draw_image: vk_images.image_t = vk_images.image_t{},
    _depth_image: vk_images.image_t = vk_images.image_t{},
    _draw_extent: c.VkExtent2D = .{},
    _descriptor_pool: descriptor.DescriptorAllocator = undefined,
    _draw_image_descriptor: c.VkDescriptorSetLayout = undefined,
    _draw_image_descriptor_set: c.VkDescriptorSet = undefined,

    // immediate submit structures
    _imm_fence: c.VkFence = undefined,
    _imm_command_buffer: c.VkCommandBuffer = undefined,
    _imm_command_pool: c.VkCommandPool = undefined,

    // scene
    _gpu_scene_data_descriptor_layout: c.VkDescriptorSetLayout = undefined,

    // data to draw
    _default_data: material.MaterialInstance = undefined,
    _metal_rough_material: material.GLTFMetallic_Roughness = undefined,

    _mat_constants: buffers.AllocatedBuffer = undefined,

    _draw_context: m.DrawContext,

    _loaded_nodes: std.hash_map.StringHashMap(*m.Node),

    _main_camera: *camera.camera_t,

    pub fn init(allocator: std.mem.Allocator, window: ?*c.SDL_Window, width: u32, height: u32, cam: *camera.camera_t) !renderer_t {
        var renderer = renderer_t{
            ._loaded_nodes = std.hash_map.StringHashMap(*m.Node).init(allocator),
            ._draw_context = m.DrawContext.init(allocator),
            ._main_camera = cam,
        };
        
        renderer._arena = std.heap.ArenaAllocator.init(allocator);
        _background_effects = std.ArrayList(effects.ComputeEffect).init(allocator);
        _loaded_scenes = std.hash_map.StringHashMap(*loader.LoadedGLTF).init(allocator);

        renderer.init_vulkan(window) catch {
            err.display_error("Failed to init vulkan API !");
            std.process.exit(1);
        };

        renderer.init_swapchain(width, height) catch {
            err.display_error("Failed to initialize the swapchain !");
            std.process.exit(1);
        };

        renderer.init_commands() catch {
            err.display_error("Failed to initialize command buffers !");
            std.process.exit(1);
        };

        renderer.init_descriptors() catch {
            err.display_error("Failed to initialize descriptors !");
            std.process.exit(1);
        };

        renderer.init_pipelines() catch {
            err.display_error("Failed to initialize pipelines !");
            std.process.exit(1);
        };

        _gui_context = imgui.GuiContext.init(window, renderer._device, renderer._instance, renderer._gpu, renderer._queues.graphics, &renderer._sw._image_format.format) catch |e| {
            switch (e) {
                imgui.Error.PoolAllocFailed => {
                    err.display_error("Failed to create pool for ImGui !");
                    std.process.exit(1);
                },
                imgui.Error.ImGuiInitFailed => {
                    err.display_error("Failed to initialize ImGui !");
                    std.process.exit(1);
                },
            }
        };

        renderer.init_default_data(std.heap.page_allocator) catch {
            err.display_error("Failed to initialize data !");
            std.process.exit(1);
        };

        const gltf = try renderer._arena.allocator().create(loader.LoadedGLTF);
        gltf.* = try loader.load_gltf(allocator, "assets/models/structure.glb", renderer._device, &renderer._imm_fence, renderer._queues.graphics, renderer._imm_command_buffer, renderer._vma, &renderer);

        try _loaded_scenes.put("structure", gltf);

        return renderer;
    }

    pub fn deinit(self: *renderer_t) void {
        defer self._arena.deinit();
        defer _background_effects.deinit();
        defer _loaded_scenes.deinit();
       
        var it = _loaded_scenes.iterator();
        while (it.next()) |*gltf| {
            gltf.value_ptr.*.deinit(self._device, self._vma);
        }

        self._draw_context.deinit();
        self._loaded_nodes.deinit();

        const result = c.vkDeviceWaitIdle(self._device);
        if (result != c.VK_SUCCESS) {
            log.write("Failed to wait for device idle ! Reason {d}.", .{result});
        }

        c.vkDestroySampler(self._device, _default_sampler_nearest, null);
        c.vkDestroySampler(self._device, _default_sampler_linear, null);

        vk_images.destroy_image(self._device, self._vma, &_white_image);
        vk_images.destroy_image(self._device, self._vma, &_grey_image);
        vk_images.destroy_image(self._device, self._vma, &_black_image);
        vk_images.destroy_image(self._device, self._vma, &_error_checker_board_image);

        self._mat_constants.deinit(self._vma);

        for (_test_meshes.items) |*mesh| {
            mesh.meshBuffers.deinit(self._vma);
        }

        _test_meshes.deinit();

        rectangle.deinit(self._vma);

        for (&self._frames) |*frame| {
            frame.deinit(self._device, self._vma);
        }

        // destroy imgui context
        _gui_context.deinit(self._device);

        c.vkDestroyFence(self._device, self._imm_fence, null);
        c.vkDestroyCommandPool(self._device, self._imm_command_pool, null);

        self.destroy_swapchain();

        c.vmaDestroyAllocator(self._vma);

        c.vkDestroySurfaceKHR(self._instance, self._surface, null);
        c.vkDestroyDevice(self._device, null);

        // if (_debug_messenger != undefined) {
        //     vk.destroy_debug_messenger(_instance, _debug_messenger);
        // }

        c.vkDestroyInstance(self._instance, null);
    }

    fn init_vulkan(self: *renderer_t, window: ?*c.SDL_Window) !void {
        self._instance = try vk.init.init_instance();
        self._surface = try vk.init.create_surface(window, self._instance);
        self._gpu = try vk.init.select_physical_device(self._instance, self._surface);
        self._device = try vk.init.create_device_interface(self._gpu, self._queue_indices);
        self._queues = try vk.queue.get_device_queue(self._device, self._queue_indices);

        const allocator_info = c.VmaAllocatorCreateInfo {
            .physicalDevice = self._gpu,
            .device = self._device,
            .instance = self._instance,
            .vulkanApiVersion = c.VK_API_VERSION_1_3,
            .flags = c.VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT,
        };
        _ = c.vmaCreateAllocator(&allocator_info, &self._vma);
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

        const image_create_info = vk_images.create_image_info(self._draw_image.format, draw_image_usages, draw_image_extent);

        const rimg_allocinfo = c.VmaAllocationCreateInfo {
            .usage = c.VMA_MEMORY_USAGE_GPU_ONLY,
            .requiredFlags = c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        };

        _ = c.vmaCreateImage(self._vma, &image_create_info, &rimg_allocinfo, &self._draw_image.image, &self._draw_image.allocation, null);

        const image_view_info = vk_images.create_imageview_info(self._draw_image.format, self._draw_image.image, c.VK_IMAGE_ASPECT_COLOR_BIT);
        _ = c.vkCreateImageView(self._device, &image_view_info, null, &self._draw_image.view);

        // depth image
        self._depth_image.format = c.VK_FORMAT_D32_SFLOAT;
        self._depth_image.extent = draw_image_extent;

        var depth_image_usages: c.VkImageUsageFlags = 0;
	    depth_image_usages |= c.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;

        const depth_create_info = vk_images.create_image_info(self._depth_image.format, depth_image_usages, self._depth_image.extent);

        _ = c.vmaCreateImage(self._vma, &depth_create_info, &rimg_allocinfo, &self._depth_image.image, &self._depth_image.allocation, null);

        const depth_view_info = vk_images.create_imageview_info(self._depth_image.format, self._depth_image.image, c.VK_IMAGE_ASPECT_DEPTH_BIT);
        _ = c.vkCreateImageView(self._device, &depth_view_info, null, &self._depth_image.view);
    }

    fn init_commands(self: *renderer_t) !void {
        self._frames = [_]frames.data_t{
            frames.data_t{},
            frames.data_t{},
        };

        for (&self._frames) |*frame| {
            try frame.init(self._device, self._queue_indices.graphics);
        }

        self._imm_command_pool = frames.create_command_pool(self._device, self._queue_indices.graphics) catch {
            err.display_error("Failed to create immediate command pool !\n");
            std.process.exit(1);
        };

        self._imm_command_buffer = frames.create_command_buffer(1,self._device, self._imm_command_pool) catch {
            err.display_error("Failed to allocate immediate command buffers !");
            std.process.exit(1);
        };

        self._imm_fence = frames.create_fence(self._device) catch {
            err.display_error("Failed to create fence !");
            std.process.exit(1);
        };
    }

    fn init_descriptors(self: *renderer_t) !void {
        const sizes = [_]descriptor.PoolSizeRatio{
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, ._ratio = 3 },
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, ._ratio = 3 },
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, ._ratio = 3 },
            descriptor.PoolSizeRatio{ ._type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, ._ratio = 4 },
        };

	    self._descriptor_pool = try descriptor.DescriptorAllocator.init(self._device, 10, &sizes);

	    //make the descriptor set layout for our compute draw
	    {
		    var builder = descriptor.DescriptorLayout.init();
            defer builder.deinit();

		    try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE);
		    self._draw_image_descriptor = builder.build(self._device, c.VK_SHADER_STAGE_COMPUTE_BIT, null, 0);
	    }

        self._draw_image_descriptor_set = self._descriptor_pool.allocate(self._device, self._draw_image_descriptor);

        var writer = descriptor.DescriptorWriter.init(std.heap.page_allocator);
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
            frame._frame_descriptors = descriptor.DescriptorAllocator2.init(self._device, 1000, &frame_size);
        }

        // make descriptor for gpu scene data
        {
            var builder = descriptor.DescriptorLayout.init();
            defer builder.deinit();

		    try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
		    self._gpu_scene_data_descriptor_layout = builder.build(self._device, c.VK_SHADER_STAGE_VERTEX_BIT | c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);
        }

        {
            var builder = descriptor.DescriptorLayout.init();
            defer builder.deinit();

		    try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
		    _single_image_descriptor_layout = builder.build(self._device, c.VK_SHADER_STAGE_FRAGMENT_BIT, null, 0);
        }
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    fn init_pipelines(self: *renderer_t) !void {
        try self.init_background_pipelines();
        try self.init_triangle_pipeline();
        try self.init_mesh_pipeline();

        self._metal_rough_material = material.GLTFMetallic_Roughness.init(std.heap.page_allocator);
        try self._metal_rough_material.build_pipeline(self);
    }

    fn init_background_pipelines(self: *renderer_t) !void {
        const push_constant = c.VkPushConstantRange {
            .offset = 0,
            .size = @sizeOf(effects.ComputePushConstants),
            .stageFlags = c.VK_SHADER_STAGE_COMPUTE_BIT,
        };
    
        const compute_layout = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
	        .pNext = null,

	        .pSetLayouts = &self._draw_image_descriptor,
	        .setLayoutCount = 1,

            .pPushConstantRanges = &push_constant,
            .pushConstantRangeCount = 1,
        };

	    const result = c.vkCreatePipelineLayout(self._device, &compute_layout, null, &_gradiant_pipeline_layout);
        if (result != c.VK_SUCCESS) {
            std.debug.panic("Failed to create pipeline layout !", .{});
        }

        const compute_shader = try pipelines.load_shader_module(self._device, "./zig-out/bin/shaders/gradiant.spv");
        defer c.vkDestroyShaderModule(self._device, compute_shader, null);

        const gradiant_stage_info = c.VkPipelineShaderStageCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
	        .pNext = null,
	        .stage = c.VK_SHADER_STAGE_COMPUTE_BIT,
	        .module = compute_shader,
	        .pName = "main",
        };
	
        const compute_pipeline_create_info = c.VkComputePipelineCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
	        .pNext = null,
	        .layout = _gradiant_pipeline_layout,
	        .stage = gradiant_stage_info,
        };

        var gradient = effects.ComputeEffect {
            .layout = _gradiant_pipeline_layout,
            .name = "gradient",
            .data = .{
                .data1 = c.vec4{ 1, 0, 0, 1 },
	            .data2 = c.vec4{ 0, 0, 1, 1 },
                .data3 = c.glms_vec4_zero().raw,
                .data4 = c.glms_vec4_zero().raw 
            },
        };

        {
            const success = c.vkCreateComputePipelines(self._device, null, 1, &compute_pipeline_create_info, null, &gradient.pipeline);
            if (success != c.VK_SUCCESS) {
                std.debug.panic("Failed to create compute pipeline !", .{});
            }
        }

        // sky shader
        const sky_shader = try pipelines.load_shader_module(self._device, "./zig-out/bin/shaders/sky.spv");
        defer c.vkDestroyShaderModule(self._device, sky_shader, null);

        const sky_stage_info = c.VkPipelineShaderStageCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
	        .pNext = null,
	        .stage = c.VK_SHADER_STAGE_COMPUTE_BIT,
	        .module = sky_shader,
	        .pName = "main",
        };
	
        const sky_pipeline_create_info = c.VkComputePipelineCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
	        .pNext = null,
	        .layout = _gradiant_pipeline_layout,
	        .stage = sky_stage_info,
        };

        var sky = effects.ComputeEffect {
            .layout = _gradiant_pipeline_layout,
            .name = "sky",
            .data = .{
                .data1 = c.vec4{ 0.1, 0.2, 0.4 , 0.97 },
	            .data2 = c.glms_vec4_zero().raw,
                .data3 = c.glms_vec4_zero().raw,
                .data4 = c.glms_vec4_zero().raw 
            },
        };

        {
            const success = c.vkCreateComputePipelines(self._device, null, 1, &sky_pipeline_create_info, null, &sky.pipeline);
            if (success != c.VK_SUCCESS) {
                std.debug.panic("Failed to create compute pipeline !", .{});
            }
        }

        try _background_effects.append(gradient);
        try _background_effects.append(sky);
    }

    fn init_triangle_pipeline(self: *renderer_t) !void {
        const triangle_frag_shader = try pipelines.load_shader_module(self._device, "./zig-out/bin/shaders/colored_triangle.frag.spv");
        defer c.vkDestroyShaderModule(self._device, triangle_frag_shader, null);

	    const triangle_vertex_shader = try pipelines.load_shader_module(self._device, "./zig-out/bin/shaders/colored_triangle.vert.spv");
        defer c.vkDestroyShaderModule(self._device, triangle_vertex_shader, null);

        const pipeline_layout_info = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        };
	
        const result = c.vkCreatePipelineLayout(self._device, &pipeline_layout_info, null, &_trianglePipelineLayout); 
	    if (result != c.VK_SUCCESS) {
            std.debug.panic("failed to create pipeline layout!", .{});
        }

        var pipeline_builder = pipelines.builder_t.init();
        defer pipeline_builder.deinit();

        pipeline_builder._pipeline_layout = _trianglePipelineLayout;
        try pipeline_builder.set_shaders(triangle_vertex_shader, triangle_frag_shader);
        pipeline_builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
	    //filled triangles
	    pipeline_builder.set_polygon_mode(c.VK_POLYGON_MODE_FILL);
	    //no backface culling
	    pipeline_builder.set_cull_mode(c.VK_CULL_MODE_NONE, c.VK_FRONT_FACE_CLOCKWISE);
	    //no multisampling
	    pipeline_builder.set_multisampling_none();
	    //no blending
	    pipeline_builder.disable_blending();
	    //no depth testing
	    pipeline_builder.disable_depthtest();

        //connect the image format we will draw into, from draw image
	    pipeline_builder.set_color_attachment_format(self._draw_image.format);
	    pipeline_builder.set_depth_format(c.VK_FORMAT_UNDEFINED);

	    //finally build the pipeline
	    _trianglePipeline = pipeline_builder.build_pipeline(self._device);
    }

    fn init_mesh_pipeline(self: *renderer_t) !void {
        // const frag_shader = try pipelines.load_shader_module(_device, "./zig-out/bin/shaders/colored_triangle.frag.spv");
        // defer c.vkDestroyShaderModule(_device, frag_shader, null);

        const frag_shader = try pipelines.load_shader_module(self._device, "./zig-out/bin/shaders/image_texture.frag.spv");
        defer c.vkDestroyShaderModule(self._device, frag_shader, null);

	    const vertex_shader = try pipelines.load_shader_module(self._device, "./zig-out/bin/shaders/colored_triangle_mesh.vert.spv");
        defer c.vkDestroyShaderModule(self._device, vertex_shader, null);

        const buffer_range = c.VkPushConstantRange {
            .offset = 0,
            .size = @sizeOf(buffers.GPUDrawPushConstants),
            .stageFlags = c.VK_SHADER_STAGE_VERTEX_BIT,
        };

        const layout_info = c.VkPipelineLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            .pNext = null,
            .pPushConstantRanges = &buffer_range,
            .pushConstantRangeCount = 1,
            .pSetLayouts = &_single_image_descriptor_layout,
            .setLayoutCount = 1,
        };
	
        const result = c.vkCreatePipelineLayout(self._device, &layout_info, null, &_meshPipelineLayout); 
	    if (result != c.VK_SUCCESS) {
            std.debug.panic("failed to create pipeline layout!", .{});
        }

        var pipeline_builder = pipelines.builder_t.init();
        defer pipeline_builder.deinit();

        //use the triangle layout we created
	    pipeline_builder._pipeline_layout = _meshPipelineLayout;
	    //connecting the vertex and pixel shaders to the pipeline
	    try pipeline_builder.set_shaders(vertex_shader, frag_shader);
	    //it will draw triangles
	    pipeline_builder.set_input_topology(c.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
	    //filled triangles
	    pipeline_builder.set_polygon_mode(c.VK_POLYGON_MODE_FILL);
	    //no backface culling
	    pipeline_builder.set_cull_mode(c.VK_CULL_MODE_NONE, c.VK_FRONT_FACE_CLOCKWISE);
	    //no multisampling
	    pipeline_builder.set_multisampling_none();
	    //no blending
	    pipeline_builder.disable_blending();
        // pipeline_builder.enable_blending_additive();

	    // pipeline_builder.disable_depthtest();
        pipeline_builder.enable_depthtest(true, c.VK_COMPARE_OP_GREATER_OR_EQUAL);

	    //connect the image format we will draw into, from draw image
	    pipeline_builder.set_color_attachment_format(self._draw_image.format);
	    pipeline_builder.set_depth_format(self._depth_image.format);

	    //finally build the pipeline
	    _meshPipeline = pipeline_builder.build_pipeline(self._device);
    }

    fn current_frame(self: *renderer_t) *frames.data_t {
        return &self._frames[self._frameNumber % frames.FRAME_OVERLAP];
    }

    fn abs(n: f32) f32 {
        return @max(-n, n);
    }

    pub fn draw(self: *renderer_t) void {
        self.update_scene();

        var result = c.vkWaitForFences(self._device, 1, &self.current_frame()._render_fence, c.VK_TRUE, 1000000000);
        if (result != c.VK_SUCCESS) {
            log.write("vkWaitForFences failed with error {x}\n", .{ result });
            self._frameNumber += 1;
            return;
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
                self._rebuild_swapchain = true;
                return;
            },
            else => {
                log.write("vkAcquireNextImageKHR failed with error {x}\n", .{ result });
                return;
            }
        }

        result = c.vkResetFences(self._device, 1, &self.current_frame()._render_fence);
        if (result != c.VK_SUCCESS) {
            log.write("vkResetFences failed with error {x}\n", .{ result });
            return;
        }

        result = c.vkResetCommandBuffer(self.current_frame()._main_buffer, 0);
        if (result != c.VK_SUCCESS) {
            log.write("vkResetCommandBuffer failed with error {x}\n", .{ result });
            return;
        }

        const cmd_buffer: c.VkCommandBuffer = self.current_frame()._main_buffer;
        const cmd_buffer_begin_info = c.VkCommandBufferBeginInfo{
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            .pNext = null,
            .pInheritanceInfo = null,
            .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        };

        result = c.vkBeginCommandBuffer(cmd_buffer, &cmd_buffer_begin_info);
        if (result != c.VK_SUCCESS) {
            log.write("vkBeginCommandBuffer failed with error {x}\n", .{ result });
            return;
        }

        utils.transition_image(cmd_buffer, self._draw_image.image, c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_GENERAL);

        self.draw_background(cmd_buffer);

        utils.transition_image(cmd_buffer, self._draw_image.image, c.VK_IMAGE_LAYOUT_GENERAL, c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
        utils.transition_image(cmd_buffer, self._depth_image.image, c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL);

        self.draw_geometry(cmd_buffer);

        utils.transition_image(cmd_buffer, self._draw_image.image, c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
        utils.transition_image(cmd_buffer, self._sw._images[image_index], c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
    
        vk_images.copy_image_to_image(cmd_buffer, self._draw_image.image, self._sw._images[image_index], self._draw_extent, self._sw._extent);

        utils.transition_image(cmd_buffer, self._sw._images[image_index], c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);

        _gui_context.draw(cmd_buffer, self._sw._image_views[image_index], self._sw._extent);

        utils.transition_image(cmd_buffer, self._sw._images[image_index], c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, c.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR);

        result = c.vkEndCommandBuffer(cmd_buffer);
        if (result != c.VK_SUCCESS) {
            log.write("vkEndCommandBuffer failed with error {x}\n", .{ result });
        }

        const cmd_submit_info = c.VkCommandBufferSubmitInfo {
            .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
	        .pNext = null,
	        .commandBuffer = cmd_buffer,
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
            log.write("vkQueueSubmit2 failed with error {x}\n", .{ result });
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
                self._rebuild_swapchain = true;
                return;
            },
            else => {
                log.write("vkQueuePresentKHR failed with error {x}\n", .{ result });
            }
        }

        self._frameNumber += 1;
    }

    pub fn draw_background(self: *renderer_t, cmd: c.VkCommandBuffer) void {
        const effect = current_effect();

        // bind the gradient drawing compute pipeline
	    c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, effect.pipeline);

	    // bind the descriptor set containing the draw image for the compute pipeline
	    c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_COMPUTE, _gradiant_pipeline_layout, 0, 1, &self._draw_image_descriptor_set, 0, null);

	    c.vkCmdPushConstants(cmd, _gradiant_pipeline_layout, c.VK_SHADER_STAGE_COMPUTE_BIT, 0, @sizeOf(effects.ComputePushConstants), &effect.data);

        const group_count_x: u32 = @intFromFloat(@as(f32, std.math.ceil(@as(f32, @floatFromInt(self._draw_extent.width)) / 16.0)));
        const group_count_y: u32 = @intFromFloat(@as(f32, std.math.ceil(@as(f32, @floatFromInt(self._draw_extent.height)) / 16.0)));

	    c.vkCmdDispatch(cmd, group_count_x, group_count_y, 1);
    }

    pub fn draw_geometry(self: *renderer_t, cmd: c.VkCommandBuffer) void {
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

	    // c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, _trianglePipeline);

	    //set dynamic viewport and scissor
	    const viewport = c.VkViewport {
            .x = 0,
	        .y = 0,
	        .width = @floatFromInt(self._draw_extent.width),
	        .height = @floatFromInt(self._draw_extent.height),
	        .minDepth = 0.0,
	        .maxDepth = 1.0,
        };

	    c.vkCmdSetViewport(cmd, 0, 1, &viewport);

	    const scissor = c.VkRect2D {
            .offset = .{ .x = 0, .y = 0 },
	        .extent = self._draw_extent,
        };

	    c.vkCmdSetScissor(cmd, 0, 1, &scissor);

        // bind pipeline for meshes
	    c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, _meshPipeline);

        // bind texture
        const image_set = self.current_frame()._frame_descriptors.allocate(self._device, _single_image_descriptor_layout, null);

        {
            var writer = descriptor.DescriptorWriter.init(std.heap.page_allocator);
            defer writer.deinit();

            writer.write_image(0, _error_checker_board_image.view, _default_sampler_nearest, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER);
            writer.update_set(self._device, image_set);
        }

        c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, _meshPipelineLayout, 0, 1, &image_set, 0, null);

        // draw rectangle
        const push_constants = buffers.GPUDrawPushConstants {
            .world_matrix = z.Mat4.identity().data,
            .vertex_buffer = rectangle.vertex_buffer_address,
        };

	    c.vkCmdPushConstants(cmd, _meshPipelineLayout, c.VK_SHADER_STAGE_VERTEX_BIT, 0, @sizeOf(buffers.GPUDrawPushConstants), &push_constants);
	    c.vkCmdBindIndexBuffer(cmd, rectangle.index_buffer.buffer, 0, c.VK_INDEX_TYPE_UINT32);

	    c.vkCmdDrawIndexed(cmd, 6, 1, 0, 0, 0);

        // allocate new uniform buffer for the scene
        const gpu_scene_data_buffer = buffers.AllocatedBuffer.init(self._vma, @sizeOf(scene.GPUData), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU);

        self.current_frame()._buffers.append(gpu_scene_data_buffer) catch {
            log.err("Failed to add buffer to the buffer list of the frame ! OOM !", .{});
            @panic("OOM");
        };

        const scene_uniform_data: *scene.GPUData = @alignCast(@ptrCast(gpu_scene_data_buffer.info.pMappedData));
        scene_uniform_data.* = _scene_data;

        const global_descriptor = self.current_frame()._frame_descriptors.allocate(self._device, self._gpu_scene_data_descriptor_layout, null);
    
        {
            var writer = descriptor.DescriptorWriter.init(std.heap.page_allocator);
            defer writer.deinit();

            writer.write_buffer(0, gpu_scene_data_buffer.buffer, @sizeOf(scene.GPUData), 0, c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER);
            writer.update_set(self._device, global_descriptor);
        }

        // draw meshes
        for (self._draw_context.opaque_surfaces.items) |*obj| {
            c.vkCmdBindPipeline(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.pipeline);
            c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.layout, 0, 1, &global_descriptor, 0, null);
            c.vkCmdBindDescriptorSets(cmd, c.VK_PIPELINE_BIND_POINT_GRAPHICS, obj.material.pipeline.layout, 1, 1, &obj.material.material_set, 0, null);

            c.vkCmdBindIndexBuffer(cmd, obj.index_buffer, 0, c.VK_INDEX_TYPE_UINT32);

            const push_constants_mesh = buffers.GPUDrawPushConstants {
                .world_matrix = obj.transform,
                .vertex_buffer = obj.vertex_buffer_address,
            };

            c.vkCmdPushConstants(cmd, obj.material.pipeline.layout, c.VK_SHADER_STAGE_VERTEX_BIT, 0, @sizeOf(buffers.GPUDrawPushConstants), &push_constants_mesh);

            c.vkCmdDrawIndexed(cmd, obj.index_count, 1, obj.first_index, 0, 0);
        }
	
	    c.vkCmdEndRendering(cmd);
    }

    var _last_view: z.Mat4 = z.Mat4.identity().translate(z.Vec3.new(0, 0, -150));
    var _last_frame_time: u128 = 0;

    fn calculate_delta_time() f32 {
        const current_time: u128 = @intCast(std.time.nanoTimestamp()); // casting because we won't have neg value
        const delta_time: f32 = @floatFromInt(current_time - _last_frame_time);
        _last_frame_time = current_time;
        return delta_time;
    }

    fn init_default_data(self: *renderer_t, allocator: std.mem.Allocator) !void {
        var rect_vertices =  std.ArrayList(buffers.Vertex).init(allocator);
        defer rect_vertices.deinit();

        try rect_vertices.append(.{
            .position = .{ 0.5, -0.5, 0.0 },
            .color = .{ 0, 0, 0, 1},
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        try rect_vertices.append(.{
            .position = .{ 0.5, 0.5, 0 },
            .color = .{ 0.5, 0.5, 0.5 ,1},
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        try rect_vertices.append(.{
            .position = .{ -0.5, -0.5, 0 },
            .color = .{ 1, 0, 0, 1 },
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        try rect_vertices.append(.{
            .position = .{ -0.5, 0.5, 0 },
            .color = .{ 0, 1, 0, 1 },
            .uv_x = 0,
            .uv_y = 0,
            .normal = .{ 0, 0, 0 }
        });

        var rect_indices = std.ArrayList(u32).init(allocator);
        defer rect_indices.deinit();

        try rect_indices.append(0);
        try rect_indices.append(1);
        try rect_indices.append(2);

        try rect_indices.append(2);
        try rect_indices.append(1);
        try rect_indices.append(3);

	    rectangle = buffers.GPUMeshBuffers.init(self._vma, self._device, &self._imm_fence, self._queues.graphics, rect_indices.items, rect_vertices.items, self._imm_command_buffer);

        _test_meshes = try loader.load_gltf_meshes(allocator, "./assets/models/basicmesh.glb", self._vma, self._device, &self._imm_fence, self._queues.graphics, self._imm_command_buffer);

        // initialize textures
        const white: u32 align(4) = maths.pack_unorm4x8(.{ 1, 1, 1, 1 });
        _white_image = vk_images.create_image_data(self._vma, self._device, @ptrCast(&white), .{ .width = 1, .height = 1, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &self._imm_fence, self._imm_command_buffer, self._queues.graphics);

        const grey: u32 align(4) = maths.pack_unorm4x8(.{ 0.66, 0.66, 0, 0.66 });
        _grey_image = vk_images.create_image_data(self._vma, self._device, @ptrCast(&grey), .{ .width = 1, .height = 1, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &self._imm_fence, self._imm_command_buffer, self._queues.graphics);

        const black: u32 align(4) = maths.pack_unorm4x8(.{ 0, 0, 0, 0 });
        _black_image = vk_images.create_image_data(self._vma, self._device, @ptrCast(&black), .{ .width = 1, .height = 1, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &self._imm_fence, self._imm_command_buffer, self._queues.graphics);

        const magenta: u32 align(4) = maths.pack_unorm4x8(.{ 1, 0, 1, 1 });
        var pixels: [16 * 16]u32 = [_]u32 { 0 } ** (16 * 16);
        for (0..16) |x| {
            for (0..16) |y| {
                pixels[(y * 16) + x] = if(((x % 2) ^ (y % 2)) != 0) magenta else black; 
            }
        }

        _error_checker_board_image = vk_images.create_image_data(self._vma, self._device, @ptrCast(&pixels), .{ .width = 16, .height = 16, .depth = 1 }, c.VK_FORMAT_R8G8B8A8_UNORM, c.VK_IMAGE_USAGE_SAMPLED_BIT, false, &self._imm_fence, self._imm_command_buffer, self._queues.graphics);

        const nearest_sampler_image = c.VkSamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_NEAREST,
            .minFilter = c.VK_FILTER_NEAREST,
        };

        _ = c.vkCreateSampler(self._device, &nearest_sampler_image, null, &_default_sampler_nearest);

        const linear_sampler_image = c.VkSamplerCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            .magFilter = c.VK_FILTER_LINEAR,
            .minFilter = c.VK_FILTER_LINEAR,
        };

        _ = c.vkCreateSampler(self._device, &linear_sampler_image, null, &_default_sampler_linear);

        // metal rough mat
        self._mat_constants = buffers.AllocatedBuffer.init(self._vma, @sizeOf(material.GLTFMetallic_Roughness.MaterialConstants), c.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU);

        const scene_uniform_data: *material.GLTFMetallic_Roughness.MaterialConstants = @alignCast(@ptrCast(self._mat_constants.info.pMappedData));
        scene_uniform_data.color_factors = maths.vec4{ 1, 1, 1, 1 };
        scene_uniform_data.metal_rough_factors = maths.vec4{ 1, 0.5, 0, 0 };

        try self.init_mesh_material();
    }

    fn init_mesh_material(self: *renderer_t) !void {
        const material_res = material.GLTFMetallic_Roughness.MaterialResources {
            .color_image = _white_image,
            .color_sampler = _default_sampler_linear,
            .metal_rough_image = _white_image,
            .metal_rough_sampler = _default_sampler_linear,
            .data_buffer = self._mat_constants.buffer,
            .data_buffer_offset = 0,
        };

        self._default_data = self._metal_rough_material.write_material_compat(self._device, material.MaterialPass.MainColor, &material_res, &self._descriptor_pool);

        for (_test_meshes.items) |*mesh| {
            var new_node: *m.Node = try std.heap.page_allocator.create(m.Node);
            new_node.children = std.ArrayList(*m.Node).init(std.heap.page_allocator);
            new_node.mesh = mesh;

            new_node.local_transform = z.Mat4.identity().data;
            new_node.world_transform =  z.Mat4.identity().data;

            for (new_node.mesh.surfaces.items) |*s| {
                s.material = self._arena.allocator().create(loader.GLTFMaterial) catch @panic("OOM");
                s.material.data = material.MaterialInstance{
                    .pipeline = self._default_data.pipeline,
                    .material_set = self._default_data.material_set,
                    .pass_type = self._default_data.pass_type,
                };
            }

            self._loaded_nodes.put(mesh.name, new_node) catch @panic("OOM");
        }
    }

    pub fn render_scale() *f32 {
        return &_render_scale;
    }

    pub fn should_rebuild_sw(self: *renderer_t) bool {
        return self._rebuild_swapchain;
    }

    pub fn rebuild_swapchain(self: *renderer_t, window: ?*c.SDL_Window) void {
        const result = c.vkDeviceWaitIdle(self._device);
        if (result != c.VK_SUCCESS) {
            log.write("Failed to wait for device with error {x}", .{ result });
        }

        self.destroy_swapchain();

        var width: i32 = 0;
        var height: i32 = 0;
        _ = c.SDL_GetWindowSize(window, &width, &height);

        self.init_swapchain(@intCast(width), @intCast(height)) catch {
            log.write("Failed to build swapchain !", .{});
            return;
        };

        self.init_descriptors() catch {
            log.write("Failed to build descriptors !", .{});
            return;
        };

        self.init_pipelines() catch {
            log.write("Failed to build pipelines !", .{});
            return;
        };

        self.init_mesh_material() catch {
            log.write("Failed to init material !", .{});
            return;
        };

        self._rebuild_swapchain = false;
    }

    fn destroy_swapchain(self: *renderer_t) void {
        self._sw.deinit(self._device);

        // destroy draw images
        c.vkDestroyImageView(self._device, self._draw_image.view, null);
        c.vmaDestroyImage(self._vma, self._draw_image.image, self._draw_image.allocation);

        c.vkDestroyImageView(self._device, self._depth_image.view, null);
        c.vmaDestroyImage(self._vma, self._depth_image.image, self._depth_image.allocation);

        // destroy materials
        self._metal_rough_material.deinit(self._device);

        // destroy descriptors
        self._descriptor_pool.deinit(self._device);
	    c.vkDestroyDescriptorSetLayout(self._device, self._draw_image_descriptor, null);

        c.vkDestroyDescriptorSetLayout(self._device, self._gpu_scene_data_descriptor_layout, null);

        c.vkDestroyDescriptorSetLayout(self._device, _single_image_descriptor_layout, null);

        for (&self._frames) |*frame| {
            frame._frame_descriptors.deinit(self._device);
        }

        // destroy pipelines
        for (_background_effects.items) |*it| {
            c.vkDestroyPipeline(self._device, it.pipeline, null);
        }
        c.vkDestroyPipelineLayout(self._device, _gradiant_pipeline_layout, null);

        c.vkDestroyPipeline(self._device, _trianglePipeline, null);
        c.vkDestroyPipelineLayout(self._device, _trianglePipelineLayout, null);

        c.vkDestroyPipeline(self._device, _meshPipeline, null);
        c.vkDestroyPipelineLayout(self._device, _meshPipelineLayout, null);

        // clear pipelines array
        _background_effects.clearAndFree();
    }

    pub fn max_effect() u32 {
        return @intCast(_background_effects.items.len);
    }

    pub fn effect_index() *u32 {
        return &_current_effect;
    }

    pub fn current_effect() *effects.ComputeEffect {
        for (_background_effects.items, 0..) |*e, i| {
            if (i == _current_effect) {
                return e;
            }
        }

        return @constCast(&_background_effects.getLast());
    }

    pub fn update_scene(self: *renderer_t) void {
        self._draw_context.opaque_surfaces.clearRetainingCapacity();

        const node = self._loaded_nodes.get("Suzanne");
        if (node == null) {
            @panic("node is null");
        }

        const top: maths.mat4 align(16) = z.Mat4.identity().data;
        node.?.draw(&top, &self._draw_context); 

        const delta_time = calculate_delta_time();

        self._main_camera.update(delta_time);

        const view = self._main_camera.view_matrix();

        const deg: f32 = 70.0;
        var proj = z.perspective(deg, @as(f32, @floatFromInt(self._draw_extent.width)) / @as(f32, @floatFromInt(self._draw_extent.height)), 0.1, 10000.0);
        proj.data[1][1] *= -1.0;

        _scene_data.view = view.data;
        _scene_data.proj = proj.data;
        _scene_data.viewproj = z.Mat4.mul(proj, view).data;

        // var view: z.Mat4 = _last_view;

        // const rotation_speed: f32 = 45.0; // Degrees per second
        // const rotation_angle = rotation_speed * (delta_time / 1_000_000_000.0);
        // view = view.rotate(rotation_angle, z.Vec3.new(0, 1, 0));

        // _last_view = view;

        // _scene_data.view = view.data;
        
        // const deg: f32 = 70.0;
        // var proj = z.perspective(z.toRadians(deg), @as(f32, @floatFromInt(self._draw_extent.width)) / @as(f32, @floatFromInt(self._draw_extent.height)), 0.1, 10000.0);
        // proj.data[1][1] *= -1.0;

        // _scene_data.proj = proj.data;

        // _scene_data.viewproj = z.Mat4.mul(proj, view).data;

        _scene_data.ambient_color = maths.vec4 { 0.1, 0.1, 0.1, 0.1 };
        _scene_data.sunlight_color = maths.vec4{ 1, 1, 1, 1 };
        _scene_data.sunlight_dir = maths.vec4{ 0, 1, 0.5, 1 };
    }
};

const std = @import("std");
const c = @import("../clibs.zig");
const imgui = @import("imgui.zig");
const z = @import("zalgebra");
const err = @import("../errors.zig");
const vk = @import("vulkan/vulkan.zig");
const frames = @import("frame.zig");
const utils = @import("utils.zig");
const vk_images = @import("vk_images.zig");
const descriptor = @import("descriptor.zig");
const effects = @import("compute_effect.zig");
const pipelines = @import("pipeline.zig");
const buffers = @import("buffers.zig");
const loader = @import("loader.zig");
const scene = @import("scene.zig");
const maths = @import("../utils/maths.zig");
const material = @import("material.zig");
const m = @import("mesh.zig");
const camera = @import("../engine/camera.zig");

const log = @import("../utils/log.zig");
