include("texture.jl")

using FreeType

type Character
    width::Integer
    left::Integer
    top::Integer
    texture::Texture

    function Character(ch::Char, height, face::FT_Face)
        error = FT_Load_Char(face, ch, FT_LOAD_TARGET_LIGHT | FT_LOAD_RENDER)
        assert(error == 0)

        bitmap = unsafe_load(unsafe_load(face).glyph).bitmap
    end
end

height = 12

library = Array(FT_Library, 1)
error = FT_Init_FreeType(library)
assert(error == 0)
face = Array(FT_Face, 1)
error = FT_New_Face(library[1], "data/fonts/Lato-Lig.otf", 0, face)
assert(error == 0)
error = FT_Set_Char_Size(face[1], height * 64, height * 64, 96, 96)
assert(error == 0)

test = Character('a', height, face[1])
