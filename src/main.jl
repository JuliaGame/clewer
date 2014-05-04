
OPENGL_MAJOR = 4
OPENGL_MINOR = 2

const OpenGLver="$OPENGL_MAJOR.$OPENGL_MINOR"
using OpenGL
import GLFW

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, OPENGL_MINOR)

window = GLFW.CreateWindow(800, 600, "Hello World", C_NULL, C_NULL)

GLFW.MakeContextCurrent(window)

vao = 0
buffer = 0
fbo = 0
texture = 0
shaderProgram = glCreateProgram()
assert(shaderProgram != 0)

while GLFW.WindowShouldClose(window) == 0
    glClearColor(0, 0, 1, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
end

GLFW.Terminate()
