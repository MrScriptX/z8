pub const GPUData = struct {
    view: [4][4]f32 align(16),
    proj: [4][4]f32 align(16),
    viewproj: [4][4]f32 align(16),
    ambient_color: [4]f32 align(4),
    sunlight_dir: [4]f32 align(4),
    sunlight_color: [4]f32 align(4)
};
