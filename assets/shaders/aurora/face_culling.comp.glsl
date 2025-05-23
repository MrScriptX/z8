#version 450

#include "constants.glsl"
#include "types.glsl"

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

layout(std430, binding = 0) buffer ChunkData {
    uint active_count;
    ivec3 position;
    voxel_t voxels[];
} Chunk;

void main() {
    const uint x = gl_GlobalInvocationID.x;
    const uint y = gl_GlobalInvocationID.y;
    const uint z = gl_GlobalInvocationID.z;

    const uint index = x + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);

    if (Chunk.voxels[index].data.x == 0) { // is not active
        return;
    }

    // encode faces in y
    const uint x_plus = (x + 1) + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);
    if (x > 0 && Chunk.voxels[x_plus].data.x != 0) {
        Chunk.voxels[index].data.y |= 0x1; // +X
    }

    const uint x_minus = (x - 1) + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);
    if (x < CHUNK_SIZE - 1 && Chunk.voxels[x_minus].data.x != 0) {
        Chunk.voxels[index].data.y |= 0x2; // -X
    }

    const uint y_plus = x + ((y + 1) * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);
    if (y < CHUNK_SIZE - 1 && Chunk.voxels[y_plus].data.x != 0) {
        Chunk.voxels[index].data.y |= 0x4; // +Y
    }

    const uint y_minus = x + ((y - 1) * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);
    if (y > 0 && Chunk.voxels[y_minus].data.x != 0) {
        Chunk.voxels[index].data.y |= 0x8; // -Y
    }

    const uint z_plus = x + (y * CHUNK_SIZE) + ((z + 1) * CHUNK_SIZE_SQR);
    if (z < CHUNK_SIZE - 1 && Chunk.voxels[z_plus].data.x != 0) {
        Chunk.voxels[index].data.y |= 0x10; // +Z
    }

    const uint z_minus = x + (y * CHUNK_SIZE) + ((z - 1) * CHUNK_SIZE_SQR);
    if (z > 0 && Chunk.voxels[z_minus].data.x != 0) {
        Chunk.voxels[index].data.y |= 0x20; // -Z
    }
}
