include("../texture.jl")
include("face.jl")
include("distancemap.jl")

using FreeType

struct Character
    width::GLfloat
    left::GLfloat
    top::GLfloat
    texture::Texture

    function Character(shaderPrograms::ShaderPrograms, face::Face, ch::Char)
        error = FT_Load_Char(face.ftFace, ch, FT_LOAD_RENDER)
        @assert error == 0

        glyph = unsafe_load(unsafe_load(face.ftFace).glyph)
        bitmap = glyph.bitmap

        @assert bitmap.pixel_mode == FT_PIXEL_MODE_GRAY

        include("font/distancemap.jl")

        SPREAD = 15
        width = bitmap.width + SPREAD * 2
        height = bitmap.rows + SPREAD * 2

        grid1 = Array{Tuple{Int32, Int32}}(undef, height, width)
        grid2 = Array{Tuple{Int32, Int32}}(undef, height, width)
        for x in 1:width
            for y in 1:height
                if x <= SPREAD || x > bitmap.width + SPREAD ||
                   y <= SPREAD || y > bitmap.rows + SPREAD
                    pixel = 0
                else
                    pixel = unsafe_load(bitmap.buffer, (y-SPREAD-1)*bitmap.width + (x-SPREAD))
                end
                if pixel == 0
                    grid1[y,x] = INSIDE
                    grid2[y,x] = OUTSIDE
                else
                    grid1[y,x] = OUTSIDE
                    grid2[y,x] = INSIDE
                end
            end
        end
        propagate(grid1)
        propagate(grid2)

        signedDistance = Array{Float32}(undef, height, width)
        for y in 1:height
            for x in 1:width
                dist2 = sqrt(distSq(grid1[y,x]))
                dist1 = sqrt(distSq(grid2[y,x]))
                signedDistance[y,x] = dist1 - dist2
            end
        end

        MAX_DIST = SPREAD
        MIN_DIST = -SPREAD
        buffer = Array{UInt8}(undef, width * height * 4)
        for x in 1:width
            for y in 1:height
                buffer[width * (y-1) * 4 + (x-1) * 4 + 1] = 255
                buffer[width * (y-1) * 4 + (x-1) * 4 + 2] = 255
                buffer[width * (y-1) * 4 + (x-1) * 4 + 3] = 255
                dist = signedDistance[y,x]
                if dist < 0
                    dist = -128 * (dist - MIN_DIST) / MIN_DIST
                else
                    dist = 128 + 128 * dist / MAX_DIST
                end
                if dist < 0
                    dist = 0
                elseif dist > 255
                    dist = 255
                end
                buffer[width * (y-1) * 4 + (x-1) * 4 + 4] = 255 - round(Int, dist)
            end
        end


        return new((glyph.advance.x >> 6) * PIXEL_SCALE, (glyph.bitmap_left - SPREAD) * PIXEL_SCALE,
                   (glyph.bitmap_top + SPREAD) * PIXEL_SCALE,
                   Texture(shaderPrograms, width, height, buffer))
    end
end

function draw(self::Character, modelview::Modelview, shaderPrograms::ShaderPrograms)
    tmp = copy(modelview)
    translate(tmp, self.left, self.top)
    setUniform(shaderPrograms, tmp)
    draw(self.texture)
    translate(modelview, self.width, 0)
end
