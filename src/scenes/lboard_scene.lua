local colors      = require("src.globals.colors")
local consts      = require("src.globals.consts")
local res         = require("src.globals.res")
local drawer      = require("src.utils.drawer")
local file        = require("src.utils.file")
local input       = require("src.utils.input")

local lboardScene = {}

local button      = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "BACK",
    active = true,
}

function lboardScene:load(assets, actions, configs)
    self.assets     = assets
    self.actions    = actions
    self.configs    = configs
    self.highScores = file.loadScores()

    button.x        = (love.graphics.getWidth() - button.width) / 2
    button.y        = (love.graphics.getHeight() - button.height) / 2 + 180
end

function lboardScene:handleInputs()
    if input:wasPressed("back") or
        input:wasPressed("accept")
        or input:wasPressed("jump")
    then
        self.assets.clickSound:play()
        self.actions.switchScene("title")
    end
end

function lboardScene:mousemoved(x, y, dx, dy, isTouch)
    local mx, my = love.mouse.getPosition()
    button.active =
        mx > button.x and mx < button.x + button.width and
        my > button.y and my < button.y + button.height
end

function lboardScene:mousepressed(x, y, btn, isTouch, presses)
    if btn == 1 and button.active then
        self.assets.clickSound:play()
        self.actions.switchScene("title")
    end
end

function lboardScene:update(dt)
    self:handleInputs()
end

function lboardScene:draw()
    love.graphics.clear(colors.SLATE_100)

    -- Draw title
    local headerFont = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    drawer.drawCenteredText("LEADERBOARD", headerFont, 0, -68)

    -- Draw high scores
    local subFont = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    local marginT = -28
    local spacingY = 28
    love.graphics.setColor(colors.SLATE_800)
    for i = 1, 5 do
        local score = self.highScores[i] or 0
        local text = "?????? " .. string.rep(".", 80) .. string.format(" %04d", score)
        drawer.drawCenteredText(text, subFont, 0, i * spacingY + marginT)
    end

    -- Draw back button
    drawer.drawButton(button, subFont)
end

return lboardScene
