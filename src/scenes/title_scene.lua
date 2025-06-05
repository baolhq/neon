local colors       = require("src.globals.colors")
local consts       = require("src.globals.consts")
local res          = require("src.globals.res")
local drawer       = require("src.utils.drawer")
local file         = require("src.utils.file")
local input        = require("src.utils.input")

local titleScene   = {}
local focusedIndex = 1
local buttonOrder  = { "start", "lboard", "settings" }
local buttons      = {
    start = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "START",
        active = true,
    },
    lboard = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "LEADERBOARD",
        active = false,
    },
    settings = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "SETTINGS",
        active = false,
    }
}

function titleScene:load(assets, actions, configs)
    self.assets        = assets
    self.actions       = actions
    self.configs       = configs

    local spacingY     = 48
    buttons.start.x    = (love.graphics.getWidth() - buttons.start.width) / 2
    buttons.start.y    = (love.graphics.getHeight() - buttons.start.height) / 2 + 28
    buttons.lboard.x   = buttons.start.x
    buttons.lboard.y   = buttons.start.y + spacingY
    buttons.settings.x = buttons.lboard.x
    buttons.settings.y = buttons.lboard.y + spacingY

    self.assets.titleSound:play()
end

-- Update active button only when the mouse moved
function titleScene:mousemoved(x, y, dx, dy, isTouch)
    local mx, my = love.mouse.getPosition()

    for i, name in ipairs(buttonOrder) do
        local btn = buttons[name]
        local isHovered =
            mx > btn.x and mx < btn.x + btn.width and
            my > btn.y and my < btn.y + btn.height

        btn.active = isHovered
        if isHovered then
            focusedIndex = i
        end
    end
end

function titleScene:mousepressed(x, y, btn)
    self.assets.clickSound:play()
    for _, b in pairs(buttons) do
        b.focused = false
    end

    if btn == 1 and buttons.start.active then
        buttons.start.active = true
        self.assets.titleSound:stop()
        self.actions.switchScene("main")
    elseif btn == 1 and buttons.lboard.active then
        buttons.lboard.active = true
        self.actions.switchScene("lboard")
    elseif btn == 1 and buttons.settings.active then
        buttons.settings.active = true
        self.actions.switchScene("settings")
    end
end

function titleScene:update(dt)
    if input:wasPressed("back") then self.actions.quit() end

    if input:wasPressed("accept") then
        if buttons.start.active then
            self.assets.titleSound:stop()
            self.actions.switchScene("main")
        elseif buttons.lboard.active then
            self.actions.switchScene("lboard")
        else
            self.actions.switchScene("settings")
        end
    end

    -- Update active button based on keyboard navigations
    if input:wasPressed("tab") or input:wasPressed("down") then
        for _, b in pairs(buttons) do b.active = false end
        focusedIndex = focusedIndex % #buttonOrder + 1
        buttons[buttonOrder[focusedIndex]].active = true
    elseif input:wasPressed("up") then
        for _, b in pairs(buttons) do b.active = false end
        focusedIndex = (focusedIndex - 2) % #buttonOrder + 1
        buttons[buttonOrder[focusedIndex]].active = true
    end
end

function titleScene:draw()
    local font = file:getFont(res.MAIN_FONT, consts.FONT_TITLE_SIZE)
    self.assets.cmsShader(function()
        love.graphics.clear(colors.SLATE_100)
        drawer.drawCenteredText(consts.GAME_TITLE, font, 0, -68)
    end)

    font = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    for _, b in pairs(buttons) do
        drawer.drawButton(b, font)
    end
end

return titleScene
