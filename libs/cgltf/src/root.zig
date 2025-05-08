pub usingnamespace @cImport({
    @cInclude("cgltf.h");
});

// struct
pub const data = c.cgltf_data;
pub const options = c.cgltf_options;
pub const accessor = c.cgltf_accessor;
pub const image = c.cgltf_image;

// enum
pub const result_success = c.cgltf_result_success;
pub const attribute_type_position = c.cgltf_attribute_type_position;
pub const attribute_type_normal = c.cgltf_attribute_type_normal;
pub const attribute_type_texcoord = c.cgltf_attribute_type_texcoord;
pub const attribute_type_color = c.cgltf_attribute_type_color;

const c = @cImport({
    @cInclude("cgltf.h");
});
