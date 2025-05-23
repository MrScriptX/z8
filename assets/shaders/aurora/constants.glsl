uint CHUNK_SIZE = 32;
uint CHUNK_SIZE_SQR = CHUNK_SIZE * CHUNK_SIZE;

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

// face bit mask
const uint FACE_NEG_Z = 0x01; // face 0
const uint FACE_POS_Z = 0x02; // face 1
const uint FACE_NEG_X = 0x04; // face 2
const uint FACE_POS_X = 0x08; // face 3
const uint FACE_POS_Y = 0x10; // face 4
const uint FACE_NEG_Y = 0x20; // face 5
