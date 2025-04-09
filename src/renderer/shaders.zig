const std = @import("std");
const c = @import("../clibs.zig");
const err = @import("../errors.zig");

pub fn load_shader_module(device: c.VkDevice, path: []const u8) !c.VkShaderModule {
    var file = std.fs.cwd().openFile(path, .{}) catch |e| {
        switch (e) {
            error.FileNotFound => {
                const msg = try std.fmt.allocPrint(std.heap.page_allocator, "Failed to open file {s}.\nReason : File was not found.", .{ path });
                err.display_error(msg);
            },
            error.AccessDenied => {
                const msg = try std.fmt.allocPrint(std.heap.page_allocator, "Failed to open file {s}.\nReason : Access was denied.", .{ path });
                err.display_error(msg);
            },
            else => {
                const msg = try std.fmt.allocPrint(std.heap.page_allocator, "Failed to open file {s}.\nReason : Unknwon error.", .{ path });
                err.display_error(msg);
            }
        }
        std.process.exit(1);
    };
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;
    const buffer = try std.heap.page_allocator.alloc(u8, file_size);
    defer std.heap.page_allocator.free(buffer);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        std.debug.panic("Failed to read shader file !", .{});
    }
    
    const create_info = c.VkShaderModuleCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .codeSize = buffer.len,
        .pCode = @alignCast(@ptrCast(buffer.ptr)),
    };
    
    var shader_module: c.VkShaderModule = undefined;
    const result = c.vkCreateShaderModule(device, &create_info, null, &shader_module) ;
    if (result != c.VK_SUCCESS) {
        std.debug.panic("Failed to create shader module !", .{});
    }

    return shader_module;
}
