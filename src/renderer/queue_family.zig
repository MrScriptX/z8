const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub const queues_t = struct {
    graphics_queue: vk.VkQueue = undefined,
    present_queue: vk.VkQueue = undefined,
    // queue_family_indices: queue_indices_t = undefined,
};

pub const queue_indices_t = struct {
    graphics_family: u32 = undefined,
    present_family: u32 = undefined,

    pub fn is_complete(self: *const queue_indices_t) bool {
        return self.graphics_family != undefined and self.present_family != undefined;
    }
};

pub fn find_queue_family(surface: vk.VkSurfaceKHR, physical_device: vk.VkPhysicalDevice) !queue_indices_t {
    var queue_family_count: u32 = 0;
    vk.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const queue_families = try allocator.alloc(vk.VkQueueFamilyProperties, queue_family_count);
    vk.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families.ptr);

    var graphics_family: usize = undefined;
    var present_family: usize = undefined;
    for (queue_families, 0..) |family, index| {
        if (family.queueCount > 0 and family.queueFlags & vk.VK_QUEUE_GRAPHICS_BIT != 0) {
            graphics_family = index;
        }

        var present_support: vk.VkBool32 = vk.VK_FALSE;
        _ = vk.vkGetPhysicalDeviceSurfaceSupportKHR(physical_device, @intCast(index), surface, &present_support);

        if (family.queueCount > 0 and present_support == vk.VK_TRUE) {
            present_family = index;
        }

        if (graphics_family != undefined and present_family != undefined) {
            break;
        }
    }

    const family_indices = queue_indices_t{
        .graphics_family = @intCast(graphics_family),
        .present_family = @intCast(present_family),
    };

    return family_indices;
}

pub fn get_device_queue(device: vk.VkDevice, indices: queue_indices_t) !queues_t {
    var queues: queues_t = undefined;

    vk.vkGetDeviceQueue(device, indices.graphics_family, 0, &queues.graphics_queue);
    vk.vkGetDeviceQueue(device, indices.present_family, 0, &queues.present_queue);

    return queues;
}
