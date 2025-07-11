#version 450

#extension GL_EXT_debug_printf : enable

#include "constants.glsl"
#include "types.glsl"

layout(std430, binding = 0) buffer VertexBuffer {
    vertex_t vertices[];
};

layout(std430, binding = 1) buffer IndexBuffer {
    uint indices[];
};

layout(std430, binding = 2) buffer SolidDrawCommand {
    uint index_count;
    uint instance_count;
    uint first_index;
    int  vertex_offset;
    uint first_instance;
} opaque_cmd;

layout(std430, binding = 3) buffer WaterVertices {
    vertex_t water_vertices[];
};

layout(std430, binding = 4) buffer WaterIndices {
    uint water_indices[];
};

layout(std430, binding = 5) buffer WaterDrawCommand {
    uint index_count;
    uint instance_count;
    uint first_index;
    int  vertex_offset;
    uint first_instance;
} water_cmd;

layout(std430, binding = 6) buffer ChunkData {
    uint active_count;
    ivec3 position;
    voxel_t voxels[];
};

// layout(std430, binding = 1) readonly buffer InputDrawBuffer {
//     DrawIndexedIndirectCommand draw_commands[];
// };

// layout(std430, binding = 2) writeonly buffer OutputDrawBuffer {
//     DrawIndexedIndirectCommand visible_draws[];
// };

struct AABB {
    vec3 min;
    vec3 max;
};

bool aabb_in_frustum(AABB aabb, vec4[6] planes) {
    for (int i = 0; i < 6; ++i) {
        vec3 n = planes[i].xyz;
        float d = planes[i].w;

        vec3 p = aabb.min;
        if (n.x > 0) p.x = aabb.max.x;
        if (n.y > 0) p.y = aabb.max.y;
        if (n.z > 0) p.z = aabb.max.z;

        if (dot(n, p) + d < 0)
            return false;
    }
    return true;
}

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

void main()
{
    if (gl_GlobalInvocationID == uvec3(0)) {
        opaque_cmd.index_count = 0;
        opaque_cmd.instance_count = 1;
        opaque_cmd.first_index = 0;
        opaque_cmd.vertex_offset = 0;
        opaque_cmd.first_instance = 0;

        water_cmd.index_count = 0;
        water_cmd.instance_count = 1;
        water_cmd.first_index = 0;
        water_cmd.vertex_offset = 0;
        water_cmd.first_instance = 0;
    }

    barrier();

    // vec3 min = vec3(chunk_coord * chunk_dim);
    // vec3 max = min + vec3(chunk_dim);
}
