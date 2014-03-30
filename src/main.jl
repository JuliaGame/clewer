
OPENGL_MAJOR = 4
OPENGL_MINOR = 2

const OpenGLver="$OPENGL_MAJOR.$OPENGL_MINOR"
import OpenGL
import GLFW

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, OPENGL_MINOR)

window = GLFW.CreateWindow(800, 600, "Hello World", C_NULL, C_NULL)

window->MakeContextCurrent()

vao = 0
buffer = 0
fbo = 0
texture = 0
shaderProgram = glCreateProgram()
assert(shaderProgram != 0)

while GLFW.WindowShouldClose(window) == 0
    window->SwapBuffers()
    GLFW.PollEvents()
end

GLFW.Terminate()
