include("../texture2.jl")
include("face.jl")

using FreeType

struct Character2
    width::GLfloat
    left::GLfloat
    top::GLfloat
    texture::Texture2

    function Character2(shaderPrograms::ShaderPrograms, face::Face, ch::Char)
        error = FT_Load_Char(face.ftFace, ch, FT_LOAD_RENDER)
        @assert error == 0

        glyph = unsafe_load(unsafe_load(face.ftFace).glyph)
        bitmap = glyph.bitmap

        @assert bitmap.pixel_mode == FT_PIXEL_MODE_GRAY

        width = bitmap.width
        height = bitmap.rows

        buffer = Array{UInt8}(undef, width * height * 4)
        for x in 1:width
            for y in 1:height
                buffer[width * (y-1) * 4 + (x-1) * 4 + 1] = 255
                buffer[width * (y-1) * 4 + (x-1) * 4 + 2] = 255
                buffer[width * (y-1) * 4 + (x-1) * 4 + 3] = 255
                buffer[width * (y-1) * 4 + (x-1) * 4 + 4] =
                    unsafe_load(bitmap.buffer, (y-1)*bitmap.width + x)
            end
        end


        return new((glyph.advance.x >> 6) * PIXEL_SCALE, glyph.bitmap_left * PIXEL_SCALE,
                   glyph.bitmap_top * PIXEL_SCALE,
                   Texture2(shaderPrograms, width, height, buffer))
    end
end

function draw(self::Character2, modelview::Modelview, shaderPrograms::ShaderPrograms)
    tmp = copy(modelview)
    translate(tmp, self.left, self.top)
    setUniform(shaderPrograms, tmp)
    draw(self.texture)
    translate(modelview, self.width, 0)
end
