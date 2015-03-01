include("shader.jl")
include("modelview.jl")

type ShaderPrograms
    simple::Shader
    texture::Shader
    window::Shader
    active::Shader

    function ShaderPrograms()
        self = new(Shader("data/glsl/simple.vert", "data/glsl/simple.frag"),
                   Shader("data/glsl/texture.vert", "data/glsl/texture.frag"),
                   Shader("data/glsl/texture.vert", "data/glsl/window.frag"))
        useProgram(self, self.simple)

        return self
    end
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
