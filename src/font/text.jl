include("character.jl")
include("character2.jl")
include("face.jl")

struct Text
    characters::Array{Any,1}

    function Text(shaderPrograms::ShaderPrograms, face::Face, text::AbstractString,
                  distanceMap = true)
        self = new([])
        for ch in text
            if distanceMap
                push!(self.characters, Character(shaderPrograms, face, ch))
            else
                push!(self.characters, Character2(shaderPrograms, face, ch))
            end
        end
        return self
    end
end

function draw(self::Text, previousModelview::Modelview, shaderPrograms::ShaderPrograms)
    modelview = copy(previousModelview)
    for ch in self.characters
        draw(ch, modelview, shaderPrograms)
    end
end
