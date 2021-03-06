mutable struct Shader
    id::GLuint
    projectionUniform::GLint
    modelviewUniform::GLint

    function Shader(vertex::AbstractString, fragment::AbstractString)
        self = new(newShaderProgram(vertex, fragment))
        self.projectionUniform = glGetUniformLocation(self.id, "projection")
        @assert self.projectionUniform != -1
        self.modelviewUniform = glGetUniformLocation(self.id, "modelview")
        @assert self.modelviewUniform != -1
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

function newShaderProgram(vertex::AbstractString, fragment::AbstractString)

    function newShader(filename :: AbstractString, shaderType)
        file = open(filename)
        src = read(file, String)
        close(file)
        shader = glCreateShader(shaderType)
        @assert shader != 0
        tmp = Array{Ptr{UInt8}}(undef, 1)
        tmp[1] = pointer(src)
        glShaderSource(shader, 1, pointer(tmp), C_NULL)
        glCompileShader(shader)
        status = Array{GLint}(undef, 1)
        glGetShaderiv(shader, GL_COMPILE_STATUS, status)
        if status[1] != GL_TRUE
            buffer = Array{UInt8}(undef, 512)
            length = Array{Int32}(undef, 1)
            glGetShaderInfoLog(shader, size(buffer, 1), length, pointer(buffer))
            buffer[length[1]] = '\0'
            error(bytestring(buffer))
        end
        return shader
    end

    vertexShader = newShader(vertex, GL_VERTEX_SHADER)
    fragmentShader = newShader(fragment, GL_FRAGMENT_SHADER)

    tmp = glCreateProgram()
    @assert tmp != 0
    glAttachShader(tmp, vertexShader)
    glAttachShader(tmp, fragmentShader)
    glLinkProgram(tmp)
    status = Array{GLint}(undef, 1)
    glGetProgramiv(tmp, GL_LINK_STATUS, status)
    @assert status[1] == GL_TRUE
    return tmp
end
