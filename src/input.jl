include("enum.jl")

@enum InputEnum LEFT RIGHT UP DOWN

type Input
    window::GLFW.Window
    waitForRelease::Array{Bool,1}

    function Input(window::GLFW.Window)
        return new(window, falses(4))
    end
end

function isPressed(self::Input, t::InputEnum)
    rtn = GLFW.GetKey(self.window, if t == LEFT
        GLFW.KEY_LEFT
    elseif t == RIGHT
        GLFW.KEY_RIGHT
    elseif t == UP
        GLFW.KEY_UP
    elseif t == DOWN
        GLFW.KEY_DOWN
    end)
    if rtn
        if self.waitForRelease[t.n + 1]
            return false
        end
        self.waitForRelease[t.n + 1] = true
    else
        self.waitForRelease[t.n + 1] = false
    end
    return rtn
end
