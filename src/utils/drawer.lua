local colors = require("src.globals.colors")
local consts = require("src.globals.consts")
local res = require("src.globals.res")
local file = require("src.utils.file")

local drawer = {}

function drawer.drawCenteredText(text, font, xOffset, yOffset)
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    local x = (lg.getWidth() - textW) / 2 + xOffset
    local y = (lg.getHeight() - textH) / 2 + yOffset

    lg.print(text, x, y)
end

function drawer.drawButton(btn, font)
    -- Draw background
    if btn.active then
        -- Active button effect
        lg.setColor(colors.SLATE_800)
        lg.setLineWidth(2)
        lg.rectangle("line", btn.x, btn.y, btn.w, btn.h, 4, 4)

        lg.setColor(colors.SLATE_400)
    end

    -- Button text
    lg.setColor(1, 1, 1)
    lg.setFont(font)
    local textW = font:getWidth(btn.text)
    local textH = font:getHeight(btn.text)
    lg.print(
        btn.text,
        btn.x + (btn.w - textW) / 2,
        btn.y + (btn.h - textH) / 2
    )
end

---Draw text overlays with background
---@param bgHeight number
---@param headerText string
---@param subTexts table
function drawer.drawOverlay(bgHeight, headerText, subTexts)
    lg.setColor(colors.SLATE_800)
    local bgY = (lg.getHeight() - bgHeight) / 2
    lg.rectangle("fill", 0, bgY, lg.getWidth(), bgHeight)

    local headerFont = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    lg.setColor(colors.SLATE_100)
    drawer.drawCenteredText(headerText, headerFont, 0, subTexts[1].y - 18)

    local subFont = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    lg.setColor(colors.SLATE_300)
    for i, textInfo in ipairs(subTexts) do
        drawer.drawCenteredText(textInfo.text, subFont, 0, textInfo.y + 18 * i)
    end
end

---Draw an interactive text box for user input
---@param textbox table {x, y, w, h, text, hovered, focused, valid, maxLength}
---@param font love.Font Font to use for text rendering
function drawer.drawTextBox(textbox, font)
    -- Draw background
    lg.setColor(colors.SLATE_200)
    lg.rectangle("fill", textbox.x, textbox.y, textbox.w, textbox.h, 4, 4)

    -- Draw border (highlighted if hovered)
    if textbox.hovered or textbox.focused then
        -- Validation border
        local color = textbox.valid and colors.SLATE_400 or colors.RED
        lg.setColor(color)
        lg.setLineWidth(2)
        lg.rectangle("line", textbox.x, textbox.y, textbox.w, textbox.h, 4, 4)
    end

    -- Draw text
    if textbox.hovered or textbox.focused then
        lg.setColor(colors.WHITE)
    else
        lg.setColor(colors.SLATE_400) -- Dimmed for placeholder
    end
    lg.setFont(font)
    local textW = font:getWidth(textbox.text)
    local textH = font:getHeight()
    lg.print(
        textbox.text,
        textbox.x + textbox.w / 2 - textW / 2, -- Centered text
        textbox.y + textbox.h / 2 - textH / 2
    )

    -- Draw blinking cursor when active
    if textbox.focused then
        local cursorTime = love.timer.getTime() % 1
        if cursorTime < 0.5 then
            local cursorX = textbox.x + textbox.w / 2 - textW / 2 + textW + 2
            lg.setColor(colors.SLATE_800)
            lg.rectangle(
                "fill",
                cursorX,
                textbox.y + (textbox.h - textH) / 2 + 2,
                4,
                textH - 4
            )
        end
    end
end

return drawer
