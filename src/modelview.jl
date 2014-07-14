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

function rotate(self::Modelview, angle, direction::Vector{GLfloat})
    c = cos(angle)
    s = sin(angle)
    direction /= norm(direction)
    x = direction[1]
    y = direction[2]
    z = direction[3]
    self.matrix *= [[x*x*(1-c)+c     x*y*(1-c)-z*s   x*z*(1-c)+y*s   0],
                    [y*x*(1-c)+z*s   y*y*(1-c)+c     y*z*(1-c)-x*s   0],
                    [x*z*(1-c)-y*s   y*z*(1-c)+x*s   z*z*(1-c)+c     0],
                    [0               0               0               1]]
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
