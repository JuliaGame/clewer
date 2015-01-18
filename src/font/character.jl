include("../texture.jl")
include("face.jl")

using FreeType

type Character
    width::GLfloat
    left::GLfloat
    top::GLfloat
    texture::Texture

    function Character(shaderPrograms::ShaderPrograms, face::Face, ch::Char)
        error = FT_Load_Char(face.ftFace, ch, FT_LOAD_TARGET_LIGHT | FT_LOAD_RENDER)
        assert(error == 0)

        glyph = unsafe_load(unsafe_load(face.ftFace).glyph)
        bitmap = glyph.bitmap

        assert(bitmap.pixel_mode == FT_PIXEL_MODE_GRAY)

        buffer = Array(UInt8, bitmap.rows * bitmap.width * 4)
        for y in 1:bitmap.rows
            for x in 1:bitmap.width
                buffer[bitmap.width * (y-1) * 4 + (x-1) * 4 + 1] = 255
                buffer[bitmap.width * (y-1) * 4 + (x-1) * 4 + 2] = 255
                buffer[bitmap.width * (y-1) * 4 + (x-1) * 4 + 3] = 255
                buffer[bitmap.width * (y-1) * 4 + (x-1) * 4 + 4] =
                    unsafe_load(bitmap.buffer, bitmap.width * (y-1)  + x)
            end
        end

        return new((glyph.advance.x >> 6) * 0.01, glyph.bitmap_left * 0.01, glyph.bitmap_top * 0.01,
                   Texture(shaderPrograms, bitmap.width, bitmap.rows, buffer))
    end
end

function draw(self::Character, modelview::Modelview)
    tmp = copy(modelview)
    translate(tmp, self.left, self.top)
    setUniform(tmp)
    draw(self.texture)
    translate(modelview, self.width, 0)
end
