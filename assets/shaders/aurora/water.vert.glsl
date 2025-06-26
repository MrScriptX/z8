#version 450

#extension GL_EXT_buffer_reference : require

#include "types.glsl"

layout(set = 0, binding = 0) uniform SceneData {  
    mat4 view;
    mat4 proj;
    mat4 viewproj;
    vec4 ambientColor;
    vec4 sunlightDirection;
    vec4 sunlightColor;
} scene_data;

layout(location = 0) out vec3 fragNormal;
layout(location = 1) out vec2 fragUV;
layout(location = 2) out float fragWave;

layout(buffer_reference, std430) readonly buffer VertexBuffer { 
    vertex_t vertices[];
};

layout(push_constant) uniform PushConstants {
    mat4 render_matrix;
    VertexBuffer vertex_buffer;
} pc;

void main() {
    // vertex_t v = pc.vertex_buffer.vertices[gl_VertexIndex];

    // // Animate water surface slightly (fake wave)
    // float wave = sin(scene_data.view[3].x + v.position.x * 0.5 + scene_data.view[3].z + v.position.z * 0.5) * 0.05;
    // vec4 position = vec4(v.position.x, v.position.y + wave, v.position.z, 1.0);

    // gl_Position = scene_data.viewproj * pc.render_matrix * position;

    // fragNormal = v.normal;
    // fragUV = vec2(v.uv_x, v.uv_y);
    // fragWave = wave;

    vertex_t v = pc.vertex_buffer.vertices[gl_VertexIndex];

    vec4 position = vec4(v.position, 1.0f);
    gl_Position = scene_data.viewproj * pc.render_matrix * position;

    fragNormal = v.normal;
    fragUV.x = v.uv_x;
    fragUV.y = v.uv_y;
}
