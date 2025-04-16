const mat4 = [4][4]f32;
const vec4 = [4]f32;

const unorm4x8 = packed struct(u32) {
    x: u8,
    y: u8,
    z: u8,
    w: u8
};

pub fn pack_unorm4x8(v: vec4) u32 {
    const x: u8 = @intFromFloat(v[0] * @as(f32, @floatFromInt(std.math.maxInt(u8))));
    const y: u8 = @intFromFloat(v[1] * @as(f32, @floatFromInt(std.math.maxInt(u8))));
    const z: u8 = @intFromFloat(v[2] * @as(f32, @floatFromInt(std.math.maxInt(u8))));
    const w: u8 = @intFromFloat(v[3] * @as(f32, @floatFromInt(std.math.maxInt(u8))));

    return @as(u32, @bitCast(unorm4x8{
        .x = x,
        .y = y,
        .z = z,
        .w = w,
    })); 
}

const std = @import("std");
