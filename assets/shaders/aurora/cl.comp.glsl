#version 450

#include "constants.glsl"
#include "simplex_noise.glsl"
#include "types.glsl"

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

layout(std430, binding = 0) buffer ChunkData {
    uint active_count;
    ivec3 position;
    voxel_t voxels[];
} Chunk;

layout( push_constant ) uniform constants {
    ivec3 position;
} PushConstant;

void main() {
    Chunk.position = PushConstant.position;

    const uint x = gl_GlobalInvocationID.x;
    const uint y = gl_GlobalInvocationID.y;
    const uint z = gl_GlobalInvocationID.z;

    const uint index = x + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);

    const vec3 chunk_world_pos = vec3(Chunk.position) * float(CHUNK_SIZE);
    const vec3 cube_pos = vec3(gl_GlobalInvocationID) - vec3(CHUNK_SIZE) * 0.5 + vec3(0.5) + chunk_world_pos;

    // Instead of absolute position, normalize relative to chunk size
    const float noise_scale = 0.09;
    const vec2 noise_pos = (vec2(cube_pos.x, cube_pos.z) + vec2(0.5 * CHUNK_SIZE)) / CHUNK_SIZE * noise_scale;

    const float n = 0.0;
    const float freq = 1.0;
    const float amp = 1.0;
    for (int i = 0; i < 4; i++) {
        n += noise2D(noise_pos.x * freq, noise_pos.y * freq) * amp;
        freq *= 2.0;
        amp *= 0.5;
    }
    n = clamp(n, -1.0, 1.0); // optional
    const float height = (n + 1.0) * 0.5 * CHUNK_SIZE;
    if (cube_pos.y > height) {
        // no need to store local position, we don't draw it
        Chunk.voxels[index].data.y = 0; // AIR
    }
    else {
        Chunk.voxels[index].data.x = atomicAdd(Chunk.active_count, 1);
        Chunk.voxels[index].data.y = 1; // SOLID        
    }
}
