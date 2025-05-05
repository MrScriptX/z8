const std = @import("std");
const c = @import("../../clibs.zig");
const buffers = @import("../buffers.zig");
const utils = @import("../utils.zig");

pub const image_t = struct {
    image: c.VkImage = undefined,
    view: c.VkImageView = undefined,
    allocation: c.VmaAllocation = undefined,
    format: c.VkFormat = undefined,
    extent: c.VkExtent3D = undefined,
};

pub fn copy_image_to_image(cmd: c.VkCommandBuffer, source: c.VkImage, destination: c.VkImage, srcSize: c.VkExtent2D, dstSize: c.VkExtent2D) void {
    const empty_offset = c.VkOffset3D {
        .x = 0,
        .y = 0,
        .z = 0,
    };
    
    const src_offset = c.VkOffset3D {
        .x = @intCast(srcSize.width),
        .y = @intCast(srcSize.height),
        .z = 1,
    };

    const dst_offset = c.VkOffset3D {
        .x = @intCast(dstSize.width),
        .y = @intCast(dstSize.height),
        .z = 1,
    };
    
    const blit_region = c.VkImageBlit2 {
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_BLIT_2,
        .pNext = null,

        .srcOffsets = [_]c.VkOffset3D{ empty_offset, src_offset },
        .dstOffsets = [_]c.VkOffset3D{ empty_offset, dst_offset },

        .srcSubresource = c.VkImageSubresourceLayers {
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .baseArrayLayer = 0,
            .layerCount = 1,
            .mipLevel = 0,
        },

        .dstSubresource = c.VkImageSubresourceLayers {
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .baseArrayLayer = 0,
            .layerCount = 1,
            .mipLevel = 0,
        },
    };

	const blit_info = c.VkBlitImageInfo2 {
        .sType = c.VK_STRUCTURE_TYPE_BLIT_IMAGE_INFO_2,
        .pNext = null,

        .dstImage = destination,
	    .dstImageLayout = c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
	    .srcImage = source,
	    .srcImageLayout = c.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
	    .filter = c.VK_FILTER_LINEAR,
	    .regionCount = 1,
	    .pRegions = &blit_region,
    };
	

	c.vkCmdBlitImage2(cmd, &blit_info);
}

pub fn create_image_info(format: c.VkFormat, usageFlags: c.VkImageUsageFlags, extent: c.VkExtent3D) c.VkImageCreateInfo {
    const image_create_info = c.VkImageCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .pNext = null,

        .imageType = c.VK_IMAGE_TYPE_2D,

        .format = format,
        .extent = extent,

        .mipLevels = 1,
        .arrayLayers = 1,

        //for MSAA. we will not be using it by default, so default it to 1 sample per pixel.
        .samples = c.VK_SAMPLE_COUNT_1_BIT,

        //optimal tiling, which means the image is stored on the best gpu format
        .tiling = c.VK_IMAGE_TILING_OPTIMAL,
        .usage = usageFlags,
    };

    return image_create_info;
}

pub fn create_imageview_info(format: c.VkFormat, image: c.VkImage, aspect_flags: c.VkImageAspectFlags) c.VkImageViewCreateInfo {
    const info = c.VkImageViewCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .pNext = null,

        .viewType = c.VK_IMAGE_VIEW_TYPE_2D,
        .image = image,
        .format = format,
        .subresourceRange = c.VkImageSubresourceRange {
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
            .aspectMask = aspect_flags,
        },
    };

    return info;
}

pub fn create_image(vma: c.VmaAllocator, device: c.VkDevice, size: c.VkExtent3D, format: c.VkFormat, usage: c.VkImageUsageFlags, mimapped: bool) image_t {
    var image = image_t {
        .format = format,
        .extent = size
    };

    var image_info = create_image_info(format, usage, size);
    if (mimapped) {
        const max: f32 = @floatFromInt(@max(size.width, size.height));
        image_info.mipLevels = @intFromFloat(@floor(@log2(max)) + 1);
    }

    const alloc_info = c.VmaAllocationCreateInfo {
        .usage = c.VMA_MEMORY_USAGE_GPU_ONLY,
        .requiredFlags = c.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
    };

    const result = c.vmaCreateImage(vma, &image_info, &alloc_info, &image.image, &image.allocation, null);
    if (result != c.VK_SUCCESS) {
        std.log.err("Failed to allocate image ! Reason {d}", .{ result });
        @panic("Failed to allocate image !");
    }

    const aspect_flags: c.VkImageAspectFlags = if (format == c.VK_FORMAT_D32_SFLOAT) c.VK_IMAGE_ASPECT_DEPTH_BIT else c.VK_IMAGE_ASPECT_COLOR_BIT;

    var image_view_info = create_imageview_info(format, image.image, aspect_flags);
    image_view_info.subresourceRange.levelCount = image_info.mipLevels;

    const success = c.vkCreateImageView(device, &image_view_info, null, &image.view);
    if (success != c.VK_SUCCESS) {
        std.log.err("Failed to create image view ! Reason {d}", .{ result });
        @panic("Failed to create image view !");
    }

    return image;
}

