#version 450

#extension GL_EXT_debug_printf : enable

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
void create_quad(vec3 pos, uint dir, uvec2 size, vec3 normal, vec4 color);

const uint DIR_X_NEG = 2;
const uint DIR_X_POS = 3;

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

    barrier();

    const uint dir = gl_GlobalInvocationID.y; // 0: -Z, 1: +Z, 2: -X, 3: +X, 4: +Y, 5: -Y
    const uint slice = gl_GlobalInvocationID.x; // slice in the direction of the mesh

    if (dir == DIR_X_NEG || dir == DIR_X_POS) {
        greedy_meshing(dir, slice);
    }
}

bool is_hidden(uint index, uint dir) {
    const uint visibility_mask = voxels[index].data.y;
    const bool hidden = (visibility_mask & (1u << dir)) != 0u;
    return hidden;
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
        for (uint j = 0; j < CHUNK_SIZE; j++) {
            if (processed[i][j]) {
                continue;
            }

            uvec3 pos; // position in the chunk
            if (dir == DIR_X_NEG || dir == DIR_X_POS) { // X direction
                pos = uvec3(slice, i, j);
            }
            else if (dir == 4 || dir == 5) { // Y direction
                pos = uvec3(i, slice, j);
            }
            else { // Z direction
                pos = uvec3(i, j, slice);
            }

            const uint index = pos.x + (pos.y * CHUNK_SIZE) + (pos.z * CHUNK_SIZE_SQR);
            if (voxels[index].data.x == 0) { // AIR
                processed[i][j] = true;
                continue;
            }

            if (is_hidden(index, dir)) {
                processed[i][j] = true;
                continue;
            }

            // Find the extent of the face in the specified direction
            uint width = 1;
            for (width = 1; i + width < CHUNK_SIZE && !processed[i + width][j]; width++) {
                uvec3 next_pos;
                if (dir == DIR_X_NEG || dir == DIR_X_POS) { // X direction
                    next_pos = uvec3(slice, i + width, j);
                }
                else if (dir == 4 || dir == 5) { // Y direction
                    next_pos = uvec3(i + width, slice, j);
                }
                else { // Z direction
                    next_pos = uvec3(i + width, j, slice);
                }

                const uint next_index = next_pos.x + (next_pos.y * CHUNK_SIZE) + (next_pos.z * CHUNK_SIZE_SQR);
                if (voxels[next_index].data.x == 0) {
                    break; // stop if we hit air or a hidden face
                }

                if (is_hidden(next_index, dir)) break;
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
                    if (dir == DIR_X_NEG || dir == DIR_X_POS) { // X direction
                        next_pos = uvec3(slice, i + k, j + height);
                    }
                    else if (dir == 4 || dir == 5) { // Y direction
                        next_pos = uvec3(i + k, slice, j + height);
                    }
                    else { // Z direction
                        next_pos = uvec3(i + k, j + height, slice);
                    }

                    const uint next_index = next_pos.x + (next_pos.y * CHUNK_SIZE) + (next_pos.z * CHUNK_SIZE_SQR);
                    if (voxels[next_index].data.x == 0) {
                        valid = false;
                        break; // stop if we hit air or a hidden face
                    }

                    if (is_hidden(next_index, dir)) break;
                }

                if (!valid) {
                    break;
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
            uvec2 size;
            if (dir == DIR_X_POS) { // X
                normal = normals[0];
                color = colors[0];
                size = uvec2(height, width);
            }
            else if (dir == DIR_X_NEG) { // -X
                normal = normals[1];
                color = colors[0];
                size = uvec2(height, width);
            }
            else if (dir == 4) { // Y
                normal = normals[2];
                color = colors[0];
                size = uvec2(width, height);
            }
            else if (dir == 5) { // -Y
                normal = normals[3];
                color = colors[0];
                size = uvec2(width, height);
            }
            else if (dir == 1) { // Z
                normal = normals[4];
                color = colors[0];
                size = uvec2(width, height);
            }
            else { // -Z
                normal = normals[5];
                color = colors[0];
                size = uvec2(width, height);
            }

            vec3 world_pos = vec3(pos) + vec3(position) * float(CHUNK_SIZE) + vec3(0.5);
            create_quad(world_pos, dir, size, normal, color);
        }
    }
}

void create_quad(vec3 pos, uint dir, uvec2 size, vec3 normal, vec4 color)
{
    vertex_t v[4];

    if (dir == 0) { // -Z
        v[0].position = pos + vec3(0.0, 0.0, 0.0);
        v[1].position = pos + vec3(size.x, 0.0, 0.0);
        v[2].position = pos + vec3(size.x, size.y, 0.0);
        v[3].position = pos + vec3(0.0, size.y, 0.0);
    }
    else if (dir == 1) { // +Z
        v[0].position = pos + vec3(0.0, 0.0, 1.0);
        v[1].position = pos + vec3(0.0, size.y, 1.0);
        v[2].position = pos + vec3(size.x, size.y, 1.0);
        v[3].position = pos + vec3(size.x, 0.0, 1.0);
    }
    else if (dir == DIR_X_NEG) { // -X
        v[0].position = pos + vec3(0.0, 0.0, 0.0);
        v[1].position = pos + vec3(0.0, size.x, 0.0);
        v[2].position = pos + vec3(0.0, size.x, size.y);
        v[3].position = pos + vec3(0.0, 0.0, size.y);
    }
    else if (dir == DIR_X_POS) { // +X
        v[0].position = pos + vec3(1.0, 0.0, 0.0);
        v[1].position = pos + vec3(1.0, 0.0, size.y);
        v[2].position = pos + vec3(1.0, size.x, size.y);
        v[3].position = pos + vec3(1.0, size.x, 0.0);
    }
    else if (dir == 4) { // +Y
        v[0].position = pos + vec3(0.0, 1.0, 0.0);
        v[1].position = pos + vec3(0.0, 1.0, size.y);
        v[2].position = pos + vec3(size.x, 1.0, size.y);
        v[3].position = pos + vec3(size.x, 1.0, 0.0);
    }
    else if (dir == 5) { // -Y
        v[0].position = pos + vec3(0.0, 0.0, 0.0);
        v[1].position = pos + vec3(size.x, 0.0, 0.0);
        v[2].position = pos + vec3(size.x, 0.0, size.y);
        v[3].position = pos + vec3(0.0, 0.0, size.y);
    }

    for (int i = 0; i < 4; i++) {
        v[i].normal = normal;
        v[i].color = color;
    }

    v[0].uv_x = 0.0; v[0].uv_y = 0.0;
    v[1].uv_x = 1.0; v[1].uv_y = 0.0;
    v[2].uv_x = 1.0; v[2].uv_y = 1.0;
    v[3].uv_x = 0.0; v[3].uv_y = 1.0;

    const uint vertex_base = atomicAdd(active_count, 4);
    const uint index_base = atomicAdd(indexCount, 6);

    vertices[vertex_base + 0] = v[0];
    vertices[vertex_base + 1] = v[1];
    vertices[vertex_base + 2] = v[2];
    vertices[vertex_base + 3] = v[3];

    indices[index_base + 0] = vertex_base + 0;
    indices[index_base + 1] = vertex_base + 1;
    indices[index_base + 2] = vertex_base + 2;
    indices[index_base + 3] = vertex_base + 0;
    indices[index_base + 4] = vertex_base + 2;
    indices[index_base + 5] = vertex_base + 3;
}
