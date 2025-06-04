local colors      = require("src.globals.colors")
local input       = require("src.utils.input")

local lboardScene = {}

function lboardScene:load(assets, actions, configs)
    self.assets  = assets
    self.actions = actions
    self.configs = configs
end

function lboardScene:handleInputs()
    if input:wasPressed("back") then
        self.actions.switchScene("title")
    end
end

function lboardScene:update(dt)
    self:handleInputs()
end

function lboardScene:draw()
    love.graphics.clear(colors.SLATE_100)
end

return lboardScene
