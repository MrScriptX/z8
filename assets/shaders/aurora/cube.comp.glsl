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

layout(local_size_x = 36, local_size_y = 1, local_size_z = 1) in;

void main() {
    if (gl_GlobalInvocationID.x == 0) {
        indexCount = 36;
        instanceCount = 1;
        firstIndex = 0;
        vertexOffset = 0;
        firstInstance = 0;
    }

    uint vertex_id = gl_GlobalInvocationID.x;

    uint face = vertex_id / 6;
    uint tri_vertex = vertex_id % 6;
    uint index_in_face = face_indices[face][tri_vertex];

    uint local_idx = index_in_face % 4;

    vertex_t v;
    v.position = positions[face][local_idx];
    v.normal = normals[face];
    v.uv_x = uvs[local_idx].x;
    v.uv_y = uvs[local_idx].y;
    v.color = colors[face];

    vertices[vertex_id] = v;
    indices[vertex_id] = vertex_id; // no reuse
}
