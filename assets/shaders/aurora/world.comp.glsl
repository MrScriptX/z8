#version 450

#include "constants.glsl"

struct vertex_t {
    vec3 position;
	float uv_x;
	vec3 normal;
	float uv_y;
	vec4 color;
};

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

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

void main() {
    uint x = gl_GlobalInvocationID.x;
    uint y = gl_GlobalInvocationID.y;
    uint z = gl_GlobalInvocationID.z;

    uint index = x + (y * CHUNK_SIZE) + (z * CHUNK_SIZE_SQR);
    uint vertex_offset = index * 36;

    vec3 cube_pos = vec3(gl_GlobalInvocationID) - vec3(CHUNK_SIZE) * 0.5 + vec3(0.5); 

    for (uint face = 0; face < 6; face++) {
        for (uint tri_vertex = 0; tri_vertex < 6; tri_vertex++) {
            uint index_in_face = face_indices[face][tri_vertex];
            uint local_idx = index_in_face % 4;

            vertex_t v;
            v.position = positions[face][local_idx] + cube_pos;
            v.normal = normals[face];
            v.uv_x = uvs[local_idx].x;
            v.uv_y = uvs[local_idx].y;
            v.color = colors[face];

            uint vtx_id = vertex_offset + face * 6 + tri_vertex;
            vertices[vtx_id] = v;
            indices[vtx_id] = vtx_id; // No reuse
        }
    }

    indexCount = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE * 36;
    instanceCount = 1;
    firstIndex = 0;
    vertexOffset = 0;
    firstInstance = 0;

    // uint vertex_id = gl_GlobalInvocationID.x;

    // uint face = vertex_id / 6;
    // uint tri_vertex = vertex_id % 6;
    // uint index_in_face = face_indices[face][tri_vertex];

    // uint local_idx = index_in_face % 4;

    // vertex_t v;
    // v.position = positions[face][local_idx];
    // v.normal = normals[face];
    // v.uv_x = uvs[local_idx].x;
    // v.uv_y = uvs[local_idx].y;
    // v.color = colors[face];

    // vertices[vertex_id] = v;
    // indices[vertex_id] = vertex_id; // no reuse
}
