const OPENGL_MAJOR = 3
const OPENGL_MINOR = 0

const OpenGLver="$OPENGL_MAJOR.$OPENGL_MINOR"
using ModernGL

import GLFW

import ModernGL.getprocaddress

function getprocaddress(name::ASCIIString)
    GLFW.GetProcAddress(name)
end

include("shader.jl")

type Triangle
    vao :: GLuint
    vbo :: GLuint
    program :: GLuint
    pos :: GLint

    function Triangle()
        vertices = [
            0.0f0, 0.2f0,
            0.5f0, -0.5f0,
            -0.5f0, -0.5f0
        ]

        vao = Array(GLuint, 1)
        glGenVertexArrays(1, vao)
        assert(vao[1] != 0)
        glBindVertexArray(vao[1])

        vbo = Array(GLuint, 1)
        glGenBuffers(1, vbo)
        assert(vbo[1] != 0)
        glBindBuffer(GL_ARRAY_BUFFER, vbo[1])
        glBufferData(GL_ARRAY_BUFFER, size(vertices, 1) * sizeof(GLfloat), vertices, GL_STATIC_DRAW)

        vertexShader = newShader("data/glsl/simple.vert", GL_VERTEX_SHADER)
        fragmentShader = newShader("data/glsl/simple.frag", GL_FRAGMENT_SHADER)

        shaderProgram = glCreateProgram()
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)
        glLinkProgram(shaderProgram)
        glUseProgram(shaderProgram)

        posAttrib = glGetAttribLocation(shaderProgram, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        uniColor = glGetUniformLocation(shaderProgram, "triangleColor")
        assert(uniColor != -1)
        glUniform3f(uniColor, 1, 1, 0)

        uniPos = glGetUniformLocation(shaderProgram, "pos")
        assert(uniPos != -1)

        return new(vao[1], vbo[1], shaderProgram, uniPos)
    end
end

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, OPENGL_MINOR)

width = 800
height = 600

window = GLFW.CreateWindow(width, height, "Hello World")

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
fragmentShader = newShader("data/glsl/texture.frag", GL_FRAGMENT_SHADER)

glAttachShader(shaderProgram, vertexShader)
glAttachShader(shaderProgram, fragmentShader)
glLinkProgram(shaderProgram)
glUseProgram(shaderProgram)

posAttrib = glGetAttribLocation(shaderProgram, "position")
assert(posAttrib >= 0)
glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, 8 * sizeof(GLfloat))
glEnableVertexAttribArray(posAttrib)

posAttrib = glGetAttribLocation(shaderProgram, "texcoord")
assert(posAttrib >= 0)
glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
glEnableVertexAttribArray(posAttrib)

triangle = Triangle()

last_time = time()
frames = 0.0
counter = 0.0

joystick = GLFW.JOYSTICK_1

while GLFW.WindowShouldClose(window) == 0
    GLFW.PollEvents()

    old = last_time
    last_time = time()
    counter += last_time - old
    frames += 1
    if counter >= 1
        frames *= counter
        counter -= 1
        GLFW.SetWindowTitle(window, "clewer - FPS: $frames")
        frames = 0
    end
    while true
        dif = time() - last_time
        if dif >= 0.008
            break
        end
        sleep(0.008 - dif)
    end

    glClearColor(0.5, 0.5, 0.5, 1)
    glClear(GL_COLOR_BUFFER_BIT)

    glBindRenderbuffer(GL_FRAMEBUFFER, buffer[1])
    glBindFramebuffer(GL_FRAMEBUFFER, fbo[1])

    glBindVertexArray(triangle.vao)
    glBindBuffer(GL_ARRAY_BUFFER, triangle.vbo)
    glUseProgram(triangle.program)

    glUniform2f(triangle.pos, 0.5, 0.5)
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawArrays(GL_TRIANGLES, 0, 3)

    glBindRenderbuffer(GL_RENDERBUFFER, 0)

    # draw framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glBindVertexArray(vao[1])
    glUseProgram(shaderProgram)

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, texture[1])

    glDrawArrays(GL_TRIANGLE_FAN, 0, 4)

    GLFW.SwapBuffers(window)
end

GLFW.Terminate()
