const std = @import("std");
const c = @import("../clibs.zig");

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
