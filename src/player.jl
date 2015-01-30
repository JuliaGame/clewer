include("rectangle.jl")

type Player
    circle::Circle
    rect::Rectangle
    position::Array{Float64, 1}
    angle::Float64

    function Player(shaderPrograms::ShaderPrograms)
        return new(Circle(shaderPrograms), Rectangle(shaderPrograms), [0.1, 0.5], 0.0)
    end
end

function step(self::Player, input::Input)
    if isPressed(input, LEFT)
        self.angle += 0.02 * pi
    end
    if isPressed(input, RIGHT)
        self.angle -= 0.02 * pi
    end
end

function draw(self::Player, previousModelview::Modelview)
    modelview = copy(previousModelview)
    translate(modelview, self.position ...)
    modelviewCircle = copy(modelview)
    scale(modelviewCircle, 0.06)
    draw(self.circle, modelviewCircle)
    rotate(modelview, self.angle, [0.0f0, 0.0f0, 1.0f0])
    scale(modelview, 0.005, 0.25)
    draw(self.rect, modelview)
end
