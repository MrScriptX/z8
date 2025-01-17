const std = @import("std");
const c = @import("../clibs.zig");

pub fn create_render_pass(color_format: c.VkFormat, depth_format: c.VkFormat, device: c.VkDevice) !c.VkRenderPass {
    const color_attachment = c.VkAttachmentDescription{
        .format = color_format, // m_graphic.swapchain_details.format;
	    .samples = c.VK_SAMPLE_COUNT_1_BIT, // use for multisampling
	    .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
	    .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
	    .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
	    .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
	    .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
	    .finalLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, // VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
    };

	const color_attachment_ref = c.VkAttachmentReference{
        .attachment = 0,
	    .layout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    };

	const depth_attachment = c.VkAttachmentDescription{
        .format = depth_format,
	    .samples = c.VK_SAMPLE_COUNT_1_BIT,
	    .loadOp = c.VK_ATTACHMENT_LOAD_OP_CLEAR,
	    .storeOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
	    .stencilLoadOp = c.VK_ATTACHMENT_LOAD_OP_DONT_CARE,
	    .stencilStoreOp = c.VK_ATTACHMENT_STORE_OP_DONT_CARE,
	    .initialLayout = c.VK_IMAGE_LAYOUT_UNDEFINED,
	    .finalLayout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    };

	const depth_attachment_ref = c.VkAttachmentReference{
        .attachment = 1,
	    .layout = c.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    };

	const attachments = [2]c.VkAttachmentDescription{ color_attachment, depth_attachment };

	const subpass = c.VkSubpassDescription{
        .pipelineBindPoint = c.VK_PIPELINE_BIND_POINT_GRAPHICS,
	    .colorAttachmentCount = 1,
	    .pColorAttachments = &color_attachment_ref,
	    .pDepthStencilAttachment = &depth_attachment_ref,
    };

	const dependency = c.VkSubpassDependency{
        .srcSubpass = c.VK_SUBPASS_EXTERNAL,
	    .dstSubpass = 0,
	    .srcStageMask = c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
	    .srcAccessMask = 0,
	    .dstStageMask = c.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
	    .dstAccessMask = c.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | c.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
    };
	
	const render_pass_info = c.VkRenderPassCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
	    .attachmentCount = attachments.len,
	    .pAttachments = @ptrCast(&attachments),
	    .subpassCount = 1,
	    .pSubpasses = @ptrCast(&subpass),
	    .dependencyCount = 1,
	    .pDependencies = @ptrCast(&dependency),
    };

	var render_pass: c.VkRenderPass = undefined;
    const result = c.vkCreateRenderPass(device, &render_pass_info, null, &render_pass);
	if (result != c.VK_SUCCESS)
		return std.debug.panic("failed to create render pass !", .{});

	return render_pass;
}

pub fn create_framebuffer(device: c.VkDevice, renderpass: c.VkRenderPass, image_views: *[2]c.VkImageView, extent: c.VkExtent2D) !c.VkFramebuffer {
	const frame_buffer_info = c.VkFramebufferCreateInfo {
		.sType = c.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
		.renderPass = renderpass,
		.width = extent.width,
		.height = extent.height,
		.layers = 1,
		.attachmentCount = @intCast(image_views.len),
		.pAttachments = @ptrCast(image_views),
	};

	var frame_buffer: c.VkFramebuffer = undefined;
	const result = c.vkCreateFramebuffer(device, &frame_buffer_info, null, &frame_buffer);
	if (result != c.VK_SUCCESS) {
		return std.debug.panic("failed to create frame buffers !", .{});
	}

	return frame_buffer;
}
