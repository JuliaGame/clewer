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
    end
end

height = 12

library = Array(FT_Library, 1)
error = FT_Init_FreeType(pointer(library))
assert(error == 0)
face = Array(FT_Face, 1)
error = FT_New_Face(library[1], bytestring("data/fonts/Lato-Lig.otf"), 0, pointer(face))
assert(error == 0)
FT_Set_Char_Size(face[1], height * 64, height * 64, convert(Uint32, 96), convert(Uint32, 96))

test = Character('a', height, face[1])
