include("opengl.jl")

PIXEL_SCALE = 0.005f0

type Texture2
    id::GLuint
    vao::GLuint

    function Texture2(shaderPrograms::ShaderPrograms, width, height, data)
        id = Array(GLuint, 1)
        glGenTextures(1, id);
        glBindTexture(GL_TEXTURE_2D, id[1])
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                     data);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

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
            0.0f0, -height * PIXEL_SCALE,
            0.0f0, 0.0f0,
            width * PIXEL_SCALE, 0.0f0,
            width * PIXEL_SCALE, -height * PIXEL_SCALE
        ]
        glBufferData(GL_ARRAY_BUFFER, size(vertexes, 1) * 4, vertexes, GL_STATIC_DRAW)

        glUseProgram(shaderPrograms.texture.id)

        posAttrib = glGetAttribLocation(shaderPrograms.texture.id, "position")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, Ptr{Void}(8 * sizeof(GLfloat)))
        glEnableVertexAttribArray(posAttrib)

        posAttrib = glGetAttribLocation(shaderPrograms.texture.id, "texcoord")
        assert(posAttrib >= 0)
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
        glEnableVertexAttribArray(posAttrib)

        self = new(id[1], vao[1])
        return self
    end
end

function draw(self::Texture2)
    glBindVertexArray(self.vao)
    glBindTexture(GL_TEXTURE_2D, self.id)
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4)
end
