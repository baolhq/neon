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
    w = 200,
    h = 40,
    text = "BACK",
    active = true,
}

function lboardScene:load(assets, actions, configs)
    self.assets     = assets
    self.actions    = actions
    self.configs    = configs
    self.highScores = file.loadScores()

    button.x        = (love.graphics.getWidth() - button.w) / 2
    button.y        = (love.graphics.getHeight() - button.h) / 2 + 170

    if not self.assets.titleSound:isPlaying() then
        self.assets.titleSound:play()
    end
end

function lboardScene:handleInputs()
    if input:wasPressed("back") or
        input:wasPressed("accept")
        or input:wasPressed("jump")
    then
        self.assets.clickSound:play()
        self.actions.switchScene("title")
    end

    if input:wasPressed("tab") then
        button.active = true
    end
end

function lboardScene:mousemoved(x, y)
    button.active =
        x > button.x and x < button.x + button.w and
        y > button.y and y < button.y + button.h

    if button.active then
        local cursor = love.mouse.getSystemCursor("hand")
        love.mouse.setCursor(cursor)
    else
        love.mouse.setCursor()
    end
end

function lboardScene:mousepressed(x, y, btn)
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
    drawer.drawCenteredText("LEADERBOARD", headerFont, 0, -120)

    -- Precompute values
    local centerX  = love.graphics.getWidth() / 2
    local marginT  = -80
    local spacingY = 35
    local maxWidth = 450
    local indexX   = centerX - maxWidth / 2 - 5
    local monoFont = file:getFont(res.MONO_FONT, consts.FONT_MAIN_SIZE)
    love.graphics.setFont(monoFont)
    love.graphics.setColor(colors.SLATE_800)

    for i = 1, 5 do
        local entry      = self.highScores[i] or { name = string.rep("?", 10), value = 0 }
        local index      = string.format("%d.", i)
        local name       = entry.name
        local score      = string.format("%04d", entry.value)

        -- Positioning
        local nameText   = name
        local scoreText  = score
        local scoreWidth = monoFont:getWidth(scoreText)
        local lineY      = (love.graphics.getHeight() - monoFont:getHeight()) / 2
            + i * spacingY + marginT

        love.graphics.print(index, indexX, lineY)
        love.graphics.print(nameText, centerX - maxWidth / 2 + 35, lineY)
        love.graphics.print(scoreText, centerX + maxWidth / 2 - scoreWidth, lineY)

        -- Draw horizontal line
        love.graphics.setLineWidth(1)
        lineY = lineY + monoFont:getHeight() - 4
        love.graphics.line(indexX, lineY, centerX + maxWidth / 2, lineY)
    end

    -- Draw back button
    local subFont = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    drawer.drawButton(button, subFont)
end

return lboardScene
