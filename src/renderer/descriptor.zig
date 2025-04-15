const std = @import("std");
const c = @import("../clibs.zig");
const log = @import("../utils/log.zig");

pub const PoolSizeRatio = struct {
    _type: c.VkDescriptorType = undefined,
    _ratio: f32 = 0,
};

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

pub const DescriptorAllocator2 = struct {
    _arena: std.heap.ArenaAllocator = undefined,

    _ratios: std.ArrayList(PoolSizeRatio) = undefined,
    _full_pools: std.ArrayList(c.VkDescriptorPool) = undefined,
    _ready_pools: std.ArrayList(c.VkDescriptorPool) = undefined,
    _sets_per_pool: u32 = 0,
    
    pub fn init(device: c.VkDevice, max_sets: u32, pool_ratios: []const PoolSizeRatio) DescriptorAllocator2 {
        var builder = DescriptorAllocator2{
            ._arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        };

        builder._ratios = std.ArrayList(PoolSizeRatio).init(builder._arena.allocator());
        builder._full_pools = std.ArrayList(c.VkDescriptorPool).init(builder._arena.allocator());
        builder._ready_pools = std.ArrayList(c.VkDescriptorPool).init(builder._arena.allocator());

        for (pool_ratios) |pool_ratio| {
            builder._ratios.append(pool_ratio) catch {
                log.err("pool sizes allocation failed ! Out of memory", .{});
                @panic("Out of memory");
            };
        }

        const new_pool = create_pool(device, max_sets, pool_ratios);
        builder._ready_pools.append(new_pool) catch {
            log.err("Failed to store Descriptor Pool ! Out of memory", .{});
            @panic("Out of memory");
        };

        builder._sets_per_pool = @intFromFloat(@as(f32, @floatFromInt(max_sets)) * 1.5);

        return builder;
    }

    pub fn deinit(self: *DescriptorAllocator2, device: c.VkDevice) void {
        defer self._arena.deinit();

        // defer self._ready_pools.deinit();
        for (self._ready_pools.items) |pool| {
            c.vkDestroyDescriptorPool(device, pool, null);
        }

        // defer self._full_pools.deinit();
        for (self._full_pools.items) |pool| {
            c.vkDestroyDescriptorPool(device, pool, null);
        }

        // self._ratios.deinit();
    }

    pub fn clear(self: *DescriptorAllocator2, device: c.VkDevice) void {
        for (self._ready_pools.items) |p| {
            const result = c.vkResetDescriptorPool(device, p, 0);
            if (result != c.VK_SUCCESS) {
                log.write("ERROR : Failed to reset descriptor pool ! Reason {d}", .{ result });
            }
        }

        for (self._full_pools.items) |p| {
            const result = c.vkResetDescriptorPool(device, p, 0);
            if (result != c.VK_SUCCESS) {
                log.write("ERROR : Failed to reset descriptor pool ! Reason {d}", .{ result });
            }

            self._ready_pools.append(p) catch {
                log.err("Failed to store Descriptor Pool ! Out of memory", .{});
                @panic("Out of memory");
            };
        }

        self._full_pools.clearAndFree();
    }

    fn get_pool(self: *DescriptorAllocator2, device: c.VkDevice) c.VkDescriptorPool {
        if (self._ready_pools.items.len != 0) {
            return self._ready_pools.pop().?;
        }

        const new_pool = create_pool(device, self._sets_per_pool, self._ratios.items);
        self._sets_per_pool = @intFromFloat(@as(f32, @floatFromInt(self._sets_per_pool)) * 1.5);
        if (self._sets_per_pool > 4092) {
            self._sets_per_pool = 4092;
        }

        return new_pool;
    }

    pub fn allocate(self: *DescriptorAllocator2, device: c.VkDevice, layout: c.VkDescriptorSetLayout, next: ?*anyopaque) c.VkDescriptorSet {
        var pool = self.get_pool(device);

	    var alloc_info = c.VkDescriptorSetAllocateInfo {
            .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
            .pNext = next,
	        .descriptorPool = pool,
	        .descriptorSetCount = 1,
	        .pSetLayouts = &layout,
        };

	    var descriptor_set: c.VkDescriptorSet = undefined;
	    var result = c.vkAllocateDescriptorSets(device, &alloc_info, &descriptor_set);
        if (result == c.VK_ERROR_OUT_OF_POOL_MEMORY or result == c.VK_ERROR_FRAGMENTED_POOL) {
            self._full_pools.append(pool) catch {
                log.err("Failed to add new pool\n", .{});
                @panic("OOM");
            };

            pool = self.get_pool(device);
            alloc_info.descriptorPool = pool;

            result = c.vkAllocateDescriptorSets(device, &alloc_info, &descriptor_set);
        }

        if (result != c.VK_SUCCESS) {
            log.err("Failed to allocate descriptor set. Reason {d}\n", .{ result });
            @panic("Failed to allocate descriptor set");
        }

        self._ready_pools.append(pool) catch {
            log.err("Failed to add new pool\n", .{});
            @panic("OOM");
        };

        return descriptor_set;
    }
};

