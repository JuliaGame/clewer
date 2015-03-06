include("shader.jl")
include("modelview.jl")

type ShaderPrograms
    simple::Shader
    texture::Shader
    window::Shader
    active::Shader
    uniColor::GLint

    function ShaderPrograms()
        self = new(Shader("data/glsl/simple.vert", "data/glsl/simple.frag"),
                   Shader("data/glsl/texture.vert", "data/glsl/texture.frag"),
                   Shader("data/glsl/texture.vert", "data/glsl/window.frag"))
        useProgram(self, self.simple)
        self.uniColor = glGetUniformLocation(self.simple.id, "color")
        assert(self.uniColor != -1)
        return self
    end
end

function setColor(self::ShaderPrograms, red::GLfloat, green::GLfloat, blue::GLfloat)
    glUniform3f(self.uniColor, red, green, blue)
end

function useProgram(self::ShaderPrograms, shader::Shader)
    self.active = shader
    glUseProgram(self.active.id)
end

function setProjectionMatrix(self::ShaderPrograms, matrix::Array{GLfloat, 2})
    setProjectionMatrix(self.simple, matrix)
    setProjectionMatrix(self.texture, matrix)
    setProjectionMatrix(self.window, matrix)
end

function setModelviewMatrix(self::ShaderPrograms, matrix::Array{GLfloat, 2})
    setModelviewMatrix(self.active, matrix)
end

function setUniform(self::ShaderPrograms, modelview::Modelview)
    setModelviewMatrix(self, modelview.matrix)
end
