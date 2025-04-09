const std = @import("std");
const c = @import("../clibs.zig");

pub const DescriptorLayout = struct {
    _bindings: std.ArrayList(c.VkDescriptorSetLayoutBinding),

    pub fn init() DescriptorLayout {
        const bindings = std.ArrayList(c.VkDescriptorSetLayoutBinding).init(std.heap.page_allocator);
        return DescriptorLayout{
            ._bindings = bindings,
        };
    }

    pub fn deinit(self: *DescriptorLayout) void {
        self._bindings.deinit();
    }

    pub fn add_binding(self: *DescriptorLayout, binding: u32, _type: c.VkDescriptorType) !void {
        const newbind = c.VkDescriptorSetLayoutBinding {
            .binding = binding,
            .descriptorCount = 1,
            .descriptorType = _type,
        };

        try self._bindings.append(newbind);
    }

    pub fn clear(self: *DescriptorLayout) void {
        self._bindings.clearAndFree();
    }

    pub fn build(self: *DescriptorLayout, device: c.VkDevice, shader_stages: c.VkShaderStageFlags, pNext: ?*const anyopaque, flags: c.VkDescriptorSetLayoutCreateFlags) c.VkDescriptorSetLayout {
        for (self._bindings.items) |*binding| {
            binding.stageFlags |= shader_stages;
        }

        const info = c.VkDescriptorSetLayoutCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
            .pNext = pNext,

            .pBindings = self._bindings.items.ptr,
            .bindingCount = @intCast(self._bindings.items.len),
            .flags = flags,
        };

        var set: c.VkDescriptorSetLayout = undefined;
        _ = c.vkCreateDescriptorSetLayout(device, &info, null, &set);

        return set;
    }
};

pub const PoolSizeRatio = struct {
	_type: c.VkDescriptorType = undefined,
	_ratio: f32 = 0,
};

pub const DescriptorAllocator = struct {
    _pool: c.VkDescriptorPool = undefined,

    pub fn init(device: c.VkDevice, max_sets: u32, pool_ratios: [] const PoolSizeRatio) !DescriptorAllocator {
        var pool_sizes = std.ArrayList(c.VkDescriptorPoolSize).init(std.heap.page_allocator);
        defer pool_sizes.deinit();
        
        for (pool_ratios) |pool_ratio| {
            const pool_size = c.VkDescriptorPoolSize {
                .type = pool_ratio._type,
                .descriptorCount = max_sets * @as(u32, @intFromFloat(pool_ratio._ratio)),
            };
            _ = try pool_sizes.append(pool_size);
        }

        const pool_info = c.VkDescriptorPoolCreateInfo {
            .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
            .pNext = null,
            .flags = 0,
	        .maxSets = max_sets,
	        .poolSizeCount = @intCast(pool_sizes.items.len),
	        .pPoolSizes = pool_sizes.items.ptr,
        };

        var pool: c.VkDescriptorPool = undefined;
	    _ = c.vkCreateDescriptorPool(device, &pool_info, null, &pool);

        return DescriptorAllocator{
            ._pool = pool,
        };
    }

    pub fn deinit(self: *DescriptorAllocator, device: c.VkDevice) void {
        c.vkDestroyDescriptorPool(device, self._pool, null);
    }

    pub fn clear(self: *DescriptorAllocator, device: c.VkDevice, ) void {
        c.vkResetDescriptorPool(device, self._pool, 0);
    }

    pub fn allocate(self: *DescriptorAllocator, device: c.VkDevice, layout: c.VkDescriptorSetLayout) c.VkDescriptorSet {
        const alloc_info = c.VkDescriptorSetAllocateInfo {
            .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
            .pNext = null,
            .descriptorPool = self._pool,
            .descriptorSetCount = 1,
            .pSetLayouts = &layout,
        };

        var descripto_set: c.VkDescriptorSet = undefined;
        _ = c.vkAllocateDescriptorSets(device, &alloc_info, &descripto_set);

        return descripto_set;
    }
};

