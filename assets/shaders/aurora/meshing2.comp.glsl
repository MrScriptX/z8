#version 450

#include "constants.glsl"
#include "simplex_noise.glsl"
#include "types.glsl"

layout(std430, binding = 0) buffer VertexBuffer {
    vertex_t vertices[];
};

layout(std430, binding = 1) buffer IndexBuffer {
    uint indices[];
};

layout(std430, binding = 2) buffer IndirectCommand {
    uint indexCount;
    uint instanceCount;
    uint firstIndex;
    int  vertexOffset;
    uint firstInstance;
};

layout(std430, binding = 3) buffer ChunkData {
    uint active_count;
    ivec3 position;
    voxel_t voxels[];
};

void greedy_meshing(uint dir, uint slice);
void create_quad(vec3 pos, uvec3 dir, uvec3 size, vec3 normal, vec4 color);

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

void main()
{
    if (gl_GlobalInvocationID == uvec3(0)) {
        indexCount = 0;
        instanceCount = 1;
        firstIndex = 0;
        vertexOffset = 0;
        firstInstance = 0;
    }

    const uint dir = gl_GlobalInvocationID.y; // 0: X, 1: -X, 2: Y, 3: -Y, 4: Z, 5: -Z
    const uint slice = gl_GlobalInvocationID.x; // slice in the direction of the mesh
    greedy_meshing(dir, slice);
}

void greedy_meshing(uint dir, uint slice)
{
    bool processed[CHUNK_SIZE][CHUNK_SIZE];
    // Initialize processed array
    for (uint i = 0; i < CHUNK_SIZE; i++) {
        for (uint j = 0; j < CHUNK_SIZE; j++) {
            processed[i][j] = false;
        }
    }

    for (uint i = 0; i < CHUNK_SIZE; i++) {
        for (uint j = 0; i < CHUNK_SIZE; j++) {
            if (processed[i][j]) {
                continue;
            }

            uvec3 pos; // position in the chunk
            if (dir == 0 || dir == 1) { // X direction
                pos = uvec3(slice, i, j);
            }
            else if (dir == 2 || dir == 3) { // Y direction
                pos = uvec3(i, slice, j);
            }
            else { // Z direction
                pos = uvec3(i, j, slice);
            }

            const uint index = pos.x + (pos.y * CHUNK_SIZE) + (pos.z * CHUNK_SIZE_SQR);
            if (voxels[index].data.x == 0) { // AIR
                continue;
            }

            const uint visibility_mask = voxels[index].data.y;
            if ((visibility_mask & (1u << dir)) != 0u) { // face is hidden
                continue;
            }

            // Find the extent of the face in the specified direction
            uint width = 1;
            for (width = 1; i + width < CHUNK_SIZE && !processed[i + width][j]; width++) {
                uvec3 next_pos;
                if (dir == 0 || dir == 1) { // X direction
                    next_pos = uvec3(slice, i + width, j);
                }
                else if (dir == 2 || dir == 3) { // Y direction
                    next_pos = uvec3(i + width, slice, j);
                }
                else { // Z direction
                    next_pos = uvec3(i + width, j, slice);
                }

                const uint next_index = next_pos.x + (next_pos.y * CHUNK_SIZE) + (next_pos.z * CHUNK_SIZE_SQR);
                if (voxels[next_index].data.x == 0 || (voxels[next_index].data.y & (1u << dir)) != 0u) {
                    break; // stop if we hit air or a hidden face
                }
            }

            // Find the extent of the face in the perpendicular direction
            uint height = 1;
            for (height = 1; j + height < CHUNK_SIZE && !processed[i][j + height]; height++) {
                bool valid = true; // mesh must be a rectangle
                for (uint k = 0; k < width; k++) {
                    if (processed[i + k][j + height]) {
                        valid = false;
                        break;
                    }

                    uvec3 next_pos;
                    if (dir == 0 || dir == 1) { // X direction
                        next_pos = uvec3(slice, i + k, j + height);
                    }
                    else if (dir == 2 || dir == 3) { // Y direction
                        next_pos = uvec3(i + k, slice, j + height);
                    }
                    else { // Z direction
                        next_pos = uvec3(i + k, j + height, slice);
                    }

                    const uint next_index = next_pos.x + (next_pos.y * CHUNK_SIZE) + (next_pos.z * CHUNK_SIZE_SQR);
                    if (voxels[next_index].data.x == 0 || (voxels[next_index].data.y & (1u << dir)) != 0u) {
                        valid = false;
                        break; // stop if we hit air or a hidden face
                    }

                    if (!valid) {
                        break;
                    }
                }
            }

            // mark the processed area
            for (uint dx = 0; dx < width; dx++) {
                for (uint dy = 0; dy < height; dy++) {
                    processed[i + dx][j + dy] = true;
                }
            }

            // create the mesh
            vec3 normal;
            vec4 color;
            if (dir == 0) { // X
                normal = normals[0];
                color = colors[0];
            }
            else if (dir == 1) { // -X
                normal = normals[1];
                color = colors[0];
            }
            else if (dir == 2) { // Y
                normal = normals[2];
                color = colors[0];
            }
            else if (dir == 3) { // -Y
                normal = normals[3];
                color = colors[0];
            }
            else if (dir == 4) { // Z
                normal = normals[4];
                color = colors[0];
            }
            else { // -Z
                normal = normals[5];
                color = colors[0];
            }

            vec3 world_pos = vec3(pos) + vec3(position) * float(CHUNK_SIZE) + vec3(0.5);
            create_quad(world_pos, uvec3(dir), uvec3(width, height, 1), normal, color);
        }
    }
}

void create_quad(vec3 pos, uvec3 dir, uvec3 size, vec3 normal, vec4 color)
{
    vertex_t v[4];
    v[0].position = pos + vec3(0.0, 0.0, 0.0);
    v[1].position = pos + vec3(size.x, 0.0, 0.0);
    v[2].position = pos + vec3(size.x, size.y, 0.0);
    v[3].position = pos + vec3(0.0, size.y, 0.0);

    v[0].normal = normal;
    v[1].normal = normal;
    v[2].normal = normal;
    v[3].normal = normal;

    v[0].uv_x = 0.0;
    v[0].uv_y = 0.0;

    v[1].uv_x = 1.0;
    v[1].uv_y = 0.0;

    v[2].uv_x = 1.0;
    v[2].uv_y = 1.0;

    v[3].uv_x = 0.0;
    v[3].uv_y = 1.0;

    v[0].color = color;
    v[1].color = color;
    v[2].color = color;
    v[3].color = color;

    const uint base_index = atomicAdd(indexCount, 6);
    vertices[base_index + 0] = v[0];
    vertices[base_index + 1] = v[1];
    vertices[base_index + 2] = v[2];
    vertices[base_index + 3] = v[3];

    indices[base_index + 0] = base_index + 0;
    indices[base_index + 1] = base_index + 1;
    indices[base_index + 2] = base_index + 2;
    indices[base_index + 3] = base_index + 0;
    indices[base_index + 4] = base_index + 2;
    indices[base_index + 5] = base_index + 3;
}
