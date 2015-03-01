include("opengl.jl")

import GLFW

include("shader_programs.jl")
include("triangle.jl")
include("circle.jl")
include("window.jl")

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, OPENGL_MINOR)

window = Window(1280, 720)

mainLoop(window)
