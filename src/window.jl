include("modelview.jl")
include("font/text.jl")
include("input.jl")
include("player.jl")
include("planet.jl")

import LinearAlgebra
using FreeType

mutable struct Window
    glfwWindow :: GLFW.Window
    width
    height
    vao :: Array{UInt32, 1}
    buffer :: Array{UInt32, 1}
    fbo :: Array{UInt32, 1}
    texture :: Array{UInt32, 1}
    vbo :: Array{UInt32, 1}
    shaderPrograms :: ShaderPrograms
    modelview::Modelview
    windowShader::GLuint

    function Window(width, height)
        glfwWindow = GLFW.CreateWindow(width, height, "clewer")
        GLFW.MakeContextCurrent(glfwWindow)
        GLFW.SwapInterval(1) # enable vsync

        vao = Array{UInt32}(undef, 1)
        glGenVertexArrays(1, vao)
        @assert vao[1] != 0
        glBindVertexArray(vao[1])

        self = new(glfwWindow, width, height, vao, zeros(UInt32, 1),
                   zeros(UInt32, 1), zeros(UInt32, 1), zeros(UInt32, 1))

        # renderbuffer
        glGenRenderbuffers(1, self.buffer)
        glBindRenderbuffer(GL_RENDERBUFFER, self.buffer[1])
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height)

        # framebuffer
        glGenFramebuffers(1, self.fbo)
        glBindFramebuffer(GL_FRAMEBUFFER, self.fbo[1])
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER,
                                  self.buffer[1])

        GLFW.SetWindowSizeCallback(glfwWindow, (_, width, height) -> resizeWindow(self, width, height))

        vertexes = [
            0.0f0, 0.0f0, 0.0f0, 1.0f0, 1.0f0, 1.0f0, 1.0f0, 0.0f0, # texture coordinates
            -1.0f0, -1.0f0,
            -1.0f0, 1.0f0,
            1.0f0, 1.0f0,
            1.0f0, -1.0f0
        ]
        glGenBuffers(1, self.vbo)
        @assert self.vbo[1] != 0

        self.windowShader = newShaderProgram("data/glsl/window.vert", "data/glsl/window.frag")
        self.modelview = Modelview(Matrix{GLfloat}(LinearAlgebra.I, (4, 4)))
        self.shaderPrograms = ShaderPrograms()

        resizeWindow(self, width, height)

        glBindVertexArray(self.vao[1])
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo[1])

        glBufferData(GL_ARRAY_BUFFER, size(vertexes, 1) * 4, vertexes, GL_STATIC_DRAW)

        glUseProgram(self.windowShader)

        posAttrib = glGetAttribLocation(self.windowShader, "position")
        @assert posAttrib >= 0
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, Ptr{Nothing}(8 * sizeof(GLfloat)))
        glEnableVertexAttribArray(posAttrib)

        posAttrib = glGetAttribLocation(self.windowShader, "texcoord")
        @assert posAttrib >= 0
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        setModelviewMatrix(self.shaderPrograms, self.modelview.matrix)

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        return self
    end
end

function resizeWindow(self::Window, width, height)
    self.width = width
    self.height = height

    if self.texture[1] != 0
        glDeleteTextures(1, self.texture)
    end
    glGenTextures(1, self.texture)
    @assert self.texture[1] != 0
    glBindTexture(GL_TEXTURE_2D, self.texture[1])
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, C_NULL)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

    glBindFramebuffer(GL_FRAMEBUFFER, self.fbo[1])
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.texture[1], 0)

    @assert glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE

    glViewport(0, 0, width, height)

    projection :: Array{GLfloat, 2} = Matrix{GLfloat}(LinearAlgebra.I, (4, 4))
    projection[1,1] = height / width
    setProjectionMatrix(self.shaderPrograms, projection)
end

function mainLoop(window::Window)
    triangle = Triangle(window.shaderPrograms)
    game = Game(window.shaderPrograms, Input(window.glfwWindow))

    library = Array{FT_Library}(undef, 1)
    error = FT_Init_FreeType(library)
    @assert error == 0
    face = Face(library[1], "data/fonts/Lato-Lig.otf")
    text = Text(window.shaderPrograms, face, "Hello World")
    text2 = Text(window.shaderPrograms, face, "Hello World", false)

    last_time = time()
    frames = 0.0
    counter = 0.0

    joystick = GLFW.JOYSTICK_1
    fps = 60

    while GLFW.WindowShouldClose(window.glfwWindow) == 0
        GLFW.PollEvents()

        while true
            dif = time() - last_time
            if dif >= 1.0 / fps
                break
            end
            wait = 1.0 / fps - dif
            if wait > 0.04
                sleep(wait)
            end
        end
        old = last_time
        last_time = time()
        counter += last_time - old
        frames += 1
        if counter >= 1
            frames *= counter
            counter -= 1
            framesRounded::Int = round(frames)
            GLFW.SetWindowTitle(window.glfwWindow, "clewer - FPS: $framesRounded")
            frames = 0
        end

        step(triangle)

        glBindRenderbuffer(GL_FRAMEBUFFER, window.buffer[1])
        glBindFramebuffer(GL_FRAMEBUFFER, window.fbo[1])

        glClearColor(1, 1, 1, 1)
        glClear(GL_COLOR_BUFFER_BIT)
        loadIdentity(window.modelview)

        #draw(triangle, window.modelview, window.shaderPrograms)
        if isPressed(game.input, UP)
            game = Game(game.shaderPrograms, game.input)
        end
        step(game)
        draw(game, window.modelview)

        useProgram(window.shaderPrograms, window.shaderPrograms.texture)
        glActiveTexture(GL_TEXTURE0)
        translate(window.modelview, -1.6, 0)
        #draw(text, window.modelview, window.shaderPrograms)
        translate(window.modelview, 0, 0.5)
        useProgram(window.shaderPrograms, window.shaderPrograms.window)
        #draw(text2, window.modelview, window.shaderPrograms)

        glBindRenderbuffer(GL_RENDERBUFFER, 0)
        glBindFramebuffer(GL_FRAMEBUFFER, 0)
        glBindVertexArray(window.vao[1])
        glUseProgram(window.windowShader)
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, window.texture[1])
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4)
        GLFW.SwapBuffers(window.glfwWindow)
    end

    GLFW.Terminate()
end
