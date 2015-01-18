include("opengl.jl")

type Texture
    id::GLuint
    vao::GLuint

    function Texture(shaderPrograms::ShaderPrograms, width, height, data)
        id = Array(GLuint, 1)
        glGenTextures(1, id);
        glBindTexture(GL_TEXTURE_2D, id[1])
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                     C_NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);

        vao = Array(GLuint, 1)
        glGenVertexArrays(1, vao)
        assert(vao[1] != 0)
        glBindVertexArray(vao[1])

        vbo = Array(GLuint, 1)
        glGenBuffers(1, vbo)
        assert(vbo[1] != 0)
        glBindBuffer(GL_ARRAY_BUFFER, vbo[1])

        vertexes = [
            0.0f0, 1.0f0, 0.0f0, 0.0f0, 1.0f0, 0.0f0, 1.0f0, 1.0f0, # texture coordinates
            0.0f0, -height * 0.01f0,
            0.0f0, 0.0f0,
            width * 0.01f0, 0.0f0,
            width * 0.01f0, -height * 0.01f0
        ]
        glBufferData(GL_ARRAY_BUFFER, size(vertexes, 1) * 4, vertexes, GL_STATIC_DRAW)

        glUseProgram(shaderPrograms.texture.id)

        posAttrib = glGetAttribLocation(shaderPrograms.texture.id, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, 8 * sizeof(GLfloat))
        glEnableVertexAttribArray(posAttrib)

        posAttrib = glGetAttribLocation(shaderPrograms.texture.id, "texcoord")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        self = new(id[1], vao[1])
        return self
    end
end

function draw(self::Texture)
    glBindVertexArray(self.vao)
    glBindTexture(GL_TEXTURE_2D, self.id)
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4)
end
