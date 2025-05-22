# Z8

Z8 is a personal 3D rendering engine project built with [Zig](https://ziglang.org/), [Vulkan](https://vulkan.lunarg.com/), and [SDL3](https://wiki.libsdl.org/SDL3/FrontPage). It's a rewrite in Zig of my original [R3DEngine](https://github.com/MrScriptX/R3D_Engine), and serves as a playground for trying out new ideas, learning graphics programming, and exploring the Zig language.


## Project Overview

This project is mostly for fun and personal growth. My goal is to have a flexible engine that I can use to experiment with rendering techniques, engine architecture, and new features as I learn. It's not intended to be a full-featured or production-ready engine, but rather a simple and approachable codebase for tinkering and prototyping.

The current implementation follows the first five chapters of the excellent [vkguide](https://vkguide.dev/) tutorial, with some modifications and my own ideas mixed in.

The project is moving toward a voxel engine using GPU compute shaders, so expect most improvements to be made in that direction. If you don't understand something, feel free to ask me on GitHub or under one YouTube videos.

## Current Features

- Vulkan-based rendering loop
- SDL3 window and input handling
- Basic scene and material system (work in progress)
- ImGui integration for UI (work in progress)
- Basic camera and input handling
- Basic shader management
- GPU-based rendering pipeline

## Getting Started

### Prerequisites

You'll need:

- [Zig](https://ziglang.org/) 0.14.0
- [Vulkan SDK 1.3](https://vulkan.lunarg.com/) or higher

### Building and Running

1. Clone this repository
2. Make sure the Vulkan SDK is installed and available in your PATH
3. Build the project:
   ```pwsh
   zig build
   ```
4. Run the engine:
   ```pwsh
   zig-out/bin/z8.exe
   ```

If you run into issues, double-check your Vulkan SDK installation and Zig version.


## Project Structure

- `src/` — Main engine source code
- `assets/` — Models, shaders, and other assets
- `common/` — Third-party and utility libraries
- `libs/` — Zig build wrappers for dependencies
- `levels/` — Example scenes and levels


## Inspirations & References

- [vkguide](https://vkguide.dev/) — Main inspiration and reference
- [Zig documentation](https://ziglang.org/documentation/)
- [Vulkan Tutorial](https://vulkan-tutorial.com/)


## Progress & Roadmap

See the TODO list below for planned features and improvements. Completed items are checked off.


### Included Libraries

The following libraries are included in the project (no need to install separately):

- [SDL3](https://wiki.libsdl.org/SDL3/FrontPage)
- [GLM](https://github.com/recp/cglm) (cglm bindings)
- [cgltf](https://github.com/jkuhlmann/cgltf)
- [ImGui](https://github.com/dearimgui/dear_bindings) (C bindings)
- [zalgebra](https://github.com/kooparse/zalgebra)

## TODO List

- [ ] Add a configuration file to load and save settings
- [ ] Split ImGui into a separate module to build more complex UI
- [x] Reorganize files and folders
- [x] Destroy and create swapchain semaphores and fences when resizing the window

### Scenes
- [ ] Add a scene graph to manage objects in the scene
- [ ] Make a more generic scene graph
- [ ] Make a scene manager to load and unload scenes

### Materials
- [x] Make a better material system
- [ ] Create a material manager to load and unload materials

---

## License

See [LICENSE](LICENSE) for details. Credits to all upstream libraries and inspirations.
