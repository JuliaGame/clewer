include("opengl.jl")

type Texture
    id::GLuint
    vbo::GLuint

    function Texture()
        self = new()

        return self
    end
end
