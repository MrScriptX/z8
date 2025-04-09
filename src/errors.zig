const std = @import("std");
const c = @import("clibs.zig");

pub fn display_error(message: []const u8) void {
    const success = c.SDL_ShowSimpleMessageBox(c.SDL_MESSAGEBOX_ERROR, "Error", message.ptr, null);
    if (!success) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "Unable to show message box: %s", c.SDL_GetError());
    }
}