local utf8 = require("utf8")
local moonshine = require("lib.moonshine")
local colors = require("src.globals.colors")
local consts = require("src.globals.consts")
local res = require("src.globals.res")
local drawer = require("src.utils.drawer")
local file = require("src.utils.file")
local input = require("src.utils.input") -- Input handling for keyboard/gamepad

local titleScene = {}

-- Ordered lists for UI navigation
local buttonOrder = { "start", "lboard", "settings" }
local focusOrder = { "start", "lboard", "settings", "nameInput" }
local focusedIndex = 1
local justFocusInput = false -- Prevents immediate action after input field loses focus
local prevName = ""          -- Store last valid player name

-- Button configurations for the main menu
local buttons = {
    start = {
        x = 0,
        y = 0,
        w = 200,
        h = 40,
        text = "START",
        active = true
    },
    lboard = {
        x = 0,
        y = 0,
        w = 200,
        h = 40,
        text = "LEADERBOARD",
        active = false
    },
    settings = {
        x = 0,
        y = 0,
        w = 200,
        h = 40,
        text = "SETTINGS",
        active = false
    }
}

-- Configuration for the player name input field
local nameInput = {
    x = 0,
    y = 0,
    w = 200,
    h = 30,
    text = "",
    hovered = false,
    focused = false,
    valid = true,
    maxLength = 10
}

-- Prevents unsupported characters in the player name for consistent rendering/saving
local function hasUtf8(str)
    for _, codepoint in utf8.codes(str) do
        if codepoint > 127 then
            return true
        end
    end
    return false
end

-- Validates the player name input
local function validateInput(text)
    return #text > 0 and #text <= nameInput.maxLength
end

-- Sets up UI positions, loads configurations, and applies visual effects
function titleScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs

    self.cmsShader = moonshine(moonshine.effects.chromasep)
    self.cmsShader.chromasep.angle = -math.pi / 4
    self.cmsShader.chromasep.radius = 4

    -- Ensures a valid default name is set and persisted
    nameInput.text = self.configs.name or "PLAYER1"
    if hasUtf8(nameInput.text) then
        -- Fallback if config name has invalid characters
        nameInput.text = "PLAYER1"
    end
    prevName = nameInput.text
    self.configs.name = prevName
    file.saveConfigs(self.configs)

    -- Center the name input field horizontally and position near bottom
    nameInput.x = (lg.getWidth() - nameInput.w) / 2
    nameInput.y = (lg.getHeight() - nameInput.h) - 40

    -- Position buttons vertically with spacing
    local spacingY = 8
    local totalHeight = #buttonOrder * buttons.start.h + (#buttonOrder - 1) * spacingY
    local startY = (lg.getHeight() - totalHeight) / 2 + 88

    local anyActive = false -- Tracks if any button is active
    for i, name in ipairs(buttonOrder) do
        local button = buttons[name]
        button.x = (lg.getWidth() - button.w) / 2
        button.y = startY + (i - 1) * (button.h + spacingY)
        if button.active then anyActive = true end
    end

    -- Prevents the UI from having no focused element on scene load
    if not anyActive then buttons.start.active = true end

    if not self.assets.titleSound:isPlaying() then
        self.assets.titleSound:play()
    end
end

-- Handles keypresses for the name input field
function titleScene:keypressed(key)
    if not nameInput.focused then return end

    if key == "return" then
        if validateInput(nameInput.text) then
            -- Submit valid input and save
            prevName = nameInput.text
            nameInput.focused = false
            justFocusInput = true
            nameInput.valid = true
            self.configs.name = nameInput.text
            file.saveConfigs(self.configs)
        else
            -- Mark invalid to show error state
            nameInput.valid = false
        end
        return
    end

    if key == "escape" or key == "tab" or key == "up" or key == "down" then
        -- Cancel input and revert to previous name
        nameInput.text = prevName
        nameInput.valid = true
        nameInput.focused = false
        justFocusInput = (key == "escape")
        return
    end

    if key == "backspace" and #nameInput.text > 0 then
        -- Enables character deletion while ensuring input validity
        nameInput.text = nameInput.text:sub(1, -2)
        nameInput.valid = validateInput(nameInput.text)
    end
end

-- Handles text input for the name field
function titleScene:textinput(t)
    if not nameInput.focused then return end
    if hasUtf8(t) then return end -- Ignore non-ASCII characters

    if #nameInput.text < nameInput.maxLength then
        nameInput.text = nameInput.text .. t
        nameInput.valid = validateInput(nameInput.text)
    else
        nameInput.valid = false
    end
end

