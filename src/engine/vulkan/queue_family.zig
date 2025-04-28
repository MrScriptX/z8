const std = @import("std");
const c = @import("../../clibs.zig");

pub const queues_t = struct {
    graphics: c.VkQueue = undefined,
    present: c.VkQueue = undefined,
    indices: indices_t = undefined,
};

pub const indices_t = struct {
    graphics: u32 = std.math.maxInt(u32),
    present: u32 = std.math.maxInt(u32),

    pub fn is_complete(self: *const indices_t) bool {
        return self.graphics != std.math.maxInt(u32) and self.present != std.math.maxInt(u32);
    }
};

pub fn find_queue_family(surface: c.VkSurfaceKHR, physical_device: c.VkPhysicalDevice) !indices_t {
    var queue_family_count: u32 = 0;
    c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const queue_families = try allocator.alloc(c.VkQueueFamilyProperties, queue_family_count);
    c.vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families.ptr);

    var graphics_family: ?usize = null;
    var present_family: ?usize = null;
    for (queue_families, 0..) |family, index| {
        if (family.queueCount > 0 and family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT != 0) {
            graphics_family = index;
        }

        var present_support: c.VkBool32 = c.VK_FALSE;
        _ = c.vkGetPhysicalDeviceSurfaceSupportKHR(physical_device, @intCast(index), surface, &present_support);

        if (family.queueCount > 0 and present_support == c.VK_TRUE) {
            present_family = index;
        }

        if (graphics_family != null and present_family != null) {
            break;
        }
    }

    const family_indices = indices_t{
        .graphics = @intCast(graphics_family.?),
        .present = @intCast(present_family.?),
    };

    return family_indices;
}

 pub fn get_device_queue(device: c.VkDevice, indices: indices_t) !queues_t {
    var queues: queues_t = undefined;

    c.vkGetDeviceQueue(device, indices.graphics, 0, &queues.graphics);
    c.vkGetDeviceQueue(device, indices.present, 0, &queues.present);

    return queues;
}
