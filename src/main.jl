const OpenGLver="4.2"
import OpenGL
import GLFW

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 4)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)

window = GLFW.CreateWindow(800, 600, "Hello World", C_NULL, C_NULL)

window->MakeContextCurrent()

while GLFW.WindowShouldClose(window) == 0
    window->SwapBuffers()
    GLFW.PollEvents()
end

GLFW.Terminate()