-- Updates button states based on mouse position
function titleScene:mousemoved(x, y)
    local btnHovered = false
    for i, name in ipairs(buttonOrder) do
        local btn = buttons[name]
        local isHovered =
            x > btn.x and x < btn.x + btn.w and
            y > btn.y and y < btn.y + btn.h
        btn.active = isHovered
        if btn.active then btnHovered = true end
        if isHovered then focusedIndex = i end
    end

    -- Highlights input field when mouse is over it
    nameInput.hovered =
        x > nameInput.x and x < nameInput.x + nameInput.w and
        y > nameInput.y and y < nameInput.y + nameInput.h

    if btnHovered then
        local cursor = lm.getSystemCursor("hand")
        lm.setCursor(cursor)
    elseif nameInput.hovered then
        local cursor = lm.getSystemCursor("ibeam")
        lm.setCursor(cursor)
    else
        lm.setCursor()
    end
end

-- Handles mouse clicks on UI elements
function titleScene:mousepressed(x, y, btn)
    focusedIndex = 0
    for _, b in pairs(buttons) do
        b.active = false -- Reset all button states
    end

    local clickedElement = nil
    for i, name in ipairs(focusOrder) do
        if name == "nameInput" then
            if x > nameInput.x and x < nameInput.x + nameInput.w and
                y > nameInput.y and y < nameInput.y + nameInput.h then
                clickedElement = name
                focusedIndex = i
                nameInput.focused = true
                nameInput.hovered = true
            end
        else
            local b = buttons[name]
            if x > b.x and x < b.x + b.w and y > b.y and y < b.y + b.h then
                clickedElement = name
                focusedIndex = i
                b.active = true
                self.assets.clickSound:play()
            end
        end
    end

    if btn == 1 then
        if clickedElement == "start" then
            lm.setCursor()
            self.assets.titleSound:stop()
            self.actions.switchScene("main")
        elseif clickedElement == "lboard" then
            self.actions.switchScene("lboard")
        elseif clickedElement == "settings" then
            self.actions.switchScene("settings")
        elseif clickedElement == "nameInput" then
            nameInput.focused = true
        else
            -- Saves or reverts input based on validity
            if validateInput(nameInput.text) then
                prevName = nameInput.text
                self.configs.name = nameInput.text
                file.saveConfigs(self.configs)
                nameInput.valid = true
            else
                nameInput.text = prevName
                nameInput.valid = true
            end
            nameInput.focused = false
        end
    end
end

-- Handles keyboard/gamepad inputs for navigation and actions
function titleScene:handleInputs()
    if nameInput.focused then return end -- Ignore inputs while typing

    if not justFocusInput and input:wasPressed("back") then
        self.actions.quit()
    end

    if not justFocusInput and (input:wasPressed("accept") or input:wasPressed("jump")) then
        local focusedName = focusOrder[focusedIndex]
        if focusedName == "start" then
            self.assets.titleSound:stop()
            self.actions.switchScene("main")
        elseif focusedName == "lboard" then
            self.actions.switchScene("lboard")
        elseif focusedName == "settings" then
            self.actions.switchScene("settings")
        elseif focusedName == "nameInput" then
            nameInput.focused = true
        end
        self.assets.clickSound:play()
    end

    if input:wasPressed("tab") or input:wasPressed("down") then
        -- Move focus to next UI element
        for _, b in pairs(buttons) do b.active = false end
        nameInput.focused = false
        focusedIndex = focusedIndex % #focusOrder + 1
        local focusedName = focusOrder[focusedIndex]
        if focusedName == "nameInput" then
            nameInput.focused = true
        else
            buttons[focusedName].active = true
        end
    elseif input:wasPressed("up") then
        -- Move focus to previous UI element
        for _, b in pairs(buttons) do b.active = false end
        nameInput.focused = false

        if focusedIndex == 0 then
            focusedIndex = #focusOrder -- Go to nameInput (last element)
        else
            focusedIndex = (focusedIndex - 2) % #focusOrder + 1
        end

        local focusedName = focusOrder[focusedIndex]
        if focusedName == "nameInput" then
            nameInput.focused = true
        else
            buttons[focusedName].active = true
        end
    end

    justFocusInput = false -- Reset flag after processing
end

-- Processes input handling each frame
function titleScene:update()
    self:handleInputs()
end

-- Draws the title screen
function titleScene:draw()
    local font = file:getFont(res.MAIN_FONT, consts.FONT_TITLE_SIZE)
    self.cmsShader(function()
        lg.clear(colors.SLATE_100)
        drawer.drawCenteredText(consts.GAME_TITLE, font, 0, -120)
    end)

    -- Draw name input field and buttons
    font = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    drawer.drawTextBox(nameInput, font)
    for _, name in ipairs(buttonOrder) do
        drawer.drawButton(buttons[name], font)
    end
end

return titleScene
