using FreeType

type Face
    ftFace::FT_Face

    function Face(library::FT_Library, filename::AbstractString)
        face = Array(FT_Face, 1)
        error = FT_New_Face(library, "data/fonts/Lato-Lig.otf", 0, face)
        assert(error == 0)
        SIZE = 72
        error = FT_Set_Char_Size(face[1], SIZE * 64, SIZE * 64, 96, 96)
        assert(error == 0)

        return new(face[1])
    end
end
