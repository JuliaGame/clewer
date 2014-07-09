const OPENGL_MAJOR = 3
const OPENGL_MINOR = 0

const OpenGLver="$OPENGL_MAJOR.$OPENGL_MINOR"
using ModernGL

import GLFW

import ModernGL.getprocaddress

function getprocaddress(name::ASCIIString)
    GLFW.GetProcAddress(name)
end

include("shader.jl")
include("triangle.jl")
include("circle.jl")
include("window.jl")

GLFW.Init()

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, OPENGL_MINOR)

window = Window(1280, 720)

mainLoop(window)
