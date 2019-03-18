include("rectangle.jl")
include("game.jl")
include("shot.jl")

mutable struct Player
    rect::Rectangle
    position::Array{Float64, 1}
    angle::Float64
    power::Float64
    radius::Float32
    color::Array{Float32,1}

    function Player(shaderPrograms::ShaderPrograms, position, color::Array{Float32,1})
        return new(Rectangle(shaderPrograms), position, 0.0, 0.25, 0.06, color)
    end
end

function step(self::Player, game::Game)
    if isPressed(game.input, LEFT)
        self.angle += 0.02 * pi
    end
    if isPressed(game.input, RIGHT)
        self.angle -= 0.02 * pi
    end
    if isPressed(game.input, UP) && self.power < 0.5
        self.power += 0.02
    end
    if isPressed(game.input, DOWN) && self.power > 0.09
        self.power -= 0.02
    end
    if isPressed(game.input, FIRE)
        add(game, Shot(self.position, [-sin(self.angle), cos(self.angle)] * self.power * 0.1))
    end
end

function draw(self::Player, previousModelview::Modelview, game::Game)
    modelview = copy(previousModelview)
    translate(modelview, self.position ...)
    modelviewCircle = copy(modelview)
    scale(modelviewCircle, self.radius)
    useProgram(game.shaderPrograms, game.shaderPrograms.simple)
    setColor(game.shaderPrograms, self.color ...)
    draw(game.circle, modelviewCircle, game.shaderPrograms)
    rotate(modelview, self.angle, [0.0f0, 0.0f0, 1.0f0])
    scale(modelview, 0.005, self.power)
    draw(self.rect, modelview, game.shaderPrograms)
end
