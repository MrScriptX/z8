const std = @import("std");
const c = @import("../clibs.zig");
const vk = @import("vulkan.zig");
const sw = @import("swapchain.zig");
const frames = @import("frame.zig");
const utils = @import("utils.zig");
const vk_images = @import("vk_images.zig");
const descriptor = @import("descriptor.zig");

const queue = @import("queue_family.zig");
const queues_t = queue.queues_t;

const deletion_queue = @import("deletion_queue.zig");

var _arena: std.heap.ArenaAllocator = undefined;
var _vma: c.VmaAllocator = undefined;

var _instance: c.VkInstance = undefined;
var _debug_messenger: c.VkDebugUtilsMessengerEXT = undefined;
var _chosenGPU: c.VkPhysicalDevice = undefined;
var _device: c.VkDevice = undefined;
var _surface: c.VkSurfaceKHR = undefined;

var _queues: queue.queues_t = undefined;
var queue_indices: queue.queue_indices_t = undefined;

var _sw: c.VkSwapchainKHR = undefined;
var _image_format: c.VkSurfaceFormatKHR = undefined;
var _images: []c.VkImage = undefined;
var _image_views: []c.VkImageView = undefined;
var _extent: c.VkExtent2D = undefined;

var _frames: [frames.FRAME_OVERLAP]frames.data_t = undefined;
var _frameNumber: u32 = 0;

var _draw_image: vk_images.image_t = vk_images.image_t{};
var _draw_extent = c.VkExtent2D{};

var _descriptor_pool: descriptor.DescriptorAllocator = undefined;
var _draw_image_descriptor: c.VkDescriptorSetLayout = undefined;
var _draw_image_descriptor_set: c.VkDescriptorSet = undefined;

var _delete_queue: deletion_queue.DeletionQueue = undefined;

pub fn init(window: ?*c.SDL_Window, width: u32, height: u32) !void {
    _arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    _delete_queue = deletion_queue.DeletionQueue.init(std.heap.page_allocator);

    try init_vulkan(window);
    try init_swapchain(width, height);
    try init_commands();
    try init_descriptors();
}

pub fn deinit() void {
    defer _arena.deinit();
    defer _delete_queue.deinit();

    _ = c.vkDeviceWaitIdle(_device);

    for (&_frames) |*frame| {
        frame.deinit(_device);
    }

    c.vkDestroyImageView(_device, _draw_image.view, null);
    c.vmaDestroyImage(_vma, _draw_image.image, _draw_image.allocation);

    c.vmaDestroyAllocator(_vma);

    _descriptor_pool.deinit(_device);
	c.vkDestroyDescriptorSetLayout(_device, _draw_image_descriptor, null);

    _delete_queue.flush();

    destroy_swapchain();

    c.vkDestroySurfaceKHR(_instance, _surface, null);
    c.vkDestroyDevice(_device, null);

    // if (_debug_messenger != undefined) {
    //     vk.destroy_debug_messenger(_instance, _debug_messenger);
    // }

    c.vkDestroyInstance(_instance, null);
}

fn init_vulkan(window: ?*c.SDL_Window) !void {
    _instance = try vk.init_instance();
    _surface = try vk.create_surface(window, _instance);
    _chosenGPU = try vk.select_physical_device(_instance, _surface);
    _device = try vk.create_device_interface(_chosenGPU, queue_indices);
    _queues = try queue.get_device_queue(_device, queue_indices);

    const allocator_info = c.VmaAllocatorCreateInfo {
        .physicalDevice = _chosenGPU,
        .device = _device,
        .instance = _instance,
        .vulkanApiVersion = c.VK_API_VERSION_1_3,
        .flags = c.VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT,
    };
    _ = c.vmaCreateAllocator(&allocator_info, &_vma);
}

fn init_swapchain(width: u32, height: u32) !void {
    const details = try sw.query_swapchain_support(_chosenGPU, _surface);
    defer details.deinit();

    _image_format = try sw.select_surface_format(details);

    const window_extent = c.VkExtent2D{
        .width = width,
        .height = height,
    };

    _extent = try sw.select_extent(details.capabilities, window_extent);
    _sw = try sw.create_swapchain(_device, _surface, details, _image_format, _extent, queue_indices);
    
    var image_count: u32 = 0;
    _ = c.vkGetSwapchainImagesKHR(_device, _sw, &image_count, null);

    const allocator = _arena.allocator();
    
    _images = try sw.create_images(allocator, _device, _sw, &image_count);
    _image_views = try sw.create_image_views(_device, _images, _image_format.format);

    //draw image size will match the window
	const draw_image_extent = c.VkExtent3D {
		.width = width,
		.height = height,
		.depth = 1
	};

    _draw_image.format = c.VK_FORMAT_R16G16B16A16_SFLOAT;
    _draw_image.extent = draw_image_extent;

    const draw_image_usages: c.VkImageUsageFlags =
	    c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT |
	    c.VK_IMAGE_USAGE_TRANSFER_DST_BIT |
	    c.VK_IMAGE_USAGE_STORAGE_BIT |
	    c.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

    const rimg_allocinfo = c.VmaAllocationCreateInfo {
        .usage = c.VMA_MEMORY_USAGE_GPU_ONLY,
        .requiredFlags = c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
    };

    const image_create_info = vk_images.create_image_info(_draw_image.format, draw_image_usages, draw_image_extent);
    _ = c.vmaCreateImage(_vma, &image_create_info, &rimg_allocinfo, &_draw_image.image, &_draw_image.allocation, null);

    const image_view_info = vk_images.create_imageview_info(_draw_image.format, _draw_image.image, c.VK_IMAGE_ASPECT_COLOR_BIT);
    _ = c.vkCreateImageView(_device, &image_view_info, null, &_draw_image.view);
}

