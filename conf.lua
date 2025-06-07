local consts = require("src.globals.consts")

-- Setup initial stuff
function love.conf(t)
    t.window.width = consts.WINDOW_W
    t.window.height = consts.WINDOW_H
end
