#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

struct Vertex {
    vec3 position;
    vec3 normal;
    vec2 uv;
};

layout(std430, binding = 0) buffer VertexBuffer {
    Vertex vertices[];
};

layout(std430, binding = 1) buffer IndexBuffer {
    uint indices[];
};

void main() {
    uint vertex_id = gl_GlobalInvocationID.x;

    // Define cube vertices
    vec3 positions[8] = vec3[](
        vec3(-0.5, -0.5, -0.5), vec3(0.5, -0.5, -0.5),
        vec3(0.5,  0.5, -0.5), vec3(-0.5,  0.5, -0.5),
        vec3(-0.5, -0.5,  0.5), vec3(0.5, -0.5,  0.5),
        vec3(0.5,  0.5,  0.5), vec3(-0.5,  0.5,  0.5)
    );

    vec3 normals[6] = vec3[](
        vec3(0, 0, -1), vec3(0, 0, 1),
        vec3(-1, 0, 0), vec3(1, 0, 0),
        vec3(0, -1, 0), vec3(0, 1, 0)
    );

    vec2 uvs[4] = vec2[](
        vec2(0, 0), vec2(1, 0),
        vec2(1, 1), vec2(0, 1)
    );

    // Define cube indices
    uint cube_indices[36] = uint[](
        0, 1, 2, 0, 2, 3, // Front
        4, 5, 6, 4, 6, 7, // Back
        0, 3, 7, 0, 7, 4, // Left
        1, 5, 6, 1, 6, 2, // Right
        3, 2, 6, 3, 6, 7, // Top
        0, 1, 5, 0, 5, 4  // Bottom
    );

    if (vertex_id < 8) {
        vertices[vertex_id].position = positions[vertex_id];
        vertices[vertex_id].normal = normals[vertex_id / 4];
        vertices[vertex_id].uv = uvs[vertex_id % 4];
    }

    if (vertex_id < 36) {
        indices[vertex_id] = cube_indices[vertex_id];
    }
}
