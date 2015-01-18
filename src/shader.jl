type Shader
    id::GLuint
    projectionUniform::GLint
    modelviewUniform::GLint

    function Shader(vertex::AbstractString, fragment::AbstractString)
        self = new(newShaderProgram(vertex, fragment))
        self.projectionUniform = glGetUniformLocation(self.id, "projection")
        assert(self.projectionUniform != -1)
        self.modelviewUniform = glGetUniformLocation(self.id, "modelview")
        assert(self.modelviewUniform != -1)
        return self
    end
end

function setProjectionMatrix(self::Shader, matrix::Array{GLfloat, 2})
    glUseProgram(self.id)
    glUniformMatrix4fv(self.projectionUniform, 1, 0, matrix)
end

function setModelviewMatrix(self::Shader, matrix::Array{GLfloat, 2})
    glUseProgram(self.id)
    glUniformMatrix4fv(self.modelviewUniform, 1, 0, matrix)
end

type ShaderPrograms
    simple::Shader
    texture::Shader

    function ShaderPrograms()
        return new(Shader("data/glsl/simple.vert", "data/glsl/simple.frag"),
                   Shader("data/glsl/texture.vert", "data/glsl/texture.frag"))
    end
end

function setProjectionMatrix(self::ShaderPrograms, matrix::Array{GLfloat, 2})
    setProjectionMatrix(self.simple, matrix)
    setProjectionMatrix(self.texture, matrix)
end

function setModelviewMatrix(self::ShaderPrograms, matrix::Array{GLfloat, 2})
    setModelviewMatrix(self.simple, matrix)
    setModelviewMatrix(self.texture, matrix)
end

function newShaderProgram(vertex::AbstractString, fragment::AbstractString)

    function newShader(filename :: String, shaderType)
        file = open(filename)
        src = readall(file)
        close(file)
        shader = glCreateShader(shaderType)
        assert(shader != 0)
        tmp = Array(Ptr{Uint8}, 1)
        tmp[1] = convert(Ptr{Uint8}, src)
        glShaderSource(shader, 1, pointer(tmp), C_NULL)
        glCompileShader(shader)
        status = Array(GLint, 1)
        glGetShaderiv(shader, GL_COMPILE_STATUS, status)
        if status[1] != GL_TRUE
            buffer = Array(Uint8, 512)
            length = Array(Int32, 1)
            glGetShaderInfoLog(shader, size(buffer, 1), length, pointer(buffer))
            buffer[length[1]] = '\0'
            error(bytestring(buffer))
        end
        return shader
    end

    vertexShader = newShader(vertex, GL_VERTEX_SHADER)
    fragmentShader = newShader(fragment, GL_FRAGMENT_SHADER)

    tmp = glCreateProgram()
    assert(tmp != 0)
    glAttachShader(tmp, vertexShader)
    glAttachShader(tmp, fragmentShader)
    glLinkProgram(tmp)
    return tmp
end
