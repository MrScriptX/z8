#version 450

#include "constants.glsl"
#include "simplex_noise.glsl"

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

layout(std430, binding = 0) buffer ChunkData {
    uint active_count;
    ivec3 position;
    uint voxels[];
};

void main() {
    uint x = gl_GlobalInvocationID.x;
    uint y = gl_GlobalInvocationID.y;
    uint z = gl_GlobalInvocationID.z;

    uint index = x + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);

    vec3 chunk_world_pos = vec3(position) * float(CHUNK_SIZE);
    vec3 cube_pos = vec3(gl_GlobalInvocationID) - vec3(CHUNK_SIZE) * 0.5 + vec3(0.5) + chunk_world_pos;

    // Instead of absolute position, normalize relative to chunk size
    vec2 noise_pos = (vec2(cube_pos.x, cube_pos.z) + vec2(0.5 * CHUNK_SIZE)) / CHUNK_SIZE;

    float n = 0.0;
    float freq = 1.0;
    float amp = 1.0;
    for (int i = 0; i < 4; i++) {
        n += noise2D(noise_pos.x * freq, noise_pos.y * freq) * amp;
        freq *= 2.0;
        amp *= 0.5;
    }
    n = clamp(n, -1.0, 1.0); // optional
    float height = (n + 1.0) * 0.5 * CHUNK_SIZE;
    if (cube_pos.y > height) {
        voxels[index] = 0; // AIR
    }
    else {
        voxels[index] = 1; // SOLID
    }

    atomicAdd(active_count, 1);
}
