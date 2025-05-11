#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inUV;

layout(location = 0) out vec3 fragNormal;
layout(location = 1) out vec2 fragUV;

layout(push_constant) uniform PushConstants {
    mat4 model;
    mat4 view;
    mat4 proj;
} pc;

void main() {
    fragNormal = inNormal;
    fragUV = inUV;
    gl_Position = pc.proj * pc.view * pc.model * vec4(inPosition, 1.0);
}
