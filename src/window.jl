include("modelview.jl")
include("font/text.jl")
include("input.jl")
include("player.jl")

using FreeType

type Window
    glfwWindow :: GLFW.Window
    width
    height
    vao :: Array{Uint32, 1}
    buffer :: Array{Uint32, 1}
    fbo :: Array{Uint32, 1}
    texture :: Array{Uint32, 1}
    vbo :: Array{Uint32, 1}
    shaderPrograms :: ShaderPrograms
    modelview::Modelview
    windowShader::GLuint

    function Window(width, height)
        glfwWindow = GLFW.CreateWindow(width, height, "Hello World")
        GLFW.MakeContextCurrent(glfwWindow)
        GLFW.SwapInterval(1) # enable vsync

        vao = Array(Uint32, 1)
        glGenVertexArrays(1, vao)
        assert(vao[1] != 0)
        glBindVertexArray(vao[1])

        self = new(glfwWindow, width, height, vao, zeros(Uint32, 1),
                   zeros(Uint32, 1), zeros(Uint32, 1), zeros(Uint32, 1))

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
        assert(self.vbo[1] != 0)

        self.shaderPrograms = ShaderPrograms()
        self.windowShader = newShaderProgram("data/glsl/window.vert", "data/glsl/window.frag")
        self.modelview = Modelview(self.shaderPrograms, eye(4))

        resizeWindow(self, width, height)

        glBindVertexArray(self.vao[1])
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo[1])

        glBufferData(GL_ARRAY_BUFFER, size(vertexes, 1) * 4, vertexes, GL_STATIC_DRAW)

        glUseProgram(self.windowShader)

        posAttrib = glGetAttribLocation(self.windowShader, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, 8 * sizeof(GLfloat))
        glEnableVertexAttribArray(posAttrib)

        posAttrib = glGetAttribLocation(self.windowShader, "texcoord")
        assert(posAttrib >= 0)
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
    assert(self.texture[1] != 0)
    glBindTexture(GL_TEXTURE_2D, self.texture[1])
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, C_NULL)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

    glBindFramebuffer(GL_FRAMEBUFFER, self.fbo[1])
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.texture[1], 0)

    assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)

    glViewport(0, 0, width, height)

    projection :: Array{GLfloat, 2} = eye(4)
    projection[1,1] = height / width
    setProjectionMatrix(self.shaderPrograms, projection)
end

function mainLoop(window::Window)
    triangle = Triangle(window.shaderPrograms)
    player = Player(window.shaderPrograms)

    library = Array(FT_Library, 1)
    error = FT_Init_FreeType(library)
    assert(error == 0)
    face = Face(library[1], "data/fonts/Lato-Lig.otf")
    text = Text(window.shaderPrograms, face, "Hello World")

    last_time = time()
    frames = 0.0
    counter = 0.0

    input = Input(window.glfwWindow)
    joystick = GLFW.JOYSTICK_1

    while GLFW.WindowShouldClose(window.glfwWindow) == 0
        GLFW.PollEvents()

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
        while true
            dif = time() - last_time
            if dif >= 0.008
                break
            end
            sleep(0.008 - dif)
        end

        step(triangle)

        glBindRenderbuffer(GL_FRAMEBUFFER, window.buffer[1])
        glBindFramebuffer(GL_FRAMEBUFFER, window.fbo[1])

        glClearColor(0, 0, 0, 1)
        glClear(GL_COLOR_BUFFER_BIT)
        loadIdentity(window.modelview)

        #draw(triangle, window.modelview)
        step(player, input)
        #draw(player, window.modelview)

        glUseProgram(window.shaderPrograms.texture.id)
        glActiveTexture(GL_TEXTURE0)
        translate(window.modelview, -1.6, 0)
        draw(text, window.modelview)

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
