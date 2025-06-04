const Instance = c.VkInstance;
pub const PhysicalDevice = c.VkPhysicalDevice;
pub const SurfaceKHR = c.VkSurfaceKHR;
pub const SurfaceCapabilitiesKHR = c.VkSurfaceCapabilitiesKHR;
const Result = c.VkResult;

pub const ApplicationInfo = c.VkApplicationInfo;
pub const InstaceCreateInfo = c.VkInstanceCreateInfo;
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

pub fn enumeratePhysicalDevices(instance: Instance, pPhysicalDeviceCount: *u32, pPhysicalDevices: ?[*]PhysicalDevice) Error!void {
    const result = c.vkEnumeratePhysicalDevices(instance, pPhysicalDeviceCount, pPhysicalDevices);
    try vk_check_result(result);
}

pub fn getPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice: PhysicalDevice, surface: SurfaceKHR, pSurfaceCapabilities: *SurfaceCapabilitiesKHR) Error!void {
    const result = c.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, pSurfaceCapabilities);
    try vk_check_result(result);
}

pub fn getPhysicalDeviceSurfaceFormatsKHR() Error!void {

}

pub fn getPhysicalDeviceSurfacePresentModesKHR() Error!void {

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
