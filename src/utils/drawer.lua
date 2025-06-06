local colors = require("src.globals.colors")
local consts = require("src.globals.consts")
local res    = require("src.globals.res")
local file   = require("src.utils.file")

local drawer = {}

function drawer.drawCenteredText(text, font, xOffset, yOffset)
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    local x = (love.graphics.getWidth() - textW) / 2 + xOffset
    local y = (love.graphics.getHeight() - textH) / 2 + yOffset

    love.graphics.print(text, x, y)
end

function drawer.drawButton(btn, font)
    -- Draw background
    if btn.active then
        -- Active button effect
        love.graphics.setColor(colors.SLATE_800)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height, 4, 4)

        love.graphics.setColor(colors.SLATE_400)
    end

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    local textW = font:getWidth(btn.text)
    local textH = font:getHeight(btn.text)
    love.graphics.print(
        btn.text,
        btn.x + (btn.width - textW) / 2,
        btn.y + (btn.height - textH) / 2
    )
end

---Draw text overlays with background
---@param bgHeight number
---@param headerText string
---@param subTexts table
function drawer.drawOverlay(bgHeight, headerText, subTexts)
    love.graphics.setColor(colors.SLATE_800)
    local bgY = (love.graphics.getHeight() - bgHeight) / 2
    love.graphics.rectangle("fill", 0, bgY, love.graphics.getWidth(), bgHeight)

    local headerFont = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    love.graphics.setColor(colors.SLATE_100)
    drawer.drawCenteredText(headerText, headerFont, 0, subTexts[1].y - 18)

    local subFont = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    love.graphics.setColor(colors.SLATE_300)
    for i, textInfo in ipairs(subTexts) do
        drawer.drawCenteredText(textInfo.text, subFont, 0, textInfo.y + 18 * i)
    end
end

---Draw an interactive text box for user input
---@param textbox table {x, y, width, height, text, active, maxLength}
---@param font love.Font Font to use for text rendering
function drawer.drawTextBox(textbox, font)
    -- Draw background
    love.graphics.setColor(colors.SLATE_400)
    love.graphics.rectangle("fill", textbox.x, textbox.y, textbox.width, textbox.height, 4, 4)

    -- Draw border (highlighted if active)
    if textbox.active then
        love.graphics.setColor(colors.SLATE_800)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", textbox.x, textbox.y, textbox.width, textbox.height, 4, 4)
    end

    -- Draw text
    love.graphics.setColor(colors.WHITE)
    love.graphics.setFont(font)
    local displayText = textbox.text or ""
    if displayText == "" then
        displayText = "Enter Name"               -- Placeholder text
        love.graphics.setColor(colors.SLATE_600) -- Dimmed for placeholder
    end
    local textW = font:getWidth(displayText)
    local textH = font:getHeight()
    love.graphics.print(
        displayText,
        textbox.x + 10, -- Padding
        textbox.y + (textbox.height - textH) / 2
    )

    -- Draw blinking cursor when active
    if textbox.active then
        local cursorTime = love.timer.getTime() % 1
        if cursorTime < 0.5 then
            local cursorX = textbox.x + 10 + (textW > 0 and textW or font:getWidth("Enter Name"))
            love.graphics.setColor(colors.SLATE_800)
            love.graphics.rectangle(
                "fill",
                cursorX,
                textbox.y + (textbox.height - textH) / 2,
                2,
                textH
            )
        end
    end
end

return drawer
