pub const camera_t = struct {
    velocity: maths.vec3 = .{ 0, 0, 0 },
    position: maths.vec3 = .{ 0, 0, 0 },

    pitch: f32 = 0,
    yaw: f32 = 0,

    pub fn view_matrix(self: *camera_t) zalgebra.Mat4 {
        const camera_translation = zalgebra.Mat4.identity().translate(self.position);
        const camera_rotation = self.rotation_matrix();
        return zalgebra.Mat4.mul(camera_translation, camera_rotation).inv();
    }

    pub fn rotation_matrix(self: *camera_t) zalgebra.Mat4 {
        const pitch_rotation = zalgebra.Quat.fromAxis(self.pitch, zalgebra.Vec3.new(1, 0, 0));
        const yaw_rotation = zalgebra.Quat.fromAxis(self.yaw, zalgebra.Vec3.new(0, -1, 0));
        return zalgebra.Mat4.mul(zalgebra.Quat.toMat4(yaw_rotation), zalgebra.Quat.toMat4(pitch_rotation));
    }

    pub fn process_sdl_event(self: *camera_t, e: *c.SDL_Event) void {
        if (e.type == c.SDL_EVENT_KEY_DOWN) {
            if (e.key.key == c.SDLK_Z) {
                self.velocity[2] = -1;
            }

            if (e.key.key == c.SDLK_S) {
                self.velocity[2] = 1;
            }

            if (e.key.key == c.SDLK_Q) {
                self.velocity[0] = -1;
            }

            if (e.key.key == c.SDLK_D) {
                self.velocity[0] = 1;
            }
        }

        if (e.type == c.SDL_EVENT_KEY_UP) {
            if (e.key.key == c.SDLK_Z) {
                self.velocity[2] = 0;
            }

            if (e.key.key == c.SDLK_S) {
                self.velocity[2] = 0;
            }

            if (e.key.key == c.SDLK_Q) {
                self.velocity[0] = 0;
            }

            if (e.key.key == c.SDLK_D) {
                self.velocity[0] = 0;
            }
        }

        if (e.type == c.SDL_EVENT_MOUSE_MOTION) {
            self.yaw += e.motion.xrel / 200.0;
            self.pitch -= e.motion.yrel / 200.0;
        }
    }

    pub fn update(self: *camera_t) void {
        const camera_rotation = self.rotation_matrix();
        const velocity = zalgebra.Vec4.new(self.velocity[0] * 0.5, self.velocity[0] * 0.5, self.velocity[0] * 0.5, 0);
        const move = camera_rotation.mulByVec4(velocity);

        self.position[0] += move.data[0];
        self.position[1] += move.data[1];
        self.position[2] += move.data[2];
    }
};

const vec4 = @Vector(4, f32);

const c = @import("../clibs.zig");
const maths = @import("../utils/maths.zig");
const zalgebra = @import("zalgebra");

test "camera update" {

}
