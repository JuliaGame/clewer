include("circle.jl")

mutable struct Shot
    position::Array{Float64, 1}
    velocity::Array{Float64, 1}

    function Shot(position::Array{Float64,1}, velocity::Array{Float64})
        return new(position, velocity)
    end
end
