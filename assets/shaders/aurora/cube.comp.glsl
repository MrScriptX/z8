#version 450

layout(local_size_x = 36, local_size_y = 1, local_size_z = 1) in;

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

void main() {
    uint vertex_id = gl_GlobalInvocationID.x;

    // Define cube vertices
    vec3 positions[6][4] = vec3[][]( // 6 faces * 4 vertices
        vec3[]( // -Z
            vec3(-0.5, -0.5, -0.5),
            vec3(0.5, -0.5, -0.5),
            vec3(0.5, 0.5, -0.5),
            vec3(-0.5, 0.5, -0.5)
        ),

        vec3[]( // +Z
            vec3(0.5, -0.5, 0.5),
            vec3(-0.5, -0.5, 0.5),
            vec3(-0.5, 0.5, 0.5),
            vec3(0.5, 0.5, 0.5)
        ),

        vec3[]( // -X
            vec3(-0.5, -0.5, 0.5),
            vec3(-0.5, -0.5, -0.5),
            vec3(-0.5, 0.5, -0.5),
            vec3(-0.5, 0.5, 0.5)
        ),

        vec3[]( // +X
            vec3( 0.5, -0.5, -0.5),
            vec3( 0.5, -0.5, 0.5),
            vec3( 0.5, 0.5, 0.5),
            vec3( 0.5, 0.5, -0.5)
        ),
        
        vec3[]( // +Y
            vec3(-0.5, 0.5, -0.5),
            vec3( 0.5,  0.5, -0.5),
            vec3( 0.5,  0.5,  0.5),
            vec3(-0.5,  0.5,  0.5)
        ),

        vec3[]( // -Y
            vec3(-0.5, -0.5, 0.5),
            vec3( 0.5, -0.5, 0.5),
            vec3( 0.5, -0.5, -0.5),
            vec3(-0.5, -0.5, -0.5)
        )
    );

    vec3 normals[6] = vec3[](
        vec3(0, 0, -1),
        vec3(0, 0, 1),
        vec3(-1, 0, 0),
        vec3(1, 0, 0),
        vec3(0, 1, 0),
        vec3(0, -1, 0)
    );

    vec2 uvs[4] = vec2[](
        vec2(0, 0),
        vec2(1, 0),
        vec2(1, 1),
        vec2(0, 1)
    );

    vec4 colors[6] = vec4[](
        vec4(1, 0, 0, 1), // -Z Red
        vec4(0, 1, 0, 1), // +Z Green
        vec4(0, 0, 1, 1), // -X Blue
        vec4(1, 1, 0, 1), // +X Yellow
        vec4(1, 0, 1, 1), // -Y Magenta
        vec4(0, 1, 1, 1)  // +Y Cyan
    );

    const uint face_indices[6][6] = uint[6][6](
        uint[](0, 1, 2, 0, 2, 3), // -Z
        uint[](4, 5, 6, 4, 6, 7), // +Z
        uint[](8, 9,10, 8,10,11), // -X
        uint[](12,13,14,12,14,15), // +X
        uint[](16,17,18,16,18,19), // +Y
        uint[](20,21,22,20,22,23)  // -Y
    );

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
