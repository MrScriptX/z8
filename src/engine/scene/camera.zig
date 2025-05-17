pub const camera_t = struct {
    velocity: maths.vec3 = .{ 0, 0, 0 },
    position: maths.vec3 = .{ 0, 0, 0 },

    pitch: f32 = 0,
    yaw: f32 = 0,

    speed: f32 = 0,
    sensitivity: f32 = 0,

    active: bool = true,

    pub fn view_matrix(self: *const camera_t) za.Mat4 {
        const position = za.Vec3.new(self.position[0], self.position[1], self.position[2]);
        const camera_translation = za.Mat4.identity().translate(position);
        const camera_rotation = self.rotation_matrix();
        return za.Mat4.mul(camera_translation, camera_rotation).inv();
    }

    pub fn rotation_matrix(self: *const camera_t) za.Mat4 {
        const pitch_rotation = za.Quat.fromAxis(self.pitch, za.Vec3.new(1, 0, 0));
        const yaw_rotation = za.Quat.fromAxis(self.yaw, za.Vec3.new(0, -1, 0));
        return za.Mat4.mul(za.Quat.toMat4(yaw_rotation), za.Quat.toMat4(pitch_rotation));
    }

    pub fn process_sdl_event(self: *camera_t, e: *sdl.SDL_Event) void {
        if (e.type == sdl.SDL_EVENT_KEY_DOWN) {
            if (e.key.key == sdl.SDLK_Z) {
                self.velocity[2] = -1 * self.speed;
            }

            if (e.key.key == sdl.SDLK_S) {
                self.velocity[2] = 1 * self.speed;
            }

            if (e.key.key == sdl.SDLK_Q) {
                self.velocity[0] = -1 * self.speed;
            }

            if (e.key.key == sdl.SDLK_D) {
                self.velocity[0] = 1 * self.speed;
            }
        }

        if (e.type == sdl.SDL_EVENT_KEY_UP) {
            if (e.key.key == sdl.SDLK_Z) {
                self.velocity[2] = 0;
            }

            if (e.key.key == sdl.SDLK_S) {
                self.velocity[2] = 0;
            }

            if (e.key.key == sdl.SDLK_Q) {
                self.velocity[0] = 0;
            }

            if (e.key.key == sdl.SDLK_D) {
                self.velocity[0] = 0;
            }
        }

        if (e.type == sdl.SDL_EVENT_MOUSE_MOTION) {
            self.yaw += e.motion.xrel * self.sensitivity;  // / 200.0;
            self.pitch -= e.motion.yrel * self.sensitivity; //  / 200.0;
        }
    }

    pub fn update(self: *camera_t, dt: f32) void {
        const camera_rotation = self.rotation_matrix();
        const velocity = za.Vec4.new(self.velocity[0] * 0.5, self.velocity[1] * 0.5, self.velocity[2] * 0.5, 0);
        const move = camera_rotation.mulByVec4(velocity);

        self.position[0] += move.data[0] * (dt / 1_000_000_000.0);
        self.position[1] += move.data[1] * (dt / 1_000_000_000.0);
        self.position[2] += move.data[2] * (dt / 1_000_000_000.0);
    }
};

const vec4 = @Vector(4, f32);

const c = @import("../../clibs.zig");
const maths = @import("../../utils/maths.zig");
const za = @import("zalgebra");
const sdl = @import("sdl3");

test "camera update" {

}
