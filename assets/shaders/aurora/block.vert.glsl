#version 450

#extension GL_EXT_buffer_reference : require

#include "types.glsl"

layout(set = 0, binding = 0) uniform  SceneData {   
	mat4 view;
	mat4 proj;
	mat4 viewproj;
	vec4 ambient_color;
	vec4 sunlight_direction; //w for sun power
	vec4 sunlight_color;
    float time;
} scene_data;

layout(set = 1, binding = 0) readonly buffer VertexBuffer2 {
    vertex_t vertices[];
} vertex_buffer;

layout(location = 0) out vec3 frag_normal;
layout(location = 1) out vec2 frag_uv;
layout(location = 2) out vec4 out_color;

layout(buffer_reference, std430) readonly buffer VertexBuffer { 
	vertex_t vertices[];
};

layout(push_constant) uniform PushConstants {
    mat4 render_matrix;
	VertexBuffer vertex_buffer;
} pc;

void main() {
    vertex_t v = vertex_buffer.vertices[gl_VertexIndex];

    vec4 position = vec4(v.position, 1.0f);
    gl_Position = scene_data.viewproj * pc.render_matrix * position;

    frag_normal = v.normal;
    frag_uv.x = v.uv_x;
    frag_uv.y = v.uv_y;
    out_color = v.color;
}
