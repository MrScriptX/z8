// Auto-generated Vulkan wrappers
const std = @import("std");
const vk = @import("../../clibs.zig");

pub const Error = error {
    SUCCESS,
    NOT_READY,
    TIMEOUT,
    EVENT_SET,
    EVENT_RESET,
    INCOMPLETE,
    ERROR_OUT_OF_HOST_MEMORY,
    ERROR_OUT_OF_DEVICE_MEMORY,
    ERROR_INITIALIZATION_FAILED,
    ERROR_DEVICE_LOST,
    ERROR_MEMORY_MAP_FAILED,
    ERROR_LAYER_NOT_PRESENT,
    ERROR_EXTENSION_NOT_PRESENT,
    ERROR_FEATURE_NOT_PRESENT,
    ERROR_INCOMPATIBLE_DRIVER,
    ERROR_TOO_MANY_OBJECTS,
    ERROR_FORMAT_NOT_SUPPORTED,
    ERROR_FRAGMENTED_POOL,
    ERROR_UNKNOWN,
    ERROR_OUT_OF_POOL_MEMORY,
    ERROR_INVALID_EXTERNAL_HANDLE,
    ERROR_FRAGMENTATION,
    ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS,
    PIPELINE_COMPILE_REQUIRED,
    ERROR_NOT_PERMITTED,
    ERROR_SURFACE_LOST_KHR,
    ERROR_NATIVE_WINDOW_IN_USE_KHR,
    SUBOPTIMAL_KHR,
    ERROR_OUT_OF_DATE_KHR,
    ERROR_INCOMPATIBLE_DISPLAY_KHR,
    ERROR_VALIDATION_FAILED_EXT,
    ERROR_INVALID_SHADER_NV,
    ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR,
    ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR,
    ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR,
    ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR,
    ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR,
    ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR,
    ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT,
    ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT,
    THREAD_IDLE_KHR,
    THREAD_DONE_KHR,
    OPERATION_DEFERRED_KHR,
    OPERATION_NOT_DEFERRED_KHR,
    ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR,
    ERROR_COMPRESSION_EXHAUSTED_EXT,
    INCOMPATIBLE_SHADER_BINARY_EXT,
    PIPELINE_BINARY_MISSING_KHR,
    ERROR_NOT_ENOUGH_SPACE_KHR,
    RESULT_MAX_ENUM,
    unknown,
};

/// Error handling function
fn check(result: vk.VkResult) Error!void {
    switch (result) {
        vk.VK_SUCCESS => return,
        vk.VK_NOT_READY => return Error.NOT_READY,
        vk.VK_TIMEOUT => return Error.TIMEOUT,
        vk.VK_EVENT_SET => return Error.EVENT_SET,
        vk.VK_EVENT_RESET => return Error.EVENT_RESET,
        vk.VK_INCOMPLETE => return Error.INCOMPLETE,
        vk.VK_ERROR_OUT_OF_HOST_MEMORY => return Error.ERROR_OUT_OF_HOST_MEMORY,
        vk.VK_ERROR_OUT_OF_DEVICE_MEMORY => return Error.ERROR_OUT_OF_DEVICE_MEMORY,
        vk.VK_ERROR_INITIALIZATION_FAILED => return Error.ERROR_INITIALIZATION_FAILED,
        vk.VK_ERROR_DEVICE_LOST => return Error.ERROR_DEVICE_LOST,
        vk.VK_ERROR_MEMORY_MAP_FAILED => return Error.ERROR_MEMORY_MAP_FAILED,
        vk.VK_ERROR_LAYER_NOT_PRESENT => return Error.ERROR_LAYER_NOT_PRESENT,
        vk.VK_ERROR_EXTENSION_NOT_PRESENT => return Error.ERROR_EXTENSION_NOT_PRESENT,
        vk.VK_ERROR_FEATURE_NOT_PRESENT => return Error.ERROR_FEATURE_NOT_PRESENT,
        vk.VK_ERROR_INCOMPATIBLE_DRIVER => return Error.ERROR_INCOMPATIBLE_DRIVER,
        vk.VK_ERROR_TOO_MANY_OBJECTS => return Error.ERROR_TOO_MANY_OBJECTS,
        vk.VK_ERROR_FORMAT_NOT_SUPPORTED => return Error.ERROR_FORMAT_NOT_SUPPORTED,
        vk.VK_ERROR_FRAGMENTED_POOL => return Error.ERROR_FRAGMENTED_POOL,
        vk.VK_ERROR_UNKNOWN => return Error.ERROR_UNKNOWN,
        vk.VK_ERROR_OUT_OF_POOL_MEMORY => return Error.ERROR_OUT_OF_POOL_MEMORY,
        vk.VK_ERROR_INVALID_EXTERNAL_HANDLE => return Error.ERROR_INVALID_EXTERNAL_HANDLE,
        vk.VK_ERROR_FRAGMENTATION => return Error.ERROR_FRAGMENTATION,
        vk.VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS => return Error.ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS,
        vk.VK_PIPELINE_COMPILE_REQUIRED => return Error.PIPELINE_COMPILE_REQUIRED,
        vk.VK_ERROR_NOT_PERMITTED => return Error.ERROR_NOT_PERMITTED,
        vk.VK_ERROR_SURFACE_LOST_KHR => return Error.ERROR_SURFACE_LOST_KHR,
        vk.VK_ERROR_NATIVE_WINDOW_IN_USE_KHR => return Error.ERROR_NATIVE_WINDOW_IN_USE_KHR,
        vk.VK_SUBOPTIMAL_KHR => return Error.SUBOPTIMAL_KHR,
        vk.VK_ERROR_OUT_OF_DATE_KHR => return Error.ERROR_OUT_OF_DATE_KHR,
        vk.VK_ERROR_INCOMPATIBLE_DISPLAY_KHR => return Error.ERROR_INCOMPATIBLE_DISPLAY_KHR,
        vk.VK_ERROR_VALIDATION_FAILED_EXT => return Error.ERROR_VALIDATION_FAILED_EXT,
        vk.VK_ERROR_INVALID_SHADER_NV => return Error.ERROR_INVALID_SHADER_NV,
        vk.VK_ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR => return Error.ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR,
        vk.VK_ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR => return Error.ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR,
        vk.VK_ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR => return Error.ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR,
        vk.VK_ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR => return Error.ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR,
        vk.VK_ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR => return Error.ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR,
        vk.VK_ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR => return Error.ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR,
        vk.VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT => return Error.ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT,
        vk.VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT => return Error.ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT,
        vk.VK_THREAD_IDLE_KHR => return Error.THREAD_IDLE_KHR,
        vk.VK_THREAD_DONE_KHR => return Error.THREAD_DONE_KHR,
        vk.VK_OPERATION_DEFERRED_KHR => return Error.OPERATION_DEFERRED_KHR,
        vk.VK_OPERATION_NOT_DEFERRED_KHR => return Error.OPERATION_NOT_DEFERRED_KHR,
        vk.VK_ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR => return Error.ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR,
        vk.VK_ERROR_COMPRESSION_EXHAUSTED_EXT => return Error.ERROR_COMPRESSION_EXHAUSTED_EXT,
        vk.VK_INCOMPATIBLE_SHADER_BINARY_EXT => return Error.INCOMPATIBLE_SHADER_BINARY_EXT,
        vk.VK_PIPELINE_BINARY_MISSING_KHR => return Error.PIPELINE_BINARY_MISSING_KHR,
        vk.VK_ERROR_NOT_ENOUGH_SPACE_KHR => return Error.ERROR_NOT_ENOUGH_SPACE_KHR,
        vk.VK_RESULT_MAX_ENUM => return Error.RESULT_MAX_ENUM,
        else => return Error.unknown,
    }
}

// Enums
pub const Result = vk.VkResult;
pub const StructureType = vk.VkStructureType;
pub const PipelineCacheHeaderVersion = vk.VkPipelineCacheHeaderVersion;
pub const ImageLayout = vk.VkImageLayout;
pub const ObjectType = vk.VkObjectType;
pub const VendorId = vk.VkVendorId;
pub const SystemAllocationScope = vk.VkSystemAllocationScope;
pub const InternalAllocationType = vk.VkInternalAllocationType;
pub const Format = vk.VkFormat;
pub const ImageTiling = vk.VkImageTiling;
pub const ImageType = vk.VkImageType;
pub const PhysicalDeviceType = vk.VkPhysicalDeviceType;
pub const QueryType = vk.VkQueryType;
pub const SharingMode = vk.VkSharingMode;
pub const ComponentSwizzle = vk.VkComponentSwizzle;
pub const ImageViewType = vk.VkImageViewType;
pub const BlendFactor = vk.VkBlendFactor;
pub const BlendOp = vk.VkBlendOp;
pub const CompareOp = vk.VkCompareOp;
pub const DynamicState = vk.VkDynamicState;
pub const FrontFace = vk.VkFrontFace;
pub const VertexInputRate = vk.VkVertexInputRate;
pub const PrimitiveTopology = vk.VkPrimitiveTopology;
pub const PolygonMode = vk.VkPolygonMode;
pub const StencilOp = vk.VkStencilOp;
pub const LogicOp = vk.VkLogicOp;
pub const BorderColor = vk.VkBorderColor;
pub const Filter = vk.VkFilter;
pub const SamplerAddressMode = vk.VkSamplerAddressMode;
pub const SamplerMipmapMode = vk.VkSamplerMipmapMode;
pub const DescriptorType = vk.VkDescriptorType;
pub const AttachmentLoadOp = vk.VkAttachmentLoadOp;
pub const AttachmentStoreOp = vk.VkAttachmentStoreOp;
pub const PipelineBindPoint = vk.VkPipelineBindPoint;
pub const CommandBufferLevel = vk.VkCommandBufferLevel;
pub const IndexType = vk.VkIndexType;
pub const SubpassContents = vk.VkSubpassContents;
pub const AccessFlagBits = vk.VkAccessFlagBits;
pub const ImageAspectFlagBits = vk.VkImageAspectFlagBits;
pub const FormatFeatureFlagBits = vk.VkFormatFeatureFlagBits;
pub const ImageCreateFlagBits = vk.VkImageCreateFlagBits;
pub const SampleCountFlagBits = vk.VkSampleCountFlagBits;
pub const ImageUsageFlagBits = vk.VkImageUsageFlagBits;
pub const InstanceCreateFlagBits = vk.VkInstanceCreateFlagBits;
pub const MemoryHeapFlagBits = vk.VkMemoryHeapFlagBits;
pub const MemoryPropertyFlagBits = vk.VkMemoryPropertyFlagBits;
pub const QueueFlagBits = vk.VkQueueFlagBits;
pub const DeviceQueueCreateFlagBits = vk.VkDeviceQueueCreateFlagBits;
pub const PipelineStageFlagBits = vk.VkPipelineStageFlagBits;
pub const MemoryMapFlagBits = vk.VkMemoryMapFlagBits;
pub const SparseMemoryBindFlagBits = vk.VkSparseMemoryBindFlagBits;
pub const SparseImageFormatFlagBits = vk.VkSparseImageFormatFlagBits;
pub const FenceCreateFlagBits = vk.VkFenceCreateFlagBits;
pub const EventCreateFlagBits = vk.VkEventCreateFlagBits;
pub const QueryPipelineStatisticFlagBits = vk.VkQueryPipelineStatisticFlagBits;
pub const QueryResultFlagBits = vk.VkQueryResultFlagBits;
pub const BufferCreateFlagBits = vk.VkBufferCreateFlagBits;
pub const BufferUsageFlagBits = vk.VkBufferUsageFlagBits;
pub const ImageViewCreateFlagBits = vk.VkImageViewCreateFlagBits;
pub const PipelineCacheCreateFlagBits = vk.VkPipelineCacheCreateFlagBits;
pub const ColorComponentFlagBits = vk.VkColorComponentFlagBits;
pub const PipelineCreateFlagBits = vk.VkPipelineCreateFlagBits;
pub const PipelineShaderStageCreateFlagBits = vk.VkPipelineShaderStageCreateFlagBits;
pub const ShaderStageFlagBits = vk.VkShaderStageFlagBits;
pub const CullModeFlagBits = vk.VkCullModeFlagBits;
pub const PipelineDepthStencilStateCreateFlagBits = vk.VkPipelineDepthStencilStateCreateFlagBits;
pub const PipelineColorBlendStateCreateFlagBits = vk.VkPipelineColorBlendStateCreateFlagBits;
pub const PipelineLayoutCreateFlagBits = vk.VkPipelineLayoutCreateFlagBits;
pub const SamplerCreateFlagBits = vk.VkSamplerCreateFlagBits;
pub const DescriptorPoolCreateFlagBits = vk.VkDescriptorPoolCreateFlagBits;
pub const DescriptorSetLayoutCreateFlagBits = vk.VkDescriptorSetLayoutCreateFlagBits;
pub const AttachmentDescriptionFlagBits = vk.VkAttachmentDescriptionFlagBits;
pub const DependencyFlagBits = vk.VkDependencyFlagBits;
pub const FramebufferCreateFlagBits = vk.VkFramebufferCreateFlagBits;
pub const RenderPassCreateFlagBits = vk.VkRenderPassCreateFlagBits;
pub const SubpassDescriptionFlagBits = vk.VkSubpassDescriptionFlagBits;
pub const CommandPoolCreateFlagBits = vk.VkCommandPoolCreateFlagBits;
pub const CommandPoolResetFlagBits = vk.VkCommandPoolResetFlagBits;
pub const CommandBufferUsageFlagBits = vk.VkCommandBufferUsageFlagBits;
pub const QueryControlFlagBits = vk.VkQueryControlFlagBits;
pub const CommandBufferResetFlagBits = vk.VkCommandBufferResetFlagBits;
pub const StencilFaceFlagBits = vk.VkStencilFaceFlagBits;
pub const PointClippingBehavior = vk.VkPointClippingBehavior;
pub const TessellationDomainOrigin = vk.VkTessellationDomainOrigin;
pub const SamplerYcbcrModelConversion = vk.VkSamplerYcbcrModelConversion;
pub const SamplerYcbcrRange = vk.VkSamplerYcbcrRange;
pub const ChromaLocation = vk.VkChromaLocation;
pub const DescriptorUpdateTemplateType = vk.VkDescriptorUpdateTemplateType;
pub const SubgroupFeatureFlagBits = vk.VkSubgroupFeatureFlagBits;
pub const PeerMemoryFeatureFlagBits = vk.VkPeerMemoryFeatureFlagBits;
pub const MemoryAllocateFlagBits = vk.VkMemoryAllocateFlagBits;
pub const ExternalMemoryHandleTypeFlagBits = vk.VkExternalMemoryHandleTypeFlagBits;
pub const ExternalMemoryFeatureFlagBits = vk.VkExternalMemoryFeatureFlagBits;
pub const ExternalFenceHandleTypeFlagBits = vk.VkExternalFenceHandleTypeFlagBits;
pub const ExternalFenceFeatureFlagBits = vk.VkExternalFenceFeatureFlagBits;
pub const FenceImportFlagBits = vk.VkFenceImportFlagBits;
pub const SemaphoreImportFlagBits = vk.VkSemaphoreImportFlagBits;
pub const ExternalSemaphoreHandleTypeFlagBits = vk.VkExternalSemaphoreHandleTypeFlagBits;
pub const ExternalSemaphoreFeatureFlagBits = vk.VkExternalSemaphoreFeatureFlagBits;
pub const DriverId = vk.VkDriverId;
pub const ShaderFloatControlsIndependence = vk.VkShaderFloatControlsIndependence;
pub const SamplerReductionMode = vk.VkSamplerReductionMode;
pub const SemaphoreType = vk.VkSemaphoreType;
pub const ResolveModeFlagBits = vk.VkResolveModeFlagBits;
pub const DescriptorBindingFlagBits = vk.VkDescriptorBindingFlagBits;
pub const SemaphoreWaitFlagBits = vk.VkSemaphoreWaitFlagBits;
pub const PipelineCreationFeedbackFlagBits = vk.VkPipelineCreationFeedbackFlagBits;
pub const ToolPurposeFlagBits = vk.VkToolPurposeFlagBits;
pub const SubmitFlagBits = vk.VkSubmitFlagBits;
pub const RenderingFlagBits = vk.VkRenderingFlagBits;
pub const PipelineRobustnessBufferBehavior = vk.VkPipelineRobustnessBufferBehavior;
pub const PipelineRobustnessImageBehavior = vk.VkPipelineRobustnessImageBehavior;
pub const QueueGlobalPriority = vk.VkQueueGlobalPriority;
pub const LineRasterizationMode = vk.VkLineRasterizationMode;
pub const MemoryUnmapFlagBits = vk.VkMemoryUnmapFlagBits;
pub const HostImageCopyFlagBits = vk.VkHostImageCopyFlagBits;
pub const PresentModeKHR = vk.VkPresentModeKHR;
pub const ColorSpaceKHR = vk.VkColorSpaceKHR;
pub const SurfaceTransformFlagBitsKHR = vk.VkSurfaceTransformFlagBitsKHR;
pub const CompositeAlphaFlagBitsKHR = vk.VkCompositeAlphaFlagBitsKHR;
pub const SwapchainCreateFlagBitsKHR = vk.VkSwapchainCreateFlagBitsKHR;
pub const DeviceGroupPresentModeFlagBitsKHR = vk.VkDeviceGroupPresentModeFlagBitsKHR;
pub const DisplayPlaneAlphaFlagBitsKHR = vk.VkDisplayPlaneAlphaFlagBitsKHR;
pub const QueryResultStatusKHR = vk.VkQueryResultStatusKHR;
pub const VideoCodecOperationFlagBitsKHR = vk.VkVideoCodecOperationFlagBitsKHR;
pub const VideoChromaSubsamplingFlagBitsKHR = vk.VkVideoChromaSubsamplingFlagBitsKHR;
pub const VideoComponentBitDepthFlagBitsKHR = vk.VkVideoComponentBitDepthFlagBitsKHR;
pub const VideoCapabilityFlagBitsKHR = vk.VkVideoCapabilityFlagBitsKHR;
pub const VideoSessionCreateFlagBitsKHR = vk.VkVideoSessionCreateFlagBitsKHR;
pub const VideoSessionParametersCreateFlagBitsKHR = vk.VkVideoSessionParametersCreateFlagBitsKHR;
pub const VideoCodingControlFlagBitsKHR = vk.VkVideoCodingControlFlagBitsKHR;
pub const VideoDecodeCapabilityFlagBitsKHR = vk.VkVideoDecodeCapabilityFlagBitsKHR;
pub const VideoDecodeUsageFlagBitsKHR = vk.VkVideoDecodeUsageFlagBitsKHR;
pub const VideoEncodeH264CapabilityFlagBitsKHR = vk.VkVideoEncodeH264CapabilityFlagBitsKHR;
pub const VideoEncodeH264StdFlagBitsKHR = vk.VkVideoEncodeH264StdFlagBitsKHR;
pub const VideoEncodeH264RateControlFlagBitsKHR = vk.VkVideoEncodeH264RateControlFlagBitsKHR;
pub const VideoEncodeH265CapabilityFlagBitsKHR = vk.VkVideoEncodeH265CapabilityFlagBitsKHR;
pub const VideoEncodeH265StdFlagBitsKHR = vk.VkVideoEncodeH265StdFlagBitsKHR;
pub const VideoEncodeH265CtbSizeFlagBitsKHR = vk.VkVideoEncodeH265CtbSizeFlagBitsKHR;
pub const VideoEncodeH265TransformBlockSizeFlagBitsKHR = vk.VkVideoEncodeH265TransformBlockSizeFlagBitsKHR;
pub const VideoEncodeH265RateControlFlagBitsKHR = vk.VkVideoEncodeH265RateControlFlagBitsKHR;
pub const VideoDecodeH264PictureLayoutFlagBitsKHR = vk.VkVideoDecodeH264PictureLayoutFlagBitsKHR;
pub const PerformanceCounterUnitKHR = vk.VkPerformanceCounterUnitKHR;
pub const PerformanceCounterScopeKHR = vk.VkPerformanceCounterScopeKHR;
pub const PerformanceCounterStorageKHR = vk.VkPerformanceCounterStorageKHR;
pub const PerformanceCounterDescriptionFlagBitsKHR = vk.VkPerformanceCounterDescriptionFlagBitsKHR;
pub const AcquireProfilingLockFlagBitsKHR = vk.VkAcquireProfilingLockFlagBitsKHR;
pub const FragmentShadingRateCombinerOpKHR = vk.VkFragmentShadingRateCombinerOpKHR;
pub const PipelineExecutableStatisticFormatKHR = vk.VkPipelineExecutableStatisticFormatKHR;
pub const VideoEncodeTuningModeKHR = vk.VkVideoEncodeTuningModeKHR;
pub const VideoEncodeFlagBitsKHR = vk.VkVideoEncodeFlagBitsKHR;
pub const VideoEncodeCapabilityFlagBitsKHR = vk.VkVideoEncodeCapabilityFlagBitsKHR;
pub const VideoEncodeRateControlModeFlagBitsKHR = vk.VkVideoEncodeRateControlModeFlagBitsKHR;
pub const VideoEncodeFeedbackFlagBitsKHR = vk.VkVideoEncodeFeedbackFlagBitsKHR;
pub const VideoEncodeUsageFlagBitsKHR = vk.VkVideoEncodeUsageFlagBitsKHR;
pub const VideoEncodeContentFlagBitsKHR = vk.VkVideoEncodeContentFlagBitsKHR;
pub const ComponentTypeKHR = vk.VkComponentTypeKHR;
pub const ScopeKHR = vk.VkScopeKHR;
pub const VideoEncodeAV1PredictionModeKHR = vk.VkVideoEncodeAV1PredictionModeKHR;
pub const VideoEncodeAV1RateControlGroupKHR = vk.VkVideoEncodeAV1RateControlGroupKHR;
pub const VideoEncodeAV1CapabilityFlagBitsKHR = vk.VkVideoEncodeAV1CapabilityFlagBitsKHR;
pub const VideoEncodeAV1StdFlagBitsKHR = vk.VkVideoEncodeAV1StdFlagBitsKHR;
pub const VideoEncodeAV1SuperblockSizeFlagBitsKHR = vk.VkVideoEncodeAV1SuperblockSizeFlagBitsKHR;
pub const VideoEncodeAV1RateControlFlagBitsKHR = vk.VkVideoEncodeAV1RateControlFlagBitsKHR;
pub const TimeDomainKHR = vk.VkTimeDomainKHR;
pub const PhysicalDeviceLayeredApiKHR = vk.VkPhysicalDeviceLayeredApiKHR;
pub const DebugReportObjectTypeEXT = vk.VkDebugReportObjectTypeEXT;
pub const DebugReportFlagBitsEXT = vk.VkDebugReportFlagBitsEXT;
pub const RasterizationOrderAMD = vk.VkRasterizationOrderAMD;
pub const ShaderInfoTypeAMD = vk.VkShaderInfoTypeAMD;
pub const ExternalMemoryHandleTypeFlagBitsNV = vk.VkExternalMemoryHandleTypeFlagBitsNV;
pub const ExternalMemoryFeatureFlagBitsNV = vk.VkExternalMemoryFeatureFlagBitsNV;
pub const ValidationCheckEXT = vk.VkValidationCheckEXT;
pub const ConditionalRenderingFlagBitsEXT = vk.VkConditionalRenderingFlagBitsEXT;
pub const SurfaceCounterFlagBitsEXT = vk.VkSurfaceCounterFlagBitsEXT;
pub const DisplayPowerStateEXT = vk.VkDisplayPowerStateEXT;
pub const DeviceEventTypeEXT = vk.VkDeviceEventTypeEXT;
pub const DisplayEventTypeEXT = vk.VkDisplayEventTypeEXT;
pub const ViewportCoordinateSwizzleNV = vk.VkViewportCoordinateSwizzleNV;
pub const DiscardRectangleModeEXT = vk.VkDiscardRectangleModeEXT;
pub const ConservativeRasterizationModeEXT = vk.VkConservativeRasterizationModeEXT;
pub const DebugUtilsMessageSeverityFlagBitsEXT = vk.VkDebugUtilsMessageSeverityFlagBitsEXT;
pub const DebugUtilsMessageTypeFlagBitsEXT = vk.VkDebugUtilsMessageTypeFlagBitsEXT;
pub const BlendOverlapEXT = vk.VkBlendOverlapEXT;
pub const CoverageModulationModeNV = vk.VkCoverageModulationModeNV;
pub const ValidationCacheHeaderVersionEXT = vk.VkValidationCacheHeaderVersionEXT;
pub const ShadingRatePaletteEntryNV = vk.VkShadingRatePaletteEntryNV;
pub const CoarseSampleOrderTypeNV = vk.VkCoarseSampleOrderTypeNV;
pub const RayTracingShaderGroupTypeKHR = vk.VkRayTracingShaderGroupTypeKHR;
pub const GeometryTypeKHR = vk.VkGeometryTypeKHR;
pub const AccelerationStructureTypeKHR = vk.VkAccelerationStructureTypeKHR;
pub const CopyAccelerationStructureModeKHR = vk.VkCopyAccelerationStructureModeKHR;
pub const AccelerationStructureMemoryRequirementsTypeNV = vk.VkAccelerationStructureMemoryRequirementsTypeNV;
pub const GeometryFlagBitsKHR = vk.VkGeometryFlagBitsKHR;
pub const GeometryInstanceFlagBitsKHR = vk.VkGeometryInstanceFlagBitsKHR;
pub const BuildAccelerationStructureFlagBitsKHR = vk.VkBuildAccelerationStructureFlagBitsKHR;
pub const PipelineCompilerControlFlagBitsAMD = vk.VkPipelineCompilerControlFlagBitsAMD;
pub const MemoryOverallocationBehaviorAMD = vk.VkMemoryOverallocationBehaviorAMD;
pub const PerformanceConfigurationTypeINTEL = vk.VkPerformanceConfigurationTypeINTEL;
pub const QueryPoolSamplingModeINTEL = vk.VkQueryPoolSamplingModeINTEL;
pub const PerformanceOverrideTypeINTEL = vk.VkPerformanceOverrideTypeINTEL;
pub const PerformanceParameterTypeINTEL = vk.VkPerformanceParameterTypeINTEL;
pub const PerformanceValueTypeINTEL = vk.VkPerformanceValueTypeINTEL;
pub const ShaderCorePropertiesFlagBitsAMD = vk.VkShaderCorePropertiesFlagBitsAMD;
pub const ValidationFeatureEnableEXT = vk.VkValidationFeatureEnableEXT;
pub const ValidationFeatureDisableEXT = vk.VkValidationFeatureDisableEXT;
pub const CoverageReductionModeNV = vk.VkCoverageReductionModeNV;
pub const ProvokingVertexModeEXT = vk.VkProvokingVertexModeEXT;
pub const PresentScalingFlagBitsEXT = vk.VkPresentScalingFlagBitsEXT;
pub const PresentGravityFlagBitsEXT = vk.VkPresentGravityFlagBitsEXT;
pub const IndirectCommandsTokenTypeNV = vk.VkIndirectCommandsTokenTypeNV;
pub const IndirectStateFlagBitsNV = vk.VkIndirectStateFlagBitsNV;
pub const IndirectCommandsLayoutUsageFlagBitsNV = vk.VkIndirectCommandsLayoutUsageFlagBitsNV;
pub const DepthBiasRepresentationEXT = vk.VkDepthBiasRepresentationEXT;
pub const DeviceMemoryReportEventTypeEXT = vk.VkDeviceMemoryReportEventTypeEXT;
pub const DeviceDiagnosticsConfigFlagBitsNV = vk.VkDeviceDiagnosticsConfigFlagBitsNV;
pub const GraphicsPipelineLibraryFlagBitsEXT = vk.VkGraphicsPipelineLibraryFlagBitsEXT;
pub const FragmentShadingRateTypeNV = vk.VkFragmentShadingRateTypeNV;
pub const FragmentShadingRateNV = vk.VkFragmentShadingRateNV;
pub const AccelerationStructureMotionInstanceTypeNV = vk.VkAccelerationStructureMotionInstanceTypeNV;
pub const ImageCompressionFlagBitsEXT = vk.VkImageCompressionFlagBitsEXT;
pub const ImageCompressionFixedRateFlagBitsEXT = vk.VkImageCompressionFixedRateFlagBitsEXT;
pub const DeviceFaultAddressTypeEXT = vk.VkDeviceFaultAddressTypeEXT;
pub const DeviceFaultVendorBinaryHeaderVersionEXT = vk.VkDeviceFaultVendorBinaryHeaderVersionEXT;
pub const DeviceAddressBindingTypeEXT = vk.VkDeviceAddressBindingTypeEXT;
pub const DeviceAddressBindingFlagBitsEXT = vk.VkDeviceAddressBindingFlagBitsEXT;
pub const FrameBoundaryFlagBitsEXT = vk.VkFrameBoundaryFlagBitsEXT;
pub const MicromapTypeEXT = vk.VkMicromapTypeEXT;
pub const BuildMicromapModeEXT = vk.VkBuildMicromapModeEXT;
pub const CopyMicromapModeEXT = vk.VkCopyMicromapModeEXT;
pub const OpacityMicromapFormatEXT = vk.VkOpacityMicromapFormatEXT;
pub const OpacityMicromapSpecialIndexEXT = vk.VkOpacityMicromapSpecialIndexEXT;
pub const AccelerationStructureCompatibilityKHR = vk.VkAccelerationStructureCompatibilityKHR;
pub const AccelerationStructureBuildTypeKHR = vk.VkAccelerationStructureBuildTypeKHR;
pub const BuildMicromapFlagBitsEXT = vk.VkBuildMicromapFlagBitsEXT;
pub const MicromapCreateFlagBitsEXT = vk.VkMicromapCreateFlagBitsEXT;
pub const RayTracingLssIndexingModeNV = vk.VkRayTracingLssIndexingModeNV;
pub const RayTracingLssPrimitiveEndCapsModeNV = vk.VkRayTracingLssPrimitiveEndCapsModeNV;
pub const SubpassMergeStatusEXT = vk.VkSubpassMergeStatusEXT;
pub const DirectDriverLoadingModeLUNARG = vk.VkDirectDriverLoadingModeLUNARG;
pub const OpticalFlowPerformanceLevelNV = vk.VkOpticalFlowPerformanceLevelNV;
pub const OpticalFlowSessionBindingPointNV = vk.VkOpticalFlowSessionBindingPointNV;
pub const OpticalFlowGridSizeFlagBitsNV = vk.VkOpticalFlowGridSizeFlagBitsNV;
pub const OpticalFlowUsageFlagBitsNV = vk.VkOpticalFlowUsageFlagBitsNV;
pub const OpticalFlowSessionCreateFlagBitsNV = vk.VkOpticalFlowSessionCreateFlagBitsNV;
pub const OpticalFlowExecuteFlagBitsNV = vk.VkOpticalFlowExecuteFlagBitsNV;
pub const AntiLagModeAMD = vk.VkAntiLagModeAMD;
pub const AntiLagStageAMD = vk.VkAntiLagStageAMD;
pub const ShaderCodeTypeEXT = vk.VkShaderCodeTypeEXT;
pub const DepthClampModeEXT = vk.VkDepthClampModeEXT;
pub const ShaderCreateFlagBitsEXT = vk.VkShaderCreateFlagBitsEXT;
pub const RayTracingInvocationReorderModeNV = vk.VkRayTracingInvocationReorderModeNV;
pub const CooperativeVectorMatrixLayoutNV = vk.VkCooperativeVectorMatrixLayoutNV;
pub const LayerSettingTypeEXT = vk.VkLayerSettingTypeEXT;
pub const LatencyMarkerNV = vk.VkLatencyMarkerNV;
pub const OutOfBandQueueTypeNV = vk.VkOutOfBandQueueTypeNV;
pub const BlockMatchWindowCompareModeQCOM = vk.VkBlockMatchWindowCompareModeQCOM;
pub const CubicFilterWeightsQCOM = vk.VkCubicFilterWeightsQCOM;
pub const LayeredDriverUnderlyingApiMSFT = vk.VkLayeredDriverUnderlyingApiMSFT;
pub const DisplaySurfaceStereoTypeNV = vk.VkDisplaySurfaceStereoTypeNV;
pub const ClusterAccelerationStructureTypeNV = vk.VkClusterAccelerationStructureTypeNV;
pub const ClusterAccelerationStructureOpTypeNV = vk.VkClusterAccelerationStructureOpTypeNV;
pub const ClusterAccelerationStructureOpModeNV = vk.VkClusterAccelerationStructureOpModeNV;
pub const ClusterAccelerationStructureAddressResolutionFlagBitsNV = vk.VkClusterAccelerationStructureAddressResolutionFlagBitsNV;
pub const ClusterAccelerationStructureClusterFlagBitsNV = vk.VkClusterAccelerationStructureClusterFlagBitsNV;
pub const ClusterAccelerationStructureGeometryFlagBitsNV = vk.VkClusterAccelerationStructureGeometryFlagBitsNV;
pub const ClusterAccelerationStructureIndexFormatFlagBitsNV = vk.VkClusterAccelerationStructureIndexFormatFlagBitsNV;
pub const PartitionedAccelerationStructureOpTypeNV = vk.VkPartitionedAccelerationStructureOpTypeNV;
pub const PartitionedAccelerationStructureInstanceFlagBitsNV = vk.VkPartitionedAccelerationStructureInstanceFlagBitsNV;
pub const IndirectExecutionSetInfoTypeEXT = vk.VkIndirectExecutionSetInfoTypeEXT;
pub const IndirectCommandsTokenTypeEXT = vk.VkIndirectCommandsTokenTypeEXT;
pub const IndirectCommandsInputModeFlagBitsEXT = vk.VkIndirectCommandsInputModeFlagBitsEXT;
pub const IndirectCommandsLayoutUsageFlagBitsEXT = vk.VkIndirectCommandsLayoutUsageFlagBitsEXT;
pub const BuildAccelerationStructureModeKHR = vk.VkBuildAccelerationStructureModeKHR;
pub const AccelerationStructureCreateFlagBitsKHR = vk.VkAccelerationStructureCreateFlagBitsKHR;
pub const ShaderGroupShaderKHR = vk.VkShaderGroupShaderKHR;

// Structs
pub const Buffer = vk.VkBuffer;
pub const Image = vk.VkImage;
pub const Instance = vk.VkInstance;
pub const PhysicalDevice = vk.VkPhysicalDevice;
pub const Device = vk.VkDevice;
pub const Queue = vk.VkQueue;
pub const Semaphore = vk.VkSemaphore;
pub const CommandBuffer = vk.VkCommandBuffer;
pub const Fence = vk.VkFence;
pub const DeviceMemory = vk.VkDeviceMemory;
pub const Event = vk.VkEvent;
pub const QueryPool = vk.VkQueryPool;
pub const BufferView = vk.VkBufferView;
pub const ImageView = vk.VkImageView;
pub const ShaderModule = vk.VkShaderModule;
pub const PipelineCache = vk.VkPipelineCache;
pub const PipelineLayout = vk.VkPipelineLayout;
pub const Pipeline = vk.VkPipeline;
pub const RenderPass = vk.VkRenderPass;
pub const DescriptorSetLayout = vk.VkDescriptorSetLayout;
pub const Sampler = vk.VkSampler;
pub const DescriptorSet = vk.VkDescriptorSet;
pub const DescriptorPool = vk.VkDescriptorPool;
pub const Framebuffer = vk.VkFramebuffer;
pub const CommandPool = vk.VkCommandPool;
pub const Extent2D = vk.VkExtent2D;
pub const Extent3D = vk.VkExtent3D;
pub const Offset2D = vk.VkOffset2D;
pub const Offset3D = vk.VkOffset3D;
pub const Rect2D = vk.VkRect2D;
pub const BaseInStructure = vk.VkBaseInStructure;
pub const BaseOutStructure = vk.VkBaseOutStructure;
pub const BufferMemoryBarrier = vk.VkBufferMemoryBarrier;
pub const DispatchIndirectCommand = vk.VkDispatchIndirectCommand;
pub const DrawIndexedIndirectCommand = vk.VkDrawIndexedIndirectCommand;
pub const DrawIndirectCommand = vk.VkDrawIndirectCommand;
pub const ImageSubresourceRange = vk.VkImageSubresourceRange;
pub const ImageMemoryBarrier = vk.VkImageMemoryBarrier;
pub const MemoryBarrier = vk.VkMemoryBarrier;
pub const PipelineCacheHeaderVersionOne = vk.VkPipelineCacheHeaderVersionOne;
pub const AllocationCallbacks = vk.VkAllocationCallbacks;
pub const ApplicationInfo = vk.VkApplicationInfo;
pub const FormatProperties = vk.VkFormatProperties;
pub const ImageFormatProperties = vk.VkImageFormatProperties;
pub const InstanceCreateInfo = vk.VkInstanceCreateInfo;
pub const MemoryHeap = vk.VkMemoryHeap;
pub const MemoryType = vk.VkMemoryType;
pub const PhysicalDeviceFeatures = vk.VkPhysicalDeviceFeatures;
pub const PhysicalDeviceLimits = vk.VkPhysicalDeviceLimits;
pub const PhysicalDeviceMemoryProperties = vk.VkPhysicalDeviceMemoryProperties;
pub const PhysicalDeviceSparseProperties = vk.VkPhysicalDeviceSparseProperties;
pub const PhysicalDeviceProperties = vk.VkPhysicalDeviceProperties;
pub const QueueFamilyProperties = vk.VkQueueFamilyProperties;
pub const DeviceQueueCreateInfo = vk.VkDeviceQueueCreateInfo;
pub const DeviceCreateInfo = vk.VkDeviceCreateInfo;
pub const ExtensionProperties = vk.VkExtensionProperties;
pub const LayerProperties = vk.VkLayerProperties;
pub const SubmitInfo = vk.VkSubmitInfo;
pub const MappedMemoryRange = vk.VkMappedMemoryRange;
pub const MemoryAllocateInfo = vk.VkMemoryAllocateInfo;
pub const MemoryRequirements = vk.VkMemoryRequirements;
pub const SparseMemoryBind = vk.VkSparseMemoryBind;
pub const SparseBufferMemoryBindInfo = vk.VkSparseBufferMemoryBindInfo;
pub const SparseImageOpaqueMemoryBindInfo = vk.VkSparseImageOpaqueMemoryBindInfo;
pub const ImageSubresource = vk.VkImageSubresource;
pub const SparseImageMemoryBind = vk.VkSparseImageMemoryBind;
pub const SparseImageMemoryBindInfo = vk.VkSparseImageMemoryBindInfo;
pub const BindSparseInfo = vk.VkBindSparseInfo;
pub const SparseImageFormatProperties = vk.VkSparseImageFormatProperties;
pub const SparseImageMemoryRequirements = vk.VkSparseImageMemoryRequirements;
pub const FenceCreateInfo = vk.VkFenceCreateInfo;
pub const SemaphoreCreateInfo = vk.VkSemaphoreCreateInfo;
pub const EventCreateInfo = vk.VkEventCreateInfo;
pub const QueryPoolCreateInfo = vk.VkQueryPoolCreateInfo;
pub const BufferCreateInfo = vk.VkBufferCreateInfo;
pub const BufferViewCreateInfo = vk.VkBufferViewCreateInfo;
pub const ImageCreateInfo = vk.VkImageCreateInfo;
pub const SubresourceLayout = vk.VkSubresourceLayout;
pub const ComponentMapping = vk.VkComponentMapping;
pub const ImageViewCreateInfo = vk.VkImageViewCreateInfo;
pub const ShaderModuleCreateInfo = vk.VkShaderModuleCreateInfo;
pub const PipelineCacheCreateInfo = vk.VkPipelineCacheCreateInfo;
pub const SpecializationMapEntry = vk.VkSpecializationMapEntry;
pub const SpecializationInfo = vk.VkSpecializationInfo;
pub const PipelineShaderStageCreateInfo = vk.VkPipelineShaderStageCreateInfo;
pub const ComputePipelineCreateInfo = vk.VkComputePipelineCreateInfo;
pub const VertexInputBindingDescription = vk.VkVertexInputBindingDescription;
pub const VertexInputAttributeDescription = vk.VkVertexInputAttributeDescription;
pub const PipelineVertexInputStateCreateInfo = vk.VkPipelineVertexInputStateCreateInfo;
pub const PipelineInputAssemblyStateCreateInfo = vk.VkPipelineInputAssemblyStateCreateInfo;
pub const PipelineTessellationStateCreateInfo = vk.VkPipelineTessellationStateCreateInfo;
pub const Viewport = vk.VkViewport;
pub const PipelineViewportStateCreateInfo = vk.VkPipelineViewportStateCreateInfo;
pub const PipelineRasterizationStateCreateInfo = vk.VkPipelineRasterizationStateCreateInfo;
pub const PipelineMultisampleStateCreateInfo = vk.VkPipelineMultisampleStateCreateInfo;
pub const StencilOpState = vk.VkStencilOpState;
pub const PipelineDepthStencilStateCreateInfo = vk.VkPipelineDepthStencilStateCreateInfo;
pub const PipelineColorBlendAttachmentState = vk.VkPipelineColorBlendAttachmentState;
pub const PipelineColorBlendStateCreateInfo = vk.VkPipelineColorBlendStateCreateInfo;
pub const PipelineDynamicStateCreateInfo = vk.VkPipelineDynamicStateCreateInfo;
pub const GraphicsPipelineCreateInfo = vk.VkGraphicsPipelineCreateInfo;
pub const PushConstantRange = vk.VkPushConstantRange;
pub const PipelineLayoutCreateInfo = vk.VkPipelineLayoutCreateInfo;
pub const SamplerCreateInfo = vk.VkSamplerCreateInfo;
pub const CopyDescriptorSet = vk.VkCopyDescriptorSet;
pub const DescriptorBufferInfo = vk.VkDescriptorBufferInfo;
pub const DescriptorImageInfo = vk.VkDescriptorImageInfo;
pub const DescriptorPoolSize = vk.VkDescriptorPoolSize;
pub const DescriptorPoolCreateInfo = vk.VkDescriptorPoolCreateInfo;
pub const DescriptorSetAllocateInfo = vk.VkDescriptorSetAllocateInfo;
pub const DescriptorSetLayoutBinding = vk.VkDescriptorSetLayoutBinding;
pub const DescriptorSetLayoutCreateInfo = vk.VkDescriptorSetLayoutCreateInfo;
pub const WriteDescriptorSet = vk.VkWriteDescriptorSet;
pub const AttachmentDescription = vk.VkAttachmentDescription;
pub const AttachmentReference = vk.VkAttachmentReference;
pub const FramebufferCreateInfo = vk.VkFramebufferCreateInfo;
pub const SubpassDescription = vk.VkSubpassDescription;
pub const SubpassDependency = vk.VkSubpassDependency;
pub const RenderPassCreateInfo = vk.VkRenderPassCreateInfo;
pub const CommandPoolCreateInfo = vk.VkCommandPoolCreateInfo;
pub const CommandBufferAllocateInfo = vk.VkCommandBufferAllocateInfo;
pub const CommandBufferInheritanceInfo = vk.VkCommandBufferInheritanceInfo;
pub const CommandBufferBeginInfo = vk.VkCommandBufferBeginInfo;
pub const BufferCopy = vk.VkBufferCopy;
pub const ImageSubresourceLayers = vk.VkImageSubresourceLayers;
pub const BufferImageCopy = vk.VkBufferImageCopy;
pub const ClearDepthStencilValue = vk.VkClearDepthStencilValue;
pub const ClearAttachment = vk.VkClearAttachment;
pub const ClearRect = vk.VkClearRect;
pub const ImageBlit = vk.VkImageBlit;
pub const ImageCopy = vk.VkImageCopy;
pub const ImageResolve = vk.VkImageResolve;
pub const RenderPassBeginInfo = vk.VkRenderPassBeginInfo;
pub const SamplerYcbcrConversion = vk.VkSamplerYcbcrConversion;
pub const DescriptorUpdateTemplate = vk.VkDescriptorUpdateTemplate;
pub const PhysicalDeviceSubgroupProperties = vk.VkPhysicalDeviceSubgroupProperties;
pub const BindBufferMemoryInfo = vk.VkBindBufferMemoryInfo;
pub const BindImageMemoryInfo = vk.VkBindImageMemoryInfo;
pub const PhysicalDevice16BitStorageFeatures = vk.VkPhysicalDevice16BitStorageFeatures;
pub const MemoryDedicatedRequirements = vk.VkMemoryDedicatedRequirements;
pub const MemoryDedicatedAllocateInfo = vk.VkMemoryDedicatedAllocateInfo;
pub const MemoryAllocateFlagsInfo = vk.VkMemoryAllocateFlagsInfo;
pub const DeviceGroupRenderPassBeginInfo = vk.VkDeviceGroupRenderPassBeginInfo;
pub const DeviceGroupCommandBufferBeginInfo = vk.VkDeviceGroupCommandBufferBeginInfo;
pub const DeviceGroupSubmitInfo = vk.VkDeviceGroupSubmitInfo;
pub const DeviceGroupBindSparseInfo = vk.VkDeviceGroupBindSparseInfo;
pub const BindBufferMemoryDeviceGroupInfo = vk.VkBindBufferMemoryDeviceGroupInfo;
pub const BindImageMemoryDeviceGroupInfo = vk.VkBindImageMemoryDeviceGroupInfo;
pub const PhysicalDeviceGroupProperties = vk.VkPhysicalDeviceGroupProperties;
pub const DeviceGroupDeviceCreateInfo = vk.VkDeviceGroupDeviceCreateInfo;
pub const BufferMemoryRequirementsInfo2 = vk.VkBufferMemoryRequirementsInfo2;
pub const ImageMemoryRequirementsInfo2 = vk.VkImageMemoryRequirementsInfo2;
pub const ImageSparseMemoryRequirementsInfo2 = vk.VkImageSparseMemoryRequirementsInfo2;
pub const MemoryRequirements2 = vk.VkMemoryRequirements2;
pub const SparseImageMemoryRequirements2 = vk.VkSparseImageMemoryRequirements2;
pub const PhysicalDeviceFeatures2 = vk.VkPhysicalDeviceFeatures2;
pub const PhysicalDeviceProperties2 = vk.VkPhysicalDeviceProperties2;
pub const FormatProperties2 = vk.VkFormatProperties2;
pub const ImageFormatProperties2 = vk.VkImageFormatProperties2;
pub const PhysicalDeviceImageFormatInfo2 = vk.VkPhysicalDeviceImageFormatInfo2;
pub const QueueFamilyProperties2 = vk.VkQueueFamilyProperties2;
pub const PhysicalDeviceMemoryProperties2 = vk.VkPhysicalDeviceMemoryProperties2;
pub const SparseImageFormatProperties2 = vk.VkSparseImageFormatProperties2;
pub const PhysicalDeviceSparseImageFormatInfo2 = vk.VkPhysicalDeviceSparseImageFormatInfo2;
pub const PhysicalDevicePointClippingProperties = vk.VkPhysicalDevicePointClippingProperties;
pub const InputAttachmentAspectReference = vk.VkInputAttachmentAspectReference;
pub const RenderPassInputAttachmentAspectCreateInfo = vk.VkRenderPassInputAttachmentAspectCreateInfo;
pub const ImageViewUsageCreateInfo = vk.VkImageViewUsageCreateInfo;
pub const PipelineTessellationDomainOriginStateCreateInfo = vk.VkPipelineTessellationDomainOriginStateCreateInfo;
pub const RenderPassMultiviewCreateInfo = vk.VkRenderPassMultiviewCreateInfo;
pub const PhysicalDeviceMultiviewFeatures = vk.VkPhysicalDeviceMultiviewFeatures;
pub const PhysicalDeviceMultiviewProperties = vk.VkPhysicalDeviceMultiviewProperties;
pub const PhysicalDeviceVariablePointersFeatures = vk.VkPhysicalDeviceVariablePointersFeatures;
pub const PhysicalDeviceProtectedMemoryFeatures = vk.VkPhysicalDeviceProtectedMemoryFeatures;
pub const PhysicalDeviceProtectedMemoryProperties = vk.VkPhysicalDeviceProtectedMemoryProperties;
pub const DeviceQueueInfo2 = vk.VkDeviceQueueInfo2;
pub const ProtectedSubmitInfo = vk.VkProtectedSubmitInfo;
pub const SamplerYcbcrConversionCreateInfo = vk.VkSamplerYcbcrConversionCreateInfo;
pub const SamplerYcbcrConversionInfo = vk.VkSamplerYcbcrConversionInfo;
pub const BindImagePlaneMemoryInfo = vk.VkBindImagePlaneMemoryInfo;
pub const ImagePlaneMemoryRequirementsInfo = vk.VkImagePlaneMemoryRequirementsInfo;
pub const PhysicalDeviceSamplerYcbcrConversionFeatures = vk.VkPhysicalDeviceSamplerYcbcrConversionFeatures;
pub const SamplerYcbcrConversionImageFormatProperties = vk.VkSamplerYcbcrConversionImageFormatProperties;
pub const DescriptorUpdateTemplateEntry = vk.VkDescriptorUpdateTemplateEntry;
pub const DescriptorUpdateTemplateCreateInfo = vk.VkDescriptorUpdateTemplateCreateInfo;
pub const ExternalMemoryProperties = vk.VkExternalMemoryProperties;
pub const PhysicalDeviceExternalImageFormatInfo = vk.VkPhysicalDeviceExternalImageFormatInfo;
pub const ExternalImageFormatProperties = vk.VkExternalImageFormatProperties;
pub const PhysicalDeviceExternalBufferInfo = vk.VkPhysicalDeviceExternalBufferInfo;
pub const ExternalBufferProperties = vk.VkExternalBufferProperties;
pub const PhysicalDeviceIDProperties = vk.VkPhysicalDeviceIDProperties;
pub const ExternalMemoryImageCreateInfo = vk.VkExternalMemoryImageCreateInfo;
pub const ExternalMemoryBufferCreateInfo = vk.VkExternalMemoryBufferCreateInfo;
pub const ExportMemoryAllocateInfo = vk.VkExportMemoryAllocateInfo;
pub const PhysicalDeviceExternalFenceInfo = vk.VkPhysicalDeviceExternalFenceInfo;
pub const ExternalFenceProperties = vk.VkExternalFenceProperties;
pub const ExportFenceCreateInfo = vk.VkExportFenceCreateInfo;
pub const ExportSemaphoreCreateInfo = vk.VkExportSemaphoreCreateInfo;
pub const PhysicalDeviceExternalSemaphoreInfo = vk.VkPhysicalDeviceExternalSemaphoreInfo;
pub const ExternalSemaphoreProperties = vk.VkExternalSemaphoreProperties;
pub const PhysicalDeviceMaintenance3Properties = vk.VkPhysicalDeviceMaintenance3Properties;
pub const DescriptorSetLayoutSupport = vk.VkDescriptorSetLayoutSupport;
pub const PhysicalDeviceShaderDrawParametersFeatures = vk.VkPhysicalDeviceShaderDrawParametersFeatures;
pub const PhysicalDeviceVulkan11Features = vk.VkPhysicalDeviceVulkan11Features;
pub const PhysicalDeviceVulkan11Properties = vk.VkPhysicalDeviceVulkan11Properties;
pub const PhysicalDeviceVulkan12Features = vk.VkPhysicalDeviceVulkan12Features;
pub const ConformanceVersion = vk.VkConformanceVersion;
pub const PhysicalDeviceVulkan12Properties = vk.VkPhysicalDeviceVulkan12Properties;
pub const ImageFormatListCreateInfo = vk.VkImageFormatListCreateInfo;
pub const AttachmentDescription2 = vk.VkAttachmentDescription2;
pub const AttachmentReference2 = vk.VkAttachmentReference2;
pub const SubpassDescription2 = vk.VkSubpassDescription2;
pub const SubpassDependency2 = vk.VkSubpassDependency2;
pub const RenderPassCreateInfo2 = vk.VkRenderPassCreateInfo2;
pub const SubpassBeginInfo = vk.VkSubpassBeginInfo;
pub const SubpassEndInfo = vk.VkSubpassEndInfo;
pub const PhysicalDevice8BitStorageFeatures = vk.VkPhysicalDevice8BitStorageFeatures;
pub const PhysicalDeviceDriverProperties = vk.VkPhysicalDeviceDriverProperties;
pub const PhysicalDeviceShaderAtomicInt64Features = vk.VkPhysicalDeviceShaderAtomicInt64Features;
pub const PhysicalDeviceShaderFloat16Int8Features = vk.VkPhysicalDeviceShaderFloat16Int8Features;
pub const PhysicalDeviceFloatControlsProperties = vk.VkPhysicalDeviceFloatControlsProperties;
pub const DescriptorSetLayoutBindingFlagsCreateInfo = vk.VkDescriptorSetLayoutBindingFlagsCreateInfo;
pub const PhysicalDeviceDescriptorIndexingFeatures = vk.VkPhysicalDeviceDescriptorIndexingFeatures;
pub const PhysicalDeviceDescriptorIndexingProperties = vk.VkPhysicalDeviceDescriptorIndexingProperties;
pub const DescriptorSetVariableDescriptorCountAllocateInfo = vk.VkDescriptorSetVariableDescriptorCountAllocateInfo;
pub const DescriptorSetVariableDescriptorCountLayoutSupport = vk.VkDescriptorSetVariableDescriptorCountLayoutSupport;
pub const SubpassDescriptionDepthStencilResolve = vk.VkSubpassDescriptionDepthStencilResolve;
pub const PhysicalDeviceDepthStencilResolveProperties = vk.VkPhysicalDeviceDepthStencilResolveProperties;
pub const PhysicalDeviceScalarBlockLayoutFeatures = vk.VkPhysicalDeviceScalarBlockLayoutFeatures;
pub const ImageStencilUsageCreateInfo = vk.VkImageStencilUsageCreateInfo;
pub const SamplerReductionModeCreateInfo = vk.VkSamplerReductionModeCreateInfo;
pub const PhysicalDeviceSamplerFilterMinmaxProperties = vk.VkPhysicalDeviceSamplerFilterMinmaxProperties;
pub const PhysicalDeviceVulkanMemoryModelFeatures = vk.VkPhysicalDeviceVulkanMemoryModelFeatures;
pub const PhysicalDeviceImagelessFramebufferFeatures = vk.VkPhysicalDeviceImagelessFramebufferFeatures;
pub const FramebufferAttachmentImageInfo = vk.VkFramebufferAttachmentImageInfo;
pub const FramebufferAttachmentsCreateInfo = vk.VkFramebufferAttachmentsCreateInfo;
pub const RenderPassAttachmentBeginInfo = vk.VkRenderPassAttachmentBeginInfo;
pub const PhysicalDeviceUniformBufferStandardLayoutFeatures = vk.VkPhysicalDeviceUniformBufferStandardLayoutFeatures;
pub const PhysicalDeviceShaderSubgroupExtendedTypesFeatures = vk.VkPhysicalDeviceShaderSubgroupExtendedTypesFeatures;
pub const PhysicalDeviceSeparateDepthStencilLayoutsFeatures = vk.VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures;
pub const AttachmentReferenceStencilLayout = vk.VkAttachmentReferenceStencilLayout;
pub const AttachmentDescriptionStencilLayout = vk.VkAttachmentDescriptionStencilLayout;
pub const PhysicalDeviceHostQueryResetFeatures = vk.VkPhysicalDeviceHostQueryResetFeatures;
pub const PhysicalDeviceTimelineSemaphoreFeatures = vk.VkPhysicalDeviceTimelineSemaphoreFeatures;
pub const PhysicalDeviceTimelineSemaphoreProperties = vk.VkPhysicalDeviceTimelineSemaphoreProperties;
pub const SemaphoreTypeCreateInfo = vk.VkSemaphoreTypeCreateInfo;
pub const TimelineSemaphoreSubmitInfo = vk.VkTimelineSemaphoreSubmitInfo;
pub const SemaphoreWaitInfo = vk.VkSemaphoreWaitInfo;
pub const SemaphoreSignalInfo = vk.VkSemaphoreSignalInfo;
pub const PhysicalDeviceBufferDeviceAddressFeatures = vk.VkPhysicalDeviceBufferDeviceAddressFeatures;
pub const BufferDeviceAddressInfo = vk.VkBufferDeviceAddressInfo;
pub const BufferOpaqueCaptureAddressCreateInfo = vk.VkBufferOpaqueCaptureAddressCreateInfo;
pub const MemoryOpaqueCaptureAddressAllocateInfo = vk.VkMemoryOpaqueCaptureAddressAllocateInfo;
pub const DeviceMemoryOpaqueCaptureAddressInfo = vk.VkDeviceMemoryOpaqueCaptureAddressInfo;
pub const PrivateDataSlot = vk.VkPrivateDataSlot;
pub const PhysicalDeviceVulkan13Features = vk.VkPhysicalDeviceVulkan13Features;
pub const PhysicalDeviceVulkan13Properties = vk.VkPhysicalDeviceVulkan13Properties;
pub const PipelineCreationFeedback = vk.VkPipelineCreationFeedback;
pub const PipelineCreationFeedbackCreateInfo = vk.VkPipelineCreationFeedbackCreateInfo;
pub const PhysicalDeviceShaderTerminateInvocationFeatures = vk.VkPhysicalDeviceShaderTerminateInvocationFeatures;
pub const PhysicalDeviceToolProperties = vk.VkPhysicalDeviceToolProperties;
pub const PhysicalDeviceShaderDemoteToHelperInvocationFeatures = vk.VkPhysicalDeviceShaderDemoteToHelperInvocationFeatures;
pub const PhysicalDevicePrivateDataFeatures = vk.VkPhysicalDevicePrivateDataFeatures;
pub const DevicePrivateDataCreateInfo = vk.VkDevicePrivateDataCreateInfo;
pub const PrivateDataSlotCreateInfo = vk.VkPrivateDataSlotCreateInfo;
pub const PhysicalDevicePipelineCreationCacheControlFeatures = vk.VkPhysicalDevicePipelineCreationCacheControlFeatures;
pub const MemoryBarrier2 = vk.VkMemoryBarrier2;
pub const BufferMemoryBarrier2 = vk.VkBufferMemoryBarrier2;
pub const ImageMemoryBarrier2 = vk.VkImageMemoryBarrier2;
pub const DependencyInfo = vk.VkDependencyInfo;
pub const SemaphoreSubmitInfo = vk.VkSemaphoreSubmitInfo;
pub const CommandBufferSubmitInfo = vk.VkCommandBufferSubmitInfo;
pub const SubmitInfo2 = vk.VkSubmitInfo2;
pub const PhysicalDeviceSynchronization2Features = vk.VkPhysicalDeviceSynchronization2Features;
pub const PhysicalDeviceZeroInitializeWorkgroupMemoryFeatures = vk.VkPhysicalDeviceZeroInitializeWorkgroupMemoryFeatures;
pub const PhysicalDeviceImageRobustnessFeatures = vk.VkPhysicalDeviceImageRobustnessFeatures;
pub const BufferCopy2 = vk.VkBufferCopy2;
pub const CopyBufferInfo2 = vk.VkCopyBufferInfo2;
pub const ImageCopy2 = vk.VkImageCopy2;
pub const CopyImageInfo2 = vk.VkCopyImageInfo2;
pub const BufferImageCopy2 = vk.VkBufferImageCopy2;
pub const CopyBufferToImageInfo2 = vk.VkCopyBufferToImageInfo2;
pub const CopyImageToBufferInfo2 = vk.VkCopyImageToBufferInfo2;
pub const ImageBlit2 = vk.VkImageBlit2;
pub const BlitImageInfo2 = vk.VkBlitImageInfo2;
pub const ImageResolve2 = vk.VkImageResolve2;
pub const ResolveImageInfo2 = vk.VkResolveImageInfo2;
pub const PhysicalDeviceSubgroupSizeControlFeatures = vk.VkPhysicalDeviceSubgroupSizeControlFeatures;
pub const PhysicalDeviceSubgroupSizeControlProperties = vk.VkPhysicalDeviceSubgroupSizeControlProperties;
pub const PipelineShaderStageRequiredSubgroupSizeCreateInfo = vk.VkPipelineShaderStageRequiredSubgroupSizeCreateInfo;
pub const PhysicalDeviceInlineUniformBlockFeatures = vk.VkPhysicalDeviceInlineUniformBlockFeatures;
pub const PhysicalDeviceInlineUniformBlockProperties = vk.VkPhysicalDeviceInlineUniformBlockProperties;
pub const WriteDescriptorSetInlineUniformBlock = vk.VkWriteDescriptorSetInlineUniformBlock;
pub const DescriptorPoolInlineUniformBlockCreateInfo = vk.VkDescriptorPoolInlineUniformBlockCreateInfo;
pub const PhysicalDeviceTextureCompressionASTCHDRFeatures = vk.VkPhysicalDeviceTextureCompressionASTCHDRFeatures;
pub const RenderingAttachmentInfo = vk.VkRenderingAttachmentInfo;
pub const RenderingInfo = vk.VkRenderingInfo;
pub const PipelineRenderingCreateInfo = vk.VkPipelineRenderingCreateInfo;
pub const PhysicalDeviceDynamicRenderingFeatures = vk.VkPhysicalDeviceDynamicRenderingFeatures;
pub const CommandBufferInheritanceRenderingInfo = vk.VkCommandBufferInheritanceRenderingInfo;
pub const PhysicalDeviceShaderIntegerDotProductFeatures = vk.VkPhysicalDeviceShaderIntegerDotProductFeatures;
pub const PhysicalDeviceShaderIntegerDotProductProperties = vk.VkPhysicalDeviceShaderIntegerDotProductProperties;
pub const PhysicalDeviceTexelBufferAlignmentProperties = vk.VkPhysicalDeviceTexelBufferAlignmentProperties;
pub const FormatProperties3 = vk.VkFormatProperties3;
pub const PhysicalDeviceMaintenance4Features = vk.VkPhysicalDeviceMaintenance4Features;
pub const PhysicalDeviceMaintenance4Properties = vk.VkPhysicalDeviceMaintenance4Properties;
pub const DeviceBufferMemoryRequirements = vk.VkDeviceBufferMemoryRequirements;
pub const DeviceImageMemoryRequirements = vk.VkDeviceImageMemoryRequirements;
pub const PhysicalDeviceVulkan14Features = vk.VkPhysicalDeviceVulkan14Features;
pub const PhysicalDeviceVulkan14Properties = vk.VkPhysicalDeviceVulkan14Properties;
pub const DeviceQueueGlobalPriorityCreateInfo = vk.VkDeviceQueueGlobalPriorityCreateInfo;
pub const PhysicalDeviceGlobalPriorityQueryFeatures = vk.VkPhysicalDeviceGlobalPriorityQueryFeatures;
pub const QueueFamilyGlobalPriorityProperties = vk.VkQueueFamilyGlobalPriorityProperties;
pub const PhysicalDeviceShaderSubgroupRotateFeatures = vk.VkPhysicalDeviceShaderSubgroupRotateFeatures;
pub const PhysicalDeviceShaderFloatControls2Features = vk.VkPhysicalDeviceShaderFloatControls2Features;
pub const PhysicalDeviceShaderExpectAssumeFeatures = vk.VkPhysicalDeviceShaderExpectAssumeFeatures;
pub const PhysicalDeviceLineRasterizationFeatures = vk.VkPhysicalDeviceLineRasterizationFeatures;
pub const PhysicalDeviceLineRasterizationProperties = vk.VkPhysicalDeviceLineRasterizationProperties;
pub const PipelineRasterizationLineStateCreateInfo = vk.VkPipelineRasterizationLineStateCreateInfo;
pub const PhysicalDeviceVertexAttributeDivisorProperties = vk.VkPhysicalDeviceVertexAttributeDivisorProperties;
pub const VertexInputBindingDivisorDescription = vk.VkVertexInputBindingDivisorDescription;
pub const PipelineVertexInputDivisorStateCreateInfo = vk.VkPipelineVertexInputDivisorStateCreateInfo;
pub const PhysicalDeviceVertexAttributeDivisorFeatures = vk.VkPhysicalDeviceVertexAttributeDivisorFeatures;
pub const PhysicalDeviceIndexTypeUint8Features = vk.VkPhysicalDeviceIndexTypeUint8Features;
pub const MemoryMapInfo = vk.VkMemoryMapInfo;
pub const MemoryUnmapInfo = vk.VkMemoryUnmapInfo;
pub const PhysicalDeviceMaintenance5Features = vk.VkPhysicalDeviceMaintenance5Features;
pub const PhysicalDeviceMaintenance5Properties = vk.VkPhysicalDeviceMaintenance5Properties;
pub const RenderingAreaInfo = vk.VkRenderingAreaInfo;
pub const ImageSubresource2 = vk.VkImageSubresource2;
pub const DeviceImageSubresourceInfo = vk.VkDeviceImageSubresourceInfo;
pub const SubresourceLayout2 = vk.VkSubresourceLayout2;
pub const PipelineCreateFlags2CreateInfo = vk.VkPipelineCreateFlags2CreateInfo;
pub const BufferUsageFlags2CreateInfo = vk.VkBufferUsageFlags2CreateInfo;
pub const PhysicalDevicePushDescriptorProperties = vk.VkPhysicalDevicePushDescriptorProperties;
pub const PhysicalDeviceDynamicRenderingLocalReadFeatures = vk.VkPhysicalDeviceDynamicRenderingLocalReadFeatures;
pub const RenderingAttachmentLocationInfo = vk.VkRenderingAttachmentLocationInfo;
pub const RenderingInputAttachmentIndexInfo = vk.VkRenderingInputAttachmentIndexInfo;
pub const PhysicalDeviceMaintenance6Features = vk.VkPhysicalDeviceMaintenance6Features;
pub const PhysicalDeviceMaintenance6Properties = vk.VkPhysicalDeviceMaintenance6Properties;
pub const BindMemoryStatus = vk.VkBindMemoryStatus;
pub const BindDescriptorSetsInfo = vk.VkBindDescriptorSetsInfo;
pub const PushConstantsInfo = vk.VkPushConstantsInfo;
pub const PushDescriptorSetInfo = vk.VkPushDescriptorSetInfo;
pub const PushDescriptorSetWithTemplateInfo = vk.VkPushDescriptorSetWithTemplateInfo;
pub const PhysicalDevicePipelineProtectedAccessFeatures = vk.VkPhysicalDevicePipelineProtectedAccessFeatures;
pub const PhysicalDevicePipelineRobustnessFeatures = vk.VkPhysicalDevicePipelineRobustnessFeatures;
pub const PhysicalDevicePipelineRobustnessProperties = vk.VkPhysicalDevicePipelineRobustnessProperties;
pub const PipelineRobustnessCreateInfo = vk.VkPipelineRobustnessCreateInfo;
pub const PhysicalDeviceHostImageCopyFeatures = vk.VkPhysicalDeviceHostImageCopyFeatures;
pub const PhysicalDeviceHostImageCopyProperties = vk.VkPhysicalDeviceHostImageCopyProperties;
pub const MemoryToImageCopy = vk.VkMemoryToImageCopy;
pub const ImageToMemoryCopy = vk.VkImageToMemoryCopy;
pub const CopyMemoryToImageInfo = vk.VkCopyMemoryToImageInfo;
pub const CopyImageToMemoryInfo = vk.VkCopyImageToMemoryInfo;
pub const CopyImageToImageInfo = vk.VkCopyImageToImageInfo;
pub const HostImageLayoutTransitionInfo = vk.VkHostImageLayoutTransitionInfo;
pub const SubresourceHostMemcpySize = vk.VkSubresourceHostMemcpySize;
pub const HostImageCopyDevicePerformanceQuery = vk.VkHostImageCopyDevicePerformanceQuery;
pub const SurfaceKHR = vk.VkSurfaceKHR;
pub const SurfaceCapabilitiesKHR = vk.VkSurfaceCapabilitiesKHR;
pub const SurfaceFormatKHR = vk.VkSurfaceFormatKHR;
pub const SwapchainKHR = vk.VkSwapchainKHR;
pub const SwapchainCreateInfoKHR = vk.VkSwapchainCreateInfoKHR;
pub const PresentInfoKHR = vk.VkPresentInfoKHR;
pub const ImageSwapchainCreateInfoKHR = vk.VkImageSwapchainCreateInfoKHR;
pub const BindImageMemorySwapchainInfoKHR = vk.VkBindImageMemorySwapchainInfoKHR;
pub const AcquireNextImageInfoKHR = vk.VkAcquireNextImageInfoKHR;
pub const DeviceGroupPresentCapabilitiesKHR = vk.VkDeviceGroupPresentCapabilitiesKHR;
pub const DeviceGroupPresentInfoKHR = vk.VkDeviceGroupPresentInfoKHR;
pub const DeviceGroupSwapchainCreateInfoKHR = vk.VkDeviceGroupSwapchainCreateInfoKHR;
pub const DisplayKHR = vk.VkDisplayKHR;
pub const DisplayModeKHR = vk.VkDisplayModeKHR;
pub const DisplayModeParametersKHR = vk.VkDisplayModeParametersKHR;
pub const DisplayModeCreateInfoKHR = vk.VkDisplayModeCreateInfoKHR;
pub const DisplayModePropertiesKHR = vk.VkDisplayModePropertiesKHR;
pub const DisplayPlaneCapabilitiesKHR = vk.VkDisplayPlaneCapabilitiesKHR;
pub const DisplayPlanePropertiesKHR = vk.VkDisplayPlanePropertiesKHR;
pub const DisplayPropertiesKHR = vk.VkDisplayPropertiesKHR;
pub const DisplaySurfaceCreateInfoKHR = vk.VkDisplaySurfaceCreateInfoKHR;
pub const DisplayPresentInfoKHR = vk.VkDisplayPresentInfoKHR;
pub const VideoSessionKHR = vk.VkVideoSessionKHR;
pub const VideoSessionParametersKHR = vk.VkVideoSessionParametersKHR;
pub const QueueFamilyQueryResultStatusPropertiesKHR = vk.VkQueueFamilyQueryResultStatusPropertiesKHR;
pub const QueueFamilyVideoPropertiesKHR = vk.VkQueueFamilyVideoPropertiesKHR;
pub const VideoProfileInfoKHR = vk.VkVideoProfileInfoKHR;
pub const VideoProfileListInfoKHR = vk.VkVideoProfileListInfoKHR;
pub const VideoCapabilitiesKHR = vk.VkVideoCapabilitiesKHR;
pub const PhysicalDeviceVideoFormatInfoKHR = vk.VkPhysicalDeviceVideoFormatInfoKHR;
pub const VideoFormatPropertiesKHR = vk.VkVideoFormatPropertiesKHR;
pub const VideoPictureResourceInfoKHR = vk.VkVideoPictureResourceInfoKHR;
pub const VideoReferenceSlotInfoKHR = vk.VkVideoReferenceSlotInfoKHR;
pub const VideoSessionMemoryRequirementsKHR = vk.VkVideoSessionMemoryRequirementsKHR;
pub const BindVideoSessionMemoryInfoKHR = vk.VkBindVideoSessionMemoryInfoKHR;
pub const VideoSessionCreateInfoKHR = vk.VkVideoSessionCreateInfoKHR;
pub const VideoSessionParametersCreateInfoKHR = vk.VkVideoSessionParametersCreateInfoKHR;
pub const VideoSessionParametersUpdateInfoKHR = vk.VkVideoSessionParametersUpdateInfoKHR;
pub const VideoBeginCodingInfoKHR = vk.VkVideoBeginCodingInfoKHR;
pub const VideoEndCodingInfoKHR = vk.VkVideoEndCodingInfoKHR;
pub const VideoCodingControlInfoKHR = vk.VkVideoCodingControlInfoKHR;
pub const VideoDecodeCapabilitiesKHR = vk.VkVideoDecodeCapabilitiesKHR;
pub const VideoDecodeUsageInfoKHR = vk.VkVideoDecodeUsageInfoKHR;
pub const VideoDecodeInfoKHR = vk.VkVideoDecodeInfoKHR;
pub const VideoEncodeH264CapabilitiesKHR = vk.VkVideoEncodeH264CapabilitiesKHR;
pub const VideoEncodeH264QpKHR = vk.VkVideoEncodeH264QpKHR;
pub const VideoEncodeH264QualityLevelPropertiesKHR = vk.VkVideoEncodeH264QualityLevelPropertiesKHR;
pub const VideoEncodeH264SessionCreateInfoKHR = vk.VkVideoEncodeH264SessionCreateInfoKHR;
pub const VideoEncodeH264SessionParametersAddInfoKHR = vk.VkVideoEncodeH264SessionParametersAddInfoKHR;
pub const VideoEncodeH264SessionParametersCreateInfoKHR = vk.VkVideoEncodeH264SessionParametersCreateInfoKHR;
pub const VideoEncodeH264SessionParametersGetInfoKHR = vk.VkVideoEncodeH264SessionParametersGetInfoKHR;
pub const VideoEncodeH264SessionParametersFeedbackInfoKHR = vk.VkVideoEncodeH264SessionParametersFeedbackInfoKHR;
pub const VideoEncodeH264NaluSliceInfoKHR = vk.VkVideoEncodeH264NaluSliceInfoKHR;
pub const VideoEncodeH264PictureInfoKHR = vk.VkVideoEncodeH264PictureInfoKHR;
pub const VideoEncodeH264DpbSlotInfoKHR = vk.VkVideoEncodeH264DpbSlotInfoKHR;
pub const VideoEncodeH264ProfileInfoKHR = vk.VkVideoEncodeH264ProfileInfoKHR;
pub const VideoEncodeH264RateControlInfoKHR = vk.VkVideoEncodeH264RateControlInfoKHR;
pub const VideoEncodeH264FrameSizeKHR = vk.VkVideoEncodeH264FrameSizeKHR;
pub const VideoEncodeH264RateControlLayerInfoKHR = vk.VkVideoEncodeH264RateControlLayerInfoKHR;
pub const VideoEncodeH264GopRemainingFrameInfoKHR = vk.VkVideoEncodeH264GopRemainingFrameInfoKHR;
pub const VideoEncodeH265CapabilitiesKHR = vk.VkVideoEncodeH265CapabilitiesKHR;
pub const VideoEncodeH265SessionCreateInfoKHR = vk.VkVideoEncodeH265SessionCreateInfoKHR;
pub const VideoEncodeH265QpKHR = vk.VkVideoEncodeH265QpKHR;
pub const VideoEncodeH265QualityLevelPropertiesKHR = vk.VkVideoEncodeH265QualityLevelPropertiesKHR;
pub const VideoEncodeH265SessionParametersAddInfoKHR = vk.VkVideoEncodeH265SessionParametersAddInfoKHR;
pub const VideoEncodeH265SessionParametersCreateInfoKHR = vk.VkVideoEncodeH265SessionParametersCreateInfoKHR;
pub const VideoEncodeH265SessionParametersGetInfoKHR = vk.VkVideoEncodeH265SessionParametersGetInfoKHR;
pub const VideoEncodeH265SessionParametersFeedbackInfoKHR = vk.VkVideoEncodeH265SessionParametersFeedbackInfoKHR;
pub const VideoEncodeH265NaluSliceSegmentInfoKHR = vk.VkVideoEncodeH265NaluSliceSegmentInfoKHR;
pub const VideoEncodeH265PictureInfoKHR = vk.VkVideoEncodeH265PictureInfoKHR;
pub const VideoEncodeH265DpbSlotInfoKHR = vk.VkVideoEncodeH265DpbSlotInfoKHR;
pub const VideoEncodeH265ProfileInfoKHR = vk.VkVideoEncodeH265ProfileInfoKHR;
pub const VideoEncodeH265RateControlInfoKHR = vk.VkVideoEncodeH265RateControlInfoKHR;
pub const VideoEncodeH265FrameSizeKHR = vk.VkVideoEncodeH265FrameSizeKHR;
pub const VideoEncodeH265RateControlLayerInfoKHR = vk.VkVideoEncodeH265RateControlLayerInfoKHR;
pub const VideoEncodeH265GopRemainingFrameInfoKHR = vk.VkVideoEncodeH265GopRemainingFrameInfoKHR;
pub const VideoDecodeH264ProfileInfoKHR = vk.VkVideoDecodeH264ProfileInfoKHR;
pub const VideoDecodeH264CapabilitiesKHR = vk.VkVideoDecodeH264CapabilitiesKHR;
pub const VideoDecodeH264SessionParametersAddInfoKHR = vk.VkVideoDecodeH264SessionParametersAddInfoKHR;
pub const VideoDecodeH264SessionParametersCreateInfoKHR = vk.VkVideoDecodeH264SessionParametersCreateInfoKHR;
pub const VideoDecodeH264PictureInfoKHR = vk.VkVideoDecodeH264PictureInfoKHR;
pub const VideoDecodeH264DpbSlotInfoKHR = vk.VkVideoDecodeH264DpbSlotInfoKHR;
pub const ImportMemoryFdInfoKHR = vk.VkImportMemoryFdInfoKHR;
pub const MemoryFdPropertiesKHR = vk.VkMemoryFdPropertiesKHR;
pub const MemoryGetFdInfoKHR = vk.VkMemoryGetFdInfoKHR;
pub const ImportSemaphoreFdInfoKHR = vk.VkImportSemaphoreFdInfoKHR;
pub const SemaphoreGetFdInfoKHR = vk.VkSemaphoreGetFdInfoKHR;
pub const RectLayerKHR = vk.VkRectLayerKHR;
pub const PresentRegionKHR = vk.VkPresentRegionKHR;
pub const PresentRegionsKHR = vk.VkPresentRegionsKHR;
pub const SharedPresentSurfaceCapabilitiesKHR = vk.VkSharedPresentSurfaceCapabilitiesKHR;
pub const ImportFenceFdInfoKHR = vk.VkImportFenceFdInfoKHR;
pub const FenceGetFdInfoKHR = vk.VkFenceGetFdInfoKHR;
pub const PhysicalDevicePerformanceQueryFeaturesKHR = vk.VkPhysicalDevicePerformanceQueryFeaturesKHR;
pub const PhysicalDevicePerformanceQueryPropertiesKHR = vk.VkPhysicalDevicePerformanceQueryPropertiesKHR;
pub const PerformanceCounterKHR = vk.VkPerformanceCounterKHR;
pub const PerformanceCounterDescriptionKHR = vk.VkPerformanceCounterDescriptionKHR;
pub const QueryPoolPerformanceCreateInfoKHR = vk.VkQueryPoolPerformanceCreateInfoKHR;
pub const AcquireProfilingLockInfoKHR = vk.VkAcquireProfilingLockInfoKHR;
pub const PerformanceQuerySubmitInfoKHR = vk.VkPerformanceQuerySubmitInfoKHR;
pub const PhysicalDeviceSurfaceInfo2KHR = vk.VkPhysicalDeviceSurfaceInfo2KHR;
pub const SurfaceCapabilities2KHR = vk.VkSurfaceCapabilities2KHR;
pub const SurfaceFormat2KHR = vk.VkSurfaceFormat2KHR;
pub const DisplayProperties2KHR = vk.VkDisplayProperties2KHR;
pub const DisplayPlaneProperties2KHR = vk.VkDisplayPlaneProperties2KHR;
pub const DisplayModeProperties2KHR = vk.VkDisplayModeProperties2KHR;
pub const DisplayPlaneInfo2KHR = vk.VkDisplayPlaneInfo2KHR;
pub const DisplayPlaneCapabilities2KHR = vk.VkDisplayPlaneCapabilities2KHR;
pub const PhysicalDeviceShaderClockFeaturesKHR = vk.VkPhysicalDeviceShaderClockFeaturesKHR;
pub const VideoDecodeH265ProfileInfoKHR = vk.VkVideoDecodeH265ProfileInfoKHR;
pub const VideoDecodeH265CapabilitiesKHR = vk.VkVideoDecodeH265CapabilitiesKHR;
pub const VideoDecodeH265SessionParametersAddInfoKHR = vk.VkVideoDecodeH265SessionParametersAddInfoKHR;
pub const VideoDecodeH265SessionParametersCreateInfoKHR = vk.VkVideoDecodeH265SessionParametersCreateInfoKHR;
pub const VideoDecodeH265PictureInfoKHR = vk.VkVideoDecodeH265PictureInfoKHR;
pub const VideoDecodeH265DpbSlotInfoKHR = vk.VkVideoDecodeH265DpbSlotInfoKHR;
pub const FragmentShadingRateAttachmentInfoKHR = vk.VkFragmentShadingRateAttachmentInfoKHR;
pub const PipelineFragmentShadingRateStateCreateInfoKHR = vk.VkPipelineFragmentShadingRateStateCreateInfoKHR;
pub const PhysicalDeviceFragmentShadingRateFeaturesKHR = vk.VkPhysicalDeviceFragmentShadingRateFeaturesKHR;
pub const PhysicalDeviceFragmentShadingRatePropertiesKHR = vk.VkPhysicalDeviceFragmentShadingRatePropertiesKHR;
pub const PhysicalDeviceFragmentShadingRateKHR = vk.VkPhysicalDeviceFragmentShadingRateKHR;
pub const RenderingFragmentShadingRateAttachmentInfoKHR = vk.VkRenderingFragmentShadingRateAttachmentInfoKHR;
pub const PhysicalDeviceShaderQuadControlFeaturesKHR = vk.VkPhysicalDeviceShaderQuadControlFeaturesKHR;
pub const SurfaceProtectedCapabilitiesKHR = vk.VkSurfaceProtectedCapabilitiesKHR;
pub const PhysicalDevicePresentWaitFeaturesKHR = vk.VkPhysicalDevicePresentWaitFeaturesKHR;
pub const DeferredOperationKHR = vk.VkDeferredOperationKHR;
pub const PhysicalDevicePipelineExecutablePropertiesFeaturesKHR = vk.VkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR;
pub const PipelineInfoKHR = vk.VkPipelineInfoKHR;
pub const PipelineExecutablePropertiesKHR = vk.VkPipelineExecutablePropertiesKHR;
pub const PipelineExecutableInfoKHR = vk.VkPipelineExecutableInfoKHR;
pub const PipelineExecutableStatisticKHR = vk.VkPipelineExecutableStatisticKHR;
pub const PipelineExecutableInternalRepresentationKHR = vk.VkPipelineExecutableInternalRepresentationKHR;
pub const PipelineLibraryCreateInfoKHR = vk.VkPipelineLibraryCreateInfoKHR;
pub const PresentIdKHR = vk.VkPresentIdKHR;
pub const PhysicalDevicePresentIdFeaturesKHR = vk.VkPhysicalDevicePresentIdFeaturesKHR;
pub const VideoEncodeInfoKHR = vk.VkVideoEncodeInfoKHR;
pub const VideoEncodeCapabilitiesKHR = vk.VkVideoEncodeCapabilitiesKHR;
pub const QueryPoolVideoEncodeFeedbackCreateInfoKHR = vk.VkQueryPoolVideoEncodeFeedbackCreateInfoKHR;
pub const VideoEncodeUsageInfoKHR = vk.VkVideoEncodeUsageInfoKHR;
pub const VideoEncodeRateControlLayerInfoKHR = vk.VkVideoEncodeRateControlLayerInfoKHR;
pub const VideoEncodeRateControlInfoKHR = vk.VkVideoEncodeRateControlInfoKHR;
pub const PhysicalDeviceVideoEncodeQualityLevelInfoKHR = vk.VkPhysicalDeviceVideoEncodeQualityLevelInfoKHR;
pub const VideoEncodeQualityLevelPropertiesKHR = vk.VkVideoEncodeQualityLevelPropertiesKHR;
pub const VideoEncodeQualityLevelInfoKHR = vk.VkVideoEncodeQualityLevelInfoKHR;
pub const VideoEncodeSessionParametersGetInfoKHR = vk.VkVideoEncodeSessionParametersGetInfoKHR;
pub const VideoEncodeSessionParametersFeedbackInfoKHR = vk.VkVideoEncodeSessionParametersFeedbackInfoKHR;
pub const PhysicalDeviceFragmentShaderBarycentricFeaturesKHR = vk.VkPhysicalDeviceFragmentShaderBarycentricFeaturesKHR;
pub const PhysicalDeviceFragmentShaderBarycentricPropertiesKHR = vk.VkPhysicalDeviceFragmentShaderBarycentricPropertiesKHR;
pub const PhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR = vk.VkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR;
pub const PhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR = vk.VkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR;
pub const PhysicalDeviceRayTracingMaintenance1FeaturesKHR = vk.VkPhysicalDeviceRayTracingMaintenance1FeaturesKHR;
pub const TraceRaysIndirectCommand2KHR = vk.VkTraceRaysIndirectCommand2KHR;
pub const PhysicalDeviceShaderMaximalReconvergenceFeaturesKHR = vk.VkPhysicalDeviceShaderMaximalReconvergenceFeaturesKHR;
pub const PhysicalDeviceRayTracingPositionFetchFeaturesKHR = vk.VkPhysicalDeviceRayTracingPositionFetchFeaturesKHR;
pub const PipelineBinaryKHR = vk.VkPipelineBinaryKHR;
pub const PhysicalDevicePipelineBinaryFeaturesKHR = vk.VkPhysicalDevicePipelineBinaryFeaturesKHR;
pub const PhysicalDevicePipelineBinaryPropertiesKHR = vk.VkPhysicalDevicePipelineBinaryPropertiesKHR;
pub const DevicePipelineBinaryInternalCacheControlKHR = vk.VkDevicePipelineBinaryInternalCacheControlKHR;
pub const PipelineBinaryKeyKHR = vk.VkPipelineBinaryKeyKHR;
pub const PipelineBinaryDataKHR = vk.VkPipelineBinaryDataKHR;
pub const PipelineBinaryKeysAndDataKHR = vk.VkPipelineBinaryKeysAndDataKHR;
pub const PipelineCreateInfoKHR = vk.VkPipelineCreateInfoKHR;
pub const PipelineBinaryCreateInfoKHR = vk.VkPipelineBinaryCreateInfoKHR;
pub const PipelineBinaryInfoKHR = vk.VkPipelineBinaryInfoKHR;
pub const ReleaseCapturedPipelineDataInfoKHR = vk.VkReleaseCapturedPipelineDataInfoKHR;
pub const PipelineBinaryDataInfoKHR = vk.VkPipelineBinaryDataInfoKHR;
pub const PipelineBinaryHandlesInfoKHR = vk.VkPipelineBinaryHandlesInfoKHR;
pub const CooperativeMatrixPropertiesKHR = vk.VkCooperativeMatrixPropertiesKHR;
pub const PhysicalDeviceCooperativeMatrixFeaturesKHR = vk.VkPhysicalDeviceCooperativeMatrixFeaturesKHR;
pub const PhysicalDeviceCooperativeMatrixPropertiesKHR = vk.VkPhysicalDeviceCooperativeMatrixPropertiesKHR;
pub const PhysicalDeviceComputeShaderDerivativesFeaturesKHR = vk.VkPhysicalDeviceComputeShaderDerivativesFeaturesKHR;
pub const PhysicalDeviceComputeShaderDerivativesPropertiesKHR = vk.VkPhysicalDeviceComputeShaderDerivativesPropertiesKHR;
pub const VideoDecodeAV1ProfileInfoKHR = vk.VkVideoDecodeAV1ProfileInfoKHR;
pub const VideoDecodeAV1CapabilitiesKHR = vk.VkVideoDecodeAV1CapabilitiesKHR;
pub const VideoDecodeAV1SessionParametersCreateInfoKHR = vk.VkVideoDecodeAV1SessionParametersCreateInfoKHR;
pub const VideoDecodeAV1PictureInfoKHR = vk.VkVideoDecodeAV1PictureInfoKHR;
pub const VideoDecodeAV1DpbSlotInfoKHR = vk.VkVideoDecodeAV1DpbSlotInfoKHR;
pub const PhysicalDeviceVideoEncodeAV1FeaturesKHR = vk.VkPhysicalDeviceVideoEncodeAV1FeaturesKHR;
pub const VideoEncodeAV1CapabilitiesKHR = vk.VkVideoEncodeAV1CapabilitiesKHR;
pub const VideoEncodeAV1QIndexKHR = vk.VkVideoEncodeAV1QIndexKHR;
pub const VideoEncodeAV1QualityLevelPropertiesKHR = vk.VkVideoEncodeAV1QualityLevelPropertiesKHR;
pub const VideoEncodeAV1SessionCreateInfoKHR = vk.VkVideoEncodeAV1SessionCreateInfoKHR;
pub const VideoEncodeAV1SessionParametersCreateInfoKHR = vk.VkVideoEncodeAV1SessionParametersCreateInfoKHR;
pub const VideoEncodeAV1PictureInfoKHR = vk.VkVideoEncodeAV1PictureInfoKHR;
pub const VideoEncodeAV1DpbSlotInfoKHR = vk.VkVideoEncodeAV1DpbSlotInfoKHR;
pub const VideoEncodeAV1ProfileInfoKHR = vk.VkVideoEncodeAV1ProfileInfoKHR;
pub const VideoEncodeAV1FrameSizeKHR = vk.VkVideoEncodeAV1FrameSizeKHR;
pub const VideoEncodeAV1GopRemainingFrameInfoKHR = vk.VkVideoEncodeAV1GopRemainingFrameInfoKHR;
pub const VideoEncodeAV1RateControlInfoKHR = vk.VkVideoEncodeAV1RateControlInfoKHR;
pub const VideoEncodeAV1RateControlLayerInfoKHR = vk.VkVideoEncodeAV1RateControlLayerInfoKHR;
pub const PhysicalDeviceVideoMaintenance1FeaturesKHR = vk.VkPhysicalDeviceVideoMaintenance1FeaturesKHR;
pub const VideoInlineQueryInfoKHR = vk.VkVideoInlineQueryInfoKHR;
pub const CalibratedTimestampInfoKHR = vk.VkCalibratedTimestampInfoKHR;
pub const SetDescriptorBufferOffsetsInfoEXT = vk.VkSetDescriptorBufferOffsetsInfoEXT;
pub const BindDescriptorBufferEmbeddedSamplersInfoEXT = vk.VkBindDescriptorBufferEmbeddedSamplersInfoEXT;
pub const VideoEncodeQuantizationMapCapabilitiesKHR = vk.VkVideoEncodeQuantizationMapCapabilitiesKHR;
pub const VideoFormatQuantizationMapPropertiesKHR = vk.VkVideoFormatQuantizationMapPropertiesKHR;
pub const VideoEncodeQuantizationMapInfoKHR = vk.VkVideoEncodeQuantizationMapInfoKHR;
pub const VideoEncodeQuantizationMapSessionParametersCreateInfoKHR = vk.VkVideoEncodeQuantizationMapSessionParametersCreateInfoKHR;
pub const PhysicalDeviceVideoEncodeQuantizationMapFeaturesKHR = vk.VkPhysicalDeviceVideoEncodeQuantizationMapFeaturesKHR;
pub const VideoEncodeH264QuantizationMapCapabilitiesKHR = vk.VkVideoEncodeH264QuantizationMapCapabilitiesKHR;
pub const VideoEncodeH265QuantizationMapCapabilitiesKHR = vk.VkVideoEncodeH265QuantizationMapCapabilitiesKHR;
pub const VideoFormatH265QuantizationMapPropertiesKHR = vk.VkVideoFormatH265QuantizationMapPropertiesKHR;
pub const VideoEncodeAV1QuantizationMapCapabilitiesKHR = vk.VkVideoEncodeAV1QuantizationMapCapabilitiesKHR;
pub const VideoFormatAV1QuantizationMapPropertiesKHR = vk.VkVideoFormatAV1QuantizationMapPropertiesKHR;
pub const PhysicalDeviceShaderRelaxedExtendedInstructionFeaturesKHR = vk.VkPhysicalDeviceShaderRelaxedExtendedInstructionFeaturesKHR;
pub const PhysicalDeviceMaintenance7FeaturesKHR = vk.VkPhysicalDeviceMaintenance7FeaturesKHR;
pub const PhysicalDeviceMaintenance7PropertiesKHR = vk.VkPhysicalDeviceMaintenance7PropertiesKHR;
pub const PhysicalDeviceLayeredApiPropertiesKHR = vk.VkPhysicalDeviceLayeredApiPropertiesKHR;
pub const PhysicalDeviceLayeredApiPropertiesListKHR = vk.VkPhysicalDeviceLayeredApiPropertiesListKHR;
pub const PhysicalDeviceLayeredApiVulkanPropertiesKHR = vk.VkPhysicalDeviceLayeredApiVulkanPropertiesKHR;
pub const PhysicalDeviceMaintenance8FeaturesKHR = vk.VkPhysicalDeviceMaintenance8FeaturesKHR;
pub const MemoryBarrierAccessFlags3KHR = vk.VkMemoryBarrierAccessFlags3KHR;
pub const PhysicalDeviceVideoMaintenance2FeaturesKHR = vk.VkPhysicalDeviceVideoMaintenance2FeaturesKHR;
pub const VideoDecodeH264InlineSessionParametersInfoKHR = vk.VkVideoDecodeH264InlineSessionParametersInfoKHR;
pub const VideoDecodeH265InlineSessionParametersInfoKHR = vk.VkVideoDecodeH265InlineSessionParametersInfoKHR;
pub const VideoDecodeAV1InlineSessionParametersInfoKHR = vk.VkVideoDecodeAV1InlineSessionParametersInfoKHR;
pub const PhysicalDeviceDepthClampZeroOneFeaturesKHR = vk.VkPhysicalDeviceDepthClampZeroOneFeaturesKHR;
pub const DebugReportCallbackEXT = vk.VkDebugReportCallbackEXT;
pub const DebugReportCallbackCreateInfoEXT = vk.VkDebugReportCallbackCreateInfoEXT;
pub const PipelineRasterizationStateRasterizationOrderAMD = vk.VkPipelineRasterizationStateRasterizationOrderAMD;
pub const DebugMarkerObjectNameInfoEXT = vk.VkDebugMarkerObjectNameInfoEXT;
pub const DebugMarkerObjectTagInfoEXT = vk.VkDebugMarkerObjectTagInfoEXT;
pub const DebugMarkerMarkerInfoEXT = vk.VkDebugMarkerMarkerInfoEXT;
pub const DedicatedAllocationImageCreateInfoNV = vk.VkDedicatedAllocationImageCreateInfoNV;
pub const DedicatedAllocationBufferCreateInfoNV = vk.VkDedicatedAllocationBufferCreateInfoNV;
pub const DedicatedAllocationMemoryAllocateInfoNV = vk.VkDedicatedAllocationMemoryAllocateInfoNV;
pub const PhysicalDeviceTransformFeedbackFeaturesEXT = vk.VkPhysicalDeviceTransformFeedbackFeaturesEXT;
pub const PhysicalDeviceTransformFeedbackPropertiesEXT = vk.VkPhysicalDeviceTransformFeedbackPropertiesEXT;
pub const PipelineRasterizationStateStreamCreateInfoEXT = vk.VkPipelineRasterizationStateStreamCreateInfoEXT;
pub const CuModuleNVX = vk.VkCuModuleNVX;
pub const CuFunctionNVX = vk.VkCuFunctionNVX;
pub const CuModuleCreateInfoNVX = vk.VkCuModuleCreateInfoNVX;
pub const CuModuleTexturingModeCreateInfoNVX = vk.VkCuModuleTexturingModeCreateInfoNVX;
pub const CuFunctionCreateInfoNVX = vk.VkCuFunctionCreateInfoNVX;
pub const CuLaunchInfoNVX = vk.VkCuLaunchInfoNVX;
pub const ImageViewHandleInfoNVX = vk.VkImageViewHandleInfoNVX;
pub const ImageViewAddressPropertiesNVX = vk.VkImageViewAddressPropertiesNVX;
pub const TextureLODGatherFormatPropertiesAMD = vk.VkTextureLODGatherFormatPropertiesAMD;
pub const ShaderResourceUsageAMD = vk.VkShaderResourceUsageAMD;
pub const ShaderStatisticsInfoAMD = vk.VkShaderStatisticsInfoAMD;
pub const PhysicalDeviceCornerSampledImageFeaturesNV = vk.VkPhysicalDeviceCornerSampledImageFeaturesNV;
pub const ExternalImageFormatPropertiesNV = vk.VkExternalImageFormatPropertiesNV;
pub const ExternalMemoryImageCreateInfoNV = vk.VkExternalMemoryImageCreateInfoNV;
pub const ExportMemoryAllocateInfoNV = vk.VkExportMemoryAllocateInfoNV;
pub const ValidationFlagsEXT = vk.VkValidationFlagsEXT;
pub const ImageViewASTCDecodeModeEXT = vk.VkImageViewASTCDecodeModeEXT;
pub const PhysicalDeviceASTCDecodeFeaturesEXT = vk.VkPhysicalDeviceASTCDecodeFeaturesEXT;
pub const ConditionalRenderingBeginInfoEXT = vk.VkConditionalRenderingBeginInfoEXT;
pub const PhysicalDeviceConditionalRenderingFeaturesEXT = vk.VkPhysicalDeviceConditionalRenderingFeaturesEXT;
pub const CommandBufferInheritanceConditionalRenderingInfoEXT = vk.VkCommandBufferInheritanceConditionalRenderingInfoEXT;
pub const ViewportWScalingNV = vk.VkViewportWScalingNV;
pub const PipelineViewportWScalingStateCreateInfoNV = vk.VkPipelineViewportWScalingStateCreateInfoNV;
pub const SurfaceCapabilities2EXT = vk.VkSurfaceCapabilities2EXT;
pub const DisplayPowerInfoEXT = vk.VkDisplayPowerInfoEXT;
pub const DeviceEventInfoEXT = vk.VkDeviceEventInfoEXT;
pub const DisplayEventInfoEXT = vk.VkDisplayEventInfoEXT;
pub const SwapchainCounterCreateInfoEXT = vk.VkSwapchainCounterCreateInfoEXT;
pub const RefreshCycleDurationGOOGLE = vk.VkRefreshCycleDurationGOOGLE;
pub const PastPresentationTimingGOOGLE = vk.VkPastPresentationTimingGOOGLE;
pub const PresentTimeGOOGLE = vk.VkPresentTimeGOOGLE;
pub const PresentTimesInfoGOOGLE = vk.VkPresentTimesInfoGOOGLE;
pub const PhysicalDeviceMultiviewPerViewAttributesPropertiesNVX = vk.VkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX;
pub const MultiviewPerViewAttributesInfoNVX = vk.VkMultiviewPerViewAttributesInfoNVX;
pub const ViewportSwizzleNV = vk.VkViewportSwizzleNV;
pub const PipelineViewportSwizzleStateCreateInfoNV = vk.VkPipelineViewportSwizzleStateCreateInfoNV;
pub const PhysicalDeviceDiscardRectanglePropertiesEXT = vk.VkPhysicalDeviceDiscardRectanglePropertiesEXT;
pub const PipelineDiscardRectangleStateCreateInfoEXT = vk.VkPipelineDiscardRectangleStateCreateInfoEXT;
pub const PhysicalDeviceConservativeRasterizationPropertiesEXT = vk.VkPhysicalDeviceConservativeRasterizationPropertiesEXT;
pub const PipelineRasterizationConservativeStateCreateInfoEXT = vk.VkPipelineRasterizationConservativeStateCreateInfoEXT;
pub const PhysicalDeviceDepthClipEnableFeaturesEXT = vk.VkPhysicalDeviceDepthClipEnableFeaturesEXT;
pub const PipelineRasterizationDepthClipStateCreateInfoEXT = vk.VkPipelineRasterizationDepthClipStateCreateInfoEXT;
pub const XYColorEXT = vk.VkXYColorEXT;
pub const HdrMetadataEXT = vk.VkHdrMetadataEXT;
pub const PhysicalDeviceRelaxedLineRasterizationFeaturesIMG = vk.VkPhysicalDeviceRelaxedLineRasterizationFeaturesIMG;
pub const DebugUtilsMessengerEXT = vk.VkDebugUtilsMessengerEXT;
pub const DebugUtilsLabelEXT = vk.VkDebugUtilsLabelEXT;
pub const DebugUtilsObjectNameInfoEXT = vk.VkDebugUtilsObjectNameInfoEXT;
pub const DebugUtilsMessengerCallbackDataEXT = vk.VkDebugUtilsMessengerCallbackDataEXT;
pub const DebugUtilsMessengerCreateInfoEXT = vk.VkDebugUtilsMessengerCreateInfoEXT;
pub const DebugUtilsObjectTagInfoEXT = vk.VkDebugUtilsObjectTagInfoEXT;
pub const AttachmentSampleCountInfoAMD = vk.VkAttachmentSampleCountInfoAMD;
pub const SampleLocationEXT = vk.VkSampleLocationEXT;
pub const SampleLocationsInfoEXT = vk.VkSampleLocationsInfoEXT;
pub const AttachmentSampleLocationsEXT = vk.VkAttachmentSampleLocationsEXT;
pub const SubpassSampleLocationsEXT = vk.VkSubpassSampleLocationsEXT;
pub const RenderPassSampleLocationsBeginInfoEXT = vk.VkRenderPassSampleLocationsBeginInfoEXT;
pub const PipelineSampleLocationsStateCreateInfoEXT = vk.VkPipelineSampleLocationsStateCreateInfoEXT;
pub const PhysicalDeviceSampleLocationsPropertiesEXT = vk.VkPhysicalDeviceSampleLocationsPropertiesEXT;
pub const MultisamplePropertiesEXT = vk.VkMultisamplePropertiesEXT;
pub const PhysicalDeviceBlendOperationAdvancedFeaturesEXT = vk.VkPhysicalDeviceBlendOperationAdvancedFeaturesEXT;
pub const PhysicalDeviceBlendOperationAdvancedPropertiesEXT = vk.VkPhysicalDeviceBlendOperationAdvancedPropertiesEXT;
pub const PipelineColorBlendAdvancedStateCreateInfoEXT = vk.VkPipelineColorBlendAdvancedStateCreateInfoEXT;
pub const PipelineCoverageToColorStateCreateInfoNV = vk.VkPipelineCoverageToColorStateCreateInfoNV;
pub const PipelineCoverageModulationStateCreateInfoNV = vk.VkPipelineCoverageModulationStateCreateInfoNV;
pub const PhysicalDeviceShaderSMBuiltinsPropertiesNV = vk.VkPhysicalDeviceShaderSMBuiltinsPropertiesNV;
pub const PhysicalDeviceShaderSMBuiltinsFeaturesNV = vk.VkPhysicalDeviceShaderSMBuiltinsFeaturesNV;
pub const DrmFormatModifierPropertiesEXT = vk.VkDrmFormatModifierPropertiesEXT;
pub const DrmFormatModifierPropertiesListEXT = vk.VkDrmFormatModifierPropertiesListEXT;
pub const PhysicalDeviceImageDrmFormatModifierInfoEXT = vk.VkPhysicalDeviceImageDrmFormatModifierInfoEXT;
pub const ImageDrmFormatModifierListCreateInfoEXT = vk.VkImageDrmFormatModifierListCreateInfoEXT;
pub const ImageDrmFormatModifierExplicitCreateInfoEXT = vk.VkImageDrmFormatModifierExplicitCreateInfoEXT;
pub const ImageDrmFormatModifierPropertiesEXT = vk.VkImageDrmFormatModifierPropertiesEXT;
pub const DrmFormatModifierProperties2EXT = vk.VkDrmFormatModifierProperties2EXT;
pub const DrmFormatModifierPropertiesList2EXT = vk.VkDrmFormatModifierPropertiesList2EXT;
pub const ValidationCacheEXT = vk.VkValidationCacheEXT;
pub const ValidationCacheCreateInfoEXT = vk.VkValidationCacheCreateInfoEXT;
pub const ShaderModuleValidationCacheCreateInfoEXT = vk.VkShaderModuleValidationCacheCreateInfoEXT;
pub const ShadingRatePaletteNV = vk.VkShadingRatePaletteNV;
pub const PipelineViewportShadingRateImageStateCreateInfoNV = vk.VkPipelineViewportShadingRateImageStateCreateInfoNV;
pub const PhysicalDeviceShadingRateImageFeaturesNV = vk.VkPhysicalDeviceShadingRateImageFeaturesNV;
pub const PhysicalDeviceShadingRateImagePropertiesNV = vk.VkPhysicalDeviceShadingRateImagePropertiesNV;
pub const CoarseSampleLocationNV = vk.VkCoarseSampleLocationNV;
pub const CoarseSampleOrderCustomNV = vk.VkCoarseSampleOrderCustomNV;
pub const PipelineViewportCoarseSampleOrderStateCreateInfoNV = vk.VkPipelineViewportCoarseSampleOrderStateCreateInfoNV;
pub const AccelerationStructureNV = vk.VkAccelerationStructureNV;
pub const RayTracingShaderGroupCreateInfoNV = vk.VkRayTracingShaderGroupCreateInfoNV;
pub const RayTracingPipelineCreateInfoNV = vk.VkRayTracingPipelineCreateInfoNV;
pub const GeometryTrianglesNV = vk.VkGeometryTrianglesNV;
pub const GeometryAABBNV = vk.VkGeometryAABBNV;
pub const GeometryDataNV = vk.VkGeometryDataNV;
pub const GeometryNV = vk.VkGeometryNV;
pub const AccelerationStructureInfoNV = vk.VkAccelerationStructureInfoNV;
pub const AccelerationStructureCreateInfoNV = vk.VkAccelerationStructureCreateInfoNV;
pub const BindAccelerationStructureMemoryInfoNV = vk.VkBindAccelerationStructureMemoryInfoNV;
pub const WriteDescriptorSetAccelerationStructureNV = vk.VkWriteDescriptorSetAccelerationStructureNV;
pub const AccelerationStructureMemoryRequirementsInfoNV = vk.VkAccelerationStructureMemoryRequirementsInfoNV;
pub const PhysicalDeviceRayTracingPropertiesNV = vk.VkPhysicalDeviceRayTracingPropertiesNV;
pub const TransformMatrixKHR = vk.VkTransformMatrixKHR;
pub const AabbPositionsKHR = vk.VkAabbPositionsKHR;
pub const AccelerationStructureInstanceKHR = vk.VkAccelerationStructureInstanceKHR;
pub const PhysicalDeviceRepresentativeFragmentTestFeaturesNV = vk.VkPhysicalDeviceRepresentativeFragmentTestFeaturesNV;
pub const PipelineRepresentativeFragmentTestStateCreateInfoNV = vk.VkPipelineRepresentativeFragmentTestStateCreateInfoNV;
pub const PhysicalDeviceImageViewImageFormatInfoEXT = vk.VkPhysicalDeviceImageViewImageFormatInfoEXT;
pub const FilterCubicImageViewImageFormatPropertiesEXT = vk.VkFilterCubicImageViewImageFormatPropertiesEXT;
pub const ImportMemoryHostPointerInfoEXT = vk.VkImportMemoryHostPointerInfoEXT;
pub const MemoryHostPointerPropertiesEXT = vk.VkMemoryHostPointerPropertiesEXT;
pub const PhysicalDeviceExternalMemoryHostPropertiesEXT = vk.VkPhysicalDeviceExternalMemoryHostPropertiesEXT;
pub const PipelineCompilerControlCreateInfoAMD = vk.VkPipelineCompilerControlCreateInfoAMD;
pub const PhysicalDeviceShaderCorePropertiesAMD = vk.VkPhysicalDeviceShaderCorePropertiesAMD;
pub const DeviceMemoryOverallocationCreateInfoAMD = vk.VkDeviceMemoryOverallocationCreateInfoAMD;
pub const PhysicalDeviceVertexAttributeDivisorPropertiesEXT = vk.VkPhysicalDeviceVertexAttributeDivisorPropertiesEXT;
pub const PhysicalDeviceMeshShaderFeaturesNV = vk.VkPhysicalDeviceMeshShaderFeaturesNV;
pub const PhysicalDeviceMeshShaderPropertiesNV = vk.VkPhysicalDeviceMeshShaderPropertiesNV;
pub const DrawMeshTasksIndirectCommandNV = vk.VkDrawMeshTasksIndirectCommandNV;
pub const PhysicalDeviceShaderImageFootprintFeaturesNV = vk.VkPhysicalDeviceShaderImageFootprintFeaturesNV;
pub const PipelineViewportExclusiveScissorStateCreateInfoNV = vk.VkPipelineViewportExclusiveScissorStateCreateInfoNV;
pub const PhysicalDeviceExclusiveScissorFeaturesNV = vk.VkPhysicalDeviceExclusiveScissorFeaturesNV;
pub const QueueFamilyCheckpointPropertiesNV = vk.VkQueueFamilyCheckpointPropertiesNV;
pub const CheckpointDataNV = vk.VkCheckpointDataNV;
pub const QueueFamilyCheckpointProperties2NV = vk.VkQueueFamilyCheckpointProperties2NV;
pub const CheckpointData2NV = vk.VkCheckpointData2NV;
pub const PhysicalDeviceShaderIntegerFunctions2FeaturesINTEL = vk.VkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL;
pub const PerformanceConfigurationINTEL = vk.VkPerformanceConfigurationINTEL;
pub const PerformanceValueINTEL = vk.VkPerformanceValueINTEL;
pub const InitializePerformanceApiInfoINTEL = vk.VkInitializePerformanceApiInfoINTEL;
pub const QueryPoolPerformanceQueryCreateInfoINTEL = vk.VkQueryPoolPerformanceQueryCreateInfoINTEL;
pub const PerformanceMarkerInfoINTEL = vk.VkPerformanceMarkerInfoINTEL;
pub const PerformanceStreamMarkerInfoINTEL = vk.VkPerformanceStreamMarkerInfoINTEL;
pub const PerformanceOverrideInfoINTEL = vk.VkPerformanceOverrideInfoINTEL;
pub const PerformanceConfigurationAcquireInfoINTEL = vk.VkPerformanceConfigurationAcquireInfoINTEL;
pub const PhysicalDevicePCIBusInfoPropertiesEXT = vk.VkPhysicalDevicePCIBusInfoPropertiesEXT;
pub const DisplayNativeHdrSurfaceCapabilitiesAMD = vk.VkDisplayNativeHdrSurfaceCapabilitiesAMD;
pub const SwapchainDisplayNativeHdrCreateInfoAMD = vk.VkSwapchainDisplayNativeHdrCreateInfoAMD;
pub const PhysicalDeviceFragmentDensityMapFeaturesEXT = vk.VkPhysicalDeviceFragmentDensityMapFeaturesEXT;
pub const PhysicalDeviceFragmentDensityMapPropertiesEXT = vk.VkPhysicalDeviceFragmentDensityMapPropertiesEXT;
pub const RenderPassFragmentDensityMapCreateInfoEXT = vk.VkRenderPassFragmentDensityMapCreateInfoEXT;
pub const RenderingFragmentDensityMapAttachmentInfoEXT = vk.VkRenderingFragmentDensityMapAttachmentInfoEXT;
pub const PhysicalDeviceShaderCoreProperties2AMD = vk.VkPhysicalDeviceShaderCoreProperties2AMD;
pub const PhysicalDeviceCoherentMemoryFeaturesAMD = vk.VkPhysicalDeviceCoherentMemoryFeaturesAMD;
pub const PhysicalDeviceShaderImageAtomicInt64FeaturesEXT = vk.VkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT;
pub const PhysicalDeviceMemoryBudgetPropertiesEXT = vk.VkPhysicalDeviceMemoryBudgetPropertiesEXT;
pub const PhysicalDeviceMemoryPriorityFeaturesEXT = vk.VkPhysicalDeviceMemoryPriorityFeaturesEXT;
pub const MemoryPriorityAllocateInfoEXT = vk.VkMemoryPriorityAllocateInfoEXT;
pub const PhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV = vk.VkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV;
pub const PhysicalDeviceBufferDeviceAddressFeaturesEXT = vk.VkPhysicalDeviceBufferDeviceAddressFeaturesEXT;
pub const BufferDeviceAddressCreateInfoEXT = vk.VkBufferDeviceAddressCreateInfoEXT;
pub const ValidationFeaturesEXT = vk.VkValidationFeaturesEXT;
pub const CooperativeMatrixPropertiesNV = vk.VkCooperativeMatrixPropertiesNV;
pub const PhysicalDeviceCooperativeMatrixFeaturesNV = vk.VkPhysicalDeviceCooperativeMatrixFeaturesNV;
pub const PhysicalDeviceCooperativeMatrixPropertiesNV = vk.VkPhysicalDeviceCooperativeMatrixPropertiesNV;
pub const PhysicalDeviceCoverageReductionModeFeaturesNV = vk.VkPhysicalDeviceCoverageReductionModeFeaturesNV;
pub const PipelineCoverageReductionStateCreateInfoNV = vk.VkPipelineCoverageReductionStateCreateInfoNV;
pub const FramebufferMixedSamplesCombinationNV = vk.VkFramebufferMixedSamplesCombinationNV;
pub const PhysicalDeviceFragmentShaderInterlockFeaturesEXT = vk.VkPhysicalDeviceFragmentShaderInterlockFeaturesEXT;
pub const PhysicalDeviceYcbcrImageArraysFeaturesEXT = vk.VkPhysicalDeviceYcbcrImageArraysFeaturesEXT;
pub const PhysicalDeviceProvokingVertexFeaturesEXT = vk.VkPhysicalDeviceProvokingVertexFeaturesEXT;
pub const PhysicalDeviceProvokingVertexPropertiesEXT = vk.VkPhysicalDeviceProvokingVertexPropertiesEXT;
pub const PipelineRasterizationProvokingVertexStateCreateInfoEXT = vk.VkPipelineRasterizationProvokingVertexStateCreateInfoEXT;
pub const HeadlessSurfaceCreateInfoEXT = vk.VkHeadlessSurfaceCreateInfoEXT;
pub const PhysicalDeviceShaderAtomicFloatFeaturesEXT = vk.VkPhysicalDeviceShaderAtomicFloatFeaturesEXT;
pub const PhysicalDeviceExtendedDynamicStateFeaturesEXT = vk.VkPhysicalDeviceExtendedDynamicStateFeaturesEXT;
pub const PhysicalDeviceMapMemoryPlacedFeaturesEXT = vk.VkPhysicalDeviceMapMemoryPlacedFeaturesEXT;
pub const PhysicalDeviceMapMemoryPlacedPropertiesEXT = vk.VkPhysicalDeviceMapMemoryPlacedPropertiesEXT;
pub const MemoryMapPlacedInfoEXT = vk.VkMemoryMapPlacedInfoEXT;
pub const PhysicalDeviceShaderAtomicFloat2FeaturesEXT = vk.VkPhysicalDeviceShaderAtomicFloat2FeaturesEXT;
pub const SurfacePresentModeEXT = vk.VkSurfacePresentModeEXT;
pub const SurfacePresentScalingCapabilitiesEXT = vk.VkSurfacePresentScalingCapabilitiesEXT;
pub const SurfacePresentModeCompatibilityEXT = vk.VkSurfacePresentModeCompatibilityEXT;
pub const PhysicalDeviceSwapchainMaintenance1FeaturesEXT = vk.VkPhysicalDeviceSwapchainMaintenance1FeaturesEXT;
pub const SwapchainPresentFenceInfoEXT = vk.VkSwapchainPresentFenceInfoEXT;
pub const SwapchainPresentModesCreateInfoEXT = vk.VkSwapchainPresentModesCreateInfoEXT;
pub const SwapchainPresentModeInfoEXT = vk.VkSwapchainPresentModeInfoEXT;
pub const SwapchainPresentScalingCreateInfoEXT = vk.VkSwapchainPresentScalingCreateInfoEXT;
pub const ReleaseSwapchainImagesInfoEXT = vk.VkReleaseSwapchainImagesInfoEXT;
pub const IndirectCommandsLayoutNV = vk.VkIndirectCommandsLayoutNV;
pub const PhysicalDeviceDeviceGeneratedCommandsPropertiesNV = vk.VkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV;
pub const PhysicalDeviceDeviceGeneratedCommandsFeaturesNV = vk.VkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV;
pub const GraphicsShaderGroupCreateInfoNV = vk.VkGraphicsShaderGroupCreateInfoNV;
pub const GraphicsPipelineShaderGroupsCreateInfoNV = vk.VkGraphicsPipelineShaderGroupsCreateInfoNV;
pub const BindShaderGroupIndirectCommandNV = vk.VkBindShaderGroupIndirectCommandNV;
pub const BindIndexBufferIndirectCommandNV = vk.VkBindIndexBufferIndirectCommandNV;
pub const BindVertexBufferIndirectCommandNV = vk.VkBindVertexBufferIndirectCommandNV;
pub const SetStateFlagsIndirectCommandNV = vk.VkSetStateFlagsIndirectCommandNV;
pub const IndirectCommandsStreamNV = vk.VkIndirectCommandsStreamNV;
pub const IndirectCommandsLayoutTokenNV = vk.VkIndirectCommandsLayoutTokenNV;
pub const IndirectCommandsLayoutCreateInfoNV = vk.VkIndirectCommandsLayoutCreateInfoNV;
pub const GeneratedCommandsInfoNV = vk.VkGeneratedCommandsInfoNV;
pub const GeneratedCommandsMemoryRequirementsInfoNV = vk.VkGeneratedCommandsMemoryRequirementsInfoNV;
pub const PhysicalDeviceInheritedViewportScissorFeaturesNV = vk.VkPhysicalDeviceInheritedViewportScissorFeaturesNV;
pub const CommandBufferInheritanceViewportScissorInfoNV = vk.VkCommandBufferInheritanceViewportScissorInfoNV;
pub const PhysicalDeviceTexelBufferAlignmentFeaturesEXT = vk.VkPhysicalDeviceTexelBufferAlignmentFeaturesEXT;
pub const RenderPassTransformBeginInfoQCOM = vk.VkRenderPassTransformBeginInfoQCOM;
pub const CommandBufferInheritanceRenderPassTransformInfoQCOM = vk.VkCommandBufferInheritanceRenderPassTransformInfoQCOM;
pub const PhysicalDeviceDepthBiasControlFeaturesEXT = vk.VkPhysicalDeviceDepthBiasControlFeaturesEXT;
pub const DepthBiasInfoEXT = vk.VkDepthBiasInfoEXT;
pub const DepthBiasRepresentationInfoEXT = vk.VkDepthBiasRepresentationInfoEXT;
pub const PhysicalDeviceDeviceMemoryReportFeaturesEXT = vk.VkPhysicalDeviceDeviceMemoryReportFeaturesEXT;
pub const DeviceMemoryReportCallbackDataEXT = vk.VkDeviceMemoryReportCallbackDataEXT;
pub const DeviceDeviceMemoryReportCreateInfoEXT = vk.VkDeviceDeviceMemoryReportCreateInfoEXT;
pub const PhysicalDeviceRobustness2FeaturesEXT = vk.VkPhysicalDeviceRobustness2FeaturesEXT;
pub const PhysicalDeviceRobustness2PropertiesEXT = vk.VkPhysicalDeviceRobustness2PropertiesEXT;
pub const SamplerCustomBorderColorCreateInfoEXT = vk.VkSamplerCustomBorderColorCreateInfoEXT;
pub const PhysicalDeviceCustomBorderColorPropertiesEXT = vk.VkPhysicalDeviceCustomBorderColorPropertiesEXT;
pub const PhysicalDeviceCustomBorderColorFeaturesEXT = vk.VkPhysicalDeviceCustomBorderColorFeaturesEXT;
pub const PhysicalDevicePresentBarrierFeaturesNV = vk.VkPhysicalDevicePresentBarrierFeaturesNV;
pub const SurfaceCapabilitiesPresentBarrierNV = vk.VkSurfaceCapabilitiesPresentBarrierNV;
pub const SwapchainPresentBarrierCreateInfoNV = vk.VkSwapchainPresentBarrierCreateInfoNV;
pub const PhysicalDeviceDiagnosticsConfigFeaturesNV = vk.VkPhysicalDeviceDiagnosticsConfigFeaturesNV;
pub const DeviceDiagnosticsConfigCreateInfoNV = vk.VkDeviceDiagnosticsConfigCreateInfoNV;
pub const CudaModuleNV = vk.VkCudaModuleNV;
pub const CudaFunctionNV = vk.VkCudaFunctionNV;
pub const CudaModuleCreateInfoNV = vk.VkCudaModuleCreateInfoNV;
pub const CudaFunctionCreateInfoNV = vk.VkCudaFunctionCreateInfoNV;
pub const CudaLaunchInfoNV = vk.VkCudaLaunchInfoNV;
pub const PhysicalDeviceCudaKernelLaunchFeaturesNV = vk.VkPhysicalDeviceCudaKernelLaunchFeaturesNV;
pub const PhysicalDeviceCudaKernelLaunchPropertiesNV = vk.VkPhysicalDeviceCudaKernelLaunchPropertiesNV;
pub const QueryLowLatencySupportNV = vk.VkQueryLowLatencySupportNV;
pub const AccelerationStructureKHR = vk.VkAccelerationStructureKHR;
pub const PhysicalDeviceDescriptorBufferPropertiesEXT = vk.VkPhysicalDeviceDescriptorBufferPropertiesEXT;
pub const PhysicalDeviceDescriptorBufferDensityMapPropertiesEXT = vk.VkPhysicalDeviceDescriptorBufferDensityMapPropertiesEXT;
pub const PhysicalDeviceDescriptorBufferFeaturesEXT = vk.VkPhysicalDeviceDescriptorBufferFeaturesEXT;
pub const DescriptorAddressInfoEXT = vk.VkDescriptorAddressInfoEXT;
pub const DescriptorBufferBindingInfoEXT = vk.VkDescriptorBufferBindingInfoEXT;
pub const DescriptorBufferBindingPushDescriptorBufferHandleEXT = vk.VkDescriptorBufferBindingPushDescriptorBufferHandleEXT;
pub const DescriptorGetInfoEXT = vk.VkDescriptorGetInfoEXT;
pub const BufferCaptureDescriptorDataInfoEXT = vk.VkBufferCaptureDescriptorDataInfoEXT;
pub const ImageCaptureDescriptorDataInfoEXT = vk.VkImageCaptureDescriptorDataInfoEXT;
pub const ImageViewCaptureDescriptorDataInfoEXT = vk.VkImageViewCaptureDescriptorDataInfoEXT;
pub const SamplerCaptureDescriptorDataInfoEXT = vk.VkSamplerCaptureDescriptorDataInfoEXT;
pub const OpaqueCaptureDescriptorDataCreateInfoEXT = vk.VkOpaqueCaptureDescriptorDataCreateInfoEXT;
pub const AccelerationStructureCaptureDescriptorDataInfoEXT = vk.VkAccelerationStructureCaptureDescriptorDataInfoEXT;
pub const PhysicalDeviceGraphicsPipelineLibraryFeaturesEXT = vk.VkPhysicalDeviceGraphicsPipelineLibraryFeaturesEXT;
pub const PhysicalDeviceGraphicsPipelineLibraryPropertiesEXT = vk.VkPhysicalDeviceGraphicsPipelineLibraryPropertiesEXT;
pub const GraphicsPipelineLibraryCreateInfoEXT = vk.VkGraphicsPipelineLibraryCreateInfoEXT;
pub const PhysicalDeviceShaderEarlyAndLateFragmentTestsFeaturesAMD = vk.VkPhysicalDeviceShaderEarlyAndLateFragmentTestsFeaturesAMD;
pub const PhysicalDeviceFragmentShadingRateEnumsFeaturesNV = vk.VkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV;
pub const PhysicalDeviceFragmentShadingRateEnumsPropertiesNV = vk.VkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV;
pub const PipelineFragmentShadingRateEnumStateCreateInfoNV = vk.VkPipelineFragmentShadingRateEnumStateCreateInfoNV;
pub const AccelerationStructureGeometryMotionTrianglesDataNV = vk.VkAccelerationStructureGeometryMotionTrianglesDataNV;
pub const AccelerationStructureMotionInfoNV = vk.VkAccelerationStructureMotionInfoNV;
pub const AccelerationStructureMatrixMotionInstanceNV = vk.VkAccelerationStructureMatrixMotionInstanceNV;
pub const SRTDataNV = vk.VkSRTDataNV;
pub const AccelerationStructureSRTMotionInstanceNV = vk.VkAccelerationStructureSRTMotionInstanceNV;
pub const AccelerationStructureMotionInstanceNV = vk.VkAccelerationStructureMotionInstanceNV;
pub const PhysicalDeviceRayTracingMotionBlurFeaturesNV = vk.VkPhysicalDeviceRayTracingMotionBlurFeaturesNV;
pub const PhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT = vk.VkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT;
pub const PhysicalDeviceFragmentDensityMap2FeaturesEXT = vk.VkPhysicalDeviceFragmentDensityMap2FeaturesEXT;
pub const PhysicalDeviceFragmentDensityMap2PropertiesEXT = vk.VkPhysicalDeviceFragmentDensityMap2PropertiesEXT;
pub const CopyCommandTransformInfoQCOM = vk.VkCopyCommandTransformInfoQCOM;
pub const PhysicalDeviceImageCompressionControlFeaturesEXT = vk.VkPhysicalDeviceImageCompressionControlFeaturesEXT;
pub const ImageCompressionControlEXT = vk.VkImageCompressionControlEXT;
pub const ImageCompressionPropertiesEXT = vk.VkImageCompressionPropertiesEXT;
pub const PhysicalDeviceAttachmentFeedbackLoopLayoutFeaturesEXT = vk.VkPhysicalDeviceAttachmentFeedbackLoopLayoutFeaturesEXT;
pub const PhysicalDevice4444FormatsFeaturesEXT = vk.VkPhysicalDevice4444FormatsFeaturesEXT;
pub const PhysicalDeviceFaultFeaturesEXT = vk.VkPhysicalDeviceFaultFeaturesEXT;
pub const DeviceFaultCountsEXT = vk.VkDeviceFaultCountsEXT;
pub const DeviceFaultAddressInfoEXT = vk.VkDeviceFaultAddressInfoEXT;
pub const DeviceFaultVendorInfoEXT = vk.VkDeviceFaultVendorInfoEXT;
pub const DeviceFaultInfoEXT = vk.VkDeviceFaultInfoEXT;
pub const DeviceFaultVendorBinaryHeaderVersionOneEXT = vk.VkDeviceFaultVendorBinaryHeaderVersionOneEXT;
pub const PhysicalDeviceRasterizationOrderAttachmentAccessFeaturesEXT = vk.VkPhysicalDeviceRasterizationOrderAttachmentAccessFeaturesEXT;
pub const PhysicalDeviceRGBA10X6FormatsFeaturesEXT = vk.VkPhysicalDeviceRGBA10X6FormatsFeaturesEXT;
pub const PhysicalDeviceMutableDescriptorTypeFeaturesEXT = vk.VkPhysicalDeviceMutableDescriptorTypeFeaturesEXT;
pub const MutableDescriptorTypeListEXT = vk.VkMutableDescriptorTypeListEXT;
pub const MutableDescriptorTypeCreateInfoEXT = vk.VkMutableDescriptorTypeCreateInfoEXT;
pub const PhysicalDeviceVertexInputDynamicStateFeaturesEXT = vk.VkPhysicalDeviceVertexInputDynamicStateFeaturesEXT;
pub const VertexInputBindingDescription2EXT = vk.VkVertexInputBindingDescription2EXT;
pub const VertexInputAttributeDescription2EXT = vk.VkVertexInputAttributeDescription2EXT;
pub const PhysicalDeviceDrmPropertiesEXT = vk.VkPhysicalDeviceDrmPropertiesEXT;
pub const PhysicalDeviceAddressBindingReportFeaturesEXT = vk.VkPhysicalDeviceAddressBindingReportFeaturesEXT;
pub const DeviceAddressBindingCallbackDataEXT = vk.VkDeviceAddressBindingCallbackDataEXT;
pub const PhysicalDeviceDepthClipControlFeaturesEXT = vk.VkPhysicalDeviceDepthClipControlFeaturesEXT;
pub const PipelineViewportDepthClipControlCreateInfoEXT = vk.VkPipelineViewportDepthClipControlCreateInfoEXT;
pub const PhysicalDevicePrimitiveTopologyListRestartFeaturesEXT = vk.VkPhysicalDevicePrimitiveTopologyListRestartFeaturesEXT;
pub const PhysicalDevicePresentModeFifoLatestReadyFeaturesEXT = vk.VkPhysicalDevicePresentModeFifoLatestReadyFeaturesEXT;
pub const SubpassShadingPipelineCreateInfoHUAWEI = vk.VkSubpassShadingPipelineCreateInfoHUAWEI;
pub const PhysicalDeviceSubpassShadingFeaturesHUAWEI = vk.VkPhysicalDeviceSubpassShadingFeaturesHUAWEI;
pub const PhysicalDeviceSubpassShadingPropertiesHUAWEI = vk.VkPhysicalDeviceSubpassShadingPropertiesHUAWEI;
pub const PhysicalDeviceInvocationMaskFeaturesHUAWEI = vk.VkPhysicalDeviceInvocationMaskFeaturesHUAWEI;
pub const MemoryGetRemoteAddressInfoNV = vk.VkMemoryGetRemoteAddressInfoNV;
pub const PhysicalDeviceExternalMemoryRDMAFeaturesNV = vk.VkPhysicalDeviceExternalMemoryRDMAFeaturesNV;
pub const PipelinePropertiesIdentifierEXT = vk.VkPipelinePropertiesIdentifierEXT;
pub const PhysicalDevicePipelinePropertiesFeaturesEXT = vk.VkPhysicalDevicePipelinePropertiesFeaturesEXT;
pub const PhysicalDeviceFrameBoundaryFeaturesEXT = vk.VkPhysicalDeviceFrameBoundaryFeaturesEXT;
pub const FrameBoundaryEXT = vk.VkFrameBoundaryEXT;
pub const PhysicalDeviceMultisampledRenderToSingleSampledFeaturesEXT = vk.VkPhysicalDeviceMultisampledRenderToSingleSampledFeaturesEXT;
pub const SubpassResolvePerformanceQueryEXT = vk.VkSubpassResolvePerformanceQueryEXT;
pub const MultisampledRenderToSingleSampledInfoEXT = vk.VkMultisampledRenderToSingleSampledInfoEXT;
pub const PhysicalDeviceExtendedDynamicState2FeaturesEXT = vk.VkPhysicalDeviceExtendedDynamicState2FeaturesEXT;
pub const PhysicalDeviceColorWriteEnableFeaturesEXT = vk.VkPhysicalDeviceColorWriteEnableFeaturesEXT;
pub const PipelineColorWriteCreateInfoEXT = vk.VkPipelineColorWriteCreateInfoEXT;
pub const PhysicalDevicePrimitivesGeneratedQueryFeaturesEXT = vk.VkPhysicalDevicePrimitivesGeneratedQueryFeaturesEXT;
pub const PhysicalDeviceImageViewMinLodFeaturesEXT = vk.VkPhysicalDeviceImageViewMinLodFeaturesEXT;
pub const ImageViewMinLodCreateInfoEXT = vk.VkImageViewMinLodCreateInfoEXT;
pub const PhysicalDeviceMultiDrawFeaturesEXT = vk.VkPhysicalDeviceMultiDrawFeaturesEXT;
pub const PhysicalDeviceMultiDrawPropertiesEXT = vk.VkPhysicalDeviceMultiDrawPropertiesEXT;
pub const MultiDrawInfoEXT = vk.VkMultiDrawInfoEXT;
pub const MultiDrawIndexedInfoEXT = vk.VkMultiDrawIndexedInfoEXT;
pub const PhysicalDeviceImage2DViewOf3DFeaturesEXT = vk.VkPhysicalDeviceImage2DViewOf3DFeaturesEXT;
pub const PhysicalDeviceShaderTileImageFeaturesEXT = vk.VkPhysicalDeviceShaderTileImageFeaturesEXT;
pub const PhysicalDeviceShaderTileImagePropertiesEXT = vk.VkPhysicalDeviceShaderTileImagePropertiesEXT;
pub const MicromapEXT = vk.VkMicromapEXT;
pub const MicromapUsageEXT = vk.VkMicromapUsageEXT;
pub const MicromapBuildInfoEXT = vk.VkMicromapBuildInfoEXT;
pub const MicromapCreateInfoEXT = vk.VkMicromapCreateInfoEXT;
pub const PhysicalDeviceOpacityMicromapFeaturesEXT = vk.VkPhysicalDeviceOpacityMicromapFeaturesEXT;
pub const PhysicalDeviceOpacityMicromapPropertiesEXT = vk.VkPhysicalDeviceOpacityMicromapPropertiesEXT;
pub const MicromapVersionInfoEXT = vk.VkMicromapVersionInfoEXT;
pub const CopyMicromapToMemoryInfoEXT = vk.VkCopyMicromapToMemoryInfoEXT;
pub const CopyMemoryToMicromapInfoEXT = vk.VkCopyMemoryToMicromapInfoEXT;
pub const CopyMicromapInfoEXT = vk.VkCopyMicromapInfoEXT;
pub const MicromapBuildSizesInfoEXT = vk.VkMicromapBuildSizesInfoEXT;
pub const AccelerationStructureTrianglesOpacityMicromapEXT = vk.VkAccelerationStructureTrianglesOpacityMicromapEXT;
pub const MicromapTriangleEXT = vk.VkMicromapTriangleEXT;
pub const PhysicalDeviceClusterCullingShaderFeaturesHUAWEI = vk.VkPhysicalDeviceClusterCullingShaderFeaturesHUAWEI;
pub const PhysicalDeviceClusterCullingShaderPropertiesHUAWEI = vk.VkPhysicalDeviceClusterCullingShaderPropertiesHUAWEI;
pub const PhysicalDeviceClusterCullingShaderVrsFeaturesHUAWEI = vk.VkPhysicalDeviceClusterCullingShaderVrsFeaturesHUAWEI;
pub const PhysicalDeviceBorderColorSwizzleFeaturesEXT = vk.VkPhysicalDeviceBorderColorSwizzleFeaturesEXT;
pub const SamplerBorderColorComponentMappingCreateInfoEXT = vk.VkSamplerBorderColorComponentMappingCreateInfoEXT;
pub const PhysicalDevicePageableDeviceLocalMemoryFeaturesEXT = vk.VkPhysicalDevicePageableDeviceLocalMemoryFeaturesEXT;
pub const PhysicalDeviceShaderCorePropertiesARM = vk.VkPhysicalDeviceShaderCorePropertiesARM;
pub const DeviceQueueShaderCoreControlCreateInfoARM = vk.VkDeviceQueueShaderCoreControlCreateInfoARM;
pub const PhysicalDeviceSchedulingControlsFeaturesARM = vk.VkPhysicalDeviceSchedulingControlsFeaturesARM;
pub const PhysicalDeviceSchedulingControlsPropertiesARM = vk.VkPhysicalDeviceSchedulingControlsPropertiesARM;
pub const PhysicalDeviceImageSlicedViewOf3DFeaturesEXT = vk.VkPhysicalDeviceImageSlicedViewOf3DFeaturesEXT;
pub const ImageViewSlicedCreateInfoEXT = vk.VkImageViewSlicedCreateInfoEXT;
pub const PhysicalDeviceDescriptorSetHostMappingFeaturesVALVE = vk.VkPhysicalDeviceDescriptorSetHostMappingFeaturesVALVE;
pub const DescriptorSetBindingReferenceVALVE = vk.VkDescriptorSetBindingReferenceVALVE;
pub const DescriptorSetLayoutHostMappingInfoVALVE = vk.VkDescriptorSetLayoutHostMappingInfoVALVE;
pub const PhysicalDeviceNonSeamlessCubeMapFeaturesEXT = vk.VkPhysicalDeviceNonSeamlessCubeMapFeaturesEXT;
pub const PhysicalDeviceRenderPassStripedFeaturesARM = vk.VkPhysicalDeviceRenderPassStripedFeaturesARM;
pub const PhysicalDeviceRenderPassStripedPropertiesARM = vk.VkPhysicalDeviceRenderPassStripedPropertiesARM;
pub const RenderPassStripeInfoARM = vk.VkRenderPassStripeInfoARM;
pub const RenderPassStripeBeginInfoARM = vk.VkRenderPassStripeBeginInfoARM;
pub const RenderPassStripeSubmitInfoARM = vk.VkRenderPassStripeSubmitInfoARM;
pub const PhysicalDeviceFragmentDensityMapOffsetFeaturesQCOM = vk.VkPhysicalDeviceFragmentDensityMapOffsetFeaturesQCOM;
pub const PhysicalDeviceFragmentDensityMapOffsetPropertiesQCOM = vk.VkPhysicalDeviceFragmentDensityMapOffsetPropertiesQCOM;
pub const SubpassFragmentDensityMapOffsetEndInfoQCOM = vk.VkSubpassFragmentDensityMapOffsetEndInfoQCOM;
pub const CopyMemoryIndirectCommandNV = vk.VkCopyMemoryIndirectCommandNV;
pub const CopyMemoryToImageIndirectCommandNV = vk.VkCopyMemoryToImageIndirectCommandNV;
pub const PhysicalDeviceCopyMemoryIndirectFeaturesNV = vk.VkPhysicalDeviceCopyMemoryIndirectFeaturesNV;
pub const PhysicalDeviceCopyMemoryIndirectPropertiesNV = vk.VkPhysicalDeviceCopyMemoryIndirectPropertiesNV;
pub const DecompressMemoryRegionNV = vk.VkDecompressMemoryRegionNV;
pub const PhysicalDeviceMemoryDecompressionFeaturesNV = vk.VkPhysicalDeviceMemoryDecompressionFeaturesNV;
pub const PhysicalDeviceMemoryDecompressionPropertiesNV = vk.VkPhysicalDeviceMemoryDecompressionPropertiesNV;
pub const PhysicalDeviceDeviceGeneratedCommandsComputeFeaturesNV = vk.VkPhysicalDeviceDeviceGeneratedCommandsComputeFeaturesNV;
pub const ComputePipelineIndirectBufferInfoNV = vk.VkComputePipelineIndirectBufferInfoNV;
pub const PipelineIndirectDeviceAddressInfoNV = vk.VkPipelineIndirectDeviceAddressInfoNV;
pub const BindPipelineIndirectCommandNV = vk.VkBindPipelineIndirectCommandNV;
pub const PhysicalDeviceRayTracingLinearSweptSpheresFeaturesNV = vk.VkPhysicalDeviceRayTracingLinearSweptSpheresFeaturesNV;
pub const AccelerationStructureGeometryLinearSweptSpheresDataNV = vk.VkAccelerationStructureGeometryLinearSweptSpheresDataNV;
pub const AccelerationStructureGeometrySpheresDataNV = vk.VkAccelerationStructureGeometrySpheresDataNV;
pub const PhysicalDeviceLinearColorAttachmentFeaturesNV = vk.VkPhysicalDeviceLinearColorAttachmentFeaturesNV;
pub const PhysicalDeviceImageCompressionControlSwapchainFeaturesEXT = vk.VkPhysicalDeviceImageCompressionControlSwapchainFeaturesEXT;
pub const ImageViewSampleWeightCreateInfoQCOM = vk.VkImageViewSampleWeightCreateInfoQCOM;
pub const PhysicalDeviceImageProcessingFeaturesQCOM = vk.VkPhysicalDeviceImageProcessingFeaturesQCOM;
pub const PhysicalDeviceImageProcessingPropertiesQCOM = vk.VkPhysicalDeviceImageProcessingPropertiesQCOM;
pub const PhysicalDeviceNestedCommandBufferFeaturesEXT = vk.VkPhysicalDeviceNestedCommandBufferFeaturesEXT;
pub const PhysicalDeviceNestedCommandBufferPropertiesEXT = vk.VkPhysicalDeviceNestedCommandBufferPropertiesEXT;
pub const ExternalMemoryAcquireUnmodifiedEXT = vk.VkExternalMemoryAcquireUnmodifiedEXT;
pub const PhysicalDeviceExtendedDynamicState3FeaturesEXT = vk.VkPhysicalDeviceExtendedDynamicState3FeaturesEXT;
pub const PhysicalDeviceExtendedDynamicState3PropertiesEXT = vk.VkPhysicalDeviceExtendedDynamicState3PropertiesEXT;
pub const ColorBlendEquationEXT = vk.VkColorBlendEquationEXT;
pub const ColorBlendAdvancedEXT = vk.VkColorBlendAdvancedEXT;
pub const PhysicalDeviceSubpassMergeFeedbackFeaturesEXT = vk.VkPhysicalDeviceSubpassMergeFeedbackFeaturesEXT;
pub const RenderPassCreationControlEXT = vk.VkRenderPassCreationControlEXT;
pub const RenderPassCreationFeedbackInfoEXT = vk.VkRenderPassCreationFeedbackInfoEXT;
pub const RenderPassCreationFeedbackCreateInfoEXT = vk.VkRenderPassCreationFeedbackCreateInfoEXT;
pub const RenderPassSubpassFeedbackInfoEXT = vk.VkRenderPassSubpassFeedbackInfoEXT;
pub const RenderPassSubpassFeedbackCreateInfoEXT = vk.VkRenderPassSubpassFeedbackCreateInfoEXT;
pub const DirectDriverLoadingInfoLUNARG = vk.VkDirectDriverLoadingInfoLUNARG;
pub const DirectDriverLoadingListLUNARG = vk.VkDirectDriverLoadingListLUNARG;
pub const PhysicalDeviceShaderModuleIdentifierFeaturesEXT = vk.VkPhysicalDeviceShaderModuleIdentifierFeaturesEXT;
pub const PhysicalDeviceShaderModuleIdentifierPropertiesEXT = vk.VkPhysicalDeviceShaderModuleIdentifierPropertiesEXT;
pub const PipelineShaderStageModuleIdentifierCreateInfoEXT = vk.VkPipelineShaderStageModuleIdentifierCreateInfoEXT;
pub const ShaderModuleIdentifierEXT = vk.VkShaderModuleIdentifierEXT;
pub const OpticalFlowSessionNV = vk.VkOpticalFlowSessionNV;
pub const PhysicalDeviceOpticalFlowFeaturesNV = vk.VkPhysicalDeviceOpticalFlowFeaturesNV;
pub const PhysicalDeviceOpticalFlowPropertiesNV = vk.VkPhysicalDeviceOpticalFlowPropertiesNV;
pub const OpticalFlowImageFormatInfoNV = vk.VkOpticalFlowImageFormatInfoNV;
pub const OpticalFlowImageFormatPropertiesNV = vk.VkOpticalFlowImageFormatPropertiesNV;
pub const OpticalFlowSessionCreateInfoNV = vk.VkOpticalFlowSessionCreateInfoNV;
pub const OpticalFlowSessionCreatePrivateDataInfoNV = vk.VkOpticalFlowSessionCreatePrivateDataInfoNV;
pub const OpticalFlowExecuteInfoNV = vk.VkOpticalFlowExecuteInfoNV;
pub const PhysicalDeviceLegacyDitheringFeaturesEXT = vk.VkPhysicalDeviceLegacyDitheringFeaturesEXT;
pub const PhysicalDeviceAntiLagFeaturesAMD = vk.VkPhysicalDeviceAntiLagFeaturesAMD;
pub const AntiLagPresentationInfoAMD = vk.VkAntiLagPresentationInfoAMD;
pub const AntiLagDataAMD = vk.VkAntiLagDataAMD;
pub const ShaderEXT = vk.VkShaderEXT;
pub const PhysicalDeviceShaderObjectFeaturesEXT = vk.VkPhysicalDeviceShaderObjectFeaturesEXT;
pub const PhysicalDeviceShaderObjectPropertiesEXT = vk.VkPhysicalDeviceShaderObjectPropertiesEXT;
pub const ShaderCreateInfoEXT = vk.VkShaderCreateInfoEXT;
pub const DepthClampRangeEXT = vk.VkDepthClampRangeEXT;
pub const PhysicalDeviceTilePropertiesFeaturesQCOM = vk.VkPhysicalDeviceTilePropertiesFeaturesQCOM;
pub const TilePropertiesQCOM = vk.VkTilePropertiesQCOM;
pub const PhysicalDeviceAmigoProfilingFeaturesSEC = vk.VkPhysicalDeviceAmigoProfilingFeaturesSEC;
pub const AmigoProfilingSubmitInfoSEC = vk.VkAmigoProfilingSubmitInfoSEC;
pub const PhysicalDeviceMultiviewPerViewViewportsFeaturesQCOM = vk.VkPhysicalDeviceMultiviewPerViewViewportsFeaturesQCOM;
pub const PhysicalDeviceRayTracingInvocationReorderPropertiesNV = vk.VkPhysicalDeviceRayTracingInvocationReorderPropertiesNV;
pub const PhysicalDeviceRayTracingInvocationReorderFeaturesNV = vk.VkPhysicalDeviceRayTracingInvocationReorderFeaturesNV;
pub const PhysicalDeviceCooperativeVectorPropertiesNV = vk.VkPhysicalDeviceCooperativeVectorPropertiesNV;
pub const PhysicalDeviceCooperativeVectorFeaturesNV = vk.VkPhysicalDeviceCooperativeVectorFeaturesNV;
pub const CooperativeVectorPropertiesNV = vk.VkCooperativeVectorPropertiesNV;
pub const ConvertCooperativeVectorMatrixInfoNV = vk.VkConvertCooperativeVectorMatrixInfoNV;
pub const PhysicalDeviceExtendedSparseAddressSpaceFeaturesNV = vk.VkPhysicalDeviceExtendedSparseAddressSpaceFeaturesNV;
pub const PhysicalDeviceExtendedSparseAddressSpacePropertiesNV = vk.VkPhysicalDeviceExtendedSparseAddressSpacePropertiesNV;
pub const PhysicalDeviceLegacyVertexAttributesFeaturesEXT = vk.VkPhysicalDeviceLegacyVertexAttributesFeaturesEXT;
pub const PhysicalDeviceLegacyVertexAttributesPropertiesEXT = vk.VkPhysicalDeviceLegacyVertexAttributesPropertiesEXT;
pub const LayerSettingEXT = vk.VkLayerSettingEXT;
pub const LayerSettingsCreateInfoEXT = vk.VkLayerSettingsCreateInfoEXT;
pub const PhysicalDeviceShaderCoreBuiltinsFeaturesARM = vk.VkPhysicalDeviceShaderCoreBuiltinsFeaturesARM;
pub const PhysicalDeviceShaderCoreBuiltinsPropertiesARM = vk.VkPhysicalDeviceShaderCoreBuiltinsPropertiesARM;
pub const PhysicalDevicePipelineLibraryGroupHandlesFeaturesEXT = vk.VkPhysicalDevicePipelineLibraryGroupHandlesFeaturesEXT;
pub const PhysicalDeviceDynamicRenderingUnusedAttachmentsFeaturesEXT = vk.VkPhysicalDeviceDynamicRenderingUnusedAttachmentsFeaturesEXT;
pub const LatencySleepModeInfoNV = vk.VkLatencySleepModeInfoNV;
pub const LatencySleepInfoNV = vk.VkLatencySleepInfoNV;
pub const SetLatencyMarkerInfoNV = vk.VkSetLatencyMarkerInfoNV;
pub const LatencyTimingsFrameReportNV = vk.VkLatencyTimingsFrameReportNV;
pub const GetLatencyMarkerInfoNV = vk.VkGetLatencyMarkerInfoNV;
pub const LatencySubmissionPresentIdNV = vk.VkLatencySubmissionPresentIdNV;
pub const SwapchainLatencyCreateInfoNV = vk.VkSwapchainLatencyCreateInfoNV;
pub const OutOfBandQueueTypeInfoNV = vk.VkOutOfBandQueueTypeInfoNV;
pub const LatencySurfaceCapabilitiesNV = vk.VkLatencySurfaceCapabilitiesNV;
pub const PhysicalDeviceMultiviewPerViewRenderAreasFeaturesQCOM = vk.VkPhysicalDeviceMultiviewPerViewRenderAreasFeaturesQCOM;
pub const MultiviewPerViewRenderAreasRenderPassBeginInfoQCOM = vk.VkMultiviewPerViewRenderAreasRenderPassBeginInfoQCOM;
pub const PhysicalDevicePerStageDescriptorSetFeaturesNV = vk.VkPhysicalDevicePerStageDescriptorSetFeaturesNV;
pub const PhysicalDeviceImageProcessing2FeaturesQCOM = vk.VkPhysicalDeviceImageProcessing2FeaturesQCOM;
pub const PhysicalDeviceImageProcessing2PropertiesQCOM = vk.VkPhysicalDeviceImageProcessing2PropertiesQCOM;
pub const SamplerBlockMatchWindowCreateInfoQCOM = vk.VkSamplerBlockMatchWindowCreateInfoQCOM;
pub const PhysicalDeviceCubicWeightsFeaturesQCOM = vk.VkPhysicalDeviceCubicWeightsFeaturesQCOM;
pub const SamplerCubicWeightsCreateInfoQCOM = vk.VkSamplerCubicWeightsCreateInfoQCOM;
pub const BlitImageCubicWeightsInfoQCOM = vk.VkBlitImageCubicWeightsInfoQCOM;
pub const PhysicalDeviceYcbcrDegammaFeaturesQCOM = vk.VkPhysicalDeviceYcbcrDegammaFeaturesQCOM;
pub const SamplerYcbcrConversionYcbcrDegammaCreateInfoQCOM = vk.VkSamplerYcbcrConversionYcbcrDegammaCreateInfoQCOM;
pub const PhysicalDeviceCubicClampFeaturesQCOM = vk.VkPhysicalDeviceCubicClampFeaturesQCOM;
pub const PhysicalDeviceAttachmentFeedbackLoopDynamicStateFeaturesEXT = vk.VkPhysicalDeviceAttachmentFeedbackLoopDynamicStateFeaturesEXT;
pub const PhysicalDeviceLayeredDriverPropertiesMSFT = vk.VkPhysicalDeviceLayeredDriverPropertiesMSFT;
pub const PhysicalDeviceDescriptorPoolOverallocationFeaturesNV = vk.VkPhysicalDeviceDescriptorPoolOverallocationFeaturesNV;
pub const DisplaySurfaceStereoCreateInfoNV = vk.VkDisplaySurfaceStereoCreateInfoNV;
pub const DisplayModeStereoPropertiesNV = vk.VkDisplayModeStereoPropertiesNV;
pub const PhysicalDeviceRawAccessChainsFeaturesNV = vk.VkPhysicalDeviceRawAccessChainsFeaturesNV;
pub const PhysicalDeviceCommandBufferInheritanceFeaturesNV = vk.VkPhysicalDeviceCommandBufferInheritanceFeaturesNV;
pub const PhysicalDeviceShaderAtomicFloat16VectorFeaturesNV = vk.VkPhysicalDeviceShaderAtomicFloat16VectorFeaturesNV;
pub const PhysicalDeviceShaderReplicatedCompositesFeaturesEXT = vk.VkPhysicalDeviceShaderReplicatedCompositesFeaturesEXT;
pub const PhysicalDeviceRayTracingValidationFeaturesNV = vk.VkPhysicalDeviceRayTracingValidationFeaturesNV;
pub const PhysicalDeviceClusterAccelerationStructureFeaturesNV = vk.VkPhysicalDeviceClusterAccelerationStructureFeaturesNV;
pub const PhysicalDeviceClusterAccelerationStructurePropertiesNV = vk.VkPhysicalDeviceClusterAccelerationStructurePropertiesNV;
pub const ClusterAccelerationStructureClustersBottomLevelInputNV = vk.VkClusterAccelerationStructureClustersBottomLevelInputNV;
pub const ClusterAccelerationStructureTriangleClusterInputNV = vk.VkClusterAccelerationStructureTriangleClusterInputNV;
pub const ClusterAccelerationStructureMoveObjectsInputNV = vk.VkClusterAccelerationStructureMoveObjectsInputNV;
pub const ClusterAccelerationStructureInputInfoNV = vk.VkClusterAccelerationStructureInputInfoNV;
pub const StridedDeviceAddressRegionKHR = vk.VkStridedDeviceAddressRegionKHR;
pub const ClusterAccelerationStructureCommandsInfoNV = vk.VkClusterAccelerationStructureCommandsInfoNV;
pub const StridedDeviceAddressNV = vk.VkStridedDeviceAddressNV;
pub const ClusterAccelerationStructureGeometryIndexAndGeometryFlagsNV = vk.VkClusterAccelerationStructureGeometryIndexAndGeometryFlagsNV;
pub const ClusterAccelerationStructureMoveObjectsInfoNV = vk.VkClusterAccelerationStructureMoveObjectsInfoNV;
pub const ClusterAccelerationStructureBuildClustersBottomLevelInfoNV = vk.VkClusterAccelerationStructureBuildClustersBottomLevelInfoNV;
pub const ClusterAccelerationStructureBuildTriangleClusterInfoNV = vk.VkClusterAccelerationStructureBuildTriangleClusterInfoNV;
pub const ClusterAccelerationStructureBuildTriangleClusterTemplateInfoNV = vk.VkClusterAccelerationStructureBuildTriangleClusterTemplateInfoNV;
pub const ClusterAccelerationStructureInstantiateClusterInfoNV = vk.VkClusterAccelerationStructureInstantiateClusterInfoNV;
pub const AccelerationStructureBuildSizesInfoKHR = vk.VkAccelerationStructureBuildSizesInfoKHR;
pub const RayTracingPipelineClusterAccelerationStructureCreateInfoNV = vk.VkRayTracingPipelineClusterAccelerationStructureCreateInfoNV;
pub const PhysicalDevicePartitionedAccelerationStructureFeaturesNV = vk.VkPhysicalDevicePartitionedAccelerationStructureFeaturesNV;
pub const PhysicalDevicePartitionedAccelerationStructurePropertiesNV = vk.VkPhysicalDevicePartitionedAccelerationStructurePropertiesNV;
pub const PartitionedAccelerationStructureFlagsNV = vk.VkPartitionedAccelerationStructureFlagsNV;
pub const BuildPartitionedAccelerationStructureIndirectCommandNV = vk.VkBuildPartitionedAccelerationStructureIndirectCommandNV;
pub const PartitionedAccelerationStructureWriteInstanceDataNV = vk.VkPartitionedAccelerationStructureWriteInstanceDataNV;
pub const PartitionedAccelerationStructureUpdateInstanceDataNV = vk.VkPartitionedAccelerationStructureUpdateInstanceDataNV;
pub const PartitionedAccelerationStructureWritePartitionTranslationDataNV = vk.VkPartitionedAccelerationStructureWritePartitionTranslationDataNV;
pub const WriteDescriptorSetPartitionedAccelerationStructureNV = vk.VkWriteDescriptorSetPartitionedAccelerationStructureNV;
pub const PartitionedAccelerationStructureInstancesInputNV = vk.VkPartitionedAccelerationStructureInstancesInputNV;
pub const BuildPartitionedAccelerationStructureInfoNV = vk.VkBuildPartitionedAccelerationStructureInfoNV;
pub const IndirectExecutionSetEXT = vk.VkIndirectExecutionSetEXT;
pub const IndirectCommandsLayoutEXT = vk.VkIndirectCommandsLayoutEXT;
pub const PhysicalDeviceDeviceGeneratedCommandsFeaturesEXT = vk.VkPhysicalDeviceDeviceGeneratedCommandsFeaturesEXT;
pub const PhysicalDeviceDeviceGeneratedCommandsPropertiesEXT = vk.VkPhysicalDeviceDeviceGeneratedCommandsPropertiesEXT;
pub const GeneratedCommandsMemoryRequirementsInfoEXT = vk.VkGeneratedCommandsMemoryRequirementsInfoEXT;
pub const IndirectExecutionSetPipelineInfoEXT = vk.VkIndirectExecutionSetPipelineInfoEXT;
pub const IndirectExecutionSetShaderLayoutInfoEXT = vk.VkIndirectExecutionSetShaderLayoutInfoEXT;
pub const IndirectExecutionSetShaderInfoEXT = vk.VkIndirectExecutionSetShaderInfoEXT;
pub const IndirectExecutionSetCreateInfoEXT = vk.VkIndirectExecutionSetCreateInfoEXT;
pub const GeneratedCommandsInfoEXT = vk.VkGeneratedCommandsInfoEXT;
pub const WriteIndirectExecutionSetPipelineEXT = vk.VkWriteIndirectExecutionSetPipelineEXT;
pub const IndirectCommandsPushConstantTokenEXT = vk.VkIndirectCommandsPushConstantTokenEXT;
pub const IndirectCommandsVertexBufferTokenEXT = vk.VkIndirectCommandsVertexBufferTokenEXT;
pub const IndirectCommandsIndexBufferTokenEXT = vk.VkIndirectCommandsIndexBufferTokenEXT;
pub const IndirectCommandsExecutionSetTokenEXT = vk.VkIndirectCommandsExecutionSetTokenEXT;
pub const IndirectCommandsLayoutTokenEXT = vk.VkIndirectCommandsLayoutTokenEXT;
pub const IndirectCommandsLayoutCreateInfoEXT = vk.VkIndirectCommandsLayoutCreateInfoEXT;
pub const DrawIndirectCountIndirectCommandEXT = vk.VkDrawIndirectCountIndirectCommandEXT;
pub const BindVertexBufferIndirectCommandEXT = vk.VkBindVertexBufferIndirectCommandEXT;
pub const BindIndexBufferIndirectCommandEXT = vk.VkBindIndexBufferIndirectCommandEXT;
pub const GeneratedCommandsPipelineInfoEXT = vk.VkGeneratedCommandsPipelineInfoEXT;
pub const GeneratedCommandsShaderInfoEXT = vk.VkGeneratedCommandsShaderInfoEXT;
pub const WriteIndirectExecutionSetShaderEXT = vk.VkWriteIndirectExecutionSetShaderEXT;
pub const PhysicalDeviceImageAlignmentControlFeaturesMESA = vk.VkPhysicalDeviceImageAlignmentControlFeaturesMESA;
pub const PhysicalDeviceImageAlignmentControlPropertiesMESA = vk.VkPhysicalDeviceImageAlignmentControlPropertiesMESA;
pub const ImageAlignmentControlCreateInfoMESA = vk.VkImageAlignmentControlCreateInfoMESA;
pub const PhysicalDeviceDepthClampControlFeaturesEXT = vk.VkPhysicalDeviceDepthClampControlFeaturesEXT;
pub const PipelineViewportDepthClampControlCreateInfoEXT = vk.VkPipelineViewportDepthClampControlCreateInfoEXT;
pub const PhysicalDeviceHdrVividFeaturesHUAWEI = vk.VkPhysicalDeviceHdrVividFeaturesHUAWEI;
pub const HdrVividDynamicMetadataHUAWEI = vk.VkHdrVividDynamicMetadataHUAWEI;
pub const CooperativeMatrixFlexibleDimensionsPropertiesNV = vk.VkCooperativeMatrixFlexibleDimensionsPropertiesNV;
pub const PhysicalDeviceCooperativeMatrix2FeaturesNV = vk.VkPhysicalDeviceCooperativeMatrix2FeaturesNV;
pub const PhysicalDeviceCooperativeMatrix2PropertiesNV = vk.VkPhysicalDeviceCooperativeMatrix2PropertiesNV;
pub const PhysicalDevicePipelineOpacityMicromapFeaturesARM = vk.VkPhysicalDevicePipelineOpacityMicromapFeaturesARM;
pub const PhysicalDeviceVertexAttributeRobustnessFeaturesEXT = vk.VkPhysicalDeviceVertexAttributeRobustnessFeaturesEXT;
pub const SetPresentConfigNV = vk.VkSetPresentConfigNV;
pub const PhysicalDevicePresentMeteringFeaturesNV = vk.VkPhysicalDevicePresentMeteringFeaturesNV;
pub const AccelerationStructureBuildRangeInfoKHR = vk.VkAccelerationStructureBuildRangeInfoKHR;
pub const AccelerationStructureGeometryTrianglesDataKHR = vk.VkAccelerationStructureGeometryTrianglesDataKHR;
pub const AccelerationStructureGeometryAabbsDataKHR = vk.VkAccelerationStructureGeometryAabbsDataKHR;
pub const AccelerationStructureGeometryInstancesDataKHR = vk.VkAccelerationStructureGeometryInstancesDataKHR;
pub const AccelerationStructureGeometryKHR = vk.VkAccelerationStructureGeometryKHR;
pub const AccelerationStructureBuildGeometryInfoKHR = vk.VkAccelerationStructureBuildGeometryInfoKHR;
pub const AccelerationStructureCreateInfoKHR = vk.VkAccelerationStructureCreateInfoKHR;
pub const WriteDescriptorSetAccelerationStructureKHR = vk.VkWriteDescriptorSetAccelerationStructureKHR;
pub const PhysicalDeviceAccelerationStructureFeaturesKHR = vk.VkPhysicalDeviceAccelerationStructureFeaturesKHR;
pub const PhysicalDeviceAccelerationStructurePropertiesKHR = vk.VkPhysicalDeviceAccelerationStructurePropertiesKHR;
pub const AccelerationStructureDeviceAddressInfoKHR = vk.VkAccelerationStructureDeviceAddressInfoKHR;
pub const AccelerationStructureVersionInfoKHR = vk.VkAccelerationStructureVersionInfoKHR;
pub const CopyAccelerationStructureToMemoryInfoKHR = vk.VkCopyAccelerationStructureToMemoryInfoKHR;
pub const CopyMemoryToAccelerationStructureInfoKHR = vk.VkCopyMemoryToAccelerationStructureInfoKHR;
pub const CopyAccelerationStructureInfoKHR = vk.VkCopyAccelerationStructureInfoKHR;
pub const RayTracingShaderGroupCreateInfoKHR = vk.VkRayTracingShaderGroupCreateInfoKHR;
pub const RayTracingPipelineInterfaceCreateInfoKHR = vk.VkRayTracingPipelineInterfaceCreateInfoKHR;
pub const RayTracingPipelineCreateInfoKHR = vk.VkRayTracingPipelineCreateInfoKHR;
pub const PhysicalDeviceRayTracingPipelineFeaturesKHR = vk.VkPhysicalDeviceRayTracingPipelineFeaturesKHR;
pub const PhysicalDeviceRayTracingPipelinePropertiesKHR = vk.VkPhysicalDeviceRayTracingPipelinePropertiesKHR;
pub const TraceRaysIndirectCommandKHR = vk.VkTraceRaysIndirectCommandKHR;
pub const PhysicalDeviceRayQueryFeaturesKHR = vk.VkPhysicalDeviceRayQueryFeaturesKHR;
pub const PhysicalDeviceMeshShaderFeaturesEXT = vk.VkPhysicalDeviceMeshShaderFeaturesEXT;
pub const PhysicalDeviceMeshShaderPropertiesEXT = vk.VkPhysicalDeviceMeshShaderPropertiesEXT;
pub const DrawMeshTasksIndirectCommandEXT = vk.VkDrawMeshTasksIndirectCommandEXT;

// Function Wrappers
pub fn CreateInstance(pCreateInfo: ?*const vk.VkInstanceCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pInstance: ?*vk.VkInstance) Error!void {
    const result = vk.vkCreateInstance(
        pCreateInfo,
        pAllocator,
        pInstance
    );
    try check(result);
}

pub fn DestroyInstance(instance: vk.VkInstance, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyInstance(
        instance,
        pAllocator
    );
    try check(result);
}

pub fn EnumeratePhysicalDevices(instance: vk.VkInstance, pPhysicalDeviceCount: ?*u32, pPhysicalDevices: ?[*]vk.VkPhysicalDevice) Error!void {
    const result = vk.vkEnumeratePhysicalDevices(
        instance,
        pPhysicalDeviceCount,
        pPhysicalDevices
    );
    try check(result);
}

pub fn GetPhysicalDeviceFeatures(physicalDevice: vk.VkPhysicalDevice, pFeatures: ?[*]vk.VkPhysicalDeviceFeatures) Error!void {
    const result = vk.vkGetPhysicalDeviceFeatures(
        physicalDevice,
        pFeatures
    );
    try check(result);
}

pub fn GetPhysicalDeviceFormatProperties(physicalDevice: vk.VkPhysicalDevice, format: vk.VkFormat, pFormatProperties: ?[*]vk.VkFormatProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceFormatProperties(
        physicalDevice,
        format,
        pFormatProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceImageFormatProperties(physicalDevice: vk.VkPhysicalDevice, format: vk.VkFormat, _type: vk.VkImageType, tiling: vk.VkImageTiling, usage: vk.VkImageUsageFlags, flags: vk.VkImageCreateFlags, pImageFormatProperties: ?[*]vk.VkImageFormatProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceImageFormatProperties(
        physicalDevice,
        format,
        _type,
        tiling,
        usage,
        flags,
        pImageFormatProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceProperties(physicalDevice: vk.VkPhysicalDevice, pProperties: ?[*]vk.VkPhysicalDeviceProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceProperties(
        physicalDevice,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceQueueFamilyProperties(physicalDevice: vk.VkPhysicalDevice, pQueueFamilyPropertyCount: ?*u32, pQueueFamilyProperties: ?[*]vk.VkQueueFamilyProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceQueueFamilyProperties(
        physicalDevice,
        pQueueFamilyPropertyCount,
        pQueueFamilyProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceMemoryProperties(physicalDevice: vk.VkPhysicalDevice, pMemoryProperties: ?[*]vk.VkPhysicalDeviceMemoryProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceMemoryProperties(
        physicalDevice,
        pMemoryProperties
    );
    try check(result);
}

pub fn CreateDevice(physicalDevice: vk.VkPhysicalDevice, pCreateInfo: ?*const vk.VkDeviceCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pDevice: ?*vk.VkDevice) Error!void {
    const result = vk.vkCreateDevice(
        physicalDevice,
        pCreateInfo,
        pAllocator,
        pDevice
    );
    try check(result);
}

pub fn DestroyDevice(device: vk.VkDevice, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDevice(
        device,
        pAllocator
    );
    try check(result);
}

pub fn EnumerateInstanceExtensionProperties(pLayerName: ?*const u8, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkExtensionProperties) Error!void {
    const result = vk.vkEnumerateInstanceExtensionProperties(
        pLayerName,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn EnumerateDeviceExtensionProperties(physicalDevice: vk.VkPhysicalDevice, pLayerName: ?*const u8, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkExtensionProperties) Error!void {
    const result = vk.vkEnumerateDeviceExtensionProperties(
        physicalDevice,
        pLayerName,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn EnumerateInstanceLayerProperties(pPropertyCount: ?*u32, pProperties: ?[*]vk.VkLayerProperties) Error!void {
    const result = vk.vkEnumerateInstanceLayerProperties(
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn EnumerateDeviceLayerProperties(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkLayerProperties) Error!void {
    const result = vk.vkEnumerateDeviceLayerProperties(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetDeviceQueue(device: vk.VkDevice, queueFamilyIndex: u32, queueIndex: u32, pQueue: ?*vk.VkQueue) Error!void {
    const result = vk.vkGetDeviceQueue(
        device,
        queueFamilyIndex,
        queueIndex,
        pQueue
    );
    try check(result);
}

pub fn QueueSubmit(queue: vk.VkQueue, submitCount: u32, pSubmits: ?[*]const vk.VkSubmitInfo, fence: vk.VkFence) Error!void {
    const result = vk.vkQueueSubmit(
        queue,
        submitCount,
        pSubmits,
        fence
    );
    try check(result);
}

pub fn QueueWaitIdle(queue: vk.VkQueue) Error!void {
    const result = vk.vkQueueWaitIdle(
        queue
    );
    try check(result);
}

pub fn DeviceWaitIdle(device: vk.VkDevice) Error!void {
    const result = vk.vkDeviceWaitIdle(
        device
    );
    try check(result);
}

pub fn AllocateMemory(device: vk.VkDevice, pAllocateInfo: ?*const vk.VkMemoryAllocateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pMemory: ?*vk.VkDeviceMemory) Error!void {
    const result = vk.vkAllocateMemory(
        device,
        pAllocateInfo,
        pAllocator,
        pMemory
    );
    try check(result);
}

pub fn FreeMemory(device: vk.VkDevice, memory: vk.VkDeviceMemory, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkFreeMemory(
        device,
        memory,
        pAllocator
    );
    try check(result);
}

pub fn MapMemory(device: vk.VkDevice, memory: vk.VkDeviceMemory, offset: vk.VkDeviceSize, size: vk.VkDeviceSize, flags: vk.VkMemoryMapFlags, ppData: ?*void) Error!void {
    const result = vk.vkMapMemory(
        device,
        memory,
        offset,
        size,
        flags,
        ppData
    );
    try check(result);
}

pub fn UnmapMemory(device: vk.VkDevice, memory: vk.VkDeviceMemory) Error!void {
    const result = vk.vkUnmapMemory(
        device,
        memory
    );
    try check(result);
}

pub fn FlushMappedMemoryRanges(device: vk.VkDevice, memoryRangeCount: u32, pMemoryRanges: ?[*]const vk.VkMappedMemoryRange) Error!void {
    const result = vk.vkFlushMappedMemoryRanges(
        device,
        memoryRangeCount,
        pMemoryRanges
    );
    try check(result);
}

pub fn InvalidateMappedMemoryRanges(device: vk.VkDevice, memoryRangeCount: u32, pMemoryRanges: ?[*]const vk.VkMappedMemoryRange) Error!void {
    const result = vk.vkInvalidateMappedMemoryRanges(
        device,
        memoryRangeCount,
        pMemoryRanges
    );
    try check(result);
}

pub fn GetDeviceMemoryCommitment(device: vk.VkDevice, memory: vk.VkDeviceMemory, pCommittedMemoryInBytes: ?[*]vk.VkDeviceSize) Error!void {
    const result = vk.vkGetDeviceMemoryCommitment(
        device,
        memory,
        pCommittedMemoryInBytes
    );
    try check(result);
}

pub fn BindBufferMemory(device: vk.VkDevice, buffer: vk.VkBuffer, memory: vk.VkDeviceMemory, memoryOffset: vk.VkDeviceSize) Error!void {
    const result = vk.vkBindBufferMemory(
        device,
        buffer,
        memory,
        memoryOffset
    );
    try check(result);
}

pub fn BindImageMemory(device: vk.VkDevice, image: vk.VkImage, memory: vk.VkDeviceMemory, memoryOffset: vk.VkDeviceSize) Error!void {
    const result = vk.vkBindImageMemory(
        device,
        image,
        memory,
        memoryOffset
    );
    try check(result);
}

pub fn GetBufferMemoryRequirements(device: vk.VkDevice, buffer: vk.VkBuffer, pMemoryRequirements: ?[*]vk.VkMemoryRequirements) Error!void {
    const result = vk.vkGetBufferMemoryRequirements(
        device,
        buffer,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetImageMemoryRequirements(device: vk.VkDevice, image: vk.VkImage, pMemoryRequirements: ?[*]vk.VkMemoryRequirements) Error!void {
    const result = vk.vkGetImageMemoryRequirements(
        device,
        image,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetImageSparseMemoryRequirements(device: vk.VkDevice, image: vk.VkImage, pSparseMemoryRequirementCount: ?*u32, pSparseMemoryRequirements: ?[*]vk.VkSparseImageMemoryRequirements) Error!void {
    const result = vk.vkGetImageSparseMemoryRequirements(
        device,
        image,
        pSparseMemoryRequirementCount,
        pSparseMemoryRequirements
    );
    try check(result);
}

pub fn GetPhysicalDeviceSparseImageFormatProperties(physicalDevice: vk.VkPhysicalDevice, format: vk.VkFormat, _type: vk.VkImageType, samples: vk.VkSampleCountFlagBits, usage: vk.VkImageUsageFlags, tiling: vk.VkImageTiling, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkSparseImageFormatProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceSparseImageFormatProperties(
        physicalDevice,
        format,
        _type,
        samples,
        usage,
        tiling,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn QueueBindSparse(queue: vk.VkQueue, bindInfoCount: u32, pBindInfo: ?*const vk.VkBindSparseInfo, fence: vk.VkFence) Error!void {
    const result = vk.vkQueueBindSparse(
        queue,
        bindInfoCount,
        pBindInfo,
        fence
    );
    try check(result);
}

pub fn CreateFence(device: vk.VkDevice, pCreateInfo: ?*const vk.VkFenceCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pFence: ?*vk.VkFence) Error!void {
    const result = vk.vkCreateFence(
        device,
        pCreateInfo,
        pAllocator,
        pFence
    );
    try check(result);
}

pub fn DestroyFence(device: vk.VkDevice, fence: vk.VkFence, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyFence(
        device,
        fence,
        pAllocator
    );
    try check(result);
}

pub fn ResetFences(device: vk.VkDevice, fenceCount: u32, pFences: ?[*]const vk.VkFence) Error!void {
    const result = vk.vkResetFences(
        device,
        fenceCount,
        pFences
    );
    try check(result);
}

pub fn GetFenceStatus(device: vk.VkDevice, fence: vk.VkFence) Error!void {
    const result = vk.vkGetFenceStatus(
        device,
        fence
    );
    try check(result);
}

pub fn WaitForFences(device: vk.VkDevice, fenceCount: u32, pFences: ?[*]const vk.VkFence, waitAll: vk.VkBool32, timeout: vk.uint64_t) Error!void {
    const result = vk.vkWaitForFences(
        device,
        fenceCount,
        pFences,
        waitAll,
        timeout
    );
    try check(result);
}

pub fn CreateSemaphore(device: vk.VkDevice, pCreateInfo: ?*const vk.VkSemaphoreCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pSemaphore: ?*vk.VkSemaphore) Error!void {
    const result = vk.vkCreateSemaphore(
        device,
        pCreateInfo,
        pAllocator,
        pSemaphore
    );
    try check(result);
}

pub fn DestroySemaphore(device: vk.VkDevice, semaphore: vk.VkSemaphore, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroySemaphore(
        device,
        semaphore,
        pAllocator
    );
    try check(result);
}

pub fn CreateEvent(device: vk.VkDevice, pCreateInfo: ?*const vk.VkEventCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pEvent: ?*vk.VkEvent) Error!void {
    const result = vk.vkCreateEvent(
        device,
        pCreateInfo,
        pAllocator,
        pEvent
    );
    try check(result);
}

pub fn DestroyEvent(device: vk.VkDevice, event: vk.VkEvent, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyEvent(
        device,
        event,
        pAllocator
    );
    try check(result);
}

pub fn GetEventStatus(device: vk.VkDevice, event: vk.VkEvent) Error!void {
    const result = vk.vkGetEventStatus(
        device,
        event
    );
    try check(result);
}

pub fn SetEvent(device: vk.VkDevice, event: vk.VkEvent) Error!void {
    const result = vk.vkSetEvent(
        device,
        event
    );
    try check(result);
}

pub fn ResetEvent(device: vk.VkDevice, event: vk.VkEvent) Error!void {
    const result = vk.vkResetEvent(
        device,
        event
    );
    try check(result);
}

pub fn CreateQueryPool(device: vk.VkDevice, pCreateInfo: ?*const vk.VkQueryPoolCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pQueryPool: ?*vk.VkQueryPool) Error!void {
    const result = vk.vkCreateQueryPool(
        device,
        pCreateInfo,
        pAllocator,
        pQueryPool
    );
    try check(result);
}

pub fn DestroyQueryPool(device: vk.VkDevice, queryPool: vk.VkQueryPool, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyQueryPool(
        device,
        queryPool,
        pAllocator
    );
    try check(result);
}

pub fn GetQueryPoolResults(device: vk.VkDevice, queryPool: vk.VkQueryPool, firstQuery: u32, queryCount: u32, dataSize: vk.size_t, pData: ?*void, stride: vk.VkDeviceSize, flags: vk.VkQueryResultFlags) Error!void {
    const result = vk.vkGetQueryPoolResults(
        device,
        queryPool,
        firstQuery,
        queryCount,
        dataSize,
        pData,
        stride,
        flags
    );
    try check(result);
}

pub fn CreateBuffer(device: vk.VkDevice, pCreateInfo: ?*const vk.VkBufferCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pBuffer: ?*vk.VkBuffer) Error!void {
    const result = vk.vkCreateBuffer(
        device,
        pCreateInfo,
        pAllocator,
        pBuffer
    );
    try check(result);
}

pub fn DestroyBuffer(device: vk.VkDevice, buffer: vk.VkBuffer, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyBuffer(
        device,
        buffer,
        pAllocator
    );
    try check(result);
}

pub fn CreateBufferView(device: vk.VkDevice, pCreateInfo: ?*const vk.VkBufferViewCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pView: ?*vk.VkBufferView) Error!void {
    const result = vk.vkCreateBufferView(
        device,
        pCreateInfo,
        pAllocator,
        pView
    );
    try check(result);
}

pub fn DestroyBufferView(device: vk.VkDevice, bufferView: vk.VkBufferView, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyBufferView(
        device,
        bufferView,
        pAllocator
    );
    try check(result);
}

pub fn CreateImage(device: vk.VkDevice, pCreateInfo: ?*const vk.VkImageCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pImage: ?*vk.VkImage) Error!void {
    const result = vk.vkCreateImage(
        device,
        pCreateInfo,
        pAllocator,
        pImage
    );
    try check(result);
}

pub fn DestroyImage(device: vk.VkDevice, image: vk.VkImage, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyImage(
        device,
        image,
        pAllocator
    );
    try check(result);
}

pub fn GetImageSubresourceLayout(device: vk.VkDevice, image: vk.VkImage, pSubresource: ?*const vk.VkImageSubresource, pLayout: ?*vk.VkSubresourceLayout) Error!void {
    const result = vk.vkGetImageSubresourceLayout(
        device,
        image,
        pSubresource,
        pLayout
    );
    try check(result);
}

pub fn CreateImageView(device: vk.VkDevice, pCreateInfo: ?*const vk.VkImageViewCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pView: ?*vk.VkImageView) Error!void {
    const result = vk.vkCreateImageView(
        device,
        pCreateInfo,
        pAllocator,
        pView
    );
    try check(result);
}

pub fn DestroyImageView(device: vk.VkDevice, imageView: vk.VkImageView, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyImageView(
        device,
        imageView,
        pAllocator
    );
    try check(result);
}

pub fn CreateShaderModule(device: vk.VkDevice, pCreateInfo: ?*const vk.VkShaderModuleCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pShaderModule: ?*vk.VkShaderModule) Error!void {
    const result = vk.vkCreateShaderModule(
        device,
        pCreateInfo,
        pAllocator,
        pShaderModule
    );
    try check(result);
}

pub fn DestroyShaderModule(device: vk.VkDevice, shaderModule: vk.VkShaderModule, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyShaderModule(
        device,
        shaderModule,
        pAllocator
    );
    try check(result);
}

pub fn CreatePipelineCache(device: vk.VkDevice, pCreateInfo: ?*const vk.VkPipelineCacheCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pPipelineCache: ?*vk.VkPipelineCache) Error!void {
    const result = vk.vkCreatePipelineCache(
        device,
        pCreateInfo,
        pAllocator,
        pPipelineCache
    );
    try check(result);
}

pub fn DestroyPipelineCache(device: vk.VkDevice, pipelineCache: vk.VkPipelineCache, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyPipelineCache(
        device,
        pipelineCache,
        pAllocator
    );
    try check(result);
}

pub fn GetPipelineCacheData(device: vk.VkDevice, pipelineCache: vk.VkPipelineCache, pDataSize: ?*vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetPipelineCacheData(
        device,
        pipelineCache,
        pDataSize,
        pData
    );
    try check(result);
}

pub fn MergePipelineCaches(device: vk.VkDevice, dstCache: vk.VkPipelineCache, srcCacheCount: u32, pSrcCaches: ?[*]const vk.VkPipelineCache) Error!void {
    const result = vk.vkMergePipelineCaches(
        device,
        dstCache,
        srcCacheCount,
        pSrcCaches
    );
    try check(result);
}

pub fn CreateGraphicsPipelines(device: vk.VkDevice, pipelineCache: vk.VkPipelineCache, createInfoCount: u32, pCreateInfos: ?[*]const vk.VkGraphicsPipelineCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pPipelines: ?[*]vk.VkPipeline) Error!void {
    const result = vk.vkCreateGraphicsPipelines(
        device,
        pipelineCache,
        createInfoCount,
        pCreateInfos,
        pAllocator,
        pPipelines
    );
    try check(result);
}

pub fn CreateComputePipelines(device: vk.VkDevice, pipelineCache: vk.VkPipelineCache, createInfoCount: u32, pCreateInfos: ?[*]const vk.VkComputePipelineCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pPipelines: ?[*]vk.VkPipeline) Error!void {
    const result = vk.vkCreateComputePipelines(
        device,
        pipelineCache,
        createInfoCount,
        pCreateInfos,
        pAllocator,
        pPipelines
    );
    try check(result);
}

pub fn DestroyPipeline(device: vk.VkDevice, pipeline: vk.VkPipeline, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyPipeline(
        device,
        pipeline,
        pAllocator
    );
    try check(result);
}

pub fn CreatePipelineLayout(device: vk.VkDevice, pCreateInfo: ?*const vk.VkPipelineLayoutCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pPipelineLayout: ?*vk.VkPipelineLayout) Error!void {
    const result = vk.vkCreatePipelineLayout(
        device,
        pCreateInfo,
        pAllocator,
        pPipelineLayout
    );
    try check(result);
}

pub fn DestroyPipelineLayout(device: vk.VkDevice, pipelineLayout: vk.VkPipelineLayout, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyPipelineLayout(
        device,
        pipelineLayout,
        pAllocator
    );
    try check(result);
}

pub fn CreateSampler(device: vk.VkDevice, pCreateInfo: ?*const vk.VkSamplerCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pSampler: ?*vk.VkSampler) Error!void {
    const result = vk.vkCreateSampler(
        device,
        pCreateInfo,
        pAllocator,
        pSampler
    );
    try check(result);
}

pub fn DestroySampler(device: vk.VkDevice, sampler: vk.VkSampler, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroySampler(
        device,
        sampler,
        pAllocator
    );
    try check(result);
}

pub fn CreateDescriptorSetLayout(device: vk.VkDevice, pCreateInfo: ?*const vk.VkDescriptorSetLayoutCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pSetLayout: ?*vk.VkDescriptorSetLayout) Error!void {
    const result = vk.vkCreateDescriptorSetLayout(
        device,
        pCreateInfo,
        pAllocator,
        pSetLayout
    );
    try check(result);
}

pub fn DestroyDescriptorSetLayout(device: vk.VkDevice, descriptorSetLayout: vk.VkDescriptorSetLayout, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDescriptorSetLayout(
        device,
        descriptorSetLayout,
        pAllocator
    );
    try check(result);
}

pub fn CreateDescriptorPool(device: vk.VkDevice, pCreateInfo: ?*const vk.VkDescriptorPoolCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pDescriptorPool: ?*vk.VkDescriptorPool) Error!void {
    const result = vk.vkCreateDescriptorPool(
        device,
        pCreateInfo,
        pAllocator,
        pDescriptorPool
    );
    try check(result);
}

pub fn DestroyDescriptorPool(device: vk.VkDevice, descriptorPool: vk.VkDescriptorPool, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDescriptorPool(
        device,
        descriptorPool,
        pAllocator
    );
    try check(result);
}

pub fn ResetDescriptorPool(device: vk.VkDevice, descriptorPool: vk.VkDescriptorPool, flags: vk.VkDescriptorPoolResetFlags) Error!void {
    const result = vk.vkResetDescriptorPool(
        device,
        descriptorPool,
        flags
    );
    try check(result);
}

pub fn AllocateDescriptorSets(device: vk.VkDevice, pAllocateInfo: ?*const vk.VkDescriptorSetAllocateInfo, pDescriptorSets: ?[*]vk.VkDescriptorSet) Error!void {
    const result = vk.vkAllocateDescriptorSets(
        device,
        pAllocateInfo,
        pDescriptorSets
    );
    try check(result);
}

pub fn FreeDescriptorSets(device: vk.VkDevice, descriptorPool: vk.VkDescriptorPool, descriptorSetCount: u32, pDescriptorSets: ?[*]const vk.VkDescriptorSet) Error!void {
    const result = vk.vkFreeDescriptorSets(
        device,
        descriptorPool,
        descriptorSetCount,
        pDescriptorSets
    );
    try check(result);
}

pub fn UpdateDescriptorSets(device: vk.VkDevice, descriptorWriteCount: u32, pDescriptorWrites: ?[*]const vk.VkWriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: ?[*]const vk.VkCopyDescriptorSet) Error!void {
    const result = vk.vkUpdateDescriptorSets(
        device,
        descriptorWriteCount,
        pDescriptorWrites,
        descriptorCopyCount,
        pDescriptorCopies
    );
    try check(result);
}

pub fn CreateFramebuffer(device: vk.VkDevice, pCreateInfo: ?*const vk.VkFramebufferCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pFramebuffer: ?*vk.VkFramebuffer) Error!void {
    const result = vk.vkCreateFramebuffer(
        device,
        pCreateInfo,
        pAllocator,
        pFramebuffer
    );
    try check(result);
}

pub fn DestroyFramebuffer(device: vk.VkDevice, framebuffer: vk.VkFramebuffer, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyFramebuffer(
        device,
        framebuffer,
        pAllocator
    );
    try check(result);
}

pub fn CreateRenderPass(device: vk.VkDevice, pCreateInfo: ?*const vk.VkRenderPassCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pRenderPass: ?[*]vk.VkRenderPass) Error!void {
    const result = vk.vkCreateRenderPass(
        device,
        pCreateInfo,
        pAllocator,
        pRenderPass
    );
    try check(result);
}

pub fn DestroyRenderPass(device: vk.VkDevice, renderPass: vk.VkRenderPass, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyRenderPass(
        device,
        renderPass,
        pAllocator
    );
    try check(result);
}

pub fn GetRenderAreaGranularity(device: vk.VkDevice, renderPass: vk.VkRenderPass, pGranularity: ?*vk.VkExtent2D) Error!void {
    const result = vk.vkGetRenderAreaGranularity(
        device,
        renderPass,
        pGranularity
    );
    try check(result);
}

pub fn CreateCommandPool(device: vk.VkDevice, pCreateInfo: ?*const vk.VkCommandPoolCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pCommandPool: ?*vk.VkCommandPool) Error!void {
    const result = vk.vkCreateCommandPool(
        device,
        pCreateInfo,
        pAllocator,
        pCommandPool
    );
    try check(result);
}

pub fn DestroyCommandPool(device: vk.VkDevice, commandPool: vk.VkCommandPool, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyCommandPool(
        device,
        commandPool,
        pAllocator
    );
    try check(result);
}

pub fn ResetCommandPool(device: vk.VkDevice, commandPool: vk.VkCommandPool, flags: vk.VkCommandPoolResetFlags) Error!void {
    const result = vk.vkResetCommandPool(
        device,
        commandPool,
        flags
    );
    try check(result);
}

pub fn AllocateCommandBuffers(device: vk.VkDevice, pAllocateInfo: ?*const vk.VkCommandBufferAllocateInfo, pCommandBuffers: ?[*]vk.VkCommandBuffer) Error!void {
    const result = vk.vkAllocateCommandBuffers(
        device,
        pAllocateInfo,
        pCommandBuffers
    );
    try check(result);
}

pub fn FreeCommandBuffers(device: vk.VkDevice, commandPool: vk.VkCommandPool, commandBufferCount: u32, pCommandBuffers: ?[*]const vk.VkCommandBuffer) Error!void {
    const result = vk.vkFreeCommandBuffers(
        device,
        commandPool,
        commandBufferCount,
        pCommandBuffers
    );
    try check(result);
}

pub fn BeginCommandBuffer(commandBuffer: vk.VkCommandBuffer, pBeginInfo: ?*const vk.VkCommandBufferBeginInfo) Error!void {
    const result = vk.vkBeginCommandBuffer(
        commandBuffer,
        pBeginInfo
    );
    try check(result);
}

pub fn EndCommandBuffer(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkEndCommandBuffer(
        commandBuffer
    );
    try check(result);
}

pub fn ResetCommandBuffer(commandBuffer: vk.VkCommandBuffer, flags: vk.VkCommandBufferResetFlags) Error!void {
    const result = vk.vkResetCommandBuffer(
        commandBuffer,
        flags
    );
    try check(result);
}

pub fn CmdBindPipeline(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, pipeline: vk.VkPipeline) Error!void {
    const result = vk.vkCmdBindPipeline(
        commandBuffer,
        pipelineBindPoint,
        pipeline
    );
    try check(result);
}

pub fn CmdSetViewport(commandBuffer: vk.VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewports: ?[*]const vk.VkViewport) Error!void {
    const result = vk.vkCmdSetViewport(
        commandBuffer,
        firstViewport,
        viewportCount,
        pViewports
    );
    try check(result);
}

pub fn CmdSetScissor(commandBuffer: vk.VkCommandBuffer, firstScissor: u32, scissorCount: u32, pScissors: ?[*]const vk.VkRect2D) Error!void {
    const result = vk.vkCmdSetScissor(
        commandBuffer,
        firstScissor,
        scissorCount,
        pScissors
    );
    try check(result);
}

pub fn CmdSetLineWidth(commandBuffer: vk.VkCommandBuffer, lineWidth: f32) Error!void {
    const result = vk.vkCmdSetLineWidth(
        commandBuffer,
        lineWidth
    );
    try check(result);
}

pub fn CmdSetDepthBias(commandBuffer: vk.VkCommandBuffer, depthBiasConstantFactor: f32, depthBiasClamp: f32, depthBiasSlopeFactor: f32) Error!void {
    const result = vk.vkCmdSetDepthBias(
        commandBuffer,
        depthBiasConstantFactor,
        depthBiasClamp,
        depthBiasSlopeFactor
    );
    try check(result);
}

pub fn CmdSetBlendConstants(commandBuffer: vk.VkCommandBuffer, blendConstants: f32) Error!void {
    const result = vk.vkCmdSetBlendConstants(
        commandBuffer,
        blendConstants
    );
    try check(result);
}

pub fn CmdSetDepthBounds(commandBuffer: vk.VkCommandBuffer, minDepthBounds: f32, maxDepthBounds: f32) Error!void {
    const result = vk.vkCmdSetDepthBounds(
        commandBuffer,
        minDepthBounds,
        maxDepthBounds
    );
    try check(result);
}

pub fn CmdSetStencilCompareMask(commandBuffer: vk.VkCommandBuffer, faceMask: vk.VkStencilFaceFlags, compareMask: u32) Error!void {
    const result = vk.vkCmdSetStencilCompareMask(
        commandBuffer,
        faceMask,
        compareMask
    );
    try check(result);
}

pub fn CmdSetStencilWriteMask(commandBuffer: vk.VkCommandBuffer, faceMask: vk.VkStencilFaceFlags, writeMask: u32) Error!void {
    const result = vk.vkCmdSetStencilWriteMask(
        commandBuffer,
        faceMask,
        writeMask
    );
    try check(result);
}

pub fn CmdSetStencilReference(commandBuffer: vk.VkCommandBuffer, faceMask: vk.VkStencilFaceFlags, reference: u32) Error!void {
    const result = vk.vkCmdSetStencilReference(
        commandBuffer,
        faceMask,
        reference
    );
    try check(result);
}

pub fn CmdBindDescriptorSets(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, layout: vk.VkPipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: ?[*]const vk.VkDescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: ?[*]const u32) Error!void {
    const result = vk.vkCmdBindDescriptorSets(
        commandBuffer,
        pipelineBindPoint,
        layout,
        firstSet,
        descriptorSetCount,
        pDescriptorSets,
        dynamicOffsetCount,
        pDynamicOffsets
    );
    try check(result);
}

pub fn CmdBindIndexBuffer(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, indexType: vk.VkIndexType) Error!void {
    const result = vk.vkCmdBindIndexBuffer(
        commandBuffer,
        buffer,
        offset,
        indexType
    );
    try check(result);
}

pub fn CmdBindVertexBuffers(commandBuffer: vk.VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: ?[*]const vk.VkBuffer, pOffsets: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdBindVertexBuffers(
        commandBuffer,
        firstBinding,
        bindingCount,
        pBuffers,
        pOffsets
    );
    try check(result);
}

pub fn CmdDraw(commandBuffer: vk.VkCommandBuffer, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) Error!void {
    const result = vk.vkCmdDraw(
        commandBuffer,
        vertexCount,
        instanceCount,
        firstVertex,
        firstInstance
    );
    try check(result);
}

pub fn CmdDrawIndexed(commandBuffer: vk.VkCommandBuffer, indexCount: u32, instanceCount: u32, firstIndex: u32, vertexOffset: i32, firstInstance: u32) Error!void {
    const result = vk.vkCmdDrawIndexed(
        commandBuffer,
        indexCount,
        instanceCount,
        firstIndex,
        vertexOffset,
        firstInstance
    );
    try check(result);
}

pub fn CmdDrawIndirect(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, drawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndirect(
        commandBuffer,
        buffer,
        offset,
        drawCount,
        stride
    );
    try check(result);
}

pub fn CmdDrawIndexedIndirect(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, drawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndexedIndirect(
        commandBuffer,
        buffer,
        offset,
        drawCount,
        stride
    );
    try check(result);
}

pub fn CmdDispatch(commandBuffer: vk.VkCommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32) Error!void {
    const result = vk.vkCmdDispatch(
        commandBuffer,
        groupCountX,
        groupCountY,
        groupCountZ
    );
    try check(result);
}

pub fn CmdDispatchIndirect(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdDispatchIndirect(
        commandBuffer,
        buffer,
        offset
    );
    try check(result);
}

pub fn CmdCopyBuffer(commandBuffer: vk.VkCommandBuffer, srcBuffer: vk.VkBuffer, dstBuffer: vk.VkBuffer, regionCount: u32, pRegions: ?[*]const vk.VkBufferCopy) Error!void {
    const result = vk.vkCmdCopyBuffer(
        commandBuffer,
        srcBuffer,
        dstBuffer,
        regionCount,
        pRegions
    );
    try check(result);
}

pub fn CmdCopyImage(commandBuffer: vk.VkCommandBuffer, srcImage: vk.VkImage, srcImageLayout: vk.VkImageLayout, dstImage: vk.VkImage, dstImageLayout: vk.VkImageLayout, regionCount: u32, pRegions: ?[*]const vk.VkImageCopy) Error!void {
    const result = vk.vkCmdCopyImage(
        commandBuffer,
        srcImage,
        srcImageLayout,
        dstImage,
        dstImageLayout,
        regionCount,
        pRegions
    );
    try check(result);
}

pub fn CmdBlitImage(commandBuffer: vk.VkCommandBuffer, srcImage: vk.VkImage, srcImageLayout: vk.VkImageLayout, dstImage: vk.VkImage, dstImageLayout: vk.VkImageLayout, regionCount: u32, pRegions: ?[*]const vk.VkImageBlit, filter: vk.VkFilter) Error!void {
    const result = vk.vkCmdBlitImage(
        commandBuffer,
        srcImage,
        srcImageLayout,
        dstImage,
        dstImageLayout,
        regionCount,
        pRegions,
        filter
    );
    try check(result);
}

pub fn CmdCopyBufferToImage(commandBuffer: vk.VkCommandBuffer, srcBuffer: vk.VkBuffer, dstImage: vk.VkImage, dstImageLayout: vk.VkImageLayout, regionCount: u32, pRegions: ?[*]const vk.VkBufferImageCopy) Error!void {
    const result = vk.vkCmdCopyBufferToImage(
        commandBuffer,
        srcBuffer,
        dstImage,
        dstImageLayout,
        regionCount,
        pRegions
    );
    try check(result);
}

pub fn CmdCopyImageToBuffer(commandBuffer: vk.VkCommandBuffer, srcImage: vk.VkImage, srcImageLayout: vk.VkImageLayout, dstBuffer: vk.VkBuffer, regionCount: u32, pRegions: ?[*]const vk.VkBufferImageCopy) Error!void {
    const result = vk.vkCmdCopyImageToBuffer(
        commandBuffer,
        srcImage,
        srcImageLayout,
        dstBuffer,
        regionCount,
        pRegions
    );
    try check(result);
}

pub fn CmdUpdateBuffer(commandBuffer: vk.VkCommandBuffer, dstBuffer: vk.VkBuffer, dstOffset: vk.VkDeviceSize, dataSize: vk.VkDeviceSize, pData: ?*const void) Error!void {
    const result = vk.vkCmdUpdateBuffer(
        commandBuffer,
        dstBuffer,
        dstOffset,
        dataSize,
        pData
    );
    try check(result);
}

pub fn CmdFillBuffer(commandBuffer: vk.VkCommandBuffer, dstBuffer: vk.VkBuffer, dstOffset: vk.VkDeviceSize, size: vk.VkDeviceSize, data: u32) Error!void {
    const result = vk.vkCmdFillBuffer(
        commandBuffer,
        dstBuffer,
        dstOffset,
        size,
        data
    );
    try check(result);
}

pub fn CmdClearColorImage(commandBuffer: vk.VkCommandBuffer, image: vk.VkImage, imageLayout: vk.VkImageLayout, pColor: ?*const vk.VkClearColorValue, rangeCount: u32, pRanges: ?[*]const vk.VkImageSubresourceRange) Error!void {
    const result = vk.vkCmdClearColorImage(
        commandBuffer,
        image,
        imageLayout,
        pColor,
        rangeCount,
        pRanges
    );
    try check(result);
}

pub fn CmdClearDepthStencilImage(commandBuffer: vk.VkCommandBuffer, image: vk.VkImage, imageLayout: vk.VkImageLayout, pDepthStencil: ?*const vk.VkClearDepthStencilValue, rangeCount: u32, pRanges: ?[*]const vk.VkImageSubresourceRange) Error!void {
    const result = vk.vkCmdClearDepthStencilImage(
        commandBuffer,
        image,
        imageLayout,
        pDepthStencil,
        rangeCount,
        pRanges
    );
    try check(result);
}

pub fn CmdClearAttachments(commandBuffer: vk.VkCommandBuffer, attachmentCount: u32, pAttachments: ?[*]const vk.VkClearAttachment, rectCount: u32, pRects: ?[*]const vk.VkClearRect) Error!void {
    const result = vk.vkCmdClearAttachments(
        commandBuffer,
        attachmentCount,
        pAttachments,
        rectCount,
        pRects
    );
    try check(result);
}

pub fn CmdResolveImage(commandBuffer: vk.VkCommandBuffer, srcImage: vk.VkImage, srcImageLayout: vk.VkImageLayout, dstImage: vk.VkImage, dstImageLayout: vk.VkImageLayout, regionCount: u32, pRegions: ?[*]const vk.VkImageResolve) Error!void {
    const result = vk.vkCmdResolveImage(
        commandBuffer,
        srcImage,
        srcImageLayout,
        dstImage,
        dstImageLayout,
        regionCount,
        pRegions
    );
    try check(result);
}

pub fn CmdSetEvent(commandBuffer: vk.VkCommandBuffer, event: vk.VkEvent, stageMask: vk.VkPipelineStageFlags) Error!void {
    const result = vk.vkCmdSetEvent(
        commandBuffer,
        event,
        stageMask
    );
    try check(result);
}

pub fn CmdResetEvent(commandBuffer: vk.VkCommandBuffer, event: vk.VkEvent, stageMask: vk.VkPipelineStageFlags) Error!void {
    const result = vk.vkCmdResetEvent(
        commandBuffer,
        event,
        stageMask
    );
    try check(result);
}

pub fn CmdWaitEvents(commandBuffer: vk.VkCommandBuffer, eventCount: u32, pEvents: ?[*]const vk.VkEvent, srcStageMask: vk.VkPipelineStageFlags, dstStageMask: vk.VkPipelineStageFlags, memoryBarrierCount: u32, pMemoryBarriers: ?[*]const vk.VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: ?[*]const vk.VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: ?[*]const vk.VkImageMemoryBarrier) Error!void {
    const result = vk.vkCmdWaitEvents(
        commandBuffer,
        eventCount,
        pEvents,
        srcStageMask,
        dstStageMask,
        memoryBarrierCount,
        pMemoryBarriers,
        bufferMemoryBarrierCount,
        pBufferMemoryBarriers,
        imageMemoryBarrierCount,
        pImageMemoryBarriers
    );
    try check(result);
}

pub fn CmdPipelineBarrier(commandBuffer: vk.VkCommandBuffer, srcStageMask: vk.VkPipelineStageFlags, dstStageMask: vk.VkPipelineStageFlags, dependencyFlags: vk.VkDependencyFlags, memoryBarrierCount: u32, pMemoryBarriers: ?[*]const vk.VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: ?[*]const vk.VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: ?[*]const vk.VkImageMemoryBarrier) Error!void {
    const result = vk.vkCmdPipelineBarrier(
        commandBuffer,
        srcStageMask,
        dstStageMask,
        dependencyFlags,
        memoryBarrierCount,
        pMemoryBarriers,
        bufferMemoryBarrierCount,
        pBufferMemoryBarriers,
        imageMemoryBarrierCount,
        pImageMemoryBarriers
    );
    try check(result);
}

pub fn CmdBeginQuery(commandBuffer: vk.VkCommandBuffer, queryPool: vk.VkQueryPool, query: u32, flags: vk.VkQueryControlFlags) Error!void {
    const result = vk.vkCmdBeginQuery(
        commandBuffer,
        queryPool,
        query,
        flags
    );
    try check(result);
}

pub fn CmdEndQuery(commandBuffer: vk.VkCommandBuffer, queryPool: vk.VkQueryPool, query: u32) Error!void {
    const result = vk.vkCmdEndQuery(
        commandBuffer,
        queryPool,
        query
    );
    try check(result);
}

pub fn CmdResetQueryPool(commandBuffer: vk.VkCommandBuffer, queryPool: vk.VkQueryPool, firstQuery: u32, queryCount: u32) Error!void {
    const result = vk.vkCmdResetQueryPool(
        commandBuffer,
        queryPool,
        firstQuery,
        queryCount
    );
    try check(result);
}

pub fn CmdWriteTimestamp(commandBuffer: vk.VkCommandBuffer, pipelineStage: vk.VkPipelineStageFlagBits, queryPool: vk.VkQueryPool, query: u32) Error!void {
    const result = vk.vkCmdWriteTimestamp(
        commandBuffer,
        pipelineStage,
        queryPool,
        query
    );
    try check(result);
}

pub fn CmdCopyQueryPoolResults(commandBuffer: vk.VkCommandBuffer, queryPool: vk.VkQueryPool, firstQuery: u32, queryCount: u32, dstBuffer: vk.VkBuffer, dstOffset: vk.VkDeviceSize, stride: vk.VkDeviceSize, flags: vk.VkQueryResultFlags) Error!void {
    const result = vk.vkCmdCopyQueryPoolResults(
        commandBuffer,
        queryPool,
        firstQuery,
        queryCount,
        dstBuffer,
        dstOffset,
        stride,
        flags
    );
    try check(result);
}

pub fn CmdPushConstants(commandBuffer: vk.VkCommandBuffer, layout: vk.VkPipelineLayout, stageFlags: vk.VkShaderStageFlags, offset: u32, size: u32, pValues: ?[*]const void) Error!void {
    const result = vk.vkCmdPushConstants(
        commandBuffer,
        layout,
        stageFlags,
        offset,
        size,
        pValues
    );
    try check(result);
}

pub fn CmdBeginRenderPass(commandBuffer: vk.VkCommandBuffer, pRenderPassBegin: ?*const vk.VkRenderPassBeginInfo, contents: vk.VkSubpassContents) Error!void {
    const result = vk.vkCmdBeginRenderPass(
        commandBuffer,
        pRenderPassBegin,
        contents
    );
    try check(result);
}

pub fn CmdNextSubpass(commandBuffer: vk.VkCommandBuffer, contents: vk.VkSubpassContents) Error!void {
    const result = vk.vkCmdNextSubpass(
        commandBuffer,
        contents
    );
    try check(result);
}

pub fn CmdEndRenderPass(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdEndRenderPass(
        commandBuffer
    );
    try check(result);
}

pub fn CmdExecuteCommands(commandBuffer: vk.VkCommandBuffer, commandBufferCount: u32, pCommandBuffers: ?[*]const vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdExecuteCommands(
        commandBuffer,
        commandBufferCount,
        pCommandBuffers
    );
    try check(result);
}

pub fn EnumerateInstanceVersion(pApiVersion: ?*u32) Error!void {
    const result = vk.vkEnumerateInstanceVersion(
        pApiVersion
    );
    try check(result);
}

pub fn BindBufferMemory2(device: vk.VkDevice, bindInfoCount: u32, pBindInfos: ?[*]const vk.VkBindBufferMemoryInfo) Error!void {
    const result = vk.vkBindBufferMemory2(
        device,
        bindInfoCount,
        pBindInfos
    );
    try check(result);
}

pub fn BindImageMemory2(device: vk.VkDevice, bindInfoCount: u32, pBindInfos: ?[*]const vk.VkBindImageMemoryInfo) Error!void {
    const result = vk.vkBindImageMemory2(
        device,
        bindInfoCount,
        pBindInfos
    );
    try check(result);
}

pub fn GetDeviceGroupPeerMemoryFeatures(device: vk.VkDevice, heapIndex: u32, localDeviceIndex: u32, remoteDeviceIndex: u32, pPeerMemoryFeatures: ?[*]vk.VkPeerMemoryFeatureFlags) Error!void {
    const result = vk.vkGetDeviceGroupPeerMemoryFeatures(
        device,
        heapIndex,
        localDeviceIndex,
        remoteDeviceIndex,
        pPeerMemoryFeatures
    );
    try check(result);
}

pub fn CmdSetDeviceMask(commandBuffer: vk.VkCommandBuffer, deviceMask: u32) Error!void {
    const result = vk.vkCmdSetDeviceMask(
        commandBuffer,
        deviceMask
    );
    try check(result);
}

pub fn CmdDispatchBase(commandBuffer: vk.VkCommandBuffer, baseGroupX: u32, baseGroupY: u32, baseGroupZ: u32, groupCountX: u32, groupCountY: u32, groupCountZ: u32) Error!void {
    const result = vk.vkCmdDispatchBase(
        commandBuffer,
        baseGroupX,
        baseGroupY,
        baseGroupZ,
        groupCountX,
        groupCountY,
        groupCountZ
    );
    try check(result);
}

pub fn EnumeratePhysicalDeviceGroups(instance: vk.VkInstance, pPhysicalDeviceGroupCount: ?*u32, pPhysicalDeviceGroupProperties: ?[*]vk.VkPhysicalDeviceGroupProperties) Error!void {
    const result = vk.vkEnumeratePhysicalDeviceGroups(
        instance,
        pPhysicalDeviceGroupCount,
        pPhysicalDeviceGroupProperties
    );
    try check(result);
}

pub fn GetImageMemoryRequirements2(device: vk.VkDevice, pInfo: ?*const vk.VkImageMemoryRequirementsInfo2, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetImageMemoryRequirements2(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetBufferMemoryRequirements2(device: vk.VkDevice, pInfo: ?*const vk.VkBufferMemoryRequirementsInfo2, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetBufferMemoryRequirements2(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetImageSparseMemoryRequirements2(device: vk.VkDevice, pInfo: ?*const vk.VkImageSparseMemoryRequirementsInfo2, pSparseMemoryRequirementCount: ?*u32, pSparseMemoryRequirements: ?[*]vk.VkSparseImageMemoryRequirements2) Error!void {
    const result = vk.vkGetImageSparseMemoryRequirements2(
        device,
        pInfo,
        pSparseMemoryRequirementCount,
        pSparseMemoryRequirements
    );
    try check(result);
}

pub fn GetPhysicalDeviceFeatures2(physicalDevice: vk.VkPhysicalDevice, pFeatures: ?[*]vk.VkPhysicalDeviceFeatures2) Error!void {
    const result = vk.vkGetPhysicalDeviceFeatures2(
        physicalDevice,
        pFeatures
    );
    try check(result);
}

pub fn GetPhysicalDeviceProperties2(physicalDevice: vk.VkPhysicalDevice, pProperties: ?[*]vk.VkPhysicalDeviceProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceProperties2(
        physicalDevice,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceFormatProperties2(physicalDevice: vk.VkPhysicalDevice, format: vk.VkFormat, pFormatProperties: ?[*]vk.VkFormatProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceFormatProperties2(
        physicalDevice,
        format,
        pFormatProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceImageFormatProperties2(physicalDevice: vk.VkPhysicalDevice, pImageFormatInfo: ?*const vk.VkPhysicalDeviceImageFormatInfo2, pImageFormatProperties: ?[*]vk.VkImageFormatProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceImageFormatProperties2(
        physicalDevice,
        pImageFormatInfo,
        pImageFormatProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceQueueFamilyProperties2(physicalDevice: vk.VkPhysicalDevice, pQueueFamilyPropertyCount: ?*u32, pQueueFamilyProperties: ?[*]vk.VkQueueFamilyProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceQueueFamilyProperties2(
        physicalDevice,
        pQueueFamilyPropertyCount,
        pQueueFamilyProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceMemoryProperties2(physicalDevice: vk.VkPhysicalDevice, pMemoryProperties: ?[*]vk.VkPhysicalDeviceMemoryProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceMemoryProperties2(
        physicalDevice,
        pMemoryProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceSparseImageFormatProperties2(physicalDevice: vk.VkPhysicalDevice, pFormatInfo: ?*const vk.VkPhysicalDeviceSparseImageFormatInfo2, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkSparseImageFormatProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceSparseImageFormatProperties2(
        physicalDevice,
        pFormatInfo,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn TrimCommandPool(device: vk.VkDevice, commandPool: vk.VkCommandPool, flags: vk.VkCommandPoolTrimFlags) Error!void {
    const result = vk.vkTrimCommandPool(
        device,
        commandPool,
        flags
    );
    try check(result);
}

pub fn GetDeviceQueue2(device: vk.VkDevice, pQueueInfo: ?*const vk.VkDeviceQueueInfo2, pQueue: ?*vk.VkQueue) Error!void {
    const result = vk.vkGetDeviceQueue2(
        device,
        pQueueInfo,
        pQueue
    );
    try check(result);
}

pub fn CreateSamplerYcbcrConversion(device: vk.VkDevice, pCreateInfo: ?*const vk.VkSamplerYcbcrConversionCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pYcbcrConversion: ?*vk.VkSamplerYcbcrConversion) Error!void {
    const result = vk.vkCreateSamplerYcbcrConversion(
        device,
        pCreateInfo,
        pAllocator,
        pYcbcrConversion
    );
    try check(result);
}

pub fn DestroySamplerYcbcrConversion(device: vk.VkDevice, ycbcrConversion: vk.VkSamplerYcbcrConversion, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroySamplerYcbcrConversion(
        device,
        ycbcrConversion,
        pAllocator
    );
    try check(result);
}

pub fn CreateDescriptorUpdateTemplate(device: vk.VkDevice, pCreateInfo: ?*const vk.VkDescriptorUpdateTemplateCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pDescriptorUpdateTemplate: ?*vk.VkDescriptorUpdateTemplate) Error!void {
    const result = vk.vkCreateDescriptorUpdateTemplate(
        device,
        pCreateInfo,
        pAllocator,
        pDescriptorUpdateTemplate
    );
    try check(result);
}

pub fn DestroyDescriptorUpdateTemplate(device: vk.VkDevice, descriptorUpdateTemplate: vk.VkDescriptorUpdateTemplate, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDescriptorUpdateTemplate(
        device,
        descriptorUpdateTemplate,
        pAllocator
    );
    try check(result);
}

pub fn UpdateDescriptorSetWithTemplate(device: vk.VkDevice, descriptorSet: vk.VkDescriptorSet, descriptorUpdateTemplate: vk.VkDescriptorUpdateTemplate, pData: ?*const void) Error!void {
    const result = vk.vkUpdateDescriptorSetWithTemplate(
        device,
        descriptorSet,
        descriptorUpdateTemplate,
        pData
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalBufferProperties(physicalDevice: vk.VkPhysicalDevice, pExternalBufferInfo: ?*const vk.VkPhysicalDeviceExternalBufferInfo, pExternalBufferProperties: ?[*]vk.VkExternalBufferProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalBufferProperties(
        physicalDevice,
        pExternalBufferInfo,
        pExternalBufferProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalFenceProperties(physicalDevice: vk.VkPhysicalDevice, pExternalFenceInfo: ?*const vk.VkPhysicalDeviceExternalFenceInfo, pExternalFenceProperties: ?[*]vk.VkExternalFenceProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalFenceProperties(
        physicalDevice,
        pExternalFenceInfo,
        pExternalFenceProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalSemaphoreProperties(physicalDevice: vk.VkPhysicalDevice, pExternalSemaphoreInfo: ?*const vk.VkPhysicalDeviceExternalSemaphoreInfo, pExternalSemaphoreProperties: ?[*]vk.VkExternalSemaphoreProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalSemaphoreProperties(
        physicalDevice,
        pExternalSemaphoreInfo,
        pExternalSemaphoreProperties
    );
    try check(result);
}

pub fn GetDescriptorSetLayoutSupport(device: vk.VkDevice, pCreateInfo: ?*const vk.VkDescriptorSetLayoutCreateInfo, pSupport: ?*vk.VkDescriptorSetLayoutSupport) Error!void {
    const result = vk.vkGetDescriptorSetLayoutSupport(
        device,
        pCreateInfo,
        pSupport
    );
    try check(result);
}

pub fn CmdDrawIndirectCount(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndirectCount(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn CmdDrawIndexedIndirectCount(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndexedIndirectCount(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn CreateRenderPass2(device: vk.VkDevice, pCreateInfo: ?*const vk.VkRenderPassCreateInfo2, pAllocator: ?*const vk.VkAllocationCallbacks, pRenderPass: ?[*]vk.VkRenderPass) Error!void {
    const result = vk.vkCreateRenderPass2(
        device,
        pCreateInfo,
        pAllocator,
        pRenderPass
    );
    try check(result);
}

pub fn CmdBeginRenderPass2(commandBuffer: vk.VkCommandBuffer, pRenderPassBegin: ?*const vk.VkRenderPassBeginInfo, pSubpassBeginInfo: ?*const vk.VkSubpassBeginInfo) Error!void {
    const result = vk.vkCmdBeginRenderPass2(
        commandBuffer,
        pRenderPassBegin,
        pSubpassBeginInfo
    );
    try check(result);
}

pub fn CmdNextSubpass2(commandBuffer: vk.VkCommandBuffer, pSubpassBeginInfo: ?*const vk.VkSubpassBeginInfo, pSubpassEndInfo: ?*const vk.VkSubpassEndInfo) Error!void {
    const result = vk.vkCmdNextSubpass2(
        commandBuffer,
        pSubpassBeginInfo,
        pSubpassEndInfo
    );
    try check(result);
}

pub fn CmdEndRenderPass2(commandBuffer: vk.VkCommandBuffer, pSubpassEndInfo: ?*const vk.VkSubpassEndInfo) Error!void {
    const result = vk.vkCmdEndRenderPass2(
        commandBuffer,
        pSubpassEndInfo
    );
    try check(result);
}

pub fn ResetQueryPool(device: vk.VkDevice, queryPool: vk.VkQueryPool, firstQuery: u32, queryCount: u32) Error!void {
    const result = vk.vkResetQueryPool(
        device,
        queryPool,
        firstQuery,
        queryCount
    );
    try check(result);
}

pub fn GetSemaphoreCounterValue(device: vk.VkDevice, semaphore: vk.VkSemaphore, pValue: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetSemaphoreCounterValue(
        device,
        semaphore,
        pValue
    );
    try check(result);
}

pub fn WaitSemaphores(device: vk.VkDevice, pWaitInfo: ?*const vk.VkSemaphoreWaitInfo, timeout: vk.uint64_t) Error!void {
    const result = vk.vkWaitSemaphores(
        device,
        pWaitInfo,
        timeout
    );
    try check(result);
}

pub fn SignalSemaphore(device: vk.VkDevice, pSignalInfo: ?*const vk.VkSemaphoreSignalInfo) Error!void {
    const result = vk.vkSignalSemaphore(
        device,
        pSignalInfo
    );
    try check(result);
}

pub fn GetBufferDeviceAddress(device: vk.VkDevice, pInfo: ?*const vk.VkBufferDeviceAddressInfo) Error!void {
    const result = vk.vkGetBufferDeviceAddress(
        device,
        pInfo
    );
    try check(result);
}

pub fn GetPhysicalDeviceToolProperties(physicalDevice: vk.VkPhysicalDevice, pToolCount: ?*u32, pToolProperties: ?[*]vk.VkPhysicalDeviceToolProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceToolProperties(
        physicalDevice,
        pToolCount,
        pToolProperties
    );
    try check(result);
}

pub fn CreatePrivateDataSlot(device: vk.VkDevice, pCreateInfo: ?*const vk.VkPrivateDataSlotCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pPrivateDataSlot: ?*vk.VkPrivateDataSlot) Error!void {
    const result = vk.vkCreatePrivateDataSlot(
        device,
        pCreateInfo,
        pAllocator,
        pPrivateDataSlot
    );
    try check(result);
}

pub fn DestroyPrivateDataSlot(device: vk.VkDevice, privateDataSlot: vk.VkPrivateDataSlot, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyPrivateDataSlot(
        device,
        privateDataSlot,
        pAllocator
    );
    try check(result);
}

pub fn SetPrivateData(device: vk.VkDevice, objectType: vk.VkObjectType, objectHandle: vk.uint64_t, privateDataSlot: vk.VkPrivateDataSlot, data: vk.uint64_t) Error!void {
    const result = vk.vkSetPrivateData(
        device,
        objectType,
        objectHandle,
        privateDataSlot,
        data
    );
    try check(result);
}

pub fn GetPrivateData(device: vk.VkDevice, objectType: vk.VkObjectType, objectHandle: vk.uint64_t, privateDataSlot: vk.VkPrivateDataSlot, pData: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetPrivateData(
        device,
        objectType,
        objectHandle,
        privateDataSlot,
        pData
    );
    try check(result);
}

pub fn CmdSetEvent2(commandBuffer: vk.VkCommandBuffer, event: vk.VkEvent, pDependencyInfo: ?*const vk.VkDependencyInfo) Error!void {
    const result = vk.vkCmdSetEvent2(
        commandBuffer,
        event,
        pDependencyInfo
    );
    try check(result);
}

pub fn CmdResetEvent2(commandBuffer: vk.VkCommandBuffer, event: vk.VkEvent, stageMask: vk.VkPipelineStageFlags2) Error!void {
    const result = vk.vkCmdResetEvent2(
        commandBuffer,
        event,
        stageMask
    );
    try check(result);
}

pub fn CmdWaitEvents2(commandBuffer: vk.VkCommandBuffer, eventCount: u32, pEvents: ?[*]const vk.VkEvent, pDependencyInfos: ?[*]const vk.VkDependencyInfo) Error!void {
    const result = vk.vkCmdWaitEvents2(
        commandBuffer,
        eventCount,
        pEvents,
        pDependencyInfos
    );
    try check(result);
}

pub fn CmdPipelineBarrier2(commandBuffer: vk.VkCommandBuffer, pDependencyInfo: ?*const vk.VkDependencyInfo) Error!void {
    const result = vk.vkCmdPipelineBarrier2(
        commandBuffer,
        pDependencyInfo
    );
    try check(result);
}

pub fn CmdWriteTimestamp2(commandBuffer: vk.VkCommandBuffer, stage: vk.VkPipelineStageFlags2, queryPool: vk.VkQueryPool, query: u32) Error!void {
    const result = vk.vkCmdWriteTimestamp2(
        commandBuffer,
        stage,
        queryPool,
        query
    );
    try check(result);
}

pub fn QueueSubmit2(queue: vk.VkQueue, submitCount: u32, pSubmits: ?[*]const vk.VkSubmitInfo2, fence: vk.VkFence) Error!void {
    const result = vk.vkQueueSubmit2(
        queue,
        submitCount,
        pSubmits,
        fence
    );
    try check(result);
}

pub fn CmdCopyBuffer2(commandBuffer: vk.VkCommandBuffer, pCopyBufferInfo: ?*const vk.VkCopyBufferInfo2) Error!void {
    const result = vk.vkCmdCopyBuffer2(
        commandBuffer,
        pCopyBufferInfo
    );
    try check(result);
}

pub fn CmdCopyImage2(commandBuffer: vk.VkCommandBuffer, pCopyImageInfo: ?*const vk.VkCopyImageInfo2) Error!void {
    const result = vk.vkCmdCopyImage2(
        commandBuffer,
        pCopyImageInfo
    );
    try check(result);
}

pub fn CmdCopyBufferToImage2(commandBuffer: vk.VkCommandBuffer, pCopyBufferToImageInfo: ?*const vk.VkCopyBufferToImageInfo2) Error!void {
    const result = vk.vkCmdCopyBufferToImage2(
        commandBuffer,
        pCopyBufferToImageInfo
    );
    try check(result);
}

pub fn CmdCopyImageToBuffer2(commandBuffer: vk.VkCommandBuffer, pCopyImageToBufferInfo: ?*const vk.VkCopyImageToBufferInfo2) Error!void {
    const result = vk.vkCmdCopyImageToBuffer2(
        commandBuffer,
        pCopyImageToBufferInfo
    );
    try check(result);
}

pub fn CmdBlitImage2(commandBuffer: vk.VkCommandBuffer, pBlitImageInfo: ?*const vk.VkBlitImageInfo2) Error!void {
    const result = vk.vkCmdBlitImage2(
        commandBuffer,
        pBlitImageInfo
    );
    try check(result);
}

pub fn CmdResolveImage2(commandBuffer: vk.VkCommandBuffer, pResolveImageInfo: ?*const vk.VkResolveImageInfo2) Error!void {
    const result = vk.vkCmdResolveImage2(
        commandBuffer,
        pResolveImageInfo
    );
    try check(result);
}

pub fn CmdBeginRendering(commandBuffer: vk.VkCommandBuffer, pRenderingInfo: ?*const vk.VkRenderingInfo) Error!void {
    const result = vk.vkCmdBeginRendering(
        commandBuffer,
        pRenderingInfo
    );
    try check(result);
}

pub fn CmdEndRendering(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdEndRendering(
        commandBuffer
    );
    try check(result);
}

pub fn CmdSetCullMode(commandBuffer: vk.VkCommandBuffer, cullMode: vk.VkCullModeFlags) Error!void {
    const result = vk.vkCmdSetCullMode(
        commandBuffer,
        cullMode
    );
    try check(result);
}

pub fn CmdSetFrontFace(commandBuffer: vk.VkCommandBuffer, frontFace: vk.VkFrontFace) Error!void {
    const result = vk.vkCmdSetFrontFace(
        commandBuffer,
        frontFace
    );
    try check(result);
}

pub fn CmdSetPrimitiveTopology(commandBuffer: vk.VkCommandBuffer, primitiveTopology: vk.VkPrimitiveTopology) Error!void {
    const result = vk.vkCmdSetPrimitiveTopology(
        commandBuffer,
        primitiveTopology
    );
    try check(result);
}

pub fn CmdSetViewportWithCount(commandBuffer: vk.VkCommandBuffer, viewportCount: u32, pViewports: ?[*]const vk.VkViewport) Error!void {
    const result = vk.vkCmdSetViewportWithCount(
        commandBuffer,
        viewportCount,
        pViewports
    );
    try check(result);
}

pub fn CmdSetScissorWithCount(commandBuffer: vk.VkCommandBuffer, scissorCount: u32, pScissors: ?[*]const vk.VkRect2D) Error!void {
    const result = vk.vkCmdSetScissorWithCount(
        commandBuffer,
        scissorCount,
        pScissors
    );
    try check(result);
}

pub fn CmdBindVertexBuffers2(commandBuffer: vk.VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: ?[*]const vk.VkBuffer, pOffsets: ?[*]const vk.VkDeviceSize, pSizes: ?[*]const vk.VkDeviceSize, pStrides: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdBindVertexBuffers2(
        commandBuffer,
        firstBinding,
        bindingCount,
        pBuffers,
        pOffsets,
        pSizes,
        pStrides
    );
    try check(result);
}

pub fn CmdSetDepthTestEnable(commandBuffer: vk.VkCommandBuffer, depthTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthTestEnable(
        commandBuffer,
        depthTestEnable
    );
    try check(result);
}

pub fn CmdSetDepthWriteEnable(commandBuffer: vk.VkCommandBuffer, depthWriteEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthWriteEnable(
        commandBuffer,
        depthWriteEnable
    );
    try check(result);
}

pub fn CmdSetDepthCompareOp(commandBuffer: vk.VkCommandBuffer, depthCompareOp: vk.VkCompareOp) Error!void {
    const result = vk.vkCmdSetDepthCompareOp(
        commandBuffer,
        depthCompareOp
    );
    try check(result);
}

pub fn CmdSetDepthBoundsTestEnable(commandBuffer: vk.VkCommandBuffer, depthBoundsTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthBoundsTestEnable(
        commandBuffer,
        depthBoundsTestEnable
    );
    try check(result);
}

pub fn CmdSetStencilTestEnable(commandBuffer: vk.VkCommandBuffer, stencilTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetStencilTestEnable(
        commandBuffer,
        stencilTestEnable
    );
    try check(result);
}

pub fn CmdSetStencilOp(commandBuffer: vk.VkCommandBuffer, faceMask: vk.VkStencilFaceFlags, failOp: vk.VkStencilOp, passOp: vk.VkStencilOp, depthFailOp: vk.VkStencilOp, compareOp: vk.VkCompareOp) Error!void {
    const result = vk.vkCmdSetStencilOp(
        commandBuffer,
        faceMask,
        failOp,
        passOp,
        depthFailOp,
        compareOp
    );
    try check(result);
}

pub fn CmdSetRasterizerDiscardEnable(commandBuffer: vk.VkCommandBuffer, rasterizerDiscardEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetRasterizerDiscardEnable(
        commandBuffer,
        rasterizerDiscardEnable
    );
    try check(result);
}

pub fn CmdSetDepthBiasEnable(commandBuffer: vk.VkCommandBuffer, depthBiasEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthBiasEnable(
        commandBuffer,
        depthBiasEnable
    );
    try check(result);
}

pub fn CmdSetPrimitiveRestartEnable(commandBuffer: vk.VkCommandBuffer, primitiveRestartEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetPrimitiveRestartEnable(
        commandBuffer,
        primitiveRestartEnable
    );
    try check(result);
}

pub fn GetDeviceBufferMemoryRequirements(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceBufferMemoryRequirements, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetDeviceBufferMemoryRequirements(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetDeviceImageMemoryRequirements(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceImageMemoryRequirements, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetDeviceImageMemoryRequirements(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetDeviceImageSparseMemoryRequirements(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceImageMemoryRequirements, pSparseMemoryRequirementCount: ?*u32, pSparseMemoryRequirements: ?[*]vk.VkSparseImageMemoryRequirements2) Error!void {
    const result = vk.vkGetDeviceImageSparseMemoryRequirements(
        device,
        pInfo,
        pSparseMemoryRequirementCount,
        pSparseMemoryRequirements
    );
    try check(result);
}

pub fn CmdSetLineStipple(commandBuffer: vk.VkCommandBuffer, lineStippleFactor: u32, lineStipplePattern: vk.uint16_t) Error!void {
    const result = vk.vkCmdSetLineStipple(
        commandBuffer,
        lineStippleFactor,
        lineStipplePattern
    );
    try check(result);
}

pub fn MapMemory2(device: vk.VkDevice, pMemoryMapInfo: ?*const vk.VkMemoryMapInfo, ppData: ?*void) Error!void {
    const result = vk.vkMapMemory2(
        device,
        pMemoryMapInfo,
        ppData
    );
    try check(result);
}

pub fn UnmapMemory2(device: vk.VkDevice, pMemoryUnmapInfo: ?*const vk.VkMemoryUnmapInfo) Error!void {
    const result = vk.vkUnmapMemory2(
        device,
        pMemoryUnmapInfo
    );
    try check(result);
}

pub fn CmdBindIndexBuffer2(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, size: vk.VkDeviceSize, indexType: vk.VkIndexType) Error!void {
    const result = vk.vkCmdBindIndexBuffer2(
        commandBuffer,
        buffer,
        offset,
        size,
        indexType
    );
    try check(result);
}

pub fn GetRenderingAreaGranularity(device: vk.VkDevice, pRenderingAreaInfo: ?*const vk.VkRenderingAreaInfo, pGranularity: ?*vk.VkExtent2D) Error!void {
    const result = vk.vkGetRenderingAreaGranularity(
        device,
        pRenderingAreaInfo,
        pGranularity
    );
    try check(result);
}

pub fn GetDeviceImageSubresourceLayout(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceImageSubresourceInfo, pLayout: ?*vk.VkSubresourceLayout2) Error!void {
    const result = vk.vkGetDeviceImageSubresourceLayout(
        device,
        pInfo,
        pLayout
    );
    try check(result);
}

pub fn GetImageSubresourceLayout2(device: vk.VkDevice, image: vk.VkImage, pSubresource: ?*const vk.VkImageSubresource2, pLayout: ?*vk.VkSubresourceLayout2) Error!void {
    const result = vk.vkGetImageSubresourceLayout2(
        device,
        image,
        pSubresource,
        pLayout
    );
    try check(result);
}

pub fn CmdPushDescriptorSet(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, layout: vk.VkPipelineLayout, set: u32, descriptorWriteCount: u32, pDescriptorWrites: ?[*]const vk.VkWriteDescriptorSet) Error!void {
    const result = vk.vkCmdPushDescriptorSet(
        commandBuffer,
        pipelineBindPoint,
        layout,
        set,
        descriptorWriteCount,
        pDescriptorWrites
    );
    try check(result);
}

pub fn CmdPushDescriptorSetWithTemplate(commandBuffer: vk.VkCommandBuffer, descriptorUpdateTemplate: vk.VkDescriptorUpdateTemplate, layout: vk.VkPipelineLayout, set: u32, pData: ?*const void) Error!void {
    const result = vk.vkCmdPushDescriptorSetWithTemplate(
        commandBuffer,
        descriptorUpdateTemplate,
        layout,
        set,
        pData
    );
    try check(result);
}

pub fn CmdSetRenderingAttachmentLocations(commandBuffer: vk.VkCommandBuffer, pLocationInfo: ?*const vk.VkRenderingAttachmentLocationInfo) Error!void {
    const result = vk.vkCmdSetRenderingAttachmentLocations(
        commandBuffer,
        pLocationInfo
    );
    try check(result);
}

pub fn CmdSetRenderingInputAttachmentIndices(commandBuffer: vk.VkCommandBuffer, pInputAttachmentIndexInfo: ?*const vk.VkRenderingInputAttachmentIndexInfo) Error!void {
    const result = vk.vkCmdSetRenderingInputAttachmentIndices(
        commandBuffer,
        pInputAttachmentIndexInfo
    );
    try check(result);
}

pub fn CmdBindDescriptorSets2(commandBuffer: vk.VkCommandBuffer, pBindDescriptorSetsInfo: ?*const vk.VkBindDescriptorSetsInfo) Error!void {
    const result = vk.vkCmdBindDescriptorSets2(
        commandBuffer,
        pBindDescriptorSetsInfo
    );
    try check(result);
}

pub fn CmdPushConstants2(commandBuffer: vk.VkCommandBuffer, pPushConstantsInfo: ?*const vk.VkPushConstantsInfo) Error!void {
    const result = vk.vkCmdPushConstants2(
        commandBuffer,
        pPushConstantsInfo
    );
    try check(result);
}

pub fn CmdPushDescriptorSet2(commandBuffer: vk.VkCommandBuffer, pPushDescriptorSetInfo: ?*const vk.VkPushDescriptorSetInfo) Error!void {
    const result = vk.vkCmdPushDescriptorSet2(
        commandBuffer,
        pPushDescriptorSetInfo
    );
    try check(result);
}

pub fn CmdPushDescriptorSetWithTemplate2(commandBuffer: vk.VkCommandBuffer, pPushDescriptorSetWithTemplateInfo: ?*const vk.VkPushDescriptorSetWithTemplateInfo) Error!void {
    const result = vk.vkCmdPushDescriptorSetWithTemplate2(
        commandBuffer,
        pPushDescriptorSetWithTemplateInfo
    );
    try check(result);
}

pub fn CopyMemoryToImage(device: vk.VkDevice, pCopyMemoryToImageInfo: ?*const vk.VkCopyMemoryToImageInfo) Error!void {
    const result = vk.vkCopyMemoryToImage(
        device,
        pCopyMemoryToImageInfo
    );
    try check(result);
}

pub fn CopyImageToMemory(device: vk.VkDevice, pCopyImageToMemoryInfo: ?*const vk.VkCopyImageToMemoryInfo) Error!void {
    const result = vk.vkCopyImageToMemory(
        device,
        pCopyImageToMemoryInfo
    );
    try check(result);
}

pub fn CopyImageToImage(device: vk.VkDevice, pCopyImageToImageInfo: ?*const vk.VkCopyImageToImageInfo) Error!void {
    const result = vk.vkCopyImageToImage(
        device,
        pCopyImageToImageInfo
    );
    try check(result);
}

pub fn TransitionImageLayout(device: vk.VkDevice, transitionCount: u32, pTransitions: ?[*]const vk.VkHostImageLayoutTransitionInfo) Error!void {
    const result = vk.vkTransitionImageLayout(
        device,
        transitionCount,
        pTransitions
    );
    try check(result);
}

pub fn DestroySurfaceKHR(instance: vk.VkInstance, surface: vk.VkSurfaceKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroySurfaceKHR(
        instance,
        surface,
        pAllocator
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfaceSupportKHR(physicalDevice: vk.VkPhysicalDevice, queueFamilyIndex: u32, surface: vk.VkSurfaceKHR, pSupported: ?*vk.VkBool32) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfaceSupportKHR(
        physicalDevice,
        queueFamilyIndex,
        surface,
        pSupported
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice: vk.VkPhysicalDevice, surface: vk.VkSurfaceKHR, pSurfaceCapabilities: ?*vk.VkSurfaceCapabilitiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
        physicalDevice,
        surface,
        pSurfaceCapabilities
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfaceFormatsKHR(physicalDevice: vk.VkPhysicalDevice, surface: vk.VkSurfaceKHR, pSurfaceFormatCount: ?*u32, pSurfaceFormats: ?[*]vk.VkSurfaceFormatKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(
        physicalDevice,
        surface,
        pSurfaceFormatCount,
        pSurfaceFormats
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfacePresentModesKHR(physicalDevice: vk.VkPhysicalDevice, surface: vk.VkSurfaceKHR, pPresentModeCount: ?*u32, pPresentModes: ?[*]vk.VkPresentModeKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(
        physicalDevice,
        surface,
        pPresentModeCount,
        pPresentModes
    );
    try check(result);
}

pub fn CreateSwapchainKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkSwapchainCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pSwapchain: ?*vk.VkSwapchainKHR) Error!void {
    const result = vk.vkCreateSwapchainKHR(
        device,
        pCreateInfo,
        pAllocator,
        pSwapchain
    );
    try check(result);
}

pub fn DestroySwapchainKHR(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroySwapchainKHR(
        device,
        swapchain,
        pAllocator
    );
    try check(result);
}

pub fn GetSwapchainImagesKHR(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pSwapchainImageCount: ?*u32, pSwapchainImages: ?[*]vk.VkImage) Error!void {
    const result = vk.vkGetSwapchainImagesKHR(
        device,
        swapchain,
        pSwapchainImageCount,
        pSwapchainImages
    );
    try check(result);
}

pub fn AcquireNextImageKHR(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, timeout: vk.uint64_t, semaphore: vk.VkSemaphore, fence: vk.VkFence, pImageIndex: ?*u32) Error!void {
    const result = vk.vkAcquireNextImageKHR(
        device,
        swapchain,
        timeout,
        semaphore,
        fence,
        pImageIndex
    );
    try check(result);
}

pub fn QueuePresentKHR(queue: vk.VkQueue, pPresentInfo: ?*const vk.VkPresentInfoKHR) Error!void {
    const result = vk.vkQueuePresentKHR(
        queue,
        pPresentInfo
    );
    try check(result);
}

pub fn GetDeviceGroupPresentCapabilitiesKHR(device: vk.VkDevice, pDeviceGroupPresentCapabilities: ?[*]vk.VkDeviceGroupPresentCapabilitiesKHR) Error!void {
    const result = vk.vkGetDeviceGroupPresentCapabilitiesKHR(
        device,
        pDeviceGroupPresentCapabilities
    );
    try check(result);
}

pub fn GetDeviceGroupSurfacePresentModesKHR(device: vk.VkDevice, surface: vk.VkSurfaceKHR, pModes: ?[*]vk.VkDeviceGroupPresentModeFlagsKHR) Error!void {
    const result = vk.vkGetDeviceGroupSurfacePresentModesKHR(
        device,
        surface,
        pModes
    );
    try check(result);
}

pub fn GetPhysicalDevicePresentRectanglesKHR(physicalDevice: vk.VkPhysicalDevice, surface: vk.VkSurfaceKHR, pRectCount: ?*u32, pRects: ?[*]vk.VkRect2D) Error!void {
    const result = vk.vkGetPhysicalDevicePresentRectanglesKHR(
        physicalDevice,
        surface,
        pRectCount,
        pRects
    );
    try check(result);
}

pub fn AcquireNextImage2KHR(device: vk.VkDevice, pAcquireInfo: ?*const vk.VkAcquireNextImageInfoKHR, pImageIndex: ?*u32) Error!void {
    const result = vk.vkAcquireNextImage2KHR(
        device,
        pAcquireInfo,
        pImageIndex
    );
    try check(result);
}

pub fn GetPhysicalDeviceDisplayPropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkDisplayPropertiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceDisplayPropertiesKHR(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceDisplayPlanePropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkDisplayPlanePropertiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceDisplayPlanePropertiesKHR(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetDisplayPlaneSupportedDisplaysKHR(physicalDevice: vk.VkPhysicalDevice, planeIndex: u32, pDisplayCount: ?*u32, pDisplays: ?[*]vk.VkDisplayKHR) Error!void {
    const result = vk.vkGetDisplayPlaneSupportedDisplaysKHR(
        physicalDevice,
        planeIndex,
        pDisplayCount,
        pDisplays
    );
    try check(result);
}

pub fn GetDisplayModePropertiesKHR(physicalDevice: vk.VkPhysicalDevice, display: vk.VkDisplayKHR, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkDisplayModePropertiesKHR) Error!void {
    const result = vk.vkGetDisplayModePropertiesKHR(
        physicalDevice,
        display,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn CreateDisplayModeKHR(physicalDevice: vk.VkPhysicalDevice, display: vk.VkDisplayKHR, pCreateInfo: ?*const vk.VkDisplayModeCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pMode: ?*vk.VkDisplayModeKHR) Error!void {
    const result = vk.vkCreateDisplayModeKHR(
        physicalDevice,
        display,
        pCreateInfo,
        pAllocator,
        pMode
    );
    try check(result);
}

pub fn GetDisplayPlaneCapabilitiesKHR(physicalDevice: vk.VkPhysicalDevice, mode: vk.VkDisplayModeKHR, planeIndex: u32, pCapabilities: ?[*]vk.VkDisplayPlaneCapabilitiesKHR) Error!void {
    const result = vk.vkGetDisplayPlaneCapabilitiesKHR(
        physicalDevice,
        mode,
        planeIndex,
        pCapabilities
    );
    try check(result);
}

pub fn CreateDisplayPlaneSurfaceKHR(instance: vk.VkInstance, pCreateInfo: ?*const vk.VkDisplaySurfaceCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pSurface: ?*vk.VkSurfaceKHR) Error!void {
    const result = vk.vkCreateDisplayPlaneSurfaceKHR(
        instance,
        pCreateInfo,
        pAllocator,
        pSurface
    );
    try check(result);
}

pub fn CreateSharedSwapchainsKHR(device: vk.VkDevice, swapchainCount: u32, pCreateInfos: ?[*]const vk.VkSwapchainCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pSwapchains: ?[*]vk.VkSwapchainKHR) Error!void {
    const result = vk.vkCreateSharedSwapchainsKHR(
        device,
        swapchainCount,
        pCreateInfos,
        pAllocator,
        pSwapchains
    );
    try check(result);
}

pub fn GetPhysicalDeviceVideoCapabilitiesKHR(physicalDevice: vk.VkPhysicalDevice, pVideoProfile: ?*const vk.VkVideoProfileInfoKHR, pCapabilities: ?[*]vk.VkVideoCapabilitiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceVideoCapabilitiesKHR(
        physicalDevice,
        pVideoProfile,
        pCapabilities
    );
    try check(result);
}

pub fn GetPhysicalDeviceVideoFormatPropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pVideoFormatInfo: ?*const vk.VkPhysicalDeviceVideoFormatInfoKHR, pVideoFormatPropertyCount: ?*u32, pVideoFormatProperties: ?[*]vk.VkVideoFormatPropertiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceVideoFormatPropertiesKHR(
        physicalDevice,
        pVideoFormatInfo,
        pVideoFormatPropertyCount,
        pVideoFormatProperties
    );
    try check(result);
}

pub fn CreateVideoSessionKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkVideoSessionCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pVideoSession: ?*vk.VkVideoSessionKHR) Error!void {
    const result = vk.vkCreateVideoSessionKHR(
        device,
        pCreateInfo,
        pAllocator,
        pVideoSession
    );
    try check(result);
}

pub fn DestroyVideoSessionKHR(device: vk.VkDevice, videoSession: vk.VkVideoSessionKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyVideoSessionKHR(
        device,
        videoSession,
        pAllocator
    );
    try check(result);
}

pub fn GetVideoSessionMemoryRequirementsKHR(device: vk.VkDevice, videoSession: vk.VkVideoSessionKHR, pMemoryRequirementsCount: ?*u32, pMemoryRequirements: ?[*]vk.VkVideoSessionMemoryRequirementsKHR) Error!void {
    const result = vk.vkGetVideoSessionMemoryRequirementsKHR(
        device,
        videoSession,
        pMemoryRequirementsCount,
        pMemoryRequirements
    );
    try check(result);
}

pub fn BindVideoSessionMemoryKHR(device: vk.VkDevice, videoSession: vk.VkVideoSessionKHR, bindSessionMemoryInfoCount: u32, pBindSessionMemoryInfos: ?[*]const vk.VkBindVideoSessionMemoryInfoKHR) Error!void {
    const result = vk.vkBindVideoSessionMemoryKHR(
        device,
        videoSession,
        bindSessionMemoryInfoCount,
        pBindSessionMemoryInfos
    );
    try check(result);
}

pub fn CreateVideoSessionParametersKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkVideoSessionParametersCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pVideoSessionParameters: ?[*]vk.VkVideoSessionParametersKHR) Error!void {
    const result = vk.vkCreateVideoSessionParametersKHR(
        device,
        pCreateInfo,
        pAllocator,
        pVideoSessionParameters
    );
    try check(result);
}

pub fn UpdateVideoSessionParametersKHR(device: vk.VkDevice, videoSessionParameters: vk.VkVideoSessionParametersKHR, pUpdateInfo: ?*const vk.VkVideoSessionParametersUpdateInfoKHR) Error!void {
    const result = vk.vkUpdateVideoSessionParametersKHR(
        device,
        videoSessionParameters,
        pUpdateInfo
    );
    try check(result);
}

pub fn DestroyVideoSessionParametersKHR(device: vk.VkDevice, videoSessionParameters: vk.VkVideoSessionParametersKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyVideoSessionParametersKHR(
        device,
        videoSessionParameters,
        pAllocator
    );
    try check(result);
}

pub fn CmdBeginVideoCodingKHR(commandBuffer: vk.VkCommandBuffer, pBeginInfo: ?*const vk.VkVideoBeginCodingInfoKHR) Error!void {
    const result = vk.vkCmdBeginVideoCodingKHR(
        commandBuffer,
        pBeginInfo
    );
    try check(result);
}

pub fn CmdEndVideoCodingKHR(commandBuffer: vk.VkCommandBuffer, pEndCodingInfo: ?*const vk.VkVideoEndCodingInfoKHR) Error!void {
    const result = vk.vkCmdEndVideoCodingKHR(
        commandBuffer,
        pEndCodingInfo
    );
    try check(result);
}

pub fn CmdControlVideoCodingKHR(commandBuffer: vk.VkCommandBuffer, pCodingControlInfo: ?*const vk.VkVideoCodingControlInfoKHR) Error!void {
    const result = vk.vkCmdControlVideoCodingKHR(
        commandBuffer,
        pCodingControlInfo
    );
    try check(result);
}

pub fn CmdDecodeVideoKHR(commandBuffer: vk.VkCommandBuffer, pDecodeInfo: ?*const vk.VkVideoDecodeInfoKHR) Error!void {
    const result = vk.vkCmdDecodeVideoKHR(
        commandBuffer,
        pDecodeInfo
    );
    try check(result);
}

pub fn CmdBeginRenderingKHR(commandBuffer: vk.VkCommandBuffer, pRenderingInfo: ?*const vk.VkRenderingInfo) Error!void {
    const result = vk.vkCmdBeginRenderingKHR(
        commandBuffer,
        pRenderingInfo
    );
    try check(result);
}

pub fn CmdEndRenderingKHR(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdEndRenderingKHR(
        commandBuffer
    );
    try check(result);
}

pub fn GetPhysicalDeviceFeatures2KHR(physicalDevice: vk.VkPhysicalDevice, pFeatures: ?[*]vk.VkPhysicalDeviceFeatures2) Error!void {
    const result = vk.vkGetPhysicalDeviceFeatures2KHR(
        physicalDevice,
        pFeatures
    );
    try check(result);
}

pub fn GetPhysicalDeviceProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pProperties: ?[*]vk.VkPhysicalDeviceProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceProperties2KHR(
        physicalDevice,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceFormatProperties2KHR(physicalDevice: vk.VkPhysicalDevice, format: vk.VkFormat, pFormatProperties: ?[*]vk.VkFormatProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceFormatProperties2KHR(
        physicalDevice,
        format,
        pFormatProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceImageFormatProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pImageFormatInfo: ?*const vk.VkPhysicalDeviceImageFormatInfo2, pImageFormatProperties: ?[*]vk.VkImageFormatProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceImageFormatProperties2KHR(
        physicalDevice,
        pImageFormatInfo,
        pImageFormatProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceQueueFamilyProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pQueueFamilyPropertyCount: ?*u32, pQueueFamilyProperties: ?[*]vk.VkQueueFamilyProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceQueueFamilyProperties2KHR(
        physicalDevice,
        pQueueFamilyPropertyCount,
        pQueueFamilyProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceMemoryProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pMemoryProperties: ?[*]vk.VkPhysicalDeviceMemoryProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceMemoryProperties2KHR(
        physicalDevice,
        pMemoryProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceSparseImageFormatProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pFormatInfo: ?*const vk.VkPhysicalDeviceSparseImageFormatInfo2, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkSparseImageFormatProperties2) Error!void {
    const result = vk.vkGetPhysicalDeviceSparseImageFormatProperties2KHR(
        physicalDevice,
        pFormatInfo,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetDeviceGroupPeerMemoryFeaturesKHR(device: vk.VkDevice, heapIndex: u32, localDeviceIndex: u32, remoteDeviceIndex: u32, pPeerMemoryFeatures: ?[*]vk.VkPeerMemoryFeatureFlags) Error!void {
    const result = vk.vkGetDeviceGroupPeerMemoryFeaturesKHR(
        device,
        heapIndex,
        localDeviceIndex,
        remoteDeviceIndex,
        pPeerMemoryFeatures
    );
    try check(result);
}

pub fn CmdSetDeviceMaskKHR(commandBuffer: vk.VkCommandBuffer, deviceMask: u32) Error!void {
    const result = vk.vkCmdSetDeviceMaskKHR(
        commandBuffer,
        deviceMask
    );
    try check(result);
}

pub fn CmdDispatchBaseKHR(commandBuffer: vk.VkCommandBuffer, baseGroupX: u32, baseGroupY: u32, baseGroupZ: u32, groupCountX: u32, groupCountY: u32, groupCountZ: u32) Error!void {
    const result = vk.vkCmdDispatchBaseKHR(
        commandBuffer,
        baseGroupX,
        baseGroupY,
        baseGroupZ,
        groupCountX,
        groupCountY,
        groupCountZ
    );
    try check(result);
}

pub fn TrimCommandPoolKHR(device: vk.VkDevice, commandPool: vk.VkCommandPool, flags: vk.VkCommandPoolTrimFlags) Error!void {
    const result = vk.vkTrimCommandPoolKHR(
        device,
        commandPool,
        flags
    );
    try check(result);
}

pub fn EnumeratePhysicalDeviceGroupsKHR(instance: vk.VkInstance, pPhysicalDeviceGroupCount: ?*u32, pPhysicalDeviceGroupProperties: ?[*]vk.VkPhysicalDeviceGroupProperties) Error!void {
    const result = vk.vkEnumeratePhysicalDeviceGroupsKHR(
        instance,
        pPhysicalDeviceGroupCount,
        pPhysicalDeviceGroupProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalBufferPropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pExternalBufferInfo: ?*const vk.VkPhysicalDeviceExternalBufferInfo, pExternalBufferProperties: ?[*]vk.VkExternalBufferProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalBufferPropertiesKHR(
        physicalDevice,
        pExternalBufferInfo,
        pExternalBufferProperties
    );
    try check(result);
}

pub fn GetMemoryFdKHR(device: vk.VkDevice, pGetFdInfo: ?*const vk.VkMemoryGetFdInfoKHR, pFd: ?*vk.int) Error!void {
    const result = vk.vkGetMemoryFdKHR(
        device,
        pGetFdInfo,
        pFd
    );
    try check(result);
}

pub fn GetMemoryFdPropertiesKHR(device: vk.VkDevice, handleType: vk.VkExternalMemoryHandleTypeFlagBits, fd: vk.int, pMemoryFdProperties: ?[*]vk.VkMemoryFdPropertiesKHR) Error!void {
    const result = vk.vkGetMemoryFdPropertiesKHR(
        device,
        handleType,
        fd,
        pMemoryFdProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalSemaphorePropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pExternalSemaphoreInfo: ?*const vk.VkPhysicalDeviceExternalSemaphoreInfo, pExternalSemaphoreProperties: ?[*]vk.VkExternalSemaphoreProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalSemaphorePropertiesKHR(
        physicalDevice,
        pExternalSemaphoreInfo,
        pExternalSemaphoreProperties
    );
    try check(result);
}

pub fn ImportSemaphoreFdKHR(device: vk.VkDevice, pImportSemaphoreFdInfo: ?*const vk.VkImportSemaphoreFdInfoKHR) Error!void {
    const result = vk.vkImportSemaphoreFdKHR(
        device,
        pImportSemaphoreFdInfo
    );
    try check(result);
}

pub fn GetSemaphoreFdKHR(device: vk.VkDevice, pGetFdInfo: ?*const vk.VkSemaphoreGetFdInfoKHR, pFd: ?*vk.int) Error!void {
    const result = vk.vkGetSemaphoreFdKHR(
        device,
        pGetFdInfo,
        pFd
    );
    try check(result);
}

pub fn CmdPushDescriptorSetKHR(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, layout: vk.VkPipelineLayout, set: u32, descriptorWriteCount: u32, pDescriptorWrites: ?[*]const vk.VkWriteDescriptorSet) Error!void {
    const result = vk.vkCmdPushDescriptorSetKHR(
        commandBuffer,
        pipelineBindPoint,
        layout,
        set,
        descriptorWriteCount,
        pDescriptorWrites
    );
    try check(result);
}

pub fn CmdPushDescriptorSetWithTemplateKHR(commandBuffer: vk.VkCommandBuffer, descriptorUpdateTemplate: vk.VkDescriptorUpdateTemplate, layout: vk.VkPipelineLayout, set: u32, pData: ?*const void) Error!void {
    const result = vk.vkCmdPushDescriptorSetWithTemplateKHR(
        commandBuffer,
        descriptorUpdateTemplate,
        layout,
        set,
        pData
    );
    try check(result);
}

pub fn CreateDescriptorUpdateTemplateKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkDescriptorUpdateTemplateCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pDescriptorUpdateTemplate: ?*vk.VkDescriptorUpdateTemplate) Error!void {
    const result = vk.vkCreateDescriptorUpdateTemplateKHR(
        device,
        pCreateInfo,
        pAllocator,
        pDescriptorUpdateTemplate
    );
    try check(result);
}

pub fn DestroyDescriptorUpdateTemplateKHR(device: vk.VkDevice, descriptorUpdateTemplate: vk.VkDescriptorUpdateTemplate, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDescriptorUpdateTemplateKHR(
        device,
        descriptorUpdateTemplate,
        pAllocator
    );
    try check(result);
}

pub fn UpdateDescriptorSetWithTemplateKHR(device: vk.VkDevice, descriptorSet: vk.VkDescriptorSet, descriptorUpdateTemplate: vk.VkDescriptorUpdateTemplate, pData: ?*const void) Error!void {
    const result = vk.vkUpdateDescriptorSetWithTemplateKHR(
        device,
        descriptorSet,
        descriptorUpdateTemplate,
        pData
    );
    try check(result);
}

pub fn CreateRenderPass2KHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkRenderPassCreateInfo2, pAllocator: ?*const vk.VkAllocationCallbacks, pRenderPass: ?[*]vk.VkRenderPass) Error!void {
    const result = vk.vkCreateRenderPass2KHR(
        device,
        pCreateInfo,
        pAllocator,
        pRenderPass
    );
    try check(result);
}

pub fn CmdBeginRenderPass2KHR(commandBuffer: vk.VkCommandBuffer, pRenderPassBegin: ?*const vk.VkRenderPassBeginInfo, pSubpassBeginInfo: ?*const vk.VkSubpassBeginInfo) Error!void {
    const result = vk.vkCmdBeginRenderPass2KHR(
        commandBuffer,
        pRenderPassBegin,
        pSubpassBeginInfo
    );
    try check(result);
}

pub fn CmdNextSubpass2KHR(commandBuffer: vk.VkCommandBuffer, pSubpassBeginInfo: ?*const vk.VkSubpassBeginInfo, pSubpassEndInfo: ?*const vk.VkSubpassEndInfo) Error!void {
    const result = vk.vkCmdNextSubpass2KHR(
        commandBuffer,
        pSubpassBeginInfo,
        pSubpassEndInfo
    );
    try check(result);
}

pub fn CmdEndRenderPass2KHR(commandBuffer: vk.VkCommandBuffer, pSubpassEndInfo: ?*const vk.VkSubpassEndInfo) Error!void {
    const result = vk.vkCmdEndRenderPass2KHR(
        commandBuffer,
        pSubpassEndInfo
    );
    try check(result);
}

pub fn GetSwapchainStatusKHR(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR) Error!void {
    const result = vk.vkGetSwapchainStatusKHR(
        device,
        swapchain
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalFencePropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pExternalFenceInfo: ?*const vk.VkPhysicalDeviceExternalFenceInfo, pExternalFenceProperties: ?[*]vk.VkExternalFenceProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalFencePropertiesKHR(
        physicalDevice,
        pExternalFenceInfo,
        pExternalFenceProperties
    );
    try check(result);
}

pub fn ImportFenceFdKHR(device: vk.VkDevice, pImportFenceFdInfo: ?*const vk.VkImportFenceFdInfoKHR) Error!void {
    const result = vk.vkImportFenceFdKHR(
        device,
        pImportFenceFdInfo
    );
    try check(result);
}

pub fn GetFenceFdKHR(device: vk.VkDevice, pGetFdInfo: ?*const vk.VkFenceGetFdInfoKHR, pFd: ?*vk.int) Error!void {
    const result = vk.vkGetFenceFdKHR(
        device,
        pGetFdInfo,
        pFd
    );
    try check(result);
}

pub fn EnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR(physicalDevice: vk.VkPhysicalDevice, queueFamilyIndex: u32, pCounterCount: ?*u32, pCounters: ?[*]vk.VkPerformanceCounterKHR, pCounterDescriptions: ?[*]vk.VkPerformanceCounterDescriptionKHR) Error!void {
    const result = vk.vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR(
        physicalDevice,
        queueFamilyIndex,
        pCounterCount,
        pCounters,
        pCounterDescriptions
    );
    try check(result);
}

pub fn GetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR(physicalDevice: vk.VkPhysicalDevice, pPerformanceQueryCreateInfo: ?*const vk.VkQueryPoolPerformanceCreateInfoKHR, pNumPasses: ?[*]u32) Error!void {
    const result = vk.vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR(
        physicalDevice,
        pPerformanceQueryCreateInfo,
        pNumPasses
    );
    try check(result);
}

pub fn AcquireProfilingLockKHR(device: vk.VkDevice, pInfo: ?*const vk.VkAcquireProfilingLockInfoKHR) Error!void {
    const result = vk.vkAcquireProfilingLockKHR(
        device,
        pInfo
    );
    try check(result);
}

pub fn ReleaseProfilingLockKHR(device: vk.VkDevice) Error!void {
    const result = vk.vkReleaseProfilingLockKHR(
        device
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfaceCapabilities2KHR(physicalDevice: vk.VkPhysicalDevice, pSurfaceInfo: ?*const vk.VkPhysicalDeviceSurfaceInfo2KHR, pSurfaceCapabilities: ?[*]vk.VkSurfaceCapabilities2KHR) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfaceCapabilities2KHR(
        physicalDevice,
        pSurfaceInfo,
        pSurfaceCapabilities
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfaceFormats2KHR(physicalDevice: vk.VkPhysicalDevice, pSurfaceInfo: ?*const vk.VkPhysicalDeviceSurfaceInfo2KHR, pSurfaceFormatCount: ?*u32, pSurfaceFormats: ?[*]vk.VkSurfaceFormat2KHR) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfaceFormats2KHR(
        physicalDevice,
        pSurfaceInfo,
        pSurfaceFormatCount,
        pSurfaceFormats
    );
    try check(result);
}

pub fn GetPhysicalDeviceDisplayProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkDisplayProperties2KHR) Error!void {
    const result = vk.vkGetPhysicalDeviceDisplayProperties2KHR(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceDisplayPlaneProperties2KHR(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkDisplayPlaneProperties2KHR) Error!void {
    const result = vk.vkGetPhysicalDeviceDisplayPlaneProperties2KHR(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetDisplayModeProperties2KHR(physicalDevice: vk.VkPhysicalDevice, display: vk.VkDisplayKHR, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkDisplayModeProperties2KHR) Error!void {
    const result = vk.vkGetDisplayModeProperties2KHR(
        physicalDevice,
        display,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetDisplayPlaneCapabilities2KHR(physicalDevice: vk.VkPhysicalDevice, pDisplayPlaneInfo: ?*const vk.VkDisplayPlaneInfo2KHR, pCapabilities: ?[*]vk.VkDisplayPlaneCapabilities2KHR) Error!void {
    const result = vk.vkGetDisplayPlaneCapabilities2KHR(
        physicalDevice,
        pDisplayPlaneInfo,
        pCapabilities
    );
    try check(result);
}

pub fn GetImageMemoryRequirements2KHR(device: vk.VkDevice, pInfo: ?*const vk.VkImageMemoryRequirementsInfo2, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetImageMemoryRequirements2KHR(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetBufferMemoryRequirements2KHR(device: vk.VkDevice, pInfo: ?*const vk.VkBufferMemoryRequirementsInfo2, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetBufferMemoryRequirements2KHR(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetImageSparseMemoryRequirements2KHR(device: vk.VkDevice, pInfo: ?*const vk.VkImageSparseMemoryRequirementsInfo2, pSparseMemoryRequirementCount: ?*u32, pSparseMemoryRequirements: ?[*]vk.VkSparseImageMemoryRequirements2) Error!void {
    const result = vk.vkGetImageSparseMemoryRequirements2KHR(
        device,
        pInfo,
        pSparseMemoryRequirementCount,
        pSparseMemoryRequirements
    );
    try check(result);
}

pub fn CreateSamplerYcbcrConversionKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkSamplerYcbcrConversionCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pYcbcrConversion: ?*vk.VkSamplerYcbcrConversion) Error!void {
    const result = vk.vkCreateSamplerYcbcrConversionKHR(
        device,
        pCreateInfo,
        pAllocator,
        pYcbcrConversion
    );
    try check(result);
}

pub fn DestroySamplerYcbcrConversionKHR(device: vk.VkDevice, ycbcrConversion: vk.VkSamplerYcbcrConversion, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroySamplerYcbcrConversionKHR(
        device,
        ycbcrConversion,
        pAllocator
    );
    try check(result);
}

pub fn BindBufferMemory2KHR(device: vk.VkDevice, bindInfoCount: u32, pBindInfos: ?[*]const vk.VkBindBufferMemoryInfo) Error!void {
    const result = vk.vkBindBufferMemory2KHR(
        device,
        bindInfoCount,
        pBindInfos
    );
    try check(result);
}

pub fn BindImageMemory2KHR(device: vk.VkDevice, bindInfoCount: u32, pBindInfos: ?[*]const vk.VkBindImageMemoryInfo) Error!void {
    const result = vk.vkBindImageMemory2KHR(
        device,
        bindInfoCount,
        pBindInfos
    );
    try check(result);
}

pub fn GetDescriptorSetLayoutSupportKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkDescriptorSetLayoutCreateInfo, pSupport: ?*vk.VkDescriptorSetLayoutSupport) Error!void {
    const result = vk.vkGetDescriptorSetLayoutSupportKHR(
        device,
        pCreateInfo,
        pSupport
    );
    try check(result);
}

pub fn CmdDrawIndirectCountKHR(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndirectCountKHR(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn CmdDrawIndexedIndirectCountKHR(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndexedIndirectCountKHR(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn GetSemaphoreCounterValueKHR(device: vk.VkDevice, semaphore: vk.VkSemaphore, pValue: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetSemaphoreCounterValueKHR(
        device,
        semaphore,
        pValue
    );
    try check(result);
}

pub fn WaitSemaphoresKHR(device: vk.VkDevice, pWaitInfo: ?*const vk.VkSemaphoreWaitInfo, timeout: vk.uint64_t) Error!void {
    const result = vk.vkWaitSemaphoresKHR(
        device,
        pWaitInfo,
        timeout
    );
    try check(result);
}

pub fn SignalSemaphoreKHR(device: vk.VkDevice, pSignalInfo: ?*const vk.VkSemaphoreSignalInfo) Error!void {
    const result = vk.vkSignalSemaphoreKHR(
        device,
        pSignalInfo
    );
    try check(result);
}

pub fn GetPhysicalDeviceFragmentShadingRatesKHR(physicalDevice: vk.VkPhysicalDevice, pFragmentShadingRateCount: ?*u32, pFragmentShadingRates: ?[*]vk.VkPhysicalDeviceFragmentShadingRateKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceFragmentShadingRatesKHR(
        physicalDevice,
        pFragmentShadingRateCount,
        pFragmentShadingRates
    );
    try check(result);
}

pub fn CmdSetFragmentShadingRateKHR(commandBuffer: vk.VkCommandBuffer, pFragmentSize: ?*const vk.VkExtent2D, combinerOps: vk.VkFragmentShadingRateCombinerOpKHR) Error!void {
    const result = vk.vkCmdSetFragmentShadingRateKHR(
        commandBuffer,
        pFragmentSize,
        combinerOps
    );
    try check(result);
}

pub fn CmdSetRenderingAttachmentLocationsKHR(commandBuffer: vk.VkCommandBuffer, pLocationInfo: ?*const vk.VkRenderingAttachmentLocationInfo) Error!void {
    const result = vk.vkCmdSetRenderingAttachmentLocationsKHR(
        commandBuffer,
        pLocationInfo
    );
    try check(result);
}

pub fn CmdSetRenderingInputAttachmentIndicesKHR(commandBuffer: vk.VkCommandBuffer, pInputAttachmentIndexInfo: ?*const vk.VkRenderingInputAttachmentIndexInfo) Error!void {
    const result = vk.vkCmdSetRenderingInputAttachmentIndicesKHR(
        commandBuffer,
        pInputAttachmentIndexInfo
    );
    try check(result);
}

pub fn WaitForPresentKHR(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, presentId: vk.uint64_t, timeout: vk.uint64_t) Error!void {
    const result = vk.vkWaitForPresentKHR(
        device,
        swapchain,
        presentId,
        timeout
    );
    try check(result);
}

pub fn GetBufferDeviceAddressKHR(device: vk.VkDevice, pInfo: ?*const vk.VkBufferDeviceAddressInfo) Error!void {
    const result = vk.vkGetBufferDeviceAddressKHR(
        device,
        pInfo
    );
    try check(result);
}

pub fn CreateDeferredOperationKHR(device: vk.VkDevice, pAllocator: ?*const vk.VkAllocationCallbacks, pDeferredOperation: ?*vk.VkDeferredOperationKHR) Error!void {
    const result = vk.vkCreateDeferredOperationKHR(
        device,
        pAllocator,
        pDeferredOperation
    );
    try check(result);
}

pub fn DestroyDeferredOperationKHR(device: vk.VkDevice, operation: vk.VkDeferredOperationKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDeferredOperationKHR(
        device,
        operation,
        pAllocator
    );
    try check(result);
}

pub fn GetDeferredOperationResultKHR(device: vk.VkDevice, operation: vk.VkDeferredOperationKHR) Error!void {
    const result = vk.vkGetDeferredOperationResultKHR(
        device,
        operation
    );
    try check(result);
}

pub fn DeferredOperationJoinKHR(device: vk.VkDevice, operation: vk.VkDeferredOperationKHR) Error!void {
    const result = vk.vkDeferredOperationJoinKHR(
        device,
        operation
    );
    try check(result);
}

pub fn GetPipelineExecutablePropertiesKHR(device: vk.VkDevice, pPipelineInfo: ?*const vk.VkPipelineInfoKHR, pExecutableCount: ?*u32, pProperties: ?[*]vk.VkPipelineExecutablePropertiesKHR) Error!void {
    const result = vk.vkGetPipelineExecutablePropertiesKHR(
        device,
        pPipelineInfo,
        pExecutableCount,
        pProperties
    );
    try check(result);
}

pub fn GetPipelineExecutableStatisticsKHR(device: vk.VkDevice, pExecutableInfo: ?*const vk.VkPipelineExecutableInfoKHR, pStatisticCount: ?*u32, pStatistics: ?[*]vk.VkPipelineExecutableStatisticKHR) Error!void {
    const result = vk.vkGetPipelineExecutableStatisticsKHR(
        device,
        pExecutableInfo,
        pStatisticCount,
        pStatistics
    );
    try check(result);
}

pub fn GetPipelineExecutableInternalRepresentationsKHR(device: vk.VkDevice, pExecutableInfo: ?*const vk.VkPipelineExecutableInfoKHR, pInternalRepresentationCount: ?*u32, pInternalRepresentations: ?[*]vk.VkPipelineExecutableInternalRepresentationKHR) Error!void {
    const result = vk.vkGetPipelineExecutableInternalRepresentationsKHR(
        device,
        pExecutableInfo,
        pInternalRepresentationCount,
        pInternalRepresentations
    );
    try check(result);
}

pub fn MapMemory2KHR(device: vk.VkDevice, pMemoryMapInfo: ?*const vk.VkMemoryMapInfo, ppData: ?*void) Error!void {
    const result = vk.vkMapMemory2KHR(
        device,
        pMemoryMapInfo,
        ppData
    );
    try check(result);
}

pub fn UnmapMemory2KHR(device: vk.VkDevice, pMemoryUnmapInfo: ?*const vk.VkMemoryUnmapInfo) Error!void {
    const result = vk.vkUnmapMemory2KHR(
        device,
        pMemoryUnmapInfo
    );
    try check(result);
}

pub fn GetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pQualityLevelInfo: ?*const vk.VkPhysicalDeviceVideoEncodeQualityLevelInfoKHR, pQualityLevelProperties: ?[*]vk.VkVideoEncodeQualityLevelPropertiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR(
        physicalDevice,
        pQualityLevelInfo,
        pQualityLevelProperties
    );
    try check(result);
}

pub fn GetEncodedVideoSessionParametersKHR(device: vk.VkDevice, pVideoSessionParametersInfo: ?*const vk.VkVideoEncodeSessionParametersGetInfoKHR, pFeedbackInfo: ?*vk.VkVideoEncodeSessionParametersFeedbackInfoKHR, pDataSize: ?*vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetEncodedVideoSessionParametersKHR(
        device,
        pVideoSessionParametersInfo,
        pFeedbackInfo,
        pDataSize,
        pData
    );
    try check(result);
}

pub fn CmdEncodeVideoKHR(commandBuffer: vk.VkCommandBuffer, pEncodeInfo: ?*const vk.VkVideoEncodeInfoKHR) Error!void {
    const result = vk.vkCmdEncodeVideoKHR(
        commandBuffer,
        pEncodeInfo
    );
    try check(result);
}

pub fn CmdSetEvent2KHR(commandBuffer: vk.VkCommandBuffer, event: vk.VkEvent, pDependencyInfo: ?*const vk.VkDependencyInfo) Error!void {
    const result = vk.vkCmdSetEvent2KHR(
        commandBuffer,
        event,
        pDependencyInfo
    );
    try check(result);
}

pub fn CmdResetEvent2KHR(commandBuffer: vk.VkCommandBuffer, event: vk.VkEvent, stageMask: vk.VkPipelineStageFlags2) Error!void {
    const result = vk.vkCmdResetEvent2KHR(
        commandBuffer,
        event,
        stageMask
    );
    try check(result);
}

pub fn CmdWaitEvents2KHR(commandBuffer: vk.VkCommandBuffer, eventCount: u32, pEvents: ?[*]const vk.VkEvent, pDependencyInfos: ?[*]const vk.VkDependencyInfo) Error!void {
    const result = vk.vkCmdWaitEvents2KHR(
        commandBuffer,
        eventCount,
        pEvents,
        pDependencyInfos
    );
    try check(result);
}

pub fn CmdPipelineBarrier2KHR(commandBuffer: vk.VkCommandBuffer, pDependencyInfo: ?*const vk.VkDependencyInfo) Error!void {
    const result = vk.vkCmdPipelineBarrier2KHR(
        commandBuffer,
        pDependencyInfo
    );
    try check(result);
}

pub fn CmdWriteTimestamp2KHR(commandBuffer: vk.VkCommandBuffer, stage: vk.VkPipelineStageFlags2, queryPool: vk.VkQueryPool, query: u32) Error!void {
    const result = vk.vkCmdWriteTimestamp2KHR(
        commandBuffer,
        stage,
        queryPool,
        query
    );
    try check(result);
}

pub fn QueueSubmit2KHR(queue: vk.VkQueue, submitCount: u32, pSubmits: ?[*]const vk.VkSubmitInfo2, fence: vk.VkFence) Error!void {
    const result = vk.vkQueueSubmit2KHR(
        queue,
        submitCount,
        pSubmits,
        fence
    );
    try check(result);
}

pub fn CmdCopyBuffer2KHR(commandBuffer: vk.VkCommandBuffer, pCopyBufferInfo: ?*const vk.VkCopyBufferInfo2) Error!void {
    const result = vk.vkCmdCopyBuffer2KHR(
        commandBuffer,
        pCopyBufferInfo
    );
    try check(result);
}

pub fn CmdCopyImage2KHR(commandBuffer: vk.VkCommandBuffer, pCopyImageInfo: ?*const vk.VkCopyImageInfo2) Error!void {
    const result = vk.vkCmdCopyImage2KHR(
        commandBuffer,
        pCopyImageInfo
    );
    try check(result);
}

pub fn CmdCopyBufferToImage2KHR(commandBuffer: vk.VkCommandBuffer, pCopyBufferToImageInfo: ?*const vk.VkCopyBufferToImageInfo2) Error!void {
    const result = vk.vkCmdCopyBufferToImage2KHR(
        commandBuffer,
        pCopyBufferToImageInfo
    );
    try check(result);
}

pub fn CmdCopyImageToBuffer2KHR(commandBuffer: vk.VkCommandBuffer, pCopyImageToBufferInfo: ?*const vk.VkCopyImageToBufferInfo2) Error!void {
    const result = vk.vkCmdCopyImageToBuffer2KHR(
        commandBuffer,
        pCopyImageToBufferInfo
    );
    try check(result);
}

pub fn CmdBlitImage2KHR(commandBuffer: vk.VkCommandBuffer, pBlitImageInfo: ?*const vk.VkBlitImageInfo2) Error!void {
    const result = vk.vkCmdBlitImage2KHR(
        commandBuffer,
        pBlitImageInfo
    );
    try check(result);
}

pub fn CmdResolveImage2KHR(commandBuffer: vk.VkCommandBuffer, pResolveImageInfo: ?*const vk.VkResolveImageInfo2) Error!void {
    const result = vk.vkCmdResolveImage2KHR(
        commandBuffer,
        pResolveImageInfo
    );
    try check(result);
}

pub fn CmdTraceRaysIndirect2KHR(commandBuffer: vk.VkCommandBuffer, indirectDeviceAddress: vk.VkDeviceAddress) Error!void {
    const result = vk.vkCmdTraceRaysIndirect2KHR(
        commandBuffer,
        indirectDeviceAddress
    );
    try check(result);
}

pub fn GetDeviceBufferMemoryRequirementsKHR(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceBufferMemoryRequirements, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetDeviceBufferMemoryRequirementsKHR(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetDeviceImageMemoryRequirementsKHR(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceImageMemoryRequirements, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetDeviceImageMemoryRequirementsKHR(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn GetDeviceImageSparseMemoryRequirementsKHR(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceImageMemoryRequirements, pSparseMemoryRequirementCount: ?*u32, pSparseMemoryRequirements: ?[*]vk.VkSparseImageMemoryRequirements2) Error!void {
    const result = vk.vkGetDeviceImageSparseMemoryRequirementsKHR(
        device,
        pInfo,
        pSparseMemoryRequirementCount,
        pSparseMemoryRequirements
    );
    try check(result);
}

pub fn CmdBindIndexBuffer2KHR(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, size: vk.VkDeviceSize, indexType: vk.VkIndexType) Error!void {
    const result = vk.vkCmdBindIndexBuffer2KHR(
        commandBuffer,
        buffer,
        offset,
        size,
        indexType
    );
    try check(result);
}

pub fn GetRenderingAreaGranularityKHR(device: vk.VkDevice, pRenderingAreaInfo: ?*const vk.VkRenderingAreaInfo, pGranularity: ?*vk.VkExtent2D) Error!void {
    const result = vk.vkGetRenderingAreaGranularityKHR(
        device,
        pRenderingAreaInfo,
        pGranularity
    );
    try check(result);
}

pub fn GetDeviceImageSubresourceLayoutKHR(device: vk.VkDevice, pInfo: ?*const vk.VkDeviceImageSubresourceInfo, pLayout: ?*vk.VkSubresourceLayout2) Error!void {
    const result = vk.vkGetDeviceImageSubresourceLayoutKHR(
        device,
        pInfo,
        pLayout
    );
    try check(result);
}

pub fn GetImageSubresourceLayout2KHR(device: vk.VkDevice, image: vk.VkImage, pSubresource: ?*const vk.VkImageSubresource2, pLayout: ?*vk.VkSubresourceLayout2) Error!void {
    const result = vk.vkGetImageSubresourceLayout2KHR(
        device,
        image,
        pSubresource,
        pLayout
    );
    try check(result);
}

pub fn CreatePipelineBinariesKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkPipelineBinaryCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pBinaries: ?[*]vk.VkPipelineBinaryHandlesInfoKHR) Error!void {
    const result = vk.vkCreatePipelineBinariesKHR(
        device,
        pCreateInfo,
        pAllocator,
        pBinaries
    );
    try check(result);
}

pub fn DestroyPipelineBinaryKHR(device: vk.VkDevice, pipelineBinary: vk.VkPipelineBinaryKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyPipelineBinaryKHR(
        device,
        pipelineBinary,
        pAllocator
    );
    try check(result);
}

pub fn GetPipelineKeyKHR(device: vk.VkDevice, pPipelineCreateInfo: ?*const vk.VkPipelineCreateInfoKHR, pPipelineKey: ?*vk.VkPipelineBinaryKeyKHR) Error!void {
    const result = vk.vkGetPipelineKeyKHR(
        device,
        pPipelineCreateInfo,
        pPipelineKey
    );
    try check(result);
}

pub fn GetPipelineBinaryDataKHR(device: vk.VkDevice, pInfo: ?*const vk.VkPipelineBinaryDataInfoKHR, pPipelineBinaryKey: ?*vk.VkPipelineBinaryKeyKHR, pPipelineBinaryDataSize: ?*vk.size_t, pPipelineBinaryData: ?*void) Error!void {
    const result = vk.vkGetPipelineBinaryDataKHR(
        device,
        pInfo,
        pPipelineBinaryKey,
        pPipelineBinaryDataSize,
        pPipelineBinaryData
    );
    try check(result);
}

pub fn ReleaseCapturedPipelineDataKHR(device: vk.VkDevice, pInfo: ?*const vk.VkReleaseCapturedPipelineDataInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkReleaseCapturedPipelineDataKHR(
        device,
        pInfo,
        pAllocator
    );
    try check(result);
}

pub fn GetPhysicalDeviceCooperativeMatrixPropertiesKHR(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkCooperativeMatrixPropertiesKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceCooperativeMatrixPropertiesKHR(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn CmdSetLineStippleKHR(commandBuffer: vk.VkCommandBuffer, lineStippleFactor: u32, lineStipplePattern: vk.uint16_t) Error!void {
    const result = vk.vkCmdSetLineStippleKHR(
        commandBuffer,
        lineStippleFactor,
        lineStipplePattern
    );
    try check(result);
}

pub fn GetPhysicalDeviceCalibrateableTimeDomainsKHR(physicalDevice: vk.VkPhysicalDevice, pTimeDomainCount: ?*u32, pTimeDomains: ?[*]vk.VkTimeDomainKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceCalibrateableTimeDomainsKHR(
        physicalDevice,
        pTimeDomainCount,
        pTimeDomains
    );
    try check(result);
}

pub fn GetCalibratedTimestampsKHR(device: vk.VkDevice, timestampCount: u32, pTimestampInfos: ?[*]const vk.VkCalibratedTimestampInfoKHR, pTimestamps: ?[*]vk.uint64_t, pMaxDeviation: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetCalibratedTimestampsKHR(
        device,
        timestampCount,
        pTimestampInfos,
        pTimestamps,
        pMaxDeviation
    );
    try check(result);
}

pub fn CmdBindDescriptorSets2KHR(commandBuffer: vk.VkCommandBuffer, pBindDescriptorSetsInfo: ?*const vk.VkBindDescriptorSetsInfo) Error!void {
    const result = vk.vkCmdBindDescriptorSets2KHR(
        commandBuffer,
        pBindDescriptorSetsInfo
    );
    try check(result);
}

pub fn CmdPushConstants2KHR(commandBuffer: vk.VkCommandBuffer, pPushConstantsInfo: ?*const vk.VkPushConstantsInfo) Error!void {
    const result = vk.vkCmdPushConstants2KHR(
        commandBuffer,
        pPushConstantsInfo
    );
    try check(result);
}

pub fn CmdPushDescriptorSet2KHR(commandBuffer: vk.VkCommandBuffer, pPushDescriptorSetInfo: ?*const vk.VkPushDescriptorSetInfo) Error!void {
    const result = vk.vkCmdPushDescriptorSet2KHR(
        commandBuffer,
        pPushDescriptorSetInfo
    );
    try check(result);
}

pub fn CmdPushDescriptorSetWithTemplate2KHR(commandBuffer: vk.VkCommandBuffer, pPushDescriptorSetWithTemplateInfo: ?*const vk.VkPushDescriptorSetWithTemplateInfo) Error!void {
    const result = vk.vkCmdPushDescriptorSetWithTemplate2KHR(
        commandBuffer,
        pPushDescriptorSetWithTemplateInfo
    );
    try check(result);
}

pub fn CmdSetDescriptorBufferOffsets2EXT(commandBuffer: vk.VkCommandBuffer, pSetDescriptorBufferOffsetsInfo: ?*const vk.VkSetDescriptorBufferOffsetsInfoEXT) Error!void {
    const result = vk.vkCmdSetDescriptorBufferOffsets2EXT(
        commandBuffer,
        pSetDescriptorBufferOffsetsInfo
    );
    try check(result);
}

pub fn CmdBindDescriptorBufferEmbeddedSamplers2EXT(commandBuffer: vk.VkCommandBuffer, pBindDescriptorBufferEmbeddedSamplersInfo: ?*const vk.VkBindDescriptorBufferEmbeddedSamplersInfoEXT) Error!void {
    const result = vk.vkCmdBindDescriptorBufferEmbeddedSamplers2EXT(
        commandBuffer,
        pBindDescriptorBufferEmbeddedSamplersInfo
    );
    try check(result);
}

pub fn CreateDebugReportCallbackEXT(instance: vk.VkInstance, pCreateInfo: ?*const vk.VkDebugReportCallbackCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pCallback: ?*vk.VkDebugReportCallbackEXT) Error!void {
    const result = vk.vkCreateDebugReportCallbackEXT(
        instance,
        pCreateInfo,
        pAllocator,
        pCallback
    );
    try check(result);
}

pub fn DestroyDebugReportCallbackEXT(instance: vk.VkInstance, callback: vk.VkDebugReportCallbackEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDebugReportCallbackEXT(
        instance,
        callback,
        pAllocator
    );
    try check(result);
}

pub fn DebugReportMessageEXT(instance: vk.VkInstance, flags: vk.VkDebugReportFlagsEXT, objectType: vk.VkDebugReportObjectTypeEXT, object: vk.uint64_t, location: vk.size_t, messageCode: i32, pLayerPrefix: ?*const u8, pMessage: ?*const u8) Error!void {
    const result = vk.vkDebugReportMessageEXT(
        instance,
        flags,
        objectType,
        object,
        location,
        messageCode,
        pLayerPrefix,
        pMessage
    );
    try check(result);
}

pub fn DebugMarkerSetObjectTagEXT(device: vk.VkDevice, pTagInfo: ?*const vk.VkDebugMarkerObjectTagInfoEXT) Error!void {
    const result = vk.vkDebugMarkerSetObjectTagEXT(
        device,
        pTagInfo
    );
    try check(result);
}

pub fn DebugMarkerSetObjectNameEXT(device: vk.VkDevice, pNameInfo: ?*const vk.VkDebugMarkerObjectNameInfoEXT) Error!void {
    const result = vk.vkDebugMarkerSetObjectNameEXT(
        device,
        pNameInfo
    );
    try check(result);
}

pub fn CmdDebugMarkerBeginEXT(commandBuffer: vk.VkCommandBuffer, pMarkerInfo: ?*const vk.VkDebugMarkerMarkerInfoEXT) Error!void {
    const result = vk.vkCmdDebugMarkerBeginEXT(
        commandBuffer,
        pMarkerInfo
    );
    try check(result);
}

pub fn CmdDebugMarkerEndEXT(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdDebugMarkerEndEXT(
        commandBuffer
    );
    try check(result);
}

pub fn CmdDebugMarkerInsertEXT(commandBuffer: vk.VkCommandBuffer, pMarkerInfo: ?*const vk.VkDebugMarkerMarkerInfoEXT) Error!void {
    const result = vk.vkCmdDebugMarkerInsertEXT(
        commandBuffer,
        pMarkerInfo
    );
    try check(result);
}

pub fn CmdBindTransformFeedbackBuffersEXT(commandBuffer: vk.VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: ?[*]const vk.VkBuffer, pOffsets: ?[*]const vk.VkDeviceSize, pSizes: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdBindTransformFeedbackBuffersEXT(
        commandBuffer,
        firstBinding,
        bindingCount,
        pBuffers,
        pOffsets,
        pSizes
    );
    try check(result);
}

pub fn CmdBeginTransformFeedbackEXT(commandBuffer: vk.VkCommandBuffer, firstCounterBuffer: u32, counterBufferCount: u32, pCounterBuffers: ?[*]const vk.VkBuffer, pCounterBufferOffsets: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdBeginTransformFeedbackEXT(
        commandBuffer,
        firstCounterBuffer,
        counterBufferCount,
        pCounterBuffers,
        pCounterBufferOffsets
    );
    try check(result);
}

pub fn CmdEndTransformFeedbackEXT(commandBuffer: vk.VkCommandBuffer, firstCounterBuffer: u32, counterBufferCount: u32, pCounterBuffers: ?[*]const vk.VkBuffer, pCounterBufferOffsets: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdEndTransformFeedbackEXT(
        commandBuffer,
        firstCounterBuffer,
        counterBufferCount,
        pCounterBuffers,
        pCounterBufferOffsets
    );
    try check(result);
}

pub fn CmdBeginQueryIndexedEXT(commandBuffer: vk.VkCommandBuffer, queryPool: vk.VkQueryPool, query: u32, flags: vk.VkQueryControlFlags, index: u32) Error!void {
    const result = vk.vkCmdBeginQueryIndexedEXT(
        commandBuffer,
        queryPool,
        query,
        flags,
        index
    );
    try check(result);
}

pub fn CmdEndQueryIndexedEXT(commandBuffer: vk.VkCommandBuffer, queryPool: vk.VkQueryPool, query: u32, index: u32) Error!void {
    const result = vk.vkCmdEndQueryIndexedEXT(
        commandBuffer,
        queryPool,
        query,
        index
    );
    try check(result);
}

pub fn CmdDrawIndirectByteCountEXT(commandBuffer: vk.VkCommandBuffer, instanceCount: u32, firstInstance: u32, counterBuffer: vk.VkBuffer, counterBufferOffset: vk.VkDeviceSize, counterOffset: u32, vertexStride: u32) Error!void {
    const result = vk.vkCmdDrawIndirectByteCountEXT(
        commandBuffer,
        instanceCount,
        firstInstance,
        counterBuffer,
        counterBufferOffset,
        counterOffset,
        vertexStride
    );
    try check(result);
}

pub fn CreateCuModuleNVX(device: vk.VkDevice, pCreateInfo: ?*const vk.VkCuModuleCreateInfoNVX, pAllocator: ?*const vk.VkAllocationCallbacks, pModule: ?*vk.VkCuModuleNVX) Error!void {
    const result = vk.vkCreateCuModuleNVX(
        device,
        pCreateInfo,
        pAllocator,
        pModule
    );
    try check(result);
}

pub fn CreateCuFunctionNVX(device: vk.VkDevice, pCreateInfo: ?*const vk.VkCuFunctionCreateInfoNVX, pAllocator: ?*const vk.VkAllocationCallbacks, pFunction: ?*vk.VkCuFunctionNVX) Error!void {
    const result = vk.vkCreateCuFunctionNVX(
        device,
        pCreateInfo,
        pAllocator,
        pFunction
    );
    try check(result);
}

pub fn DestroyCuModuleNVX(device: vk.VkDevice, module: vk.VkCuModuleNVX, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyCuModuleNVX(
        device,
        module,
        pAllocator
    );
    try check(result);
}

pub fn DestroyCuFunctionNVX(device: vk.VkDevice, function: vk.VkCuFunctionNVX, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyCuFunctionNVX(
        device,
        function,
        pAllocator
    );
    try check(result);
}

pub fn CmdCuLaunchKernelNVX(commandBuffer: vk.VkCommandBuffer, pLaunchInfo: ?*const vk.VkCuLaunchInfoNVX) Error!void {
    const result = vk.vkCmdCuLaunchKernelNVX(
        commandBuffer,
        pLaunchInfo
    );
    try check(result);
}

pub fn GetImageViewAddressNVX(device: vk.VkDevice, imageView: vk.VkImageView, pProperties: ?[*]vk.VkImageViewAddressPropertiesNVX) Error!void {
    const result = vk.vkGetImageViewAddressNVX(
        device,
        imageView,
        pProperties
    );
    try check(result);
}

pub fn CmdDrawIndirectCountAMD(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndirectCountAMD(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn CmdDrawIndexedIndirectCountAMD(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawIndexedIndirectCountAMD(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn GetShaderInfoAMD(device: vk.VkDevice, pipeline: vk.VkPipeline, shaderStage: vk.VkShaderStageFlagBits, infoType: vk.VkShaderInfoTypeAMD, pInfoSize: ?*vk.size_t, pInfo: ?*void) Error!void {
    const result = vk.vkGetShaderInfoAMD(
        device,
        pipeline,
        shaderStage,
        infoType,
        pInfoSize,
        pInfo
    );
    try check(result);
}

pub fn GetPhysicalDeviceExternalImageFormatPropertiesNV(physicalDevice: vk.VkPhysicalDevice, format: vk.VkFormat, _type: vk.VkImageType, tiling: vk.VkImageTiling, usage: vk.VkImageUsageFlags, flags: vk.VkImageCreateFlags, externalHandleType: vk.VkExternalMemoryHandleTypeFlagsNV, pExternalImageFormatProperties: ?[*]vk.VkExternalImageFormatPropertiesNV) Error!void {
    const result = vk.vkGetPhysicalDeviceExternalImageFormatPropertiesNV(
        physicalDevice,
        format,
        _type,
        tiling,
        usage,
        flags,
        externalHandleType,
        pExternalImageFormatProperties
    );
    try check(result);
}

pub fn CmdBeginConditionalRenderingEXT(commandBuffer: vk.VkCommandBuffer, pConditionalRenderingBegin: ?*const vk.VkConditionalRenderingBeginInfoEXT) Error!void {
    const result = vk.vkCmdBeginConditionalRenderingEXT(
        commandBuffer,
        pConditionalRenderingBegin
    );
    try check(result);
}

pub fn CmdEndConditionalRenderingEXT(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdEndConditionalRenderingEXT(
        commandBuffer
    );
    try check(result);
}

pub fn CmdSetViewportWScalingNV(commandBuffer: vk.VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewportWScalings: ?[*]const vk.VkViewportWScalingNV) Error!void {
    const result = vk.vkCmdSetViewportWScalingNV(
        commandBuffer,
        firstViewport,
        viewportCount,
        pViewportWScalings
    );
    try check(result);
}

pub fn ReleaseDisplayEXT(physicalDevice: vk.VkPhysicalDevice, display: vk.VkDisplayKHR) Error!void {
    const result = vk.vkReleaseDisplayEXT(
        physicalDevice,
        display
    );
    try check(result);
}

pub fn GetPhysicalDeviceSurfaceCapabilities2EXT(physicalDevice: vk.VkPhysicalDevice, surface: vk.VkSurfaceKHR, pSurfaceCapabilities: ?[*]vk.VkSurfaceCapabilities2EXT) Error!void {
    const result = vk.vkGetPhysicalDeviceSurfaceCapabilities2EXT(
        physicalDevice,
        surface,
        pSurfaceCapabilities
    );
    try check(result);
}

pub fn DisplayPowerControlEXT(device: vk.VkDevice, display: vk.VkDisplayKHR, pDisplayPowerInfo: ?*const vk.VkDisplayPowerInfoEXT) Error!void {
    const result = vk.vkDisplayPowerControlEXT(
        device,
        display,
        pDisplayPowerInfo
    );
    try check(result);
}

pub fn RegisterDeviceEventEXT(device: vk.VkDevice, pDeviceEventInfo: ?*const vk.VkDeviceEventInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pFence: ?*vk.VkFence) Error!void {
    const result = vk.vkRegisterDeviceEventEXT(
        device,
        pDeviceEventInfo,
        pAllocator,
        pFence
    );
    try check(result);
}

pub fn RegisterDisplayEventEXT(device: vk.VkDevice, display: vk.VkDisplayKHR, pDisplayEventInfo: ?*const vk.VkDisplayEventInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pFence: ?*vk.VkFence) Error!void {
    const result = vk.vkRegisterDisplayEventEXT(
        device,
        display,
        pDisplayEventInfo,
        pAllocator,
        pFence
    );
    try check(result);
}

pub fn GetSwapchainCounterEXT(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, counter: vk.VkSurfaceCounterFlagBitsEXT, pCounterValue: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetSwapchainCounterEXT(
        device,
        swapchain,
        counter,
        pCounterValue
    );
    try check(result);
}

pub fn GetRefreshCycleDurationGOOGLE(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pDisplayTimingProperties: ?[*]vk.VkRefreshCycleDurationGOOGLE) Error!void {
    const result = vk.vkGetRefreshCycleDurationGOOGLE(
        device,
        swapchain,
        pDisplayTimingProperties
    );
    try check(result);
}

pub fn GetPastPresentationTimingGOOGLE(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pPresentationTimingCount: ?*u32, pPresentationTimings: ?[*]vk.VkPastPresentationTimingGOOGLE) Error!void {
    const result = vk.vkGetPastPresentationTimingGOOGLE(
        device,
        swapchain,
        pPresentationTimingCount,
        pPresentationTimings
    );
    try check(result);
}

pub fn CmdSetDiscardRectangleEXT(commandBuffer: vk.VkCommandBuffer, firstDiscardRectangle: u32, discardRectangleCount: u32, pDiscardRectangles: ?[*]const vk.VkRect2D) Error!void {
    const result = vk.vkCmdSetDiscardRectangleEXT(
        commandBuffer,
        firstDiscardRectangle,
        discardRectangleCount,
        pDiscardRectangles
    );
    try check(result);
}

pub fn CmdSetDiscardRectangleEnableEXT(commandBuffer: vk.VkCommandBuffer, discardRectangleEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDiscardRectangleEnableEXT(
        commandBuffer,
        discardRectangleEnable
    );
    try check(result);
}

pub fn CmdSetDiscardRectangleModeEXT(commandBuffer: vk.VkCommandBuffer, discardRectangleMode: vk.VkDiscardRectangleModeEXT) Error!void {
    const result = vk.vkCmdSetDiscardRectangleModeEXT(
        commandBuffer,
        discardRectangleMode
    );
    try check(result);
}

pub fn SetHdrMetadataEXT(device: vk.VkDevice, swapchainCount: u32, pSwapchains: ?[*]const vk.VkSwapchainKHR, pMetadata: ?*const vk.VkHdrMetadataEXT) Error!void {
    const result = vk.vkSetHdrMetadataEXT(
        device,
        swapchainCount,
        pSwapchains,
        pMetadata
    );
    try check(result);
}

pub fn SetDebugUtilsObjectNameEXT(device: vk.VkDevice, pNameInfo: ?*const vk.VkDebugUtilsObjectNameInfoEXT) Error!void {
    const result = vk.vkSetDebugUtilsObjectNameEXT(
        device,
        pNameInfo
    );
    try check(result);
}

pub fn SetDebugUtilsObjectTagEXT(device: vk.VkDevice, pTagInfo: ?*const vk.VkDebugUtilsObjectTagInfoEXT) Error!void {
    const result = vk.vkSetDebugUtilsObjectTagEXT(
        device,
        pTagInfo
    );
    try check(result);
}

pub fn QueueBeginDebugUtilsLabelEXT(queue: vk.VkQueue, pLabelInfo: ?*const vk.VkDebugUtilsLabelEXT) Error!void {
    const result = vk.vkQueueBeginDebugUtilsLabelEXT(
        queue,
        pLabelInfo
    );
    try check(result);
}

pub fn QueueEndDebugUtilsLabelEXT(queue: vk.VkQueue) Error!void {
    const result = vk.vkQueueEndDebugUtilsLabelEXT(
        queue
    );
    try check(result);
}

pub fn QueueInsertDebugUtilsLabelEXT(queue: vk.VkQueue, pLabelInfo: ?*const vk.VkDebugUtilsLabelEXT) Error!void {
    const result = vk.vkQueueInsertDebugUtilsLabelEXT(
        queue,
        pLabelInfo
    );
    try check(result);
}

pub fn CmdBeginDebugUtilsLabelEXT(commandBuffer: vk.VkCommandBuffer, pLabelInfo: ?*const vk.VkDebugUtilsLabelEXT) Error!void {
    const result = vk.vkCmdBeginDebugUtilsLabelEXT(
        commandBuffer,
        pLabelInfo
    );
    try check(result);
}

pub fn CmdEndDebugUtilsLabelEXT(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdEndDebugUtilsLabelEXT(
        commandBuffer
    );
    try check(result);
}

pub fn CmdInsertDebugUtilsLabelEXT(commandBuffer: vk.VkCommandBuffer, pLabelInfo: ?*const vk.VkDebugUtilsLabelEXT) Error!void {
    const result = vk.vkCmdInsertDebugUtilsLabelEXT(
        commandBuffer,
        pLabelInfo
    );
    try check(result);
}

pub fn CreateDebugUtilsMessengerEXT(instance: vk.VkInstance, pCreateInfo: ?*const vk.VkDebugUtilsMessengerCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pMessenger: ?*vk.VkDebugUtilsMessengerEXT) Error!void {
    const result = vk.vkCreateDebugUtilsMessengerEXT(
        instance,
        pCreateInfo,
        pAllocator,
        pMessenger
    );
    try check(result);
}

pub fn DestroyDebugUtilsMessengerEXT(instance: vk.VkInstance, messenger: vk.VkDebugUtilsMessengerEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyDebugUtilsMessengerEXT(
        instance,
        messenger,
        pAllocator
    );
    try check(result);
}

pub fn SubmitDebugUtilsMessageEXT(instance: vk.VkInstance, messageSeverity: vk.VkDebugUtilsMessageSeverityFlagBitsEXT, messageTypes: vk.VkDebugUtilsMessageTypeFlagsEXT, pCallbackData: ?*const vk.VkDebugUtilsMessengerCallbackDataEXT) Error!void {
    const result = vk.vkSubmitDebugUtilsMessageEXT(
        instance,
        messageSeverity,
        messageTypes,
        pCallbackData
    );
    try check(result);
}

pub fn CmdSetSampleLocationsEXT(commandBuffer: vk.VkCommandBuffer, pSampleLocationsInfo: ?*const vk.VkSampleLocationsInfoEXT) Error!void {
    const result = vk.vkCmdSetSampleLocationsEXT(
        commandBuffer,
        pSampleLocationsInfo
    );
    try check(result);
}

pub fn GetPhysicalDeviceMultisamplePropertiesEXT(physicalDevice: vk.VkPhysicalDevice, samples: vk.VkSampleCountFlagBits, pMultisampleProperties: ?[*]vk.VkMultisamplePropertiesEXT) Error!void {
    const result = vk.vkGetPhysicalDeviceMultisamplePropertiesEXT(
        physicalDevice,
        samples,
        pMultisampleProperties
    );
    try check(result);
}

pub fn GetImageDrmFormatModifierPropertiesEXT(device: vk.VkDevice, image: vk.VkImage, pProperties: ?[*]vk.VkImageDrmFormatModifierPropertiesEXT) Error!void {
    const result = vk.vkGetImageDrmFormatModifierPropertiesEXT(
        device,
        image,
        pProperties
    );
    try check(result);
}

pub fn CreateValidationCacheEXT(device: vk.VkDevice, pCreateInfo: ?*const vk.VkValidationCacheCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pValidationCache: ?*vk.VkValidationCacheEXT) Error!void {
    const result = vk.vkCreateValidationCacheEXT(
        device,
        pCreateInfo,
        pAllocator,
        pValidationCache
    );
    try check(result);
}

pub fn DestroyValidationCacheEXT(device: vk.VkDevice, validationCache: vk.VkValidationCacheEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyValidationCacheEXT(
        device,
        validationCache,
        pAllocator
    );
    try check(result);
}

pub fn MergeValidationCachesEXT(device: vk.VkDevice, dstCache: vk.VkValidationCacheEXT, srcCacheCount: u32, pSrcCaches: ?[*]const vk.VkValidationCacheEXT) Error!void {
    const result = vk.vkMergeValidationCachesEXT(
        device,
        dstCache,
        srcCacheCount,
        pSrcCaches
    );
    try check(result);
}

pub fn GetValidationCacheDataEXT(device: vk.VkDevice, validationCache: vk.VkValidationCacheEXT, pDataSize: ?*vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetValidationCacheDataEXT(
        device,
        validationCache,
        pDataSize,
        pData
    );
    try check(result);
}

pub fn CmdBindShadingRateImageNV(commandBuffer: vk.VkCommandBuffer, imageView: vk.VkImageView, imageLayout: vk.VkImageLayout) Error!void {
    const result = vk.vkCmdBindShadingRateImageNV(
        commandBuffer,
        imageView,
        imageLayout
    );
    try check(result);
}

pub fn CmdSetViewportShadingRatePaletteNV(commandBuffer: vk.VkCommandBuffer, firstViewport: u32, viewportCount: u32, pShadingRatePalettes: ?[*]const vk.VkShadingRatePaletteNV) Error!void {
    const result = vk.vkCmdSetViewportShadingRatePaletteNV(
        commandBuffer,
        firstViewport,
        viewportCount,
        pShadingRatePalettes
    );
    try check(result);
}

pub fn CmdSetCoarseSampleOrderNV(commandBuffer: vk.VkCommandBuffer, sampleOrderType: vk.VkCoarseSampleOrderTypeNV, customSampleOrderCount: u32, pCustomSampleOrders: ?[*]const vk.VkCoarseSampleOrderCustomNV) Error!void {
    const result = vk.vkCmdSetCoarseSampleOrderNV(
        commandBuffer,
        sampleOrderType,
        customSampleOrderCount,
        pCustomSampleOrders
    );
    try check(result);
}

pub fn CreateAccelerationStructureNV(device: vk.VkDevice, pCreateInfo: ?*const vk.VkAccelerationStructureCreateInfoNV, pAllocator: ?*const vk.VkAllocationCallbacks, pAccelerationStructure: ?*vk.VkAccelerationStructureNV) Error!void {
    const result = vk.vkCreateAccelerationStructureNV(
        device,
        pCreateInfo,
        pAllocator,
        pAccelerationStructure
    );
    try check(result);
}

pub fn DestroyAccelerationStructureNV(device: vk.VkDevice, accelerationStructure: vk.VkAccelerationStructureNV, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyAccelerationStructureNV(
        device,
        accelerationStructure,
        pAllocator
    );
    try check(result);
}

pub fn GetAccelerationStructureMemoryRequirementsNV(device: vk.VkDevice, pInfo: ?*const vk.VkAccelerationStructureMemoryRequirementsInfoNV, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2KHR) Error!void {
    const result = vk.vkGetAccelerationStructureMemoryRequirementsNV(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn BindAccelerationStructureMemoryNV(device: vk.VkDevice, bindInfoCount: u32, pBindInfos: ?[*]const vk.VkBindAccelerationStructureMemoryInfoNV) Error!void {
    const result = vk.vkBindAccelerationStructureMemoryNV(
        device,
        bindInfoCount,
        pBindInfos
    );
    try check(result);
}

pub fn CmdBuildAccelerationStructureNV(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkAccelerationStructureInfoNV, instanceData: vk.VkBuffer, instanceOffset: vk.VkDeviceSize, update: vk.VkBool32, dst: vk.VkAccelerationStructureNV, src: vk.VkAccelerationStructureNV, scratch: vk.VkBuffer, scratchOffset: vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdBuildAccelerationStructureNV(
        commandBuffer,
        pInfo,
        instanceData,
        instanceOffset,
        update,
        dst,
        src,
        scratch,
        scratchOffset
    );
    try check(result);
}

pub fn CmdCopyAccelerationStructureNV(commandBuffer: vk.VkCommandBuffer, dst: vk.VkAccelerationStructureNV, src: vk.VkAccelerationStructureNV, mode: vk.VkCopyAccelerationStructureModeKHR) Error!void {
    const result = vk.vkCmdCopyAccelerationStructureNV(
        commandBuffer,
        dst,
        src,
        mode
    );
    try check(result);
}

pub fn CmdTraceRaysNV(commandBuffer: vk.VkCommandBuffer, raygenShaderBindingTableBuffer: vk.VkBuffer, raygenShaderBindingOffset: vk.VkDeviceSize, missShaderBindingTableBuffer: vk.VkBuffer, missShaderBindingOffset: vk.VkDeviceSize, missShaderBindingStride: vk.VkDeviceSize, hitShaderBindingTableBuffer: vk.VkBuffer, hitShaderBindingOffset: vk.VkDeviceSize, hitShaderBindingStride: vk.VkDeviceSize, callableShaderBindingTableBuffer: vk.VkBuffer, callableShaderBindingOffset: vk.VkDeviceSize, callableShaderBindingStride: vk.VkDeviceSize, width: u32, height: u32, depth: u32) Error!void {
    const result = vk.vkCmdTraceRaysNV(
        commandBuffer,
        raygenShaderBindingTableBuffer,
        raygenShaderBindingOffset,
        missShaderBindingTableBuffer,
        missShaderBindingOffset,
        missShaderBindingStride,
        hitShaderBindingTableBuffer,
        hitShaderBindingOffset,
        hitShaderBindingStride,
        callableShaderBindingTableBuffer,
        callableShaderBindingOffset,
        callableShaderBindingStride,
        width,
        height,
        depth
    );
    try check(result);
}

pub fn CreateRayTracingPipelinesNV(device: vk.VkDevice, pipelineCache: vk.VkPipelineCache, createInfoCount: u32, pCreateInfos: ?[*]const vk.VkRayTracingPipelineCreateInfoNV, pAllocator: ?*const vk.VkAllocationCallbacks, pPipelines: ?[*]vk.VkPipeline) Error!void {
    const result = vk.vkCreateRayTracingPipelinesNV(
        device,
        pipelineCache,
        createInfoCount,
        pCreateInfos,
        pAllocator,
        pPipelines
    );
    try check(result);
}

pub fn GetRayTracingShaderGroupHandlesKHR(device: vk.VkDevice, pipeline: vk.VkPipeline, firstGroup: u32, groupCount: u32, dataSize: vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetRayTracingShaderGroupHandlesKHR(
        device,
        pipeline,
        firstGroup,
        groupCount,
        dataSize,
        pData
    );
    try check(result);
}

pub fn GetRayTracingShaderGroupHandlesNV(device: vk.VkDevice, pipeline: vk.VkPipeline, firstGroup: u32, groupCount: u32, dataSize: vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetRayTracingShaderGroupHandlesNV(
        device,
        pipeline,
        firstGroup,
        groupCount,
        dataSize,
        pData
    );
    try check(result);
}

pub fn GetAccelerationStructureHandleNV(device: vk.VkDevice, accelerationStructure: vk.VkAccelerationStructureNV, dataSize: vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetAccelerationStructureHandleNV(
        device,
        accelerationStructure,
        dataSize,
        pData
    );
    try check(result);
}

pub fn CmdWriteAccelerationStructuresPropertiesNV(commandBuffer: vk.VkCommandBuffer, accelerationStructureCount: u32, pAccelerationStructures: ?[*]const vk.VkAccelerationStructureNV, queryType: vk.VkQueryType, queryPool: vk.VkQueryPool, firstQuery: u32) Error!void {
    const result = vk.vkCmdWriteAccelerationStructuresPropertiesNV(
        commandBuffer,
        accelerationStructureCount,
        pAccelerationStructures,
        queryType,
        queryPool,
        firstQuery
    );
    try check(result);
}

pub fn CompileDeferredNV(device: vk.VkDevice, pipeline: vk.VkPipeline, shader: u32) Error!void {
    const result = vk.vkCompileDeferredNV(
        device,
        pipeline,
        shader
    );
    try check(result);
}

pub fn GetMemoryHostPointerPropertiesEXT(device: vk.VkDevice, handleType: vk.VkExternalMemoryHandleTypeFlagBits, pHostPointer: ?*const void, pMemoryHostPointerProperties: ?[*]vk.VkMemoryHostPointerPropertiesEXT) Error!void {
    const result = vk.vkGetMemoryHostPointerPropertiesEXT(
        device,
        handleType,
        pHostPointer,
        pMemoryHostPointerProperties
    );
    try check(result);
}

pub fn CmdWriteBufferMarkerAMD(commandBuffer: vk.VkCommandBuffer, pipelineStage: vk.VkPipelineStageFlagBits, dstBuffer: vk.VkBuffer, dstOffset: vk.VkDeviceSize, marker: u32) Error!void {
    const result = vk.vkCmdWriteBufferMarkerAMD(
        commandBuffer,
        pipelineStage,
        dstBuffer,
        dstOffset,
        marker
    );
    try check(result);
}

pub fn CmdWriteBufferMarker2AMD(commandBuffer: vk.VkCommandBuffer, stage: vk.VkPipelineStageFlags2, dstBuffer: vk.VkBuffer, dstOffset: vk.VkDeviceSize, marker: u32) Error!void {
    const result = vk.vkCmdWriteBufferMarker2AMD(
        commandBuffer,
        stage,
        dstBuffer,
        dstOffset,
        marker
    );
    try check(result);
}

pub fn GetPhysicalDeviceCalibrateableTimeDomainsEXT(physicalDevice: vk.VkPhysicalDevice, pTimeDomainCount: ?*u32, pTimeDomains: ?[*]vk.VkTimeDomainKHR) Error!void {
    const result = vk.vkGetPhysicalDeviceCalibrateableTimeDomainsEXT(
        physicalDevice,
        pTimeDomainCount,
        pTimeDomains
    );
    try check(result);
}

pub fn GetCalibratedTimestampsEXT(device: vk.VkDevice, timestampCount: u32, pTimestampInfos: ?[*]const vk.VkCalibratedTimestampInfoKHR, pTimestamps: ?[*]vk.uint64_t, pMaxDeviation: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetCalibratedTimestampsEXT(
        device,
        timestampCount,
        pTimestampInfos,
        pTimestamps,
        pMaxDeviation
    );
    try check(result);
}

pub fn CmdDrawMeshTasksNV(commandBuffer: vk.VkCommandBuffer, taskCount: u32, firstTask: u32) Error!void {
    const result = vk.vkCmdDrawMeshTasksNV(
        commandBuffer,
        taskCount,
        firstTask
    );
    try check(result);
}

pub fn CmdDrawMeshTasksIndirectNV(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, drawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawMeshTasksIndirectNV(
        commandBuffer,
        buffer,
        offset,
        drawCount,
        stride
    );
    try check(result);
}

pub fn CmdDrawMeshTasksIndirectCountNV(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawMeshTasksIndirectCountNV(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

pub fn CmdSetExclusiveScissorEnableNV(commandBuffer: vk.VkCommandBuffer, firstExclusiveScissor: u32, exclusiveScissorCount: u32, pExclusiveScissorEnables: ?[*]const vk.VkBool32) Error!void {
    const result = vk.vkCmdSetExclusiveScissorEnableNV(
        commandBuffer,
        firstExclusiveScissor,
        exclusiveScissorCount,
        pExclusiveScissorEnables
    );
    try check(result);
}

pub fn CmdSetExclusiveScissorNV(commandBuffer: vk.VkCommandBuffer, firstExclusiveScissor: u32, exclusiveScissorCount: u32, pExclusiveScissors: ?[*]const vk.VkRect2D) Error!void {
    const result = vk.vkCmdSetExclusiveScissorNV(
        commandBuffer,
        firstExclusiveScissor,
        exclusiveScissorCount,
        pExclusiveScissors
    );
    try check(result);
}

pub fn CmdSetCheckpointNV(commandBuffer: vk.VkCommandBuffer, pCheckpointMarker: ?*const void) Error!void {
    const result = vk.vkCmdSetCheckpointNV(
        commandBuffer,
        pCheckpointMarker
    );
    try check(result);
}

pub fn GetQueueCheckpointDataNV(queue: vk.VkQueue, pCheckpointDataCount: ?*u32, pCheckpointData: ?*vk.VkCheckpointDataNV) Error!void {
    const result = vk.vkGetQueueCheckpointDataNV(
        queue,
        pCheckpointDataCount,
        pCheckpointData
    );
    try check(result);
}

pub fn GetQueueCheckpointData2NV(queue: vk.VkQueue, pCheckpointDataCount: ?*u32, pCheckpointData: ?*vk.VkCheckpointData2NV) Error!void {
    const result = vk.vkGetQueueCheckpointData2NV(
        queue,
        pCheckpointDataCount,
        pCheckpointData
    );
    try check(result);
}

pub fn InitializePerformanceApiINTEL(device: vk.VkDevice, pInitializeInfo: ?*const vk.VkInitializePerformanceApiInfoINTEL) Error!void {
    const result = vk.vkInitializePerformanceApiINTEL(
        device,
        pInitializeInfo
    );
    try check(result);
}

pub fn UninitializePerformanceApiINTEL(device: vk.VkDevice) Error!void {
    const result = vk.vkUninitializePerformanceApiINTEL(
        device
    );
    try check(result);
}

pub fn CmdSetPerformanceMarkerINTEL(commandBuffer: vk.VkCommandBuffer, pMarkerInfo: ?*const vk.VkPerformanceMarkerInfoINTEL) Error!void {
    const result = vk.vkCmdSetPerformanceMarkerINTEL(
        commandBuffer,
        pMarkerInfo
    );
    try check(result);
}

pub fn CmdSetPerformanceStreamMarkerINTEL(commandBuffer: vk.VkCommandBuffer, pMarkerInfo: ?*const vk.VkPerformanceStreamMarkerInfoINTEL) Error!void {
    const result = vk.vkCmdSetPerformanceStreamMarkerINTEL(
        commandBuffer,
        pMarkerInfo
    );
    try check(result);
}

pub fn CmdSetPerformanceOverrideINTEL(commandBuffer: vk.VkCommandBuffer, pOverrideInfo: ?*const vk.VkPerformanceOverrideInfoINTEL) Error!void {
    const result = vk.vkCmdSetPerformanceOverrideINTEL(
        commandBuffer,
        pOverrideInfo
    );
    try check(result);
}

pub fn AcquirePerformanceConfigurationINTEL(device: vk.VkDevice, pAcquireInfo: ?*const vk.VkPerformanceConfigurationAcquireInfoINTEL, pConfiguration: ?*vk.VkPerformanceConfigurationINTEL) Error!void {
    const result = vk.vkAcquirePerformanceConfigurationINTEL(
        device,
        pAcquireInfo,
        pConfiguration
    );
    try check(result);
}

pub fn ReleasePerformanceConfigurationINTEL(device: vk.VkDevice, configuration: vk.VkPerformanceConfigurationINTEL) Error!void {
    const result = vk.vkReleasePerformanceConfigurationINTEL(
        device,
        configuration
    );
    try check(result);
}

pub fn QueueSetPerformanceConfigurationINTEL(queue: vk.VkQueue, configuration: vk.VkPerformanceConfigurationINTEL) Error!void {
    const result = vk.vkQueueSetPerformanceConfigurationINTEL(
        queue,
        configuration
    );
    try check(result);
}

pub fn GetPerformanceParameterINTEL(device: vk.VkDevice, parameter: vk.VkPerformanceParameterTypeINTEL, pValue: ?*vk.VkPerformanceValueINTEL) Error!void {
    const result = vk.vkGetPerformanceParameterINTEL(
        device,
        parameter,
        pValue
    );
    try check(result);
}

pub fn SetLocalDimmingAMD(device: vk.VkDevice, swapChain: vk.VkSwapchainKHR, localDimmingEnable: vk.VkBool32) Error!void {
    const result = vk.vkSetLocalDimmingAMD(
        device,
        swapChain,
        localDimmingEnable
    );
    try check(result);
}

pub fn GetBufferDeviceAddressEXT(device: vk.VkDevice, pInfo: ?*const vk.VkBufferDeviceAddressInfo) Error!void {
    const result = vk.vkGetBufferDeviceAddressEXT(
        device,
        pInfo
    );
    try check(result);
}

pub fn GetPhysicalDeviceToolPropertiesEXT(physicalDevice: vk.VkPhysicalDevice, pToolCount: ?*u32, pToolProperties: ?[*]vk.VkPhysicalDeviceToolProperties) Error!void {
    const result = vk.vkGetPhysicalDeviceToolPropertiesEXT(
        physicalDevice,
        pToolCount,
        pToolProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceCooperativeMatrixPropertiesNV(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkCooperativeMatrixPropertiesNV) Error!void {
    const result = vk.vkGetPhysicalDeviceCooperativeMatrixPropertiesNV(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV(physicalDevice: vk.VkPhysicalDevice, pCombinationCount: ?*u32, pCombinations: ?[*]vk.VkFramebufferMixedSamplesCombinationNV) Error!void {
    const result = vk.vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV(
        physicalDevice,
        pCombinationCount,
        pCombinations
    );
    try check(result);
}

pub fn CreateHeadlessSurfaceEXT(instance: vk.VkInstance, pCreateInfo: ?*const vk.VkHeadlessSurfaceCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pSurface: ?*vk.VkSurfaceKHR) Error!void {
    const result = vk.vkCreateHeadlessSurfaceEXT(
        instance,
        pCreateInfo,
        pAllocator,
        pSurface
    );
    try check(result);
}

pub fn CmdSetLineStippleEXT(commandBuffer: vk.VkCommandBuffer, lineStippleFactor: u32, lineStipplePattern: vk.uint16_t) Error!void {
    const result = vk.vkCmdSetLineStippleEXT(
        commandBuffer,
        lineStippleFactor,
        lineStipplePattern
    );
    try check(result);
}

pub fn ResetQueryPoolEXT(device: vk.VkDevice, queryPool: vk.VkQueryPool, firstQuery: u32, queryCount: u32) Error!void {
    const result = vk.vkResetQueryPoolEXT(
        device,
        queryPool,
        firstQuery,
        queryCount
    );
    try check(result);
}

pub fn CmdSetCullModeEXT(commandBuffer: vk.VkCommandBuffer, cullMode: vk.VkCullModeFlags) Error!void {
    const result = vk.vkCmdSetCullModeEXT(
        commandBuffer,
        cullMode
    );
    try check(result);
}

pub fn CmdSetFrontFaceEXT(commandBuffer: vk.VkCommandBuffer, frontFace: vk.VkFrontFace) Error!void {
    const result = vk.vkCmdSetFrontFaceEXT(
        commandBuffer,
        frontFace
    );
    try check(result);
}

pub fn CmdSetPrimitiveTopologyEXT(commandBuffer: vk.VkCommandBuffer, primitiveTopology: vk.VkPrimitiveTopology) Error!void {
    const result = vk.vkCmdSetPrimitiveTopologyEXT(
        commandBuffer,
        primitiveTopology
    );
    try check(result);
}

pub fn CmdSetViewportWithCountEXT(commandBuffer: vk.VkCommandBuffer, viewportCount: u32, pViewports: ?[*]const vk.VkViewport) Error!void {
    const result = vk.vkCmdSetViewportWithCountEXT(
        commandBuffer,
        viewportCount,
        pViewports
    );
    try check(result);
}

pub fn CmdSetScissorWithCountEXT(commandBuffer: vk.VkCommandBuffer, scissorCount: u32, pScissors: ?[*]const vk.VkRect2D) Error!void {
    const result = vk.vkCmdSetScissorWithCountEXT(
        commandBuffer,
        scissorCount,
        pScissors
    );
    try check(result);
}

pub fn CmdBindVertexBuffers2EXT(commandBuffer: vk.VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: ?[*]const vk.VkBuffer, pOffsets: ?[*]const vk.VkDeviceSize, pSizes: ?[*]const vk.VkDeviceSize, pStrides: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdBindVertexBuffers2EXT(
        commandBuffer,
        firstBinding,
        bindingCount,
        pBuffers,
        pOffsets,
        pSizes,
        pStrides
    );
    try check(result);
}

pub fn CmdSetDepthTestEnableEXT(commandBuffer: vk.VkCommandBuffer, depthTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthTestEnableEXT(
        commandBuffer,
        depthTestEnable
    );
    try check(result);
}

pub fn CmdSetDepthWriteEnableEXT(commandBuffer: vk.VkCommandBuffer, depthWriteEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthWriteEnableEXT(
        commandBuffer,
        depthWriteEnable
    );
    try check(result);
}

pub fn CmdSetDepthCompareOpEXT(commandBuffer: vk.VkCommandBuffer, depthCompareOp: vk.VkCompareOp) Error!void {
    const result = vk.vkCmdSetDepthCompareOpEXT(
        commandBuffer,
        depthCompareOp
    );
    try check(result);
}

pub fn CmdSetDepthBoundsTestEnableEXT(commandBuffer: vk.VkCommandBuffer, depthBoundsTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthBoundsTestEnableEXT(
        commandBuffer,
        depthBoundsTestEnable
    );
    try check(result);
}

pub fn CmdSetStencilTestEnableEXT(commandBuffer: vk.VkCommandBuffer, stencilTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetStencilTestEnableEXT(
        commandBuffer,
        stencilTestEnable
    );
    try check(result);
}

pub fn CmdSetStencilOpEXT(commandBuffer: vk.VkCommandBuffer, faceMask: vk.VkStencilFaceFlags, failOp: vk.VkStencilOp, passOp: vk.VkStencilOp, depthFailOp: vk.VkStencilOp, compareOp: vk.VkCompareOp) Error!void {
    const result = vk.vkCmdSetStencilOpEXT(
        commandBuffer,
        faceMask,
        failOp,
        passOp,
        depthFailOp,
        compareOp
    );
    try check(result);
}

pub fn CopyMemoryToImageEXT(device: vk.VkDevice, pCopyMemoryToImageInfo: ?*const vk.VkCopyMemoryToImageInfo) Error!void {
    const result = vk.vkCopyMemoryToImageEXT(
        device,
        pCopyMemoryToImageInfo
    );
    try check(result);
}

pub fn CopyImageToMemoryEXT(device: vk.VkDevice, pCopyImageToMemoryInfo: ?*const vk.VkCopyImageToMemoryInfo) Error!void {
    const result = vk.vkCopyImageToMemoryEXT(
        device,
        pCopyImageToMemoryInfo
    );
    try check(result);
}

pub fn CopyImageToImageEXT(device: vk.VkDevice, pCopyImageToImageInfo: ?*const vk.VkCopyImageToImageInfo) Error!void {
    const result = vk.vkCopyImageToImageEXT(
        device,
        pCopyImageToImageInfo
    );
    try check(result);
}

pub fn TransitionImageLayoutEXT(device: vk.VkDevice, transitionCount: u32, pTransitions: ?[*]const vk.VkHostImageLayoutTransitionInfo) Error!void {
    const result = vk.vkTransitionImageLayoutEXT(
        device,
        transitionCount,
        pTransitions
    );
    try check(result);
}

pub fn GetImageSubresourceLayout2EXT(device: vk.VkDevice, image: vk.VkImage, pSubresource: ?*const vk.VkImageSubresource2, pLayout: ?*vk.VkSubresourceLayout2) Error!void {
    const result = vk.vkGetImageSubresourceLayout2EXT(
        device,
        image,
        pSubresource,
        pLayout
    );
    try check(result);
}

pub fn ReleaseSwapchainImagesEXT(device: vk.VkDevice, pReleaseInfo: ?*const vk.VkReleaseSwapchainImagesInfoEXT) Error!void {
    const result = vk.vkReleaseSwapchainImagesEXT(
        device,
        pReleaseInfo
    );
    try check(result);
}

pub fn GetGeneratedCommandsMemoryRequirementsNV(device: vk.VkDevice, pInfo: ?*const vk.VkGeneratedCommandsMemoryRequirementsInfoNV, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetGeneratedCommandsMemoryRequirementsNV(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn CmdPreprocessGeneratedCommandsNV(commandBuffer: vk.VkCommandBuffer, pGeneratedCommandsInfo: ?*const vk.VkGeneratedCommandsInfoNV) Error!void {
    const result = vk.vkCmdPreprocessGeneratedCommandsNV(
        commandBuffer,
        pGeneratedCommandsInfo
    );
    try check(result);
}

pub fn CmdExecuteGeneratedCommandsNV(commandBuffer: vk.VkCommandBuffer, isPreprocessed: vk.VkBool32, pGeneratedCommandsInfo: ?*const vk.VkGeneratedCommandsInfoNV) Error!void {
    const result = vk.vkCmdExecuteGeneratedCommandsNV(
        commandBuffer,
        isPreprocessed,
        pGeneratedCommandsInfo
    );
    try check(result);
}

pub fn CmdBindPipelineShaderGroupNV(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, pipeline: vk.VkPipeline, groupIndex: u32) Error!void {
    const result = vk.vkCmdBindPipelineShaderGroupNV(
        commandBuffer,
        pipelineBindPoint,
        pipeline,
        groupIndex
    );
    try check(result);
}

pub fn CreateIndirectCommandsLayoutNV(device: vk.VkDevice, pCreateInfo: ?*const vk.VkIndirectCommandsLayoutCreateInfoNV, pAllocator: ?*const vk.VkAllocationCallbacks, pIndirectCommandsLayout: ?*vk.VkIndirectCommandsLayoutNV) Error!void {
    const result = vk.vkCreateIndirectCommandsLayoutNV(
        device,
        pCreateInfo,
        pAllocator,
        pIndirectCommandsLayout
    );
    try check(result);
}

pub fn DestroyIndirectCommandsLayoutNV(device: vk.VkDevice, indirectCommandsLayout: vk.VkIndirectCommandsLayoutNV, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyIndirectCommandsLayoutNV(
        device,
        indirectCommandsLayout,
        pAllocator
    );
    try check(result);
}

pub fn CmdSetDepthBias2EXT(commandBuffer: vk.VkCommandBuffer, pDepthBiasInfo: ?*const vk.VkDepthBiasInfoEXT) Error!void {
    const result = vk.vkCmdSetDepthBias2EXT(
        commandBuffer,
        pDepthBiasInfo
    );
    try check(result);
}

pub fn AcquireDrmDisplayEXT(physicalDevice: vk.VkPhysicalDevice, drmFd: i32, display: vk.VkDisplayKHR) Error!void {
    const result = vk.vkAcquireDrmDisplayEXT(
        physicalDevice,
        drmFd,
        display
    );
    try check(result);
}

pub fn GetDrmDisplayEXT(physicalDevice: vk.VkPhysicalDevice, drmFd: i32, connectorId: u32, display: ?*vk.VkDisplayKHR) Error!void {
    const result = vk.vkGetDrmDisplayEXT(
        physicalDevice,
        drmFd,
        connectorId,
        display
    );
    try check(result);
}

pub fn CreatePrivateDataSlotEXT(device: vk.VkDevice, pCreateInfo: ?*const vk.VkPrivateDataSlotCreateInfo, pAllocator: ?*const vk.VkAllocationCallbacks, pPrivateDataSlot: ?*vk.VkPrivateDataSlot) Error!void {
    const result = vk.vkCreatePrivateDataSlotEXT(
        device,
        pCreateInfo,
        pAllocator,
        pPrivateDataSlot
    );
    try check(result);
}

pub fn DestroyPrivateDataSlotEXT(device: vk.VkDevice, privateDataSlot: vk.VkPrivateDataSlot, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyPrivateDataSlotEXT(
        device,
        privateDataSlot,
        pAllocator
    );
    try check(result);
}

pub fn SetPrivateDataEXT(device: vk.VkDevice, objectType: vk.VkObjectType, objectHandle: vk.uint64_t, privateDataSlot: vk.VkPrivateDataSlot, data: vk.uint64_t) Error!void {
    const result = vk.vkSetPrivateDataEXT(
        device,
        objectType,
        objectHandle,
        privateDataSlot,
        data
    );
    try check(result);
}

pub fn GetPrivateDataEXT(device: vk.VkDevice, objectType: vk.VkObjectType, objectHandle: vk.uint64_t, privateDataSlot: vk.VkPrivateDataSlot, pData: ?*vk.uint64_t) Error!void {
    const result = vk.vkGetPrivateDataEXT(
        device,
        objectType,
        objectHandle,
        privateDataSlot,
        pData
    );
    try check(result);
}

pub fn CreateCudaModuleNV(device: vk.VkDevice, pCreateInfo: ?*const vk.VkCudaModuleCreateInfoNV, pAllocator: ?*const vk.VkAllocationCallbacks, pModule: ?*vk.VkCudaModuleNV) Error!void {
    const result = vk.vkCreateCudaModuleNV(
        device,
        pCreateInfo,
        pAllocator,
        pModule
    );
    try check(result);
}

pub fn GetCudaModuleCacheNV(device: vk.VkDevice, module: vk.VkCudaModuleNV, pCacheSize: ?*vk.size_t, pCacheData: ?*void) Error!void {
    const result = vk.vkGetCudaModuleCacheNV(
        device,
        module,
        pCacheSize,
        pCacheData
    );
    try check(result);
}

pub fn CreateCudaFunctionNV(device: vk.VkDevice, pCreateInfo: ?*const vk.VkCudaFunctionCreateInfoNV, pAllocator: ?*const vk.VkAllocationCallbacks, pFunction: ?*vk.VkCudaFunctionNV) Error!void {
    const result = vk.vkCreateCudaFunctionNV(
        device,
        pCreateInfo,
        pAllocator,
        pFunction
    );
    try check(result);
}

pub fn DestroyCudaModuleNV(device: vk.VkDevice, module: vk.VkCudaModuleNV, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyCudaModuleNV(
        device,
        module,
        pAllocator
    );
    try check(result);
}

pub fn DestroyCudaFunctionNV(device: vk.VkDevice, function: vk.VkCudaFunctionNV, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyCudaFunctionNV(
        device,
        function,
        pAllocator
    );
    try check(result);
}

pub fn CmdCudaLaunchKernelNV(commandBuffer: vk.VkCommandBuffer, pLaunchInfo: ?*const vk.VkCudaLaunchInfoNV) Error!void {
    const result = vk.vkCmdCudaLaunchKernelNV(
        commandBuffer,
        pLaunchInfo
    );
    try check(result);
}

pub fn GetDescriptorSetLayoutSizeEXT(device: vk.VkDevice, layout: vk.VkDescriptorSetLayout, pLayoutSizeInBytes: ?[*]vk.VkDeviceSize) Error!void {
    const result = vk.vkGetDescriptorSetLayoutSizeEXT(
        device,
        layout,
        pLayoutSizeInBytes
    );
    try check(result);
}

pub fn GetDescriptorSetLayoutBindingOffsetEXT(device: vk.VkDevice, layout: vk.VkDescriptorSetLayout, binding: u32, pOffset: ?*vk.VkDeviceSize) Error!void {
    const result = vk.vkGetDescriptorSetLayoutBindingOffsetEXT(
        device,
        layout,
        binding,
        pOffset
    );
    try check(result);
}

pub fn GetDescriptorEXT(device: vk.VkDevice, pDescriptorInfo: ?*const vk.VkDescriptorGetInfoEXT, dataSize: vk.size_t, pDescriptor: ?*void) Error!void {
    const result = vk.vkGetDescriptorEXT(
        device,
        pDescriptorInfo,
        dataSize,
        pDescriptor
    );
    try check(result);
}

pub fn CmdBindDescriptorBuffersEXT(commandBuffer: vk.VkCommandBuffer, bufferCount: u32, pBindingInfos: ?[*]const vk.VkDescriptorBufferBindingInfoEXT) Error!void {
    const result = vk.vkCmdBindDescriptorBuffersEXT(
        commandBuffer,
        bufferCount,
        pBindingInfos
    );
    try check(result);
}

pub fn CmdSetDescriptorBufferOffsetsEXT(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, layout: vk.VkPipelineLayout, firstSet: u32, setCount: u32, pBufferIndices: ?[*]const u32, pOffsets: ?[*]const vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdSetDescriptorBufferOffsetsEXT(
        commandBuffer,
        pipelineBindPoint,
        layout,
        firstSet,
        setCount,
        pBufferIndices,
        pOffsets
    );
    try check(result);
}

pub fn CmdBindDescriptorBufferEmbeddedSamplersEXT(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, layout: vk.VkPipelineLayout, set: u32) Error!void {
    const result = vk.vkCmdBindDescriptorBufferEmbeddedSamplersEXT(
        commandBuffer,
        pipelineBindPoint,
        layout,
        set
    );
    try check(result);
}

pub fn GetBufferOpaqueCaptureDescriptorDataEXT(device: vk.VkDevice, pInfo: ?*const vk.VkBufferCaptureDescriptorDataInfoEXT, pData: ?*void) Error!void {
    const result = vk.vkGetBufferOpaqueCaptureDescriptorDataEXT(
        device,
        pInfo,
        pData
    );
    try check(result);
}

pub fn GetImageOpaqueCaptureDescriptorDataEXT(device: vk.VkDevice, pInfo: ?*const vk.VkImageCaptureDescriptorDataInfoEXT, pData: ?*void) Error!void {
    const result = vk.vkGetImageOpaqueCaptureDescriptorDataEXT(
        device,
        pInfo,
        pData
    );
    try check(result);
}

pub fn GetImageViewOpaqueCaptureDescriptorDataEXT(device: vk.VkDevice, pInfo: ?*const vk.VkImageViewCaptureDescriptorDataInfoEXT, pData: ?*void) Error!void {
    const result = vk.vkGetImageViewOpaqueCaptureDescriptorDataEXT(
        device,
        pInfo,
        pData
    );
    try check(result);
}

pub fn GetSamplerOpaqueCaptureDescriptorDataEXT(device: vk.VkDevice, pInfo: ?*const vk.VkSamplerCaptureDescriptorDataInfoEXT, pData: ?*void) Error!void {
    const result = vk.vkGetSamplerOpaqueCaptureDescriptorDataEXT(
        device,
        pInfo,
        pData
    );
    try check(result);
}

pub fn GetAccelerationStructureOpaqueCaptureDescriptorDataEXT(device: vk.VkDevice, pInfo: ?*const vk.VkAccelerationStructureCaptureDescriptorDataInfoEXT, pData: ?*void) Error!void {
    const result = vk.vkGetAccelerationStructureOpaqueCaptureDescriptorDataEXT(
        device,
        pInfo,
        pData
    );
    try check(result);
}

pub fn CmdSetFragmentShadingRateEnumNV(commandBuffer: vk.VkCommandBuffer, shadingRate: vk.VkFragmentShadingRateNV, combinerOps: vk.VkFragmentShadingRateCombinerOpKHR) Error!void {
    const result = vk.vkCmdSetFragmentShadingRateEnumNV(
        commandBuffer,
        shadingRate,
        combinerOps
    );
    try check(result);
}

pub fn GetDeviceFaultInfoEXT(device: vk.VkDevice, pFaultCounts: ?[*]vk.VkDeviceFaultCountsEXT, pFaultInfo: ?*vk.VkDeviceFaultInfoEXT) Error!void {
    const result = vk.vkGetDeviceFaultInfoEXT(
        device,
        pFaultCounts,
        pFaultInfo
    );
    try check(result);
}

pub fn CmdSetVertexInputEXT(commandBuffer: vk.VkCommandBuffer, vertexBindingDescriptionCount: u32, pVertexBindingDescriptions: ?[*]const vk.VkVertexInputBindingDescription2EXT, vertexAttributeDescriptionCount: u32, pVertexAttributeDescriptions: ?[*]const vk.VkVertexInputAttributeDescription2EXT) Error!void {
    const result = vk.vkCmdSetVertexInputEXT(
        commandBuffer,
        vertexBindingDescriptionCount,
        pVertexBindingDescriptions,
        vertexAttributeDescriptionCount,
        pVertexAttributeDescriptions
    );
    try check(result);
}

pub fn GetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI(device: vk.VkDevice, renderpass: vk.VkRenderPass, pMaxWorkgroupSize: ?*vk.VkExtent2D) Error!void {
    const result = vk.vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI(
        device,
        renderpass,
        pMaxWorkgroupSize
    );
    try check(result);
}

pub fn CmdSubpassShadingHUAWEI(commandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdSubpassShadingHUAWEI(
        commandBuffer
    );
    try check(result);
}

pub fn CmdBindInvocationMaskHUAWEI(commandBuffer: vk.VkCommandBuffer, imageView: vk.VkImageView, imageLayout: vk.VkImageLayout) Error!void {
    const result = vk.vkCmdBindInvocationMaskHUAWEI(
        commandBuffer,
        imageView,
        imageLayout
    );
    try check(result);
}

pub fn GetMemoryRemoteAddressNV(device: vk.VkDevice, pMemoryGetRemoteAddressInfo: ?*const vk.VkMemoryGetRemoteAddressInfoNV, pAddress: ?[*]vk.VkRemoteAddressNV) Error!void {
    const result = vk.vkGetMemoryRemoteAddressNV(
        device,
        pMemoryGetRemoteAddressInfo,
        pAddress
    );
    try check(result);
}

pub fn GetPipelinePropertiesEXT(device: vk.VkDevice, pPipelineInfo: ?*const vk.VkPipelineInfoEXT, pPipelineProperties: ?[*]vk.VkBaseOutStructure) Error!void {
    const result = vk.vkGetPipelinePropertiesEXT(
        device,
        pPipelineInfo,
        pPipelineProperties
    );
    try check(result);
}

pub fn CmdSetPatchControlPointsEXT(commandBuffer: vk.VkCommandBuffer, patchControlPoints: u32) Error!void {
    const result = vk.vkCmdSetPatchControlPointsEXT(
        commandBuffer,
        patchControlPoints
    );
    try check(result);
}

pub fn CmdSetRasterizerDiscardEnableEXT(commandBuffer: vk.VkCommandBuffer, rasterizerDiscardEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetRasterizerDiscardEnableEXT(
        commandBuffer,
        rasterizerDiscardEnable
    );
    try check(result);
}

pub fn CmdSetDepthBiasEnableEXT(commandBuffer: vk.VkCommandBuffer, depthBiasEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthBiasEnableEXT(
        commandBuffer,
        depthBiasEnable
    );
    try check(result);
}

pub fn CmdSetLogicOpEXT(commandBuffer: vk.VkCommandBuffer, logicOp: vk.VkLogicOp) Error!void {
    const result = vk.vkCmdSetLogicOpEXT(
        commandBuffer,
        logicOp
    );
    try check(result);
}

pub fn CmdSetPrimitiveRestartEnableEXT(commandBuffer: vk.VkCommandBuffer, primitiveRestartEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetPrimitiveRestartEnableEXT(
        commandBuffer,
        primitiveRestartEnable
    );
    try check(result);
}

pub fn CmdDrawMultiEXT(commandBuffer: vk.VkCommandBuffer, drawCount: u32, pVertexInfo: ?*const vk.VkMultiDrawInfoEXT, instanceCount: u32, firstInstance: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawMultiEXT(
        commandBuffer,
        drawCount,
        pVertexInfo,
        instanceCount,
        firstInstance,
        stride
    );
    try check(result);
}

pub fn CmdDrawMultiIndexedEXT(commandBuffer: vk.VkCommandBuffer, drawCount: u32, pIndexInfo: ?*const vk.VkMultiDrawIndexedInfoEXT, instanceCount: u32, firstInstance: u32, stride: u32, pVertexOffset: ?*const i32) Error!void {
    const result = vk.vkCmdDrawMultiIndexedEXT(
        commandBuffer,
        drawCount,
        pIndexInfo,
        instanceCount,
        firstInstance,
        stride,
        pVertexOffset
    );
    try check(result);
}

pub fn CreateMicromapEXT(device: vk.VkDevice, pCreateInfo: ?*const vk.VkMicromapCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pMicromap: ?*vk.VkMicromapEXT) Error!void {
    const result = vk.vkCreateMicromapEXT(
        device,
        pCreateInfo,
        pAllocator,
        pMicromap
    );
    try check(result);
}

pub fn DestroyMicromapEXT(device: vk.VkDevice, micromap: vk.VkMicromapEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyMicromapEXT(
        device,
        micromap,
        pAllocator
    );
    try check(result);
}

pub fn CmdBuildMicromapsEXT(commandBuffer: vk.VkCommandBuffer, infoCount: u32, pInfos: ?[*]const vk.VkMicromapBuildInfoEXT) Error!void {
    const result = vk.vkCmdBuildMicromapsEXT(
        commandBuffer,
        infoCount,
        pInfos
    );
    try check(result);
}

pub fn BuildMicromapsEXT(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, infoCount: u32, pInfos: ?[*]const vk.VkMicromapBuildInfoEXT) Error!void {
    const result = vk.vkBuildMicromapsEXT(
        device,
        deferredOperation,
        infoCount,
        pInfos
    );
    try check(result);
}

pub fn CopyMicromapEXT(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pInfo: ?*const vk.VkCopyMicromapInfoEXT) Error!void {
    const result = vk.vkCopyMicromapEXT(
        device,
        deferredOperation,
        pInfo
    );
    try check(result);
}

pub fn CopyMicromapToMemoryEXT(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pInfo: ?*const vk.VkCopyMicromapToMemoryInfoEXT) Error!void {
    const result = vk.vkCopyMicromapToMemoryEXT(
        device,
        deferredOperation,
        pInfo
    );
    try check(result);
}

pub fn CopyMemoryToMicromapEXT(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pInfo: ?*const vk.VkCopyMemoryToMicromapInfoEXT) Error!void {
    const result = vk.vkCopyMemoryToMicromapEXT(
        device,
        deferredOperation,
        pInfo
    );
    try check(result);
}

pub fn WriteMicromapsPropertiesEXT(device: vk.VkDevice, micromapCount: u32, pMicromaps: ?[*]const vk.VkMicromapEXT, queryType: vk.VkQueryType, dataSize: vk.size_t, pData: ?*void, stride: vk.size_t) Error!void {
    const result = vk.vkWriteMicromapsPropertiesEXT(
        device,
        micromapCount,
        pMicromaps,
        queryType,
        dataSize,
        pData,
        stride
    );
    try check(result);
}

pub fn CmdCopyMicromapEXT(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkCopyMicromapInfoEXT) Error!void {
    const result = vk.vkCmdCopyMicromapEXT(
        commandBuffer,
        pInfo
    );
    try check(result);
}

pub fn CmdCopyMicromapToMemoryEXT(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkCopyMicromapToMemoryInfoEXT) Error!void {
    const result = vk.vkCmdCopyMicromapToMemoryEXT(
        commandBuffer,
        pInfo
    );
    try check(result);
}

pub fn CmdCopyMemoryToMicromapEXT(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkCopyMemoryToMicromapInfoEXT) Error!void {
    const result = vk.vkCmdCopyMemoryToMicromapEXT(
        commandBuffer,
        pInfo
    );
    try check(result);
}

pub fn CmdWriteMicromapsPropertiesEXT(commandBuffer: vk.VkCommandBuffer, micromapCount: u32, pMicromaps: ?[*]const vk.VkMicromapEXT, queryType: vk.VkQueryType, queryPool: vk.VkQueryPool, firstQuery: u32) Error!void {
    const result = vk.vkCmdWriteMicromapsPropertiesEXT(
        commandBuffer,
        micromapCount,
        pMicromaps,
        queryType,
        queryPool,
        firstQuery
    );
    try check(result);
}

pub fn GetDeviceMicromapCompatibilityEXT(device: vk.VkDevice, pVersionInfo: ?*const vk.VkMicromapVersionInfoEXT, pCompatibility: ?*vk.VkAccelerationStructureCompatibilityKHR) Error!void {
    const result = vk.vkGetDeviceMicromapCompatibilityEXT(
        device,
        pVersionInfo,
        pCompatibility
    );
    try check(result);
}

pub fn GetMicromapBuildSizesEXT(device: vk.VkDevice, buildType: vk.VkAccelerationStructureBuildTypeKHR, pBuildInfo: ?*const vk.VkMicromapBuildInfoEXT, pSizeInfo: ?*vk.VkMicromapBuildSizesInfoEXT) Error!void {
    const result = vk.vkGetMicromapBuildSizesEXT(
        device,
        buildType,
        pBuildInfo,
        pSizeInfo
    );
    try check(result);
}

pub fn CmdDrawClusterHUAWEI(commandBuffer: vk.VkCommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32) Error!void {
    const result = vk.vkCmdDrawClusterHUAWEI(
        commandBuffer,
        groupCountX,
        groupCountY,
        groupCountZ
    );
    try check(result);
}

pub fn CmdDrawClusterIndirectHUAWEI(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize) Error!void {
    const result = vk.vkCmdDrawClusterIndirectHUAWEI(
        commandBuffer,
        buffer,
        offset
    );
    try check(result);
}

pub fn SetDeviceMemoryPriorityEXT(device: vk.VkDevice, memory: vk.VkDeviceMemory, priority: f32) Error!void {
    const result = vk.vkSetDeviceMemoryPriorityEXT(
        device,
        memory,
        priority
    );
    try check(result);
}

pub fn GetDescriptorSetLayoutHostMappingInfoVALVE(device: vk.VkDevice, pBindingReference: ?*const vk.VkDescriptorSetBindingReferenceVALVE, pHostMapping: ?*vk.VkDescriptorSetLayoutHostMappingInfoVALVE) Error!void {
    const result = vk.vkGetDescriptorSetLayoutHostMappingInfoVALVE(
        device,
        pBindingReference,
        pHostMapping
    );
    try check(result);
}

pub fn GetDescriptorSetHostMappingVALVE(device: vk.VkDevice, descriptorSet: vk.VkDescriptorSet, ppData: ?*void) Error!void {
    const result = vk.vkGetDescriptorSetHostMappingVALVE(
        device,
        descriptorSet,
        ppData
    );
    try check(result);
}

pub fn CmdCopyMemoryIndirectNV(commandBuffer: vk.VkCommandBuffer, copyBufferAddress: vk.VkDeviceAddress, copyCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdCopyMemoryIndirectNV(
        commandBuffer,
        copyBufferAddress,
        copyCount,
        stride
    );
    try check(result);
}

pub fn CmdCopyMemoryToImageIndirectNV(commandBuffer: vk.VkCommandBuffer, copyBufferAddress: vk.VkDeviceAddress, copyCount: u32, stride: u32, dstImage: vk.VkImage, dstImageLayout: vk.VkImageLayout, pImageSubresources: ?[*]const vk.VkImageSubresourceLayers) Error!void {
    const result = vk.vkCmdCopyMemoryToImageIndirectNV(
        commandBuffer,
        copyBufferAddress,
        copyCount,
        stride,
        dstImage,
        dstImageLayout,
        pImageSubresources
    );
    try check(result);
}

pub fn CmdDecompressMemoryNV(commandBuffer: vk.VkCommandBuffer, decompressRegionCount: u32, pDecompressMemoryRegions: ?[*]const vk.VkDecompressMemoryRegionNV) Error!void {
    const result = vk.vkCmdDecompressMemoryNV(
        commandBuffer,
        decompressRegionCount,
        pDecompressMemoryRegions
    );
    try check(result);
}

pub fn CmdDecompressMemoryIndirectCountNV(commandBuffer: vk.VkCommandBuffer, indirectCommandsAddress: vk.VkDeviceAddress, indirectCommandsCountAddress: vk.VkDeviceAddress, stride: u32) Error!void {
    const result = vk.vkCmdDecompressMemoryIndirectCountNV(
        commandBuffer,
        indirectCommandsAddress,
        indirectCommandsCountAddress,
        stride
    );
    try check(result);
}

pub fn GetPipelineIndirectMemoryRequirementsNV(device: vk.VkDevice, pCreateInfo: ?*const vk.VkComputePipelineCreateInfo, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetPipelineIndirectMemoryRequirementsNV(
        device,
        pCreateInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn CmdUpdatePipelineIndirectBufferNV(commandBuffer: vk.VkCommandBuffer, pipelineBindPoint: vk.VkPipelineBindPoint, pipeline: vk.VkPipeline) Error!void {
    const result = vk.vkCmdUpdatePipelineIndirectBufferNV(
        commandBuffer,
        pipelineBindPoint,
        pipeline
    );
    try check(result);
}

pub fn GetPipelineIndirectDeviceAddressNV(device: vk.VkDevice, pInfo: ?*const vk.VkPipelineIndirectDeviceAddressInfoNV) Error!void {
    const result = vk.vkGetPipelineIndirectDeviceAddressNV(
        device,
        pInfo
    );
    try check(result);
}

pub fn CmdSetDepthClampEnableEXT(commandBuffer: vk.VkCommandBuffer, depthClampEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthClampEnableEXT(
        commandBuffer,
        depthClampEnable
    );
    try check(result);
}

pub fn CmdSetPolygonModeEXT(commandBuffer: vk.VkCommandBuffer, polygonMode: vk.VkPolygonMode) Error!void {
    const result = vk.vkCmdSetPolygonModeEXT(
        commandBuffer,
        polygonMode
    );
    try check(result);
}

pub fn CmdSetRasterizationSamplesEXT(commandBuffer: vk.VkCommandBuffer, rasterizationSamples: vk.VkSampleCountFlagBits) Error!void {
    const result = vk.vkCmdSetRasterizationSamplesEXT(
        commandBuffer,
        rasterizationSamples
    );
    try check(result);
}

pub fn CmdSetSampleMaskEXT(commandBuffer: vk.VkCommandBuffer, samples: vk.VkSampleCountFlagBits, pSampleMask: ?*const vk.VkSampleMask) Error!void {
    const result = vk.vkCmdSetSampleMaskEXT(
        commandBuffer,
        samples,
        pSampleMask
    );
    try check(result);
}

pub fn CmdSetAlphaToCoverageEnableEXT(commandBuffer: vk.VkCommandBuffer, alphaToCoverageEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetAlphaToCoverageEnableEXT(
        commandBuffer,
        alphaToCoverageEnable
    );
    try check(result);
}

pub fn CmdSetAlphaToOneEnableEXT(commandBuffer: vk.VkCommandBuffer, alphaToOneEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetAlphaToOneEnableEXT(
        commandBuffer,
        alphaToOneEnable
    );
    try check(result);
}

pub fn CmdSetLogicOpEnableEXT(commandBuffer: vk.VkCommandBuffer, logicOpEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetLogicOpEnableEXT(
        commandBuffer,
        logicOpEnable
    );
    try check(result);
}

pub fn CmdSetColorBlendEnableEXT(commandBuffer: vk.VkCommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorBlendEnables: ?[*]const vk.VkBool32) Error!void {
    const result = vk.vkCmdSetColorBlendEnableEXT(
        commandBuffer,
        firstAttachment,
        attachmentCount,
        pColorBlendEnables
    );
    try check(result);
}

pub fn CmdSetColorBlendEquationEXT(commandBuffer: vk.VkCommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorBlendEquations: ?[*]const vk.VkColorBlendEquationEXT) Error!void {
    const result = vk.vkCmdSetColorBlendEquationEXT(
        commandBuffer,
        firstAttachment,
        attachmentCount,
        pColorBlendEquations
    );
    try check(result);
}

pub fn CmdSetColorWriteMaskEXT(commandBuffer: vk.VkCommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorWriteMasks: ?[*]const vk.VkColorComponentFlags) Error!void {
    const result = vk.vkCmdSetColorWriteMaskEXT(
        commandBuffer,
        firstAttachment,
        attachmentCount,
        pColorWriteMasks
    );
    try check(result);
}

pub fn CmdSetTessellationDomainOriginEXT(commandBuffer: vk.VkCommandBuffer, domainOrigin: vk.VkTessellationDomainOrigin) Error!void {
    const result = vk.vkCmdSetTessellationDomainOriginEXT(
        commandBuffer,
        domainOrigin
    );
    try check(result);
}

pub fn CmdSetRasterizationStreamEXT(commandBuffer: vk.VkCommandBuffer, rasterizationStream: u32) Error!void {
    const result = vk.vkCmdSetRasterizationStreamEXT(
        commandBuffer,
        rasterizationStream
    );
    try check(result);
}

pub fn CmdSetConservativeRasterizationModeEXT(commandBuffer: vk.VkCommandBuffer, conservativeRasterizationMode: vk.VkConservativeRasterizationModeEXT) Error!void {
    const result = vk.vkCmdSetConservativeRasterizationModeEXT(
        commandBuffer,
        conservativeRasterizationMode
    );
    try check(result);
}

pub fn CmdSetExtraPrimitiveOverestimationSizeEXT(commandBuffer: vk.VkCommandBuffer, extraPrimitiveOverestimationSize: f32) Error!void {
    const result = vk.vkCmdSetExtraPrimitiveOverestimationSizeEXT(
        commandBuffer,
        extraPrimitiveOverestimationSize
    );
    try check(result);
}

pub fn CmdSetDepthClipEnableEXT(commandBuffer: vk.VkCommandBuffer, depthClipEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthClipEnableEXT(
        commandBuffer,
        depthClipEnable
    );
    try check(result);
}

pub fn CmdSetSampleLocationsEnableEXT(commandBuffer: vk.VkCommandBuffer, sampleLocationsEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetSampleLocationsEnableEXT(
        commandBuffer,
        sampleLocationsEnable
    );
    try check(result);
}

pub fn CmdSetColorBlendAdvancedEXT(commandBuffer: vk.VkCommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorBlendAdvanced: ?*const vk.VkColorBlendAdvancedEXT) Error!void {
    const result = vk.vkCmdSetColorBlendAdvancedEXT(
        commandBuffer,
        firstAttachment,
        attachmentCount,
        pColorBlendAdvanced
    );
    try check(result);
}

pub fn CmdSetProvokingVertexModeEXT(commandBuffer: vk.VkCommandBuffer, provokingVertexMode: vk.VkProvokingVertexModeEXT) Error!void {
    const result = vk.vkCmdSetProvokingVertexModeEXT(
        commandBuffer,
        provokingVertexMode
    );
    try check(result);
}

pub fn CmdSetLineRasterizationModeEXT(commandBuffer: vk.VkCommandBuffer, lineRasterizationMode: vk.VkLineRasterizationModeEXT) Error!void {
    const result = vk.vkCmdSetLineRasterizationModeEXT(
        commandBuffer,
        lineRasterizationMode
    );
    try check(result);
}

pub fn CmdSetLineStippleEnableEXT(commandBuffer: vk.VkCommandBuffer, stippledLineEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetLineStippleEnableEXT(
        commandBuffer,
        stippledLineEnable
    );
    try check(result);
}

pub fn CmdSetDepthClipNegativeOneToOneEXT(commandBuffer: vk.VkCommandBuffer, negativeOneToOne: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetDepthClipNegativeOneToOneEXT(
        commandBuffer,
        negativeOneToOne
    );
    try check(result);
}

pub fn CmdSetViewportWScalingEnableNV(commandBuffer: vk.VkCommandBuffer, viewportWScalingEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetViewportWScalingEnableNV(
        commandBuffer,
        viewportWScalingEnable
    );
    try check(result);
}

pub fn CmdSetViewportSwizzleNV(commandBuffer: vk.VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewportSwizzles: ?[*]const vk.VkViewportSwizzleNV) Error!void {
    const result = vk.vkCmdSetViewportSwizzleNV(
        commandBuffer,
        firstViewport,
        viewportCount,
        pViewportSwizzles
    );
    try check(result);
}

pub fn CmdSetCoverageToColorEnableNV(commandBuffer: vk.VkCommandBuffer, coverageToColorEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetCoverageToColorEnableNV(
        commandBuffer,
        coverageToColorEnable
    );
    try check(result);
}

pub fn CmdSetCoverageToColorLocationNV(commandBuffer: vk.VkCommandBuffer, coverageToColorLocation: u32) Error!void {
    const result = vk.vkCmdSetCoverageToColorLocationNV(
        commandBuffer,
        coverageToColorLocation
    );
    try check(result);
}

pub fn CmdSetCoverageModulationModeNV(commandBuffer: vk.VkCommandBuffer, coverageModulationMode: vk.VkCoverageModulationModeNV) Error!void {
    const result = vk.vkCmdSetCoverageModulationModeNV(
        commandBuffer,
        coverageModulationMode
    );
    try check(result);
}

pub fn CmdSetCoverageModulationTableEnableNV(commandBuffer: vk.VkCommandBuffer, coverageModulationTableEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetCoverageModulationTableEnableNV(
        commandBuffer,
        coverageModulationTableEnable
    );
    try check(result);
}

pub fn CmdSetCoverageModulationTableNV(commandBuffer: vk.VkCommandBuffer, coverageModulationTableCount: u32, pCoverageModulationTable: ?*const f32) Error!void {
    const result = vk.vkCmdSetCoverageModulationTableNV(
        commandBuffer,
        coverageModulationTableCount,
        pCoverageModulationTable
    );
    try check(result);
}

pub fn CmdSetShadingRateImageEnableNV(commandBuffer: vk.VkCommandBuffer, shadingRateImageEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetShadingRateImageEnableNV(
        commandBuffer,
        shadingRateImageEnable
    );
    try check(result);
}

pub fn CmdSetRepresentativeFragmentTestEnableNV(commandBuffer: vk.VkCommandBuffer, representativeFragmentTestEnable: vk.VkBool32) Error!void {
    const result = vk.vkCmdSetRepresentativeFragmentTestEnableNV(
        commandBuffer,
        representativeFragmentTestEnable
    );
    try check(result);
}

pub fn CmdSetCoverageReductionModeNV(commandBuffer: vk.VkCommandBuffer, coverageReductionMode: vk.VkCoverageReductionModeNV) Error!void {
    const result = vk.vkCmdSetCoverageReductionModeNV(
        commandBuffer,
        coverageReductionMode
    );
    try check(result);
}

pub fn GetShaderModuleIdentifierEXT(device: vk.VkDevice, shaderModule: vk.VkShaderModule, pIdentifier: ?*vk.VkShaderModuleIdentifierEXT) Error!void {
    const result = vk.vkGetShaderModuleIdentifierEXT(
        device,
        shaderModule,
        pIdentifier
    );
    try check(result);
}

pub fn GetShaderModuleCreateInfoIdentifierEXT(device: vk.VkDevice, pCreateInfo: ?*const vk.VkShaderModuleCreateInfo, pIdentifier: ?*vk.VkShaderModuleIdentifierEXT) Error!void {
    const result = vk.vkGetShaderModuleCreateInfoIdentifierEXT(
        device,
        pCreateInfo,
        pIdentifier
    );
    try check(result);
}

pub fn GetPhysicalDeviceOpticalFlowImageFormatsNV(physicalDevice: vk.VkPhysicalDevice, pOpticalFlowImageFormatInfo: ?*const vk.VkOpticalFlowImageFormatInfoNV, pFormatCount: ?*u32, pImageFormatProperties: ?[*]vk.VkOpticalFlowImageFormatPropertiesNV) Error!void {
    const result = vk.vkGetPhysicalDeviceOpticalFlowImageFormatsNV(
        physicalDevice,
        pOpticalFlowImageFormatInfo,
        pFormatCount,
        pImageFormatProperties
    );
    try check(result);
}

pub fn CreateOpticalFlowSessionNV(device: vk.VkDevice, pCreateInfo: ?*const vk.VkOpticalFlowSessionCreateInfoNV, pAllocator: ?*const vk.VkAllocationCallbacks, pSession: ?*vk.VkOpticalFlowSessionNV) Error!void {
    const result = vk.vkCreateOpticalFlowSessionNV(
        device,
        pCreateInfo,
        pAllocator,
        pSession
    );
    try check(result);
}

pub fn DestroyOpticalFlowSessionNV(device: vk.VkDevice, session: vk.VkOpticalFlowSessionNV, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyOpticalFlowSessionNV(
        device,
        session,
        pAllocator
    );
    try check(result);
}

pub fn BindOpticalFlowSessionImageNV(device: vk.VkDevice, session: vk.VkOpticalFlowSessionNV, bindingPoint: vk.VkOpticalFlowSessionBindingPointNV, view: vk.VkImageView, layout: vk.VkImageLayout) Error!void {
    const result = vk.vkBindOpticalFlowSessionImageNV(
        device,
        session,
        bindingPoint,
        view,
        layout
    );
    try check(result);
}

pub fn CmdOpticalFlowExecuteNV(commandBuffer: vk.VkCommandBuffer, session: vk.VkOpticalFlowSessionNV, pExecuteInfo: ?*const vk.VkOpticalFlowExecuteInfoNV) Error!void {
    const result = vk.vkCmdOpticalFlowExecuteNV(
        commandBuffer,
        session,
        pExecuteInfo
    );
    try check(result);
}

pub fn AntiLagUpdateAMD(device: vk.VkDevice, pData: ?*const vk.VkAntiLagDataAMD) Error!void {
    const result = vk.vkAntiLagUpdateAMD(
        device,
        pData
    );
    try check(result);
}

pub fn CreateShadersEXT(device: vk.VkDevice, createInfoCount: u32, pCreateInfos: ?[*]const vk.VkShaderCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pShaders: ?[*]vk.VkShaderEXT) Error!void {
    const result = vk.vkCreateShadersEXT(
        device,
        createInfoCount,
        pCreateInfos,
        pAllocator,
        pShaders
    );
    try check(result);
}

pub fn DestroyShaderEXT(device: vk.VkDevice, shader: vk.VkShaderEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyShaderEXT(
        device,
        shader,
        pAllocator
    );
    try check(result);
}

pub fn GetShaderBinaryDataEXT(device: vk.VkDevice, shader: vk.VkShaderEXT, pDataSize: ?*vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetShaderBinaryDataEXT(
        device,
        shader,
        pDataSize,
        pData
    );
    try check(result);
}

pub fn CmdBindShadersEXT(commandBuffer: vk.VkCommandBuffer, stageCount: u32, pStages: ?[*]vk.VkShaderStageFlagBits, pShaders: ?[*]const vk.VkShaderEXT) Error!void {
    const result = vk.vkCmdBindShadersEXT(
        commandBuffer,
        stageCount,
        pStages,
        pShaders
    );
    try check(result);
}

pub fn CmdSetDepthClampRangeEXT(commandBuffer: vk.VkCommandBuffer, depthClampMode: vk.VkDepthClampModeEXT, pDepthClampRange: ?*const vk.VkDepthClampRangeEXT) Error!void {
    const result = vk.vkCmdSetDepthClampRangeEXT(
        commandBuffer,
        depthClampMode,
        pDepthClampRange
    );
    try check(result);
}

pub fn GetFramebufferTilePropertiesQCOM(device: vk.VkDevice, framebuffer: vk.VkFramebuffer, pPropertiesCount: ?*u32, pProperties: ?[*]vk.VkTilePropertiesQCOM) Error!void {
    const result = vk.vkGetFramebufferTilePropertiesQCOM(
        device,
        framebuffer,
        pPropertiesCount,
        pProperties
    );
    try check(result);
}

pub fn GetDynamicRenderingTilePropertiesQCOM(device: vk.VkDevice, pRenderingInfo: ?*const vk.VkRenderingInfo, pProperties: ?[*]vk.VkTilePropertiesQCOM) Error!void {
    const result = vk.vkGetDynamicRenderingTilePropertiesQCOM(
        device,
        pRenderingInfo,
        pProperties
    );
    try check(result);
}

pub fn GetPhysicalDeviceCooperativeVectorPropertiesNV(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkCooperativeVectorPropertiesNV) Error!void {
    const result = vk.vkGetPhysicalDeviceCooperativeVectorPropertiesNV(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn ConvertCooperativeVectorMatrixNV(device: vk.VkDevice, pInfo: ?*const vk.VkConvertCooperativeVectorMatrixInfoNV) Error!void {
    const result = vk.vkConvertCooperativeVectorMatrixNV(
        device,
        pInfo
    );
    try check(result);
}

pub fn CmdConvertCooperativeVectorMatrixNV(commandBuffer: vk.VkCommandBuffer, infoCount: u32, pInfos: ?[*]const vk.VkConvertCooperativeVectorMatrixInfoNV) Error!void {
    const result = vk.vkCmdConvertCooperativeVectorMatrixNV(
        commandBuffer,
        infoCount,
        pInfos
    );
    try check(result);
}

pub fn SetLatencySleepModeNV(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pSleepModeInfo: ?*const vk.VkLatencySleepModeInfoNV) Error!void {
    const result = vk.vkSetLatencySleepModeNV(
        device,
        swapchain,
        pSleepModeInfo
    );
    try check(result);
}

pub fn LatencySleepNV(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pSleepInfo: ?*const vk.VkLatencySleepInfoNV) Error!void {
    const result = vk.vkLatencySleepNV(
        device,
        swapchain,
        pSleepInfo
    );
    try check(result);
}

pub fn SetLatencyMarkerNV(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pLatencyMarkerInfo: ?*const vk.VkSetLatencyMarkerInfoNV) Error!void {
    const result = vk.vkSetLatencyMarkerNV(
        device,
        swapchain,
        pLatencyMarkerInfo
    );
    try check(result);
}

pub fn GetLatencyTimingsNV(device: vk.VkDevice, swapchain: vk.VkSwapchainKHR, pLatencyMarkerInfo: ?*vk.VkGetLatencyMarkerInfoNV) Error!void {
    const result = vk.vkGetLatencyTimingsNV(
        device,
        swapchain,
        pLatencyMarkerInfo
    );
    try check(result);
}

pub fn QueueNotifyOutOfBandNV(queue: vk.VkQueue, pQueueTypeInfo: ?*const vk.VkOutOfBandQueueTypeInfoNV) Error!void {
    const result = vk.vkQueueNotifyOutOfBandNV(
        queue,
        pQueueTypeInfo
    );
    try check(result);
}

pub fn CmdSetAttachmentFeedbackLoopEnableEXT(commandBuffer: vk.VkCommandBuffer, aspectMask: vk.VkImageAspectFlags) Error!void {
    const result = vk.vkCmdSetAttachmentFeedbackLoopEnableEXT(
        commandBuffer,
        aspectMask
    );
    try check(result);
}

pub fn GetClusterAccelerationStructureBuildSizesNV(device: vk.VkDevice, pInfo: ?*const vk.VkClusterAccelerationStructureInputInfoNV, pSizeInfo: ?*vk.VkAccelerationStructureBuildSizesInfoKHR) Error!void {
    const result = vk.vkGetClusterAccelerationStructureBuildSizesNV(
        device,
        pInfo,
        pSizeInfo
    );
    try check(result);
}

pub fn CmdBuildClusterAccelerationStructureIndirectNV(commandBuffer: vk.VkCommandBuffer, pCommandInfos: ?[*]const vk.VkClusterAccelerationStructureCommandsInfoNV) Error!void {
    const result = vk.vkCmdBuildClusterAccelerationStructureIndirectNV(
        commandBuffer,
        pCommandInfos
    );
    try check(result);
}

pub fn GetPartitionedAccelerationStructuresBuildSizesNV(device: vk.VkDevice, pInfo: ?*const vk.VkPartitionedAccelerationStructureInstancesInputNV, pSizeInfo: ?*vk.VkAccelerationStructureBuildSizesInfoKHR) Error!void {
    const result = vk.vkGetPartitionedAccelerationStructuresBuildSizesNV(
        device,
        pInfo,
        pSizeInfo
    );
    try check(result);
}

pub fn CmdBuildPartitionedAccelerationStructuresNV(commandBuffer: vk.VkCommandBuffer, pBuildInfo: ?*const vk.VkBuildPartitionedAccelerationStructureInfoNV) Error!void {
    const result = vk.vkCmdBuildPartitionedAccelerationStructuresNV(
        commandBuffer,
        pBuildInfo
    );
    try check(result);
}

pub fn GetGeneratedCommandsMemoryRequirementsEXT(device: vk.VkDevice, pInfo: ?*const vk.VkGeneratedCommandsMemoryRequirementsInfoEXT, pMemoryRequirements: ?[*]vk.VkMemoryRequirements2) Error!void {
    const result = vk.vkGetGeneratedCommandsMemoryRequirementsEXT(
        device,
        pInfo,
        pMemoryRequirements
    );
    try check(result);
}

pub fn CmdPreprocessGeneratedCommandsEXT(commandBuffer: vk.VkCommandBuffer, pGeneratedCommandsInfo: ?*const vk.VkGeneratedCommandsInfoEXT, stateCommandBuffer: vk.VkCommandBuffer) Error!void {
    const result = vk.vkCmdPreprocessGeneratedCommandsEXT(
        commandBuffer,
        pGeneratedCommandsInfo,
        stateCommandBuffer
    );
    try check(result);
}

pub fn CmdExecuteGeneratedCommandsEXT(commandBuffer: vk.VkCommandBuffer, isPreprocessed: vk.VkBool32, pGeneratedCommandsInfo: ?*const vk.VkGeneratedCommandsInfoEXT) Error!void {
    const result = vk.vkCmdExecuteGeneratedCommandsEXT(
        commandBuffer,
        isPreprocessed,
        pGeneratedCommandsInfo
    );
    try check(result);
}

pub fn CreateIndirectCommandsLayoutEXT(device: vk.VkDevice, pCreateInfo: ?*const vk.VkIndirectCommandsLayoutCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pIndirectCommandsLayout: ?*vk.VkIndirectCommandsLayoutEXT) Error!void {
    const result = vk.vkCreateIndirectCommandsLayoutEXT(
        device,
        pCreateInfo,
        pAllocator,
        pIndirectCommandsLayout
    );
    try check(result);
}

pub fn DestroyIndirectCommandsLayoutEXT(device: vk.VkDevice, indirectCommandsLayout: vk.VkIndirectCommandsLayoutEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyIndirectCommandsLayoutEXT(
        device,
        indirectCommandsLayout,
        pAllocator
    );
    try check(result);
}

pub fn CreateIndirectExecutionSetEXT(device: vk.VkDevice, pCreateInfo: ?*const vk.VkIndirectExecutionSetCreateInfoEXT, pAllocator: ?*const vk.VkAllocationCallbacks, pIndirectExecutionSet: ?*vk.VkIndirectExecutionSetEXT) Error!void {
    const result = vk.vkCreateIndirectExecutionSetEXT(
        device,
        pCreateInfo,
        pAllocator,
        pIndirectExecutionSet
    );
    try check(result);
}

pub fn DestroyIndirectExecutionSetEXT(device: vk.VkDevice, indirectExecutionSet: vk.VkIndirectExecutionSetEXT, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyIndirectExecutionSetEXT(
        device,
        indirectExecutionSet,
        pAllocator
    );
    try check(result);
}

pub fn UpdateIndirectExecutionSetPipelineEXT(device: vk.VkDevice, indirectExecutionSet: vk.VkIndirectExecutionSetEXT, executionSetWriteCount: u32, pExecutionSetWrites: ?[*]const vk.VkWriteIndirectExecutionSetPipelineEXT) Error!void {
    const result = vk.vkUpdateIndirectExecutionSetPipelineEXT(
        device,
        indirectExecutionSet,
        executionSetWriteCount,
        pExecutionSetWrites
    );
    try check(result);
}

pub fn UpdateIndirectExecutionSetShaderEXT(device: vk.VkDevice, indirectExecutionSet: vk.VkIndirectExecutionSetEXT, executionSetWriteCount: u32, pExecutionSetWrites: ?[*]const vk.VkWriteIndirectExecutionSetShaderEXT) Error!void {
    const result = vk.vkUpdateIndirectExecutionSetShaderEXT(
        device,
        indirectExecutionSet,
        executionSetWriteCount,
        pExecutionSetWrites
    );
    try check(result);
}

pub fn GetPhysicalDeviceCooperativeMatrixFlexibleDimensionsPropertiesNV(physicalDevice: vk.VkPhysicalDevice, pPropertyCount: ?*u32, pProperties: ?[*]vk.VkCooperativeMatrixFlexibleDimensionsPropertiesNV) Error!void {
    const result = vk.vkGetPhysicalDeviceCooperativeMatrixFlexibleDimensionsPropertiesNV(
        physicalDevice,
        pPropertyCount,
        pProperties
    );
    try check(result);
}

pub fn CreateAccelerationStructureKHR(device: vk.VkDevice, pCreateInfo: ?*const vk.VkAccelerationStructureCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pAccelerationStructure: ?*vk.VkAccelerationStructureKHR) Error!void {
    const result = vk.vkCreateAccelerationStructureKHR(
        device,
        pCreateInfo,
        pAllocator,
        pAccelerationStructure
    );
    try check(result);
}

pub fn DestroyAccelerationStructureKHR(device: vk.VkDevice, accelerationStructure: vk.VkAccelerationStructureKHR, pAllocator: ?*const vk.VkAllocationCallbacks) Error!void {
    const result = vk.vkDestroyAccelerationStructureKHR(
        device,
        accelerationStructure,
        pAllocator
    );
    try check(result);
}

pub fn CmdBuildAccelerationStructuresKHR(commandBuffer: vk.VkCommandBuffer, infoCount: u32, pInfos: ?[*]const vk.VkAccelerationStructureBuildGeometryInfoKHR, ppBuildRangeInfos: ?*const ?[*]const vk.VkAccelerationStructureBuildRangeInfoKHR) Error!void {
    const result = vk.vkCmdBuildAccelerationStructuresKHR(
        commandBuffer,
        infoCount,
        pInfos,
        ppBuildRangeInfos
    );
    try check(result);
}

pub fn CmdBuildAccelerationStructuresIndirectKHR(commandBuffer: vk.VkCommandBuffer, infoCount: u32, pInfos: ?[*]const vk.VkAccelerationStructureBuildGeometryInfoKHR, pIndirectDeviceAddresses: ?[*]const vk.VkDeviceAddress, pIndirectStrides: ?[*]const u32, ppMaxPrimitiveCounts: ?*const ?[*]const u32) Error!void {
    const result = vk.vkCmdBuildAccelerationStructuresIndirectKHR(
        commandBuffer,
        infoCount,
        pInfos,
        pIndirectDeviceAddresses,
        pIndirectStrides,
        ppMaxPrimitiveCounts
    );
    try check(result);
}

pub fn BuildAccelerationStructuresKHR(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, infoCount: u32, pInfos: ?[*]const vk.VkAccelerationStructureBuildGeometryInfoKHR, ppBuildRangeInfos: ?*const ?[*]const vk.VkAccelerationStructureBuildRangeInfoKHR) Error!void {
    const result = vk.vkBuildAccelerationStructuresKHR(
        device,
        deferredOperation,
        infoCount,
        pInfos,
        ppBuildRangeInfos
    );
    try check(result);
}

pub fn CopyAccelerationStructureKHR(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pInfo: ?*const vk.VkCopyAccelerationStructureInfoKHR) Error!void {
    const result = vk.vkCopyAccelerationStructureKHR(
        device,
        deferredOperation,
        pInfo
    );
    try check(result);
}

pub fn CopyAccelerationStructureToMemoryKHR(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pInfo: ?*const vk.VkCopyAccelerationStructureToMemoryInfoKHR) Error!void {
    const result = vk.vkCopyAccelerationStructureToMemoryKHR(
        device,
        deferredOperation,
        pInfo
    );
    try check(result);
}

pub fn CopyMemoryToAccelerationStructureKHR(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pInfo: ?*const vk.VkCopyMemoryToAccelerationStructureInfoKHR) Error!void {
    const result = vk.vkCopyMemoryToAccelerationStructureKHR(
        device,
        deferredOperation,
        pInfo
    );
    try check(result);
}

pub fn WriteAccelerationStructuresPropertiesKHR(device: vk.VkDevice, accelerationStructureCount: u32, pAccelerationStructures: ?[*]const vk.VkAccelerationStructureKHR, queryType: vk.VkQueryType, dataSize: vk.size_t, pData: ?*void, stride: vk.size_t) Error!void {
    const result = vk.vkWriteAccelerationStructuresPropertiesKHR(
        device,
        accelerationStructureCount,
        pAccelerationStructures,
        queryType,
        dataSize,
        pData,
        stride
    );
    try check(result);
}

pub fn CmdCopyAccelerationStructureKHR(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkCopyAccelerationStructureInfoKHR) Error!void {
    const result = vk.vkCmdCopyAccelerationStructureKHR(
        commandBuffer,
        pInfo
    );
    try check(result);
}

pub fn CmdCopyAccelerationStructureToMemoryKHR(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkCopyAccelerationStructureToMemoryInfoKHR) Error!void {
    const result = vk.vkCmdCopyAccelerationStructureToMemoryKHR(
        commandBuffer,
        pInfo
    );
    try check(result);
}

pub fn CmdCopyMemoryToAccelerationStructureKHR(commandBuffer: vk.VkCommandBuffer, pInfo: ?*const vk.VkCopyMemoryToAccelerationStructureInfoKHR) Error!void {
    const result = vk.vkCmdCopyMemoryToAccelerationStructureKHR(
        commandBuffer,
        pInfo
    );
    try check(result);
}

pub fn GetAccelerationStructureDeviceAddressKHR(device: vk.VkDevice, pInfo: ?*const vk.VkAccelerationStructureDeviceAddressInfoKHR) Error!void {
    const result = vk.vkGetAccelerationStructureDeviceAddressKHR(
        device,
        pInfo
    );
    try check(result);
}

pub fn CmdWriteAccelerationStructuresPropertiesKHR(commandBuffer: vk.VkCommandBuffer, accelerationStructureCount: u32, pAccelerationStructures: ?[*]const vk.VkAccelerationStructureKHR, queryType: vk.VkQueryType, queryPool: vk.VkQueryPool, firstQuery: u32) Error!void {
    const result = vk.vkCmdWriteAccelerationStructuresPropertiesKHR(
        commandBuffer,
        accelerationStructureCount,
        pAccelerationStructures,
        queryType,
        queryPool,
        firstQuery
    );
    try check(result);
}

pub fn GetDeviceAccelerationStructureCompatibilityKHR(device: vk.VkDevice, pVersionInfo: ?*const vk.VkAccelerationStructureVersionInfoKHR, pCompatibility: ?*vk.VkAccelerationStructureCompatibilityKHR) Error!void {
    const result = vk.vkGetDeviceAccelerationStructureCompatibilityKHR(
        device,
        pVersionInfo,
        pCompatibility
    );
    try check(result);
}

pub fn GetAccelerationStructureBuildSizesKHR(device: vk.VkDevice, buildType: vk.VkAccelerationStructureBuildTypeKHR, pBuildInfo: ?*const vk.VkAccelerationStructureBuildGeometryInfoKHR, pMaxPrimitiveCounts: ?[*]const u32, pSizeInfo: ?*vk.VkAccelerationStructureBuildSizesInfoKHR) Error!void {
    const result = vk.vkGetAccelerationStructureBuildSizesKHR(
        device,
        buildType,
        pBuildInfo,
        pMaxPrimitiveCounts,
        pSizeInfo
    );
    try check(result);
}

pub fn CmdTraceRaysKHR(commandBuffer: vk.VkCommandBuffer, pRaygenShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, pMissShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, pHitShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, pCallableShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, width: u32, height: u32, depth: u32) Error!void {
    const result = vk.vkCmdTraceRaysKHR(
        commandBuffer,
        pRaygenShaderBindingTable,
        pMissShaderBindingTable,
        pHitShaderBindingTable,
        pCallableShaderBindingTable,
        width,
        height,
        depth
    );
    try check(result);
}

pub fn CreateRayTracingPipelinesKHR(device: vk.VkDevice, deferredOperation: vk.VkDeferredOperationKHR, pipelineCache: vk.VkPipelineCache, createInfoCount: u32, pCreateInfos: ?[*]const vk.VkRayTracingPipelineCreateInfoKHR, pAllocator: ?*const vk.VkAllocationCallbacks, pPipelines: ?[*]vk.VkPipeline) Error!void {
    const result = vk.vkCreateRayTracingPipelinesKHR(
        device,
        deferredOperation,
        pipelineCache,
        createInfoCount,
        pCreateInfos,
        pAllocator,
        pPipelines
    );
    try check(result);
}

pub fn GetRayTracingCaptureReplayShaderGroupHandlesKHR(device: vk.VkDevice, pipeline: vk.VkPipeline, firstGroup: u32, groupCount: u32, dataSize: vk.size_t, pData: ?*void) Error!void {
    const result = vk.vkGetRayTracingCaptureReplayShaderGroupHandlesKHR(
        device,
        pipeline,
        firstGroup,
        groupCount,
        dataSize,
        pData
    );
    try check(result);
}

pub fn CmdTraceRaysIndirectKHR(commandBuffer: vk.VkCommandBuffer, pRaygenShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, pMissShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, pHitShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, pCallableShaderBindingTable: ?*const vk.VkStridedDeviceAddressRegionKHR, indirectDeviceAddress: vk.VkDeviceAddress) Error!void {
    const result = vk.vkCmdTraceRaysIndirectKHR(
        commandBuffer,
        pRaygenShaderBindingTable,
        pMissShaderBindingTable,
        pHitShaderBindingTable,
        pCallableShaderBindingTable,
        indirectDeviceAddress
    );
    try check(result);
}

pub fn GetRayTracingShaderGroupStackSizeKHR(device: vk.VkDevice, pipeline: vk.VkPipeline, group: u32, groupShader: vk.VkShaderGroupShaderKHR) Error!void {
    const result = vk.vkGetRayTracingShaderGroupStackSizeKHR(
        device,
        pipeline,
        group,
        groupShader
    );
    try check(result);
}

pub fn CmdSetRayTracingPipelineStackSizeKHR(commandBuffer: vk.VkCommandBuffer, pipelineStackSize: u32) Error!void {
    const result = vk.vkCmdSetRayTracingPipelineStackSizeKHR(
        commandBuffer,
        pipelineStackSize
    );
    try check(result);
}

pub fn CmdDrawMeshTasksEXT(commandBuffer: vk.VkCommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32) Error!void {
    const result = vk.vkCmdDrawMeshTasksEXT(
        commandBuffer,
        groupCountX,
        groupCountY,
        groupCountZ
    );
    try check(result);
}

pub fn CmdDrawMeshTasksIndirectEXT(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, drawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawMeshTasksIndirectEXT(
        commandBuffer,
        buffer,
        offset,
        drawCount,
        stride
    );
    try check(result);
}

pub fn CmdDrawMeshTasksIndirectCountEXT(commandBuffer: vk.VkCommandBuffer, buffer: vk.VkBuffer, offset: vk.VkDeviceSize, countBuffer: vk.VkBuffer, countBufferOffset: vk.VkDeviceSize, maxDrawCount: u32, stride: u32) Error!void {
    const result = vk.vkCmdDrawMeshTasksIndirectCountEXT(
        commandBuffer,
        buffer,
        offset,
        countBuffer,
        countBufferOffset,
        maxDrawCount,
        stride
    );
    try check(result);
}

