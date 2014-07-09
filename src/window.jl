type Window
    glfwWindow :: GLFW.Window
    width
    height
    vao :: Array{Uint32, 1}
    buffer :: Array{Uint32, 1}
    fbo :: Array{Uint32, 1}
    texture :: Array{Uint32, 1}
    vbo :: Array{Uint32, 1}
    shaderProgram :: GLuint

    function Window(width, height)
        glfwWindow = GLFW.CreateWindow(width, height, "Hello World")
        GLFW.MakeContextCurrent(glfwWindow)
        GLFW.SwapInterval(1) # enable vsync

        vao = Array(Uint32, 1)
        glGenVertexArrays(1, vao)
        assert(vao[1] != 0)
        glBindVertexArray(vao[1])

        window = new(glfwWindow, width, height, vao, Array(Uint32, 1),
                   Array(Uint32, 1), Array(Uint32, 1), Array(Uint32, 1))

        GLFW.SetWindowSizeCallback(glfwWindow, (_, width, height) -> resizeWindow(window, width, height))

        vertexes = [
            0.0f0, 0.0f0, 0.0f0, 1.0f0, 1.0f0, 1.0f0, 1.0f0, 0.0f0, # texture coordinates
            -1.0f0, -1.0f0,
            -1.0f0, 1.0f0,
            1.0f0, 1.0f0,
            1.0f0, -1.0f0
        ]
        glGenBuffers(1, window.vbo)
        assert(window.vbo[1] != 0)

        resizeWindow(window, width, height)

        glBindVertexArray(window.vao[1])
        glBindBuffer(GL_ARRAY_BUFFER, window.vbo[1])

        glBufferData(GL_ARRAY_BUFFER, size(vertexes, 1) * 4, vertexes, GL_STATIC_DRAW)

        vertexShader = newShader("data/glsl/texture.vert", GL_VERTEX_SHADER)
        fragmentShader = newShader("data/glsl/texture.frag", GL_FRAGMENT_SHADER)

        window.shaderProgram = glCreateProgram()
        assert(window.shaderProgram != 0)

        glAttachShader(window.shaderProgram, vertexShader)
        glAttachShader(window.shaderProgram, fragmentShader)
        glLinkProgram(window.shaderProgram)
        glUseProgram(window.shaderProgram)

        posAttrib = glGetAttribLocation(window.shaderProgram, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, 8 * sizeof(GLfloat))
        glEnableVertexAttribArray(posAttrib)

        posAttrib = glGetAttribLocation(window.shaderProgram, "texcoord")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        return window
    end
end

function resizeWindow(window::Window, width, height)
    window.width = width
    window.height = height
    # renderbuffer
    glGenRenderbuffers(1, window.buffer)
    glBindRenderbuffer(GL_RENDERBUFFER, window.buffer[1])
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height)

    # framebuffer
    glGenFramebuffers(1, window.fbo)
    glBindFramebuffer(GL_FRAMEBUFFER, window.fbo[1])
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER,
                              window.buffer[1])

    window.texture[1] = 0
    glGenTextures(1, window.texture)
    assert(window.texture[1] != 0)
    glBindTexture(GL_TEXTURE_2D, window.texture[1])
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, C_NULL)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

    vertexBuffer = Array(Uint32, 1)
    glGenBuffers(1, vertexBuffer)
    assert(vertexBuffer[1] != 0)
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer[1])

    glBindBuffer(GL_ARRAY_BUFFER, window.vbo[1]) # FIXME: Is this really needed?

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, window.texture[1],
                           0)

    assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)

    glClearColor(1, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    glViewport(0, 0, width, height)

    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glBindRenderbuffer(GL_RENDERBUFFER, 0)
end

function mainLoop(window::Window)
    triangle = Triangle()
    circle = Circle()

    last_time = time()
    frames = 0.0
    counter = 0.0

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

        glClearColor(0.5, 0.5, 0.5, 1)
        glClear(GL_COLOR_BUFFER_BIT)

        glBindRenderbuffer(GL_FRAMEBUFFER, window.buffer[1])
        glBindFramebuffer(GL_FRAMEBUFFER, window.fbo[1])

        if int(last_time) % 2 == 0
            draw(triangle)
        else
            draw(circle)
        end

        glBindRenderbuffer(GL_RENDERBUFFER, 0)

        # draw framebuffer
        glBindFramebuffer(GL_FRAMEBUFFER, 0)
        glBindVertexArray(window.vao[1])
        glUseProgram(window.shaderProgram)

        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, window.texture[1])

        glDrawArrays(GL_TRIANGLE_FAN, 0, 4)

        GLFW.SwapBuffers(window.glfwWindow)
    end

    GLFW.Terminate()
end
