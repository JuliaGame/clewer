type Circle
    vao :: GLuint
    vbo :: GLuint
    program :: GLuint
    pos :: GLint
    verticesCount :: GLsizei

    function Circle()
        vertices :: Array{GLfloat,1} = vcat([0.0f0, 0.0f0],
            vcat( { [cos(i), sin(i)] for i = 0:pi/32:2*pi } ... ))
        verticesCount = size(vertices, 1)

        vao = Array(GLuint, 1)
        glGenVertexArrays(1, vao)
        assert(vao[1] != 0)
        glBindVertexArray(vao[1])

        vbo = Array(GLuint, 1)
        glGenBuffers(1, vbo)
        assert(vbo[1] != 0)
        glBindBuffer(GL_ARRAY_BUFFER, vbo[1])
        glBufferData(GL_ARRAY_BUFFER, verticesCount * sizeof(GLfloat), vertices, GL_STATIC_DRAW)

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
        glUniform2f(uniPos, 0, 0)
        assert(uniPos != -1)

        return new(vao[1], vbo[1], shaderProgram, uniPos, verticesCount)
    end
end

function draw(circle::Circle)
    glBindVertexArray(circle.vao)
    glBindBuffer(GL_ARRAY_BUFFER, circle.vbo)
    glUseProgram(circle.program)

    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawArrays(GL_TRIANGLE_FAN, 0, circle.verticesCount)
end
