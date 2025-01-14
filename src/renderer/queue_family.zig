const std = @import("std");
const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
const queue_family_indices_t = @import("types.zig").queue_family_indices_t;
const queues_t = @import("types.zig").queues_t;
const app_t = @import("app.zig").app_t;

pub fn find_queue_family(surface: vk.VkSurfaceKHR, physical_device: vk.VkPhysicalDevice) !queue_family_indices_t {
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

    const family_indices = queue_family_indices_t{
        .graphics_family = @intCast(graphics_family),
        .present_family = @intCast(present_family),
    };

    return family_indices;
}

pub fn get_device_queue(app: app_t) !queues_t {
    var queues = queues_t{ .queue_family_indices = app.queues.queue_family_indices };

    vk.vkGetDeviceQueue(app.device, queues.queue_family_indices.graphics_family, 0, &queues.graphics_queue);
    vk.vkGetDeviceQueue(app.device, queues.queue_family_indices.present_family, 0, &queues.present_queue);

    return queues;
}
