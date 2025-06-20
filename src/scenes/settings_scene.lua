local colors = require("src.globals.colors")
local consts = require("src.globals.consts")
local res = require("src.globals.res")
local drawer = require("src.utils.drawer")
local file = require("src.utils.file")
local input = require("src.utils.input")

local settingsScene = {}

local focusedIndex = 1
local buttonOrder = { "music", "mode", "back" }
local buttons = {
    music = {
        x = 0,
        y = 0,
        w = 200,
        h = 40,
        text = "MUSIC: ON",
        active = true,
        toggle = true,
        state = true, -- true = ON, false = OFF
    },
    mode = {
        x = 0,
        y = 0,
        w = 200,
        h = 40,
        text = "MODE: NORMAL",
        options = { "NORMAL", "HARD", "INSANE" },
        index = 1,
        active = false,
    },
    back = {
        x = 0,
        y = 0,
        w = 200,
        h = 40,
        text = "BACK",
        active = false,
    }
}

function settingsScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs

    -- Draw buttons with spacings
    local spacingY = 8
    local totalHeight = #buttonOrder * buttons.music.h + (#buttonOrder - 1) * spacingY
    local startY = (lg.getHeight() - totalHeight) / 2 + 88

    for i = 1, #buttonOrder do
        local button = buttons[buttonOrder[i]]
        button.x = (lg.getWidth() - button.w) / 2
        button.y = startY + (i - 1) * (button.h + spacingY)
    end

    if configs.music then
        local state = configs.music == "true"
        buttons.music.state = state
        buttons.music.text = state and "MUSIC: ON" or "MUSIC: OFF"
    end

    if configs.mode then
        local id = tonumber(configs.mode)
        buttons.mode.index = id
        buttons.mode.text = "MODE: " .. buttons.mode.options[id]
    end
end

local function updateMusicBtn(btn, cfg)
    btn.state = not btn.state
    btn.text = "MUSIC: " .. (btn.state and "ON" or "OFF")
    cfg.music = btn.state
    file.saveConfigs(cfg)
end

local function updateModeBtn(btn, cfg)
    btn.index = btn.index % #btn.options + 1
    btn.text = "MODE: " .. btn.options[btn.index]
    cfg.mode = btn.index
    file.saveConfigs(cfg)
end

function settingsScene:handleInputs()
    if input:wasPressed("back") then
        self.actions.switchScene("title")
    end

    if input:wasPressed("accept") or input:wasPressed("jump") then
        if buttons.music.active then
            updateMusicBtn(buttons.music, self.configs)
        elseif buttons.mode.active then
            updateModeBtn(buttons.mode, self.configs)
        else
            self.actions.switchScene("title")
        end
        self.assets.clickSound:play()
    end

    -- Cycling through button focuses
    if input:wasPressed("tab") or
        input:wasPressed("up") or
        input:wasPressed("down")
    then
        -- Remove old focuses
        for _, b in pairs(buttons) do
            b.active = false
        end

        if input:wasPressed("up") then
            focusedIndex = (focusedIndex - 2) % #buttonOrder + 1
        else
            focusedIndex = focusedIndex % #buttonOrder + 1
        end

        buttons[buttonOrder[focusedIndex]].active = true
    end
end

function settingsScene:mousemoved(x, y)
    local btnHovered = false
    for _, b in pairs(buttons) do
        b.active =
            x > b.x and x < b.x + b.w and
            y > b.y and y < b.y + b.h
        if b.active then btnHovered = true end
    end

    if btnHovered then
        local cursor = lm.getSystemCursor("hand")
        lm.setCursor(cursor)
    else
        lm.setCursor()
    end
end

function settingsScene:mousepressed(x, y, btn)
    self.assets.clickSound:play()
    if btn ~= 1 then return end -- left click only

    for name, b in pairs(buttons) do
        if b.active then
            if name == "music" and b.toggle then
                updateMusicBtn(b, self.configs)
            elseif name == "mode" and b.options then
                updateModeBtn(b, self.configs)
            elseif name == "back" then
                self.actions.switchScene("title")
            end
        end
    end
end

function settingsScene:update()
    self:handleInputs()
end

function settingsScene:draw()
    lg.clear(colors.SLATE_100)

    local font = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    drawer.drawCenteredText("SETTINGS", font, 0, -120)

    font = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    for _, btn in pairs(buttons) do
        drawer.drawButton(btn, font)
    end
end

return settingsScene
