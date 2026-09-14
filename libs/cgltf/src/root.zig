// pub usingnamespace @cImport({
//     @cInclude("cgltf.h");
// });
const cgltf = @import("cgltf"); 

// struct
pub const data = cgltf.cgltf_data;
pub const options = cgltf.cgltf_options;
pub const accessor = cgltf.cgltf_accessor;
pub const image = cgltf.cgltf_image;

// enum
pub const result_success = cgltf.cgltf_result_success;
pub const attribute_type_position = cgltf.cgltf_attribute_type_position;
pub const attribute_type_normal = cgltf.cgltf_attribute_type_normal;
pub const attribute_type_texcoord = cgltf.cgltf_attribute_type_texcoord;
pub const attribute_type_color = cgltf.cgltf_attribute_type_color;

// const c = @cImport({
//     @cInclude("cgltf.h");
// });
