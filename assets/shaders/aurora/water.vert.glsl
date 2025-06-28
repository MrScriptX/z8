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
    float time;
} scene_data;

layout(set = 1, binding = 0) readonly buffer VertexBuffer2 {
    vertex_t vertices[];
} vertex_buffer;

layout(location = 0) out vec3 frag_normal;
layout(location = 1) out vec2 frag_uv;
layout(location = 2) out float frag_wave;
layout(location = 3) out float frag_time;

layout(buffer_reference, std430) readonly buffer VertexBuffer { 
    vertex_t vertices[];
};

layout(push_constant) uniform PushConstants {
    mat4 render_matrix;
    VertexBuffer vertex_buffer;
} pc;

void main() {
    vertex_t v = vertex_buffer.vertices[gl_VertexIndex];

    // Animate water surface slightly (fake wave)
    float wave = sin(scene_data.time * 2.0 + v.position.x * 0.5 + v.position.z * 0.5) * 0.085;
    vec4 position = vec4(v.position.x, v.position.y - 0.15 + wave, v.position.z, 1.0);

    gl_Position = scene_data.viewproj * pc.render_matrix * position;

    frag_normal = v.normal;
    frag_uv = vec2(v.uv_x, v.uv_y);
    frag_wave = wave;
    frag_time = scene_data.time;
}
