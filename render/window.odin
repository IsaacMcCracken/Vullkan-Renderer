package render

import "vendor:glfw"

window: glfw.WindowHandle
ctx: VkContext

windowInit :: proc(width, height: i32) {
  glfw.Init()
  
  
  glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
  glfw.WindowHint(glfw.RESIZABLE, glfw.FALSE)
  
  window = glfw.CreateWindow(width, height, "Demo", nil, nil)

  ctx = vulkanInit()
}

windowShouldClose :: proc() -> bool {
  result := bool(glfw.WindowShouldClose(window))
  glfw.PollEvents()
  return result
}

windowDeinit :: proc() {
  vulkanDeinit(ctx)
  glfw.DestroyWindow(window)
  glfw.Terminate()
}
