local consts = require("src.globals.consts")

-- Setup initial stuff
function love.conf(t)
    t.window.width = consts.WINDOW_WIDTH
    t.window.height = consts.WINDOW_HEIGHT
    t.window.msaa = 4
end
