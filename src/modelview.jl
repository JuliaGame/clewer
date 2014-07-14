import Base.copy

type Modelview
    shaderPrograms::ShaderPrograms
    matrix::Array{GLfloat,2}
end

function scale(self::Modelview, x, y=x)
    self.matrix *= [[x 0 0 0],
                    [0 y 0 0],
                    [0 0 1 0],
                    [0 0 0 1]]
end

function rotate(self::Modelview, angle)
    self.matrix *= [[cos(angle) -sin(angle) 0 0],
                    [sin(angle)  cos(angle) 0 0],
                    [0           0          1 0],
                    [0           0          0 1]]
end

function translate(self::Modelview, x, y, z=0)
    self.matrix *= [[1 0 0 x],
                    [0 1 0 y],
                    [0 0 1 z],
                    [0 0 0 1]]
end

function setUniform(self::Modelview)
    setModelviewMatrix(self.shaderPrograms, self.matrix)
end

function reset(self::Modelview)
    self.matrix = eye(4)
end

function copy(self::Modelview)
    return Modelview(self.shaderPrograms, copy(self.matrix))
end
