#version 450

#extension GL_EXT_buffer_reference : require

struct vertex_t {
    vec3 position;
	float uv_x;
	vec3 normal;
	float uv_y;
	vec4 color;
};

layout(set = 0, binding = 0) uniform  SceneData{   
	mat4 view;
	mat4 proj;
	mat4 viewproj;
	vec4 ambientColor;
	vec4 sunlightDirection; //w for sun power
	vec4 sunlightColor;
} scene_data;

layout(set = 1, binding = 0) readonly buffer VertexBuffer2 {
    vertex_t vertices[];
} vertex_buffer;

layout(location = 0) out vec3 fragNormal;
layout(location = 1) out vec2 fragUV;

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

    fragNormal = v.normal;
    fragUV.x = v.uv_x;
    fragUV.y = v.uv_y;
}
