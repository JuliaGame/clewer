type Rectangle
    vao :: GLuint
    vbo :: GLuint
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
        self.vbo = vbo[1]
        assert(self.vbo != 0)
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        glBufferData(GL_ARRAY_BUFFER, 4 * 2 * sizeof(GLfloat), vertices,
                     GL_STATIC_DRAW)

        self.program = shaderPrograms.simple.id
        glUseProgram(self.program)

        posAttrib = glGetAttribLocation(self.program, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        uniColor = glGetUniformLocation(self.program, "triangleColor")
        assert(uniColor != -1)
        glUniform3f(uniColor, 1, 1, 0)

        return self
    end
end

function draw(self::Rectangle, modelview::Modelview)
    setUniform(modelview)
    glBindVertexArray(self.vao)
    glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
    glUseProgram(self.program)
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4)
end
