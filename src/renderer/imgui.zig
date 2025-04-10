const c = @import("../clibs.zig");
pub usingnamespace @cImport({
   @cInclude("dcimgui.h");
   @cInclude("dcimgui_impl_sdl3.h");
   @cInclude("dcimgui_impl_vulkan.h");
});

const lib = @cImport({
   @cInclude("dcimgui.h");
   @cInclude("dcimgui_impl_sdl3.h");
   @cInclude("dcimgui_impl_vulkan.h");
});

pub const Error = error{
   PoolAllocFailed
};

pub const GuiContext = struct {
   _pool: c.VkDescriptorPool = undefined,

   pub fn init(window: ?*c.SDL_Window, device: c.VkDevice, instance: c.VkInstance,
      gpu: c.VkPhysicalDevice, queue: c.VkQueue, format: *c.VkFormat) Error!GuiContext {
      const pool_sizes = [_]c.VkDescriptorPoolSize{
         .{ .type = c.VK_DESCRIPTOR_TYPE_SAMPLER, .descriptorCount = 1000 },
         .{ .type = c.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC, .descriptorCount = 1000 },
		   .{ .type = c.VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT, .descriptorCount = 1000 }
      };

      const pool_info = c.VkDescriptorPoolCreateInfo {
         .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
         .flags = c.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT,
	      .maxSets = 1000,
	      .poolSizeCount = pool_sizes.len,
	      .pPoolSizes = &pool_sizes,
      };

      var pool: c.VkDescriptorPool = undefined;
      const result = c.vkCreateDescriptorPool(device, &pool_info, null, &pool);
      if (result != c.VK_SUCCESS) {
         return Error.PoolAllocFailed;
      }

      _ = lib.ImGui_CreateContext(null);

      _ = lib.cImGui_ImplSDL3_InitForVulkan(@ptrCast(window));

      var init_imgui_info = lib.ImGui_ImplVulkan_InitInfo {
         .Instance = @ptrCast(instance),
	      .PhysicalDevice = @ptrCast(gpu),
	      .Device = @ptrCast(device),
	      .Queue = @ptrCast(queue),
	      .DescriptorPool = @ptrCast(pool),
	      .MinImageCount = 3,
	      .ImageCount = 3,
	      .UseDynamicRendering = true,

         .PipelineRenderingCreateInfo = .{
            .sType = c.VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO,
            .colorAttachmentCount = 1,
            .pColorAttachmentFormats = format
         },

         .MSAASamples = c.VK_SAMPLE_COUNT_1_BIT,
      };

      _ = lib.cImGui_ImplVulkan_Init(&init_imgui_info);
      _ = lib.cImGui_ImplVulkan_CreateFontsTexture();

      return GuiContext {
         ._pool = pool
      };
   }

   pub fn deinit(self: *GuiContext, device: c.VkDevice) void {
      lib.cImGui_ImplVulkan_Shutdown();
      c.vkDestroyDescriptorPool(device, self._pool, null);
   }

   pub fn draw(_: *GuiContext, cmd: c.VkCommandBuffer, view: c.VkImageView, extent: c.VkExtent2D) void {
      const color_attachment = c.VkRenderingAttachmentInfo {
         .sType = c.VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO,
         .pNext = null,

         .imageView = view,
         .imageLayout = c.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
         .loadOp = c.VK_ATTACHMENT_LOAD_OP_LOAD,
         .storeOp = c.VK_ATTACHMENT_STORE_OP_STORE,
      };

	   const render_info = c.VkRenderingInfo {
         .sType = c.VK_STRUCTURE_TYPE_RENDERING_INFO,
         .pNext = null,
         .pColorAttachments = &color_attachment,
         .colorAttachmentCount = 1,
         .renderArea = .{
            .extent = extent,
            .offset = c.VkOffset2D {.x = 0, .y = 0}
         },
         .layerCount = 1,
         .viewMask = 0
      };

	   c.vkCmdBeginRendering(cmd, &render_info);

	   lib.cImGui_ImplVulkan_RenderDrawData(lib.ImGui_GetDrawData(), @ptrCast(cmd));

	   c.vkCmdEndRendering(cmd);
   }
};
