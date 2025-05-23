pub usingnamespace @cImport({
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_sdl3.h");
    @cInclude("dcimgui_impl_vulkan.h");
});

pub const ImplVulkan_InitInfo = c.ImGui_ImplVulkan_InitInfo;

pub fn ImplVulkan_Init(info: *ImplVulkan_InitInfo) bool {
    return c.cImGui_ImplVulkan_Init(info);
}

pub fn ImplVulkan_NewFrame() void {
    c.cImGui_ImplVulkan_NewFrame();
}

pub fn ImplVulkan_Shutdown() void {
    c.cImGui_ImplVulkan_Shutdown();
}

pub fn ImplSDL3_InitForVulkan(window: ?*c.SDL_Window) bool {
    return c.cImGui_ImplSDL3_InitForVulkan(window);
}

pub fn ImplSDL3_ProcessEvent(event: *c.SDL_Event) bool {
    return c.cImGui_ImplSDL3_ProcessEvent(event);
}

pub fn ImplSDL3_NewFrame() void {
    c.cImGui_ImplSDL3_NewFrame();
}

pub fn CreateContext(shared_font_atlas: ?*c.ImFontAtlas) ?*c.ImGuiContext {
    return c.ImGui_CreateContext(shared_font_atlas);
}

pub fn NewFrame() void {
    c.ImGui_NewFrame();
}

pub fn Render() void {
    c.ImGui_Render();
}

pub fn Begin(name: []const u8, p_open: ?*bool, flags: c.ImGuiWindowFlags) bool {
    return c.ImGui_Begin(@ptrCast(name), p_open, flags);
}

pub fn End() void {
    c.ImGui_End();
}

pub fn SliderInt(label: []const u8, v: *i32, v_min: i32, v_max: i32) bool {
    return c.ImGui_SliderInt(@ptrCast(label), v, v_min, v_max);
}

pub fn SliderUint(label: []const u8, v: *u32, v_min: u32, v_max: u32) bool {
    if (v_max > std.math.maxInt(i32)) { // overflow
        return false;
    }

    if (v.* > std.math.maxInt(i32)) { // overflow
        return false;
    }

    return c.ImGui_SliderInt(@ptrCast(label), @ptrCast(v), @intCast(v_min), @intCast(v_max));
}

pub fn SliderFloat(label: []const u8, v: *f32, v_min: f32, v_max: f32) bool {
    return c.ImGui_SliderFloat(@ptrCast(label), v, v_min, v_max);
}

pub fn InputInt(label: []const u8, v: *i32) bool {
    return c.ImGui_InputInt(@ptrCast(label), @ptrCast(v));
}

pub fn InputUint(label: []const u8, v: *u32) bool {
    if (v.* > std.math.maxInt(i32)) { // overflow
        return false;
    }

    return c.ImGui_InputInt(@ptrCast(label), @ptrCast(v));
}

pub fn InputFloat(label: []const u8, v: *f32) bool {
    return c.ImGui_InputFloat(@ptrCast(label), v);
}

pub fn InputFloat3(label: []const u8, v: *[3]f32) bool {
    return c.ImGui_InputFloat3(@ptrCast(label), v);
}

pub fn InputFloat4(label: []const u8, v: *[4]f32) bool {
    return c.ImGui_InputFloat4(@ptrCast(label), v);
}

const std = @import("std");
const c = @cImport({
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_sdl3.h");
    @cInclude("dcimgui_impl_vulkan.h");
});
