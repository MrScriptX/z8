pub const mat4 = [4][4]f32;
pub const vec4 = [4]f32;
pub const vec3 = @Vector(3, f32);

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

    for (0..4) |row| {
        for (0..4) |col| {
            var sum: f32 = 0.0;
            for (0..4) |k| {
                sum += mx[row][k] * my[k][col];
            }
            result[row][col] = sum;
        }
    }

    return result;
}

pub const mat4_t = struct {
    pub fn mul_vec4(m: mat4, v: @Vector(4, f32)) @Vector(4, f32) {
        var result: @Vector(4, f32) = undefined;

        for (m, 0..) |row, i| {
            result[i] = row[0] * v[0] +
                row[1] * v[1] +
                row[2] * v[2] +
                row[3] * v[3];
        }

        return result;
    }
};

test "matrix multiplication identity" {
    const identity: mat4 = .{
        .{1, 0, 0, 0},
        .{0, 1, 0, 0},
        .{0, 0, 1, 0},
        .{0, 0, 0, 1},
    };

    const some_matrix: mat4 = .{
        .{1, 2, 3, 4},
        .{5, 6, 7, 8},
        .{9, 10, 11, 12},
        .{13, 14, 15, 16},
    };

    const result1 = mul(identity, some_matrix);
    const result2 = mul(some_matrix, identity);

    try std.testing.expectEqual(result1, some_matrix);
    try std.testing.expectEqual(result2, some_matrix);
}

test "matrix multiplication basic" {
    const a: mat4 = .{
        .{1, 0, 0, 0},
        .{0, 2, 0, 0},
        .{0, 0, 3, 0},
        .{0, 0, 0, 4},
    };

    const b: mat4 = .{
        .{2, 3, 4, 5},
        .{6, 7, 8, 9},
        .{10, 11, 12, 13},
        .{14, 15, 16, 17},
    };

    const expected: mat4 = .{
        .{2, 3, 4, 5},
        .{12, 14, 16, 18},
        .{30, 33, 36, 39},
        .{56, 60, 64, 68},
    };

    const result = mul(a, b);

    try std.testing.expectEqual(result, expected);
}

const std = @import("std");
