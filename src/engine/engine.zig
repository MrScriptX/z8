pub const camera = @import("scene/camera.zig");
pub const materials = @import("graphics/materials.zig");
pub const scene = @import("scene/scene.zig");
pub const renderer = @import("renderer.zig");
pub const gui = @import("graphics/gui.zig");

pub const Engine = struct {
    r: renderer.renderer_t,

    pub fn init(allocator: std.mem.Allocator, window: sdl.SDL_Window) Engine {
        var width: i32 = 0;
        var height: i32 = 0;
        const succeed = sdl.SDL_GetWindowSize(window, &width, &height);
        if (!succeed) {
            std.log.warn("Failed to get window current size", .{});
            width = 800;
            height = 600;
        }
        
        const default_cam: camera.camera_t = .{
            .position = .{ 0, 0, 75 },
            .speed = 50,
            .sensitivity = 0.02,
        };

        return .{
            .r = renderer.renderer_t.init(allocator, window, width, height, &default_cam),
        };
    }

    pub fn deinit(self: *Engine) void {
        self.r.deinit();
    }
};

const std = @import("std");
const sdl = @import("sdl3");
