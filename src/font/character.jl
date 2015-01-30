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

        return new((glyph.advance.x >> 6) * 0.01, glyph.bitmap_left * 0.01, glyph.bitmap_top * 0.01,
                   Texture(shaderPrograms, bitmap.width, bitmap.rows,
                           pointer_to_array(bitmap.buffer, bitmap.rows * bitmap.width)))
    end
end

function draw(self::Character, modelview::Modelview)
    tmp = copy(modelview)
    translate(tmp, self.left, self.top)
    setUniform(tmp)
    draw(self.texture)
    translate(modelview, self.width, 0)
end
