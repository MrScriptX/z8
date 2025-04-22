# Z8

Rendering engine built on top of Vulkan and SDL3. It is rewrite in Zig of the original R3DEngine.

This project is moslty for fun and to try out Zig as a programming language.
It is not intended to be a full featured engine, but rather a simple and easy to use engine for rendering 3D graphics.
The end goal is to have a flexible engine, that I can use to play around.

## Dependencies

### External Libraries

The folowing libraries are required to be installed on your system:

- Zig 0.14.0
- Vulkan SDK 1.3 or higher

### Included Libraries

The following libraries are included in the project, and don't need to be installed on your system:

- SDL3
- GLM (cglm bindings)
- cgltf
- ImGui (c bindings)
- zalgebra