pub fn create_image_data(vma: c.VmaAllocator, device: c.VkDevice, data: *const anyopaque, size: c.VkExtent3D, format: c.VkFormat, usage: c.VkImageUsageFlags, mimapped: bool, fence: *c.VkFence, cmd: c.VkCommandBuffer, queue: c.VkQueue) image_t {
    const data_size = size.depth * size.width * size.height * 4;

    var upload_buffer = buffers.AllocatedBuffer.init(vma, data_size, c.VK_BUFFER_USAGE_TRANSFER_SRC_BIT, c.VMA_MEMORY_USAGE_CPU_TO_GPU);
    defer upload_buffer.deinit(vma);

    const mapped_data: [*]u8 = @alignCast(@ptrCast(upload_buffer.info.pMappedData));
    const data_ptr: [*]const u8 = @alignCast(@ptrCast(data));
    @memcpy(mapped_data[0..data_size], data_ptr[0..data_size]);

    // const bytes: *[4]u8 = mapped_data[0..4];
    // std.debug.print("packed bytes: {d}, {d}, {d}, {d}\n", .{ bytes[0], bytes[1], bytes[2], bytes[3] });

    const new_image = create_image(vma, device, size, format, usage | c.VK_IMAGE_USAGE_TRANSFER_DST_BIT | c.VK_IMAGE_USAGE_TRANSFER_SRC_BIT, mimapped);

    // submit
    var result = c.vkResetFences(device, 1, fence);
    if (result != c.VK_SUCCESS) {
        std.log.warn("vkResetFences failed with error {x}\n", .{ result });
    }

    result = c.vkResetCommandBuffer(cmd, 0);
    if (result != c.VK_SUCCESS) {
        std.log.warn("vkResetCommandBuffer failed with error {x}\n", .{ result });
    }

    const begin_info = c.VkCommandBufferBeginInfo {
        .sType = c.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .pNext = null,
        .flags = c.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
    };

    result = c.vkBeginCommandBuffer(cmd, &begin_info);
    if (result != c.VK_SUCCESS) {
        std.log.warn("vkBeginCommandBuffer failed with error {x}\n", .{ result });
    }

    utils.transition_image(cmd, new_image.image, c.VK_IMAGE_LAYOUT_UNDEFINED, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);

    const copy_region = c.VkBufferImageCopy {
        .bufferOffset = 0,
        .bufferRowLength = 0,
        .bufferImageHeight = 0,

        .imageSubresource = .{
            .aspectMask = c.VK_IMAGE_ASPECT_COLOR_BIT,
            .mipLevel = 0,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },

        .imageExtent = size,
    };

    c.vkCmdCopyBufferToImage(cmd, upload_buffer.buffer, new_image.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &copy_region);

    utils.transition_image(cmd, new_image.image, c.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, c.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

    // end command buffer and submit
    result = c.vkEndCommandBuffer(cmd);
    if (result != c.VK_SUCCESS) {
        std.log.warn("vkEndCommandBuffer failed with error {x}\n", .{ result });
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
        std.log.warn("vkQueueSubmit2 failed with error {x}\n", .{ result });
    }

    result = c.vkWaitForFences(device, 1, fence, c.VK_TRUE, 9999999999);
    if (result != c.VK_SUCCESS) {
        std.log.warn("vkWaitForFences failed with error {x}\n", .{ result });
    }

    return new_image;
}

pub fn destroy_image(device: c.VkDevice, vma: c.VmaAllocator, image: *const image_t) void {
    c.vkDestroyImageView(device, image.view, null);
    c.vmaDestroyImage(vma, image.image, image.allocation);
}
