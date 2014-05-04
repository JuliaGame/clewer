
OPENGL_MAJOR = 4
OPENGL_MINOR = 2

const OpenGLver="$OPENGL_MAJOR.$OPENGL_MINOR"
using OpenGL
import GLFW

include("shader.jl")

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, OPENGL_MINOR)

width = 800
height = 600

window = GLFW.CreateWindow(width, height, "Hello World", C_NULL, C_NULL)

GLFW.MakeContextCurrent(window)

shaderProgram = glCreateProgram()
assert(shaderProgram != 0)

vao = Array(Uint32, 1)
glGenVertexArrays(1, vao)
assert(vao[1] != 0)
glBindVertexArray(vao[1])

# renderbuffer
buffer = Array(Uint32, 1)
glGenRenderbuffers(1, buffer)
glBindRenderbuffer(GL_RENDERBUFFER, buffer[1])
glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height)

# framebuffer
fbo = Array(Uint32, 1)
glGenFramebuffers(1, fbo)
glBindFramebuffer(GL_FRAMEBUFFER, fbo[1])
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, buffer[1])

texture = Array(Uint32, 1)
glGenTextures(1, texture)
assert(texture[1] != 0)
glBindTexture(GL_TEXTURE_2D, texture[1])
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, C_NULL)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

vertexes = [
    0.0f0, 0.0f0, 0.0f0, 1.0f0, 1.0f0, 1.0f0, 1.0f0, 0.0f0, # texture coordinates
    -1.0f0, -1.0f0,
    -1.0f0, 1.0f0,
    1.0f0, 1.0f0,
    1.0f0, -1.0f0
]
vertexBuffer = Array(Uint32, 1)
glGenBuffers(1, vertexBuffer)
assert(vertexBuffer[1] != 0)
glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer[1])

vbo = Array(Uint32, 1)
glGenBuffers(1, vbo)
assert(vbo[1] != 0)
glBindBuffer(GL_ARRAY_BUFFER, vbo[1])

glBufferData(GL_ARRAY_BUFFER, size(vertexes, 1) * 4, vertexes, GL_STATIC_DRAW)

glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture[1], 0)

assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)

glClearColor(1, 0, 0, 1)
glClear(GL_COLOR_BUFFER_BIT)

glBindFramebuffer(GL_FRAMEBUFFER, 0)
glBindRenderbuffer(GL_RENDERBUFFER, 0)

glBindVertexArray(vao[1])
glBindBuffer(GL_ARRAY_BUFFER, vbo[1])

vertexShader = newShader("data/glsl/texture.vert", GL_VERTEX_SHADER)

while GLFW.WindowShouldClose(window) == 0
    glClearColor(0, 0, 1, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
end

GLFW.Terminate()
