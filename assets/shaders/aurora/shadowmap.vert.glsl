#version 450

layout(location = 0) in vec3 in_position;

layout(std140, set = 0, binding = 0) uniform vp_ubo {
    mat4 viewproj;
} light;

layout(push_constant) uniform PushConstants {
    uint cascade_index;
};

void main() {
    gl_Position = light.viewproj[cascade_index] * vec4(in_position, 1.0);
}
