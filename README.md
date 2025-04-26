# Z8

Rendering engine built on top of Vulkan and SDL3. It is rewrite in Zig of the original [R3DEngine](https://github.com/MrScriptX/R3D_Engine).

This project is moslty for fun and to try out Zig as a programming language.
It is not intended to be a full featured engine, but rather a simple and easy to use engine for rendering 3D graphics.
The end goal is to have a flexible engine, that I can use to play around.

The current state of the engine is following the 5 first chapters of the [vkguide](https://vkguide.dev/) with some modifications.

## Dependencies

### External Libraries

The folowing libraries are required to be installed on your system:

- [Zig](https://ziglang.org/) 0.14.0
- [Vulkan SDK 1.3](https://vulkan.lunarg.com/) or higher

### Included Libraries

The following libraries are included in the project, and don't need to be installed on your system:

- [SDL3](https://wiki.libsdl.org/SDL3/FrontPage)
- [GLM](https://github.com/recp/cglm) (cglm bindings)
- [cgltf](https://github.com/jkuhlmann/cgltf)
- [ImGui](https://github.com/dearimgui/dear_bindings) (c bindings)
- [zalgebra](https://github.com/kooparse/zalgebra)

## TODO List

- [ ] Add a configuration file to load and save settings
- [ ] Split ImGui into a separate module to build more complex UI
- [ ] Reorganize files and folders

### Scenes

- [ ] Add a scene graph to manage objects in the scene
- [ ] Make a more generic scene graph
- [ ] Make a scene manager to load and unload scenes

### Materials

- [ ] Make a better material system
- [ ] Create a material manager to load and unload materials
