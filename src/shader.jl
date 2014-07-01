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
