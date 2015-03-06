include("modelview.jl")

type Circle
    vao :: GLuint
    program :: GLuint
    verticesCount :: GLsizei

    function Circle(shaderPrograms :: ShaderPrograms)
        self = new()
        vertices :: Array{GLfloat,1} = vcat([0.0f0, 0.0f0],
            vcat(Any[ [cos(i), sin(i)] for i = 0:pi/32:2*pi ] ... ))
        self.verticesCount = size(vertices, 1) / 2

        vao = Array(GLuint, 1)
        glGenVertexArrays(1, vao)
        self.vao = vao[1]
        assert(self.vao != 0)
        glBindVertexArray(self.vao)

        vbo = Array(GLuint, 1)
        glGenBuffers(1, vbo)
        assert(vbo[1] != 0)
        glBindBuffer(GL_ARRAY_BUFFER, vbo[1])
        glBufferData(GL_ARRAY_BUFFER, self.verticesCount * 2 * sizeof(GLfloat), vertices,
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

function draw(self::Circle, modelview::Modelview, shaderPrograms::ShaderPrograms)
    useProgram(shaderPrograms, shaderPrograms.simple)
    setUniform(shaderPrograms, modelview)
    glBindVertexArray(self.vao)
    glDrawArrays(GL_TRIANGLE_FAN, 0, self.verticesCount)
end
