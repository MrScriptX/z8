const std = @import("std");
const c = @import("../clibs.zig");

pub fn load_shader_module(device: c.VkDevice, path: []const u8) !c.VkShaderModule {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try std.heap.page_allocator.alloc(u8, file_size);
    defer std.heap.page_allocator.free(buffer);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        std.debug.panic("Failed to read shader file !", .{});
    }
    
    const create_info = c.VkShaderModuleCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .codeSize = buffer.len * @sizeOf(u32),
        .pCode = @alignCast(@ptrCast(buffer.ptr)),
    };
    
    var shader_module: c.VkShaderModule = undefined;
    const result = c.vkCreateShaderModule(device, &create_info, null, &shader_module) ;
    if (result != c.VK_SUCCESS) {
        std.debug.panic("Failed to create shader module !", .{});
    }

    return shader_module;
}
