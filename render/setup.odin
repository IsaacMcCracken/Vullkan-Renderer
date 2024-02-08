package render

import dl "core:dynlib"
import vk "vendor:vulkan"
import "vendor:glfw"
import "core:fmt"
import win "core:sys/windows"
import mem "core:mem/virtual"

QueueIndex :: u32
QueueIndexNil: QueueIndex: 0xffffffff

VkContext :: struct {
  instance: vk.Instance,
  gpu: vk.PhysicalDevice,
  logic: vk.Device,
  surface: vk.SurfaceKHR,
  graphicsQueue: vk.Queue,
  presentQueue: vk.Queue,
}


QueueFamilyIndices :: struct {
  graphicsFamily: QueueIndex,
  presentFamily:  QueueIndex,
} 

findQueueFamilyIndices :: proc(ctx: VkContext) -> QueueFamilyIndices {
  indices: QueueFamilyIndices
  queue_family_count: u32 = 0
  vk.GetPhysicalDeviceQueueFamilyProperties(ctx.gpu, &queue_family_count, nil)

  queue_families := make([]vk.QueueFamilyProperties, queue_family_count, context.temp_allocator)

  for queue_family, index in queue_families {
    if vk.QueueFlag.GRAPHICS in queue_family.queueFlags {
      indices.graphicsFamily = QueueIndex(index)
    }

    presentSupport :b32 = false
    vk.GetPhysicalDeviceSurfaceSupportKHR(ctx.gpu, u32(index), ctx.surface, &presentSupport)

    if presentSupport do indices.presentFamily = QueueIndex(index)




  }

  


  return indices
}



vulkanInit :: proc(temp_allocator := context.temp_allocator) -> VkContext {
  ctx: VkContext
  
  loadDLL: {
    vulkan_lib, loaded := dl.load_library("vulkan-1.dll")
    assert(loaded)
  
    vkGetInstanceProcAddr, found := dl.symbol_address(vulkan_lib, "vkGetInstanceProcAddr")
    assert(found)
    
    vk.load_proc_addresses_global(vkGetInstanceProcAddr)
  }

  createInstance: {
    appInfo: vk.ApplicationInfo
    appInfo.sType = vk.StructureType.APPLICATION_INFO
    appInfo.pApplicationName = "Demo"
    appInfo.applicationVersion = vk.MAKE_VERSION(1, 0, 0)
    appInfo.pEngineName = "No Engine"
    appInfo.engineVersion = vk.MAKE_VERSION(1, 0, 0)
    appInfo.apiVersion = vk.API_VERSION_1_0
  
  
    createInfo: vk.InstanceCreateInfo
    createInfo.sType = vk.StructureType.INSTANCE_CREATE_INFO
    createInfo.pApplicationInfo = &appInfo
  
    glfwExtensions := glfw.GetRequiredInstanceExtensions()
    
  
    createInfo.ppEnabledExtensionNames = raw_data(glfwExtensions)
    createInfo.enabledExtensionCount = u32(len(glfwExtensions))
  
    createInfo.enabledLayerCount = 0
  
  
    result := vk.CreateInstance(&createInfo, nil, &ctx.instance)
  
    if result != vk.Result.SUCCESS do panic("Oh Fuck! we could open vulkan")
  }

  setupDebugMessenger: {

  }

  createSurface: {
    result := glfw.CreateWindowSurface(ctx.instance, window, nil,  &ctx.surface)
    if result != .SUCCESS do panic("Oh Balls! We could not create a Win32 Surface")



  }

  // Load more vulkan
  vk.load_proc_addresses(ctx.instance)

  // validation layers
  pickGPU: {
    count: u32 = 0

    vk.EnumeratePhysicalDevices(ctx.instance, &count, nil)

    if count == 0 do panic("Oh Fuck! we could not find a physical device.")
    gpus := make([]vk.PhysicalDevice, count, temp_allocator)
    vk.EnumeratePhysicalDevices(ctx.instance, &count, raw_data(gpus))

    // TODO clean this up and find best graphics card or something
    ctx.gpu = gpus[0]
    // fmt.println("GPU count:", count, "GPU Handles:", gpus)
  }

  createLogicalDevice: {
    indices := findQueueFamilyIndices(ctx)

    queuePriority := f32(1)

    uniqueQueueFamilies := [?]QueueIndex{indices.graphicsFamily, indices.presentFamily}
    queueCreateInfos := make([]vk.DeviceQueueCreateInfo, len(uniqueQueueFamilies), temp_allocator)

    for queueFamily, i in uniqueQueueFamilies {
      queueCreateInfo: vk.DeviceQueueCreateInfo
      queueCreateInfo.sType = vk.StructureType.DEVICE_QUEUE_CREATE_INFO
      queueCreateInfo.queueFamilyIndex = queueFamily;
      queueCreateInfo.queueCount = 1;
      queueCreateInfo.pQueuePriorities = &queuePriority;
      queueCreateInfos[i] = queueCreateInfo

    }

    createInfo: vk.DeviceCreateInfo
    createInfo.pQueueCreateInfos = raw_data(queueCreateInfos)
    createInfo.queueCreateInfoCount = u32(len(queueCreateInfos))


    result := vk.CreateDevice(ctx.gpu, &createInfo, nil, &ctx.logic)


    if result != .SUCCESS do panic("Oh Shit! We could not create a logical device.\n")


    vk.GetDeviceQueue(ctx.logic, indices.graphicsFamily, 0, &ctx.graphicsQueue)
    vk.GetDeviceQueue(ctx.logic, indices.presentFamily, 0, &ctx.presentQueue)
    


  }

  bootOutput: {
    gpuInfo: vk.PhysicalDeviceProperties
    vk.GetPhysicalDeviceProperties(ctx.gpu, &gpuInfo)



    fmt.println("GPU:", cstring(raw_data(&gpuInfo.deviceName)))


    
  }




  return ctx
}


vulkanDeinit :: proc(ctx: VkContext) {
  vk.DestroyDevice(ctx.logic, nil)
  vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
  vk.DestroyInstance(ctx.instance, nil)
}

