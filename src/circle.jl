include("modelview.jl")

type Circle
    vao :: GLuint
    vbo :: GLuint
    program :: GLuint
    verticesCount :: GLsizei

    function Circle(shaderPrograms :: ShaderPrograms)
        self = new()
        vertices :: Array{GLfloat,1} = vcat([0.0f0, 0.0f0],
            vcat( { [cos(i), sin(i)] for i = 0:pi/32:2*pi } ... ))
        self.verticesCount = size(vertices, 1) / 2

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
        glBufferData(GL_ARRAY_BUFFER, self.verticesCount * 2 * sizeof(GLfloat), vertices,
                     GL_STATIC_DRAW)

        self.program = shaderPrograms.simple
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

function draw(modelview::Modelview, circle::Circle)
    scale(modelview, rand()+1, 1)
    setUniform(modelview)

    glBindVertexArray(circle.vao)
    glBindBuffer(GL_ARRAY_BUFFER, circle.vbo)
    glUseProgram(circle.program)
    glDrawArrays(GL_TRIANGLE_FAN, 0, circle.verticesCount)
end