pub const DescriptorWriter = struct {
    _arena: std.heap.ArenaAllocator,

    _image_infos: std.ArrayList(*c.VkDescriptorImageInfo),
    _buffer_infos: std.ArrayList(*c.VkDescriptorBufferInfo),
    _writes: std.ArrayList(c.VkWriteDescriptorSet),

    pub fn init(allocator: std.mem.Allocator) DescriptorWriter {
        const writer = DescriptorWriter {
            ._arena = std.heap.ArenaAllocator.init(allocator),
            ._image_infos = std.ArrayList(*c.VkDescriptorImageInfo).init(allocator),
            ._buffer_infos = std.ArrayList(*c.VkDescriptorBufferInfo).init(allocator),
            ._writes = std.ArrayList(c.VkWriteDescriptorSet).init(allocator),
        };

        return writer;
    }

    pub fn deinit(self: *DescriptorWriter) void {
        self._arena.deinit();

        self._image_infos.deinit();
        self._buffer_infos.deinit();
        self._writes.deinit();
    }

    pub fn write_buffer(self: *DescriptorWriter, binding: u32, buffer: c.VkBuffer, size: usize, offset: usize, dtype: c.VkDescriptorType) void {
        const allocator = self._arena.allocator();
        const buffer_info = allocator.create(c.VkDescriptorBufferInfo) catch {
            log.err("Failed to allocate memory for VkDescriptorBufferInfo.", .{});
            @panic("OOM");
        };

        buffer_info.*.buffer = buffer;
        buffer_info.*.offset = offset;
        buffer_info.*.range = size;

        self._buffer_infos.append(buffer_info) catch {
            log.err("Failed to insert new buffer info !", .{});
            @panic("OOM");
        };

        const write = c.VkWriteDescriptorSet {
            .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
            .pNext = null,

            .dstBinding = binding,
            .dstSet = null,
            .descriptorCount = 1,
            .descriptorType = dtype,
            .pBufferInfo = self._buffer_infos.getLast(),
        };

        self._writes.append(write) catch {
            log.err("Failed to insert new VkWriteDescriptorSet !", .{});
            @panic("OOM");
        };
    }

    pub fn write_image(self: *DescriptorWriter, binding: u32, image_view: c.VkImageView, sampler: c.VkSampler, layout: c.VkImageLayout, dtype: c.VkDescriptorType) void {
        const allocator = self._arena.allocator();
        const image_info = allocator.create(c.VkDescriptorImageInfo) catch {
            log.err("Failed to allocate memory for VkDescriptorImageInfo.", .{});
            @panic("OOM");
        };

        image_info.*.sampler = sampler;
        image_info.*.imageView = image_view;
        image_info.*.imageLayout = layout;

        self._image_infos.append(image_info) catch {
            log.err("Failed to insert new image info !", .{});
            @panic("OOM");
        };

        const write = c.VkWriteDescriptorSet {
            .sType = c.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
            .pNext = null,

            .dstBinding = binding,
            .dstSet = null,
            .descriptorCount = 1,
            .descriptorType = dtype,
            .pImageInfo = self._image_infos.getLast(),
        };

        self._writes.append(write) catch {
            log.err("Failed to insert new VkWriteDescriptorSet !", .{});
            @panic("OOM");
        };
    }

    pub fn clear(self: *DescriptorWriter) void {
        self._buffer_infos.clearRetainingCapacity();
        self._image_infos.clearRetainingCapacity();
        self._writes.clearRetainingCapacity();
    }

    pub fn update_set(self: *DescriptorWriter, device: c.VkDevice, set: c.VkDescriptorSet) void {
        for (self._writes.items) |*write| {
            write.dstSet = set;
        }

        c.vkUpdateDescriptorSets(device, @intCast(self._writes.items.len), self._writes.items.ptr, 0, null);
    }
};

fn create_pool(device: c.VkDevice, set_count: u32, pool_ratios: []const PoolSizeRatio) c.VkDescriptorPool {
    var pool_sizes = std.ArrayList(c.VkDescriptorPoolSize).init(std.heap.page_allocator);
    defer pool_sizes.deinit();

	for (pool_ratios) |ratio| {
		pool_sizes.append(c.VkDescriptorPoolSize{
			.type = ratio._type,
			.descriptorCount = @intFromFloat(ratio._ratio * @as(f32, @floatFromInt(set_count)))
		}) catch {
            log.err("Failed to allocate memory for pool sizes ! Out of memory !", .{});
            @panic("Out of memory");
        };
	}

    const pool_info = c.VkDescriptorPoolCreateInfo {
        .sType = c.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
	    .flags = 0,
	    .maxSets = set_count,
	    .poolSizeCount = @intCast(pool_sizes.items.len),
	    .pPoolSizes = pool_sizes.items.ptr,
    };

    var new_pool: c.VkDescriptorPool = undefined;
    const result = c.vkCreateDescriptorPool(device, &pool_info, null, &new_pool);
    if (result != c.VK_SUCCESS) {
        log.write("Failed to create descriptor pool. Reason {d}", .{ result });
    }

    return new_pool;
}
