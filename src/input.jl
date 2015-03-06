@enum InputEnum LEFT RIGHT UP DOWN FIRE

type Input
    window::GLFW.Window
    waitForRelease::Array{Bool,1}

    function Input(window::GLFW.Window)
        return new(window, falses(5))
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
    elseif t == FIRE
        GLFW.KEY_ENTER
    end)
    if rtn
        if self.waitForRelease[int(t) + 1]
            return false
        end
        self.waitForRelease[int(t) + 1] = true
    else
        self.waitForRelease[int(t) + 1] = false
    end
    return rtn
end
