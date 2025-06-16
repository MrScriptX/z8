const Instance = c.VkInstance;
pub const PhysicalDevice = c.VkPhysicalDevice;
pub const SurfaceKHR = c.VkSurfaceKHR;
pub const Device = c.VkDevice;
pub const Fence = c.VkFence;
pub const SurfaceCapabilitiesKHR = c.VkSurfaceCapabilitiesKHR;
pub const SurfaceFormatKHR = c.VkSurfaceFormatKHR;
pub const PresentModeKHR = c.VkPresentModeKHR;
pub const ExtensionProperties = c.VkExtensionProperties;
pub const CommandBuffer = c.VkCommandBuffer;
pub const CommandBufferResetFlags = c.VkCommandBufferResetFlags;
const Result = c.VkResult;

pub const ApplicationInfo = c.VkApplicationInfo;
pub const InstaceCreateInfo = c.VkInstanceCreateInfo;
pub const DeviceCreateInfo = c.VkDeviceCreateInfo;
pub const CommandBufferBeginInfo = c.VkCommandBufferBeginInfo;
const AllocationCallbacks = c.VkAllocationCallbacks;

pub const Error = error{
    Incomplete,
    OutOfHostMemory,
    OutOfDeviceMemory,
    InitializationFailed,
    LayerNotPresent,
    ExtensionNotPresent,
    IncompatibleDriver,
    Unknown
};

pub fn createInstance(pCreateInfo: *const InstaceCreateInfo, pAllocator: ?*const AllocationCallbacks, pInstance: *Instance) Error!void {
    const result = c.vkCreateInstance(pCreateInfo, pAllocator, pInstance);
    try vk_check_result(result);
}

pub fn createDevice(physicalDevice: PhysicalDevice, pCreateInfo: *const DeviceCreateInfo, pAllocator: ?*const AllocationCallbacks, pDevice: *Device) Error!void {
    const result = c.vkCreateDevice(physicalDevice, pCreateInfo, pAllocator, pDevice);
    try vk_check_result(result);
}

pub fn enumeratePhysicalDevices(instance: Instance, pPhysicalDeviceCount: *u32, pPhysicalDevices: ?[*]PhysicalDevice) Error!void {
    const result = c.vkEnumeratePhysicalDevices(instance, pPhysicalDeviceCount, pPhysicalDevices);
    try vk_check_result(result);
}

pub fn enumerateDeviceExtensionProperties(physicalDevice: PhysicalDevice, pLayerName: ?[]const u8, pPropertyCount: *u32, pProperties: ?[*]ExtensionProperties) Error!void {
    const result = c.vkEnumerateDeviceExtensionProperties(physicalDevice, @ptrCast(pLayerName), pPropertyCount, pProperties);
    try vk_check_result(result);
}

pub fn getPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice: PhysicalDevice, surface: SurfaceKHR, pSurfaceCapabilities: *SurfaceCapabilitiesKHR) Error!void {
    const result = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, pSurfaceCapabilities);
    try vk_check_result(result);
}

pub fn getPhysicalDeviceSurfaceFormatsKHR(physicalDevice: PhysicalDevice, surface: SurfaceKHR, pSurfaceFormatCount: *u32, pSurfaceFormats: ?[*]SurfaceFormatKHR) Error!void {
    const result = c.vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, pSurfaceFormatCount, pSurfaceFormats);
    try vk_check_result(result);
}

pub fn getPhysicalDeviceSurfacePresentModesKHR(physicalDevice: PhysicalDevice, surface: SurfaceKHR, pPresentModeCount: *u32, pPresentModes: ?[*]PresentModeKHR) Error!void {
    const result = c.vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, pPresentModeCount, pPresentModes);
    try vk_check_result(result);
}

pub fn resetFences(device: Device, fenceCount: u32, pFences: [*]const Fence) Error!void {
    const result = c.vkResetFences(device, fenceCount, pFences);
    try vk_check_result(result);
}

pub fn beginCommandBuffer(commandBuffer: CommandBuffer, pBeginInfo: [*c]const CommandBufferBeginInfo) Error!void {
    const result = c.vkBeginCommandBuffer(commandBuffer, pBeginInfo);
    try vk_check_result(result);
}

pub fn resetCommandBuffer(commandBuffer: CommandBuffer, flags: CommandBufferResetFlags) Error!void {
    const result = c.vkResetCommandBuffer(commandBuffer, flags);
    try vk_check_result(result);
}

pub fn endCommandBuffer(commandBuffer: CommandBuffer) Error!void {
    const result = c.vkEndCommandBuffer(commandBuffer);
    try vk_check_result(result);
}

fn vk_check_result(result: c.VkResult) Error!void {
    switch (result) {
        c.VK_SUCCESS => return,
        c.VK_INCOMPLETE => return Error.Incomplete,
        c.VK_ERROR_OUT_OF_HOST_MEMORY => return Error.OutOfHostMemory,
        c.VK_ERROR_OUT_OF_DEVICE_MEMORY => return Error.OutOfDeviceMemory,
        c.VK_ERROR_INITIALIZATION_FAILED => return Error.InitializationFailed,
        c.VK_ERROR_LAYER_NOT_PRESENT => return Error.LayerNotPresent,
        c.VK_ERROR_EXTENSION_NOT_PRESENT => return Error.ExtensionNotPresent,
        c.VK_ERROR_INCOMPATIBLE_DRIVER => return Error.IncompatibleDriver,
        else => return Error.Unknown
    }
}

const c = @import("../../clibs.zig");
