type Rectangle
    vao :: GLuint
    program :: GLuint

    function Rectangle(shaderPrograms :: ShaderPrograms)
        self = new()
        vertices :: Array{GLfloat,1} = [
            -0.5, 1,
             0.5, 1,
             0.5, 0,
            -0.5, 0
        ]

        vao = Array(GLuint, 1)
        glGenVertexArrays(1, vao)
        self.vao = vao[1]
        assert(self.vao != 0)
        glBindVertexArray(self.vao)

        vbo = Array(GLuint, 1)
        glGenBuffers(1, vbo)
        assert(vbo[1] != 0)
        glBindBuffer(GL_ARRAY_BUFFER, vbo[1])
        glBufferData(GL_ARRAY_BUFFER, 4 * 2 * sizeof(GLfloat), vertices,
                     GL_STATIC_DRAW)

        self.program = shaderPrograms.simple.id
        glUseProgram(self.program)

        posAttrib = glGetAttribLocation(self.program, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        return self
    end
end

function draw(self::Rectangle, modelview::Modelview, shaderPrograms::ShaderPrograms)
    setUniform(shaderPrograms, modelview)
    useProgram(shaderPrograms, shaderPrograms.simple)
    glBindVertexArray(self.vao)
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4)
end
