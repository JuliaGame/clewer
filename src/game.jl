include("shot.jl")

using LinearAlgebra

mutable struct Game
    shaderPrograms::ShaderPrograms
    input::Input
    objects::Array{Any, 1}
    shots::Array{Shot, 1}
    shotsToBeRemoved::Array{Shot, 1}
    circle::Circle

    function Game(shaderPrograms::ShaderPrograms, input::Input)
        self = new(shaderPrograms, input, [], [], [], Circle(shaderPrograms))
        players = [Player(window.shaderPrograms, [-0.7, -0.6], [1.0f0, 0.0f0, 0.0f0]),
                   Player(window.shaderPrograms, [0.7, -0.6], [0.0f0, 1.0f0, 0.0f0]),
                   Player(window.shaderPrograms, [0.7, 0.6], [0.0f0, 0.0f0, 1.0f0])]
        planets = []
        for i in 1:4
            valid = false
            planet = 0 # FIXME: Is there some kind of NULL in Julia?
            while !valid
                radius = rand() * 0.32 + 0.09
                planet = Planet([(rand()-0.5) * (3.3 - 2*radius), (rand() - 0.5) * (2 - 2*radius)],
                                radius)
                valid = true
                for player in players
                    if norm(planet.position - player.position) < planet.radius + player.radius * 2
                        valid = false
                        break
                    end
                end
                for other in planets
                    if overlap(planet, other)
                        valid = false
                        break
                    end
                end
            end
            push!(planets, planet)
        end
        for planet in planets
            add(self, planet)
        end
        for player in players
            add(self, player)
        end
        return self
    end
end

include("shot-impl.jl")

function step(self::Game)
    for shot in self.shots
        step(shot, self)
    end
    for obj in self.objects
        step(obj, self)
    end
    for shotToBeRemoved in self.shotsToBeRemoved
        i = 1
        for shot in self.shots
            if shot == shotToBeRemoved
                deleteat!(self.shots, i)
                break
            end
            i += 1
        end
    end
end

function draw(self::Game, modelview::Modelview)
    for obj in self.objects
        draw(obj, modelview, self)
    end
    for shot in self.shots
        draw(shot, modelview, self)
    end
end

function add(self::Game, object)
    push!(self.objects, object)
end

function add(self::Game, shot::Shot)
    push!(self.shots, shot)
end

function remove(self::Game, shot::Shot)
    push!(self.shotsToBeRemoved, shot)
end
