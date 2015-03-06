type Planet
    position::Array{Float64,1}
    radius::Float64

    function Planet(position, radius)
        assert(radius > 0)
        return new(position, radius)
    end
end

function step(self::Planet, game::Game)
    for shot in game.shots
        distance = norm(shot.position - self.position)
        if distance < self.radius
            remove(game, shot)
        else
            shot.velocity += 0.0005 * (self.position - shot.position) * self.radius / distance^3
        end
    end
end

function overlap(self::Planet, other::Planet)
    dist = norm(self.position - other.position)
    SPACING = 0.1
    max = self.radius + other.radius + SPACING
    return dist < max
end

function draw(self::Planet, previousModelview::Modelview, game::Game)
    modelview = copy(previousModelview)
    translate(modelview, self.position ...)
    scale(modelview, self.radius)
    draw(game.circle, modelview, game.shaderPrograms)
end
