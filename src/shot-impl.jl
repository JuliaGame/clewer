function step(self::Shot, game::Game)
    self.position += self.velocity
end

function draw(self::Shot, previousModelview::Modelview, game::Game)
    modelview = copy(previousModelview)
    translate(modelview, self.position ...)
    scale(modelview, 0.01)
    draw(game.circle, modelview, game.shaderPrograms)
end
