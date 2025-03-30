const c = @import("../clibs.zig");

pub const vertex_t  = struct {
    pos: c.vec3s
};

pub fn get_binding_description() c.VkVertexInputBindingDescription {
    const bindingDescription = c.VkVertexInputBindingDescription {
        .binding = 0,
		.stride = @sizeOf(vertex_t),
		.inputRate = c.VK_VERTEX_INPUT_RATE_VERTEX, // VK_VERTEX_INPUT_RATE_INSTANCE
    };

	return bindingDescription;
}

pub fn get_attributes_description() [1]c.VkVertexInputAttributeDescription {
    const attributes_description = [1]c.VkVertexInputAttributeDescription {
        c.VkVertexInputAttributeDescription {
            .binding = 0,
		    .location = 0,
		    .format = c.VK_FORMAT_R32G32B32_SFLOAT,
		    .offset = @offsetOf(vertex_t, "pos"),
        }
    };

    return attributes_description;
}
