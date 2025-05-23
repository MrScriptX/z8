#version 450

#include "constants.glsl"
#include "simplex_noise.glsl"
#include "types.glsl"

layout(std430, binding = 0) buffer VertexBuffer {
    vertex_t vertices[];
};

layout(std430, binding = 1) buffer IndexBuffer {
    uint indices[];
};

layout(std430, binding = 2) buffer IndirectCommand {
    uint indexCount;
    uint instanceCount;
    uint firstIndex;
    int  vertexOffset;
    uint firstInstance;
};

layout(std430, binding = 3) buffer ChunkData {
    uint active_count;
    ivec3 position;
    voxel_t voxels[];
};

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

void main() {
    const uint x = gl_GlobalInvocationID.x;
    const uint y = gl_GlobalInvocationID.y;
    const uint z = gl_GlobalInvocationID.z;
 
    const uint index = x + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);
    if (voxels[index].data.x == 0) { // AIR
        return;
    }

    const vec3 chunk_world_pos = vec3(position) * float(CHUNK_SIZE);
    const vec3 cube_pos = vec3(gl_GlobalInvocationID) - vec3(CHUNK_SIZE) * 0.5 + vec3(0.5) + chunk_world_pos;

    for (uint face = 0; face < 6; face++) {
        for (uint tri_vertex = 0; tri_vertex < 6; tri_vertex++) {
            const uint index_in_face = face_indices[face][tri_vertex];
            const uint local_idx = index_in_face % 4;

            vertex_t v;
            v.position = positions[face][local_idx] + cube_pos;
            v.normal = normals[face];
            v.uv_x = uvs[local_idx].x;
            v.uv_y = uvs[local_idx].y;
            v.color = colors[face];

            const uint vertex_offset = index * 36;
            const uint vtx_id = vertex_offset + face * 6 + tri_vertex;
            vertices[vtx_id] = v;
            indices[vtx_id] = vtx_id; // No reuse
        }
    }

    if (gl_GlobalInvocationID == uvec3(0)) {
        indexCount = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE * 36;
        instanceCount = 1;
        firstIndex = 0;
        vertexOffset = 0;
        firstInstance = 0;
    }
}