fn init_commands() !void {
    _frames = [_]frames.data_t{
        frames.data_t{},
        frames.data_t{},
    };

    for (&_frames) |*frame| {
        try frame.init(_device, queue_indices.graphics_family);
    }
}

fn init_descriptors() !void {
    const sizes = [_]descriptor.PoolSizeRatio{
        descriptor.PoolSizeRatio{
            ._type = c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
            ._ratio = 1.0,
        },
    };

	_descriptor_pool = try descriptor.DescriptorAllocator.init(_device, 10, &sizes);

	//make the descriptor set layout for our compute draw
	{
		var builder = descriptor.DescriptorLayout.init();
        defer builder.deinit();

		try builder.add_binding(0, c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE);
		_draw_image_descriptor = builder.build(_device, c.VK_SHADER_STAGE_COMPUTE_BIT, null, 0);
	}

    _draw_image_descriptor_set = _descriptor_pool.allocate(_device, _draw_image_descriptor);

    const img_info = c.VkDescriptorImageInfo {
        .imageLayout = c.VK_IMAGE_LAYOUT_GENERAL,
	    .imageView = _draw_image.view
    };

	const draw_image_write = c.VkWriteDescriptorSet {
        .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
	    .pNext = null,

	    .dstBinding = 0,
	    .dstSet = _draw_image_descriptor_set,
	    .descriptorCount = 1,
	    .descriptorType = c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
	    .pImageInfo = &img_info,
    };

    c.vkUpdateDescriptorSets(_device, 1, &draw_image_write, 0, null);
}

fn current_frame() *frames.data_t {
    return &_frames[_frameNumber % frames.FRAME_OVERLAP];
}

fn abs(n: f32) f32 {
    return @max(-n, n);
}

pub fn draw() void {
    _ = c.vkWaitForFences(_device, 1, &current_frame()._render_fence, c.VK_TRUE, 1000000000);

    current_frame()._delete_queue.flush();

    _ = c.vkResetFences(_device, 1, &current_frame()._render_fence);

    var image_index: u32 = 0;
    _ = c.vkAcquireNextImageKHR(_device, _sw, 1000000000, current_frame()._sw_semaphore, null, &image_index);


    const cmd_buffer: c.VkCommandBuffer = current_frame()._main_buffer;
    const cmd_buffer_begin_info = c.VkCommandBufferBeginInfo{
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .pNext = null,
        .pInheritanceInfo = null,
        .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
    };

    _ = c.vkBeginCommandBuffer(cmd_buffer, &cmd_buffer_begin_info);

    utils.transition_image(cmd_buffer, _images[image_index], c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_GENERAL);

    const flash = abs(std.math.sin(@as(f32, @floatFromInt(_frameNumber)) / 120.0));
    const clear_color = c.VkClearColorValue{
        .float32 = [_]f32{ 0.0, 0.0, flash, 1.0 },
    };
    var clear_value = c.VkClearValue {
        .color = clear_color,
    };

    const clear_range = utils.image_subresource_range(c.VK_IMAGE_ASPECT_COLOR_BIT);

    c.vkCmdClearColorImage(cmd_buffer, _images[image_index], c.VK_IMAGE_LAYOUT_GENERAL, &clear_value.color, 1, &clear_range);
    
    utils.transition_image(cmd_buffer, _draw_image.image, c.VK_IMAGE_LAYOUT_GENERAL, c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
    utils.transition_image(cmd_buffer, _images[image_index], c.VK_IMAGE_LAYOUT_GENERAL, c.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR);
    
    vk_images.copy_image_to_image(cmd_buffer, _draw_image.image, _images[image_index], _draw_extent, _extent);

    utils.transition_image(cmd_buffer, _images[image_index], c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, c.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR);

    _ = c.vkEndCommandBuffer(cmd_buffer);

    const cmd_submit_info = c.VkCommandBufferSubmitInfo {
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO,
	    .pNext = null,
	    .commandBuffer = cmd_buffer,
	    .deviceMask = 0,
    };

    const wait_info = utils.semaphore_submit_info(c.VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT_KHR, current_frame()._sw_semaphore);
    const signal_info = utils.semaphore_submit_info(c.VK_PIPELINE_STAGE_2_BOTTOM_OF_PIPE_BIT_KHR, current_frame()._render_semaphore);

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

    _ = c.vkQueueSubmit2(_queues.graphics_queue, 1, &submit_info, current_frame()._render_fence);

    const present_info = c.VkPresentInfoKHR {
        .sType = c.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
	    .pNext = null,
	    .pSwapchains = &_sw,
	    .swapchainCount = 1,

	    .pWaitSemaphores = &current_frame()._render_semaphore,
	    .waitSemaphoreCount = 1,

	    .pImageIndices = &image_index,
    };
	

	_ = c.vkQueuePresentKHR(_queues.graphics_queue, &present_info);

    _frameNumber += 1;
}

fn destroy_swapchain() void {
    c.vkDestroySwapchainKHR(_device, _sw, null);

    for (_image_views) |image_view| {
        c.vkDestroyImageView(_device, image_view, null);
    }
}
