pub const mat4 = [4][4]f32;
pub const vec4 = [4]f32;

const unorm4x8 = packed struct(u32) {
    x: u8,
    y: u8,
    z: u8,
    w: u8
};

pub fn pack_unorm4x8(v: vec4) align(@alignOf(unorm4x8)) u32 {
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

pub fn mul(mx: mat4, my: mat4) mat4 {
    var result: [4][4]f32 = undefined;

    for (0..4) |col| {
        for (0..4) |row| {
            var sum: f32 = 0.0;
            for (0..4) |k| {
                sum += mx[k][row] * my[col][k];
            }
            result[col][row] = sum;
        }
    }

    return result;
}

test "mat4 mul" {
     const identity: [4][4]f32 = .{
        .{1, 0, 0, 0},
        .{0, 1, 0, 0},
        .{0, 0, 1, 0},
        .{0, 0, 0, 1},
    };

    const test_mat: [4][4]f32 = .{
        .{1, 2, 3, 4},
        .{5, 6, 7, 8},
        .{9, 10, 11, 12},
        .{13, 14, 15, 16},
    };

    const zero_mat: [4][4]f32 = .{
        .{0, 0, 0, 0},
        .{0, 0, 0, 0},
        .{0, 0, 0, 0},
        .{0, 0, 0, 0},
    };

    // Identity * test_mat = test_mat
    const id_mul = mul(identity, test_mat);
    for (0..4) |col| {
        for (0..4) |row| {
            try std.testing.expect(id_mul[col][row] == test_mat[col][row]);
        }
    }

    // test_mat * Identity = test_mat
    const id_mul2 = mul(test_mat, identity);
    for (0..4) |col| {
        for (0..4) |row| {
            try std.testing.expect(id_mul2[col][row] == test_mat[col][row]);
        }
    }

    // Zero * test_mat = Zero
    const zero_mul = mul(zero_mat, test_mat);
    for (0..4) |col| {
        for (0..4) |row| {
            try std.testing.expect(zero_mul[col][row] == 0.0);
        }
    }

    // test_mat * Zero = Zero
    const zero_mul2 = mul(test_mat, zero_mat);
    for (0..4) |col| {
        for (0..4) |row| {
            try std.testing.expect(zero_mul2[col][row] == 0.0);
        }
    }
}

const std = @import("std");
