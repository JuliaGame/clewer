type ShaderPrograms
    simple :: GLuint
    texture :: GLuint
    projectionUniform :: GLint
    modelviewUniform::GLint

    function ShaderPrograms()
        self = new(newShaderProgram("data/glsl/simple.vert", "data/glsl/simple.frag"),
                   newShaderProgram("data/glsl/texture.vert", "data/glsl/texture.frag"))

        self.projectionUniform = glGetUniformLocation(self.simple, "projection")
        assert(self.projectionUniform != -1)
        self.modelviewUniform = glGetUniformLocation(self.simple, "modelview")
        assert(self.modelviewUniform != -1)

        return self
    end
end

function setProjectionMatrix(shaderPrograms :: ShaderPrograms,
                             matrix :: Array{GLfloat, 2})
    glUseProgram(shaderPrograms.simple)
    glUniformMatrix4fv(shaderPrograms.projectionUniform, 1, 0, matrix)
end

function setModelviewMatrix(shaderPrograms::ShaderPrograms, matrix::Array{GLfloat, 2})
    glUseProgram(shaderPrograms.simple)
    glUniformMatrix4fv(shaderPrograms.modelviewUniform, 1, 0, matrix)
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
            glGetShaderInfoLog(shader, size(buffer, 1), convert(Ptr{Int}, length),
                               convert(Ptr{Int}, buffer))
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
