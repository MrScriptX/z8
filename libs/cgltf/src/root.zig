const cgltf = @import("cgltf"); 

// struct
pub const data = cgltf.cgltf_data;
pub const options = cgltf.cgltf_options;
pub const accessor = cgltf.cgltf_accessor;
pub const image = cgltf.cgltf_image;
pub const cgltf_float = cgltf.cgltf_float;

// enum
pub const result_success = cgltf.cgltf_result_success;
pub const attribute_type_position = cgltf.cgltf_attribute_type_position;
pub const attribute_type_normal = cgltf.cgltf_attribute_type_normal;
pub const attribute_type_texcoord = cgltf.cgltf_attribute_type_texcoord;
pub const attribute_type_color = cgltf.cgltf_attribute_type_color;
pub const cgltf_filter_type_nearest = cgltf.cgltf_filter_type_nearest;
pub const cgltf_alpha_mode_blend = cgltf.cgltf_alpha_mode_blend;
pub const cgltf_filter_type_nearest_mipmap_nearest = cgltf.cgltf_filter_type_nearest_mipmap_nearest;
pub const cgltf_filter_type_nearest_mipmap_linear = cgltf.cgltf_filter_type_nearest_mipmap_linear;
pub const cgltf_filter_type_linear = cgltf.cgltf_filter_type_linear;
pub const cgltf_filter_type_linear_mipmap_nearest = cgltf.cgltf_filter_type_linear_mipmap_nearest;
pub const cgltf_filter_type_linear_mipmap_linear = cgltf.cgltf_filter_type_linear_mipmap_linear;

// functions
pub const cgltf_parse_file = cgltf.cgltf_parse_file;
pub const cgltf_load_buffers = cgltf.cgltf_load_buffers;
pub const cgltf_free = cgltf.cgltf_free;
pub const cgltf_accessor_read_index = cgltf.cgltf_accessor_read_index;
pub const cgltf_accessor_read_float = cgltf.cgltf_accessor_read_float;