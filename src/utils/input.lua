local input = {
    -- Action to keys mappings
    bindings = {
        up     = { "up", "w" },
        down   = { "down", "s" },
        left   = { "left", "a" },
        right  = { "right", "d" },
        accept = { "return", "space" },
        back   = { "escape" },
        tab    = { "tab" },
    },
    keysDown = {},     -- Currently held
    keysPressed = {},  -- Pressed this frame
    keysReleased = {}, -- Released this frame
}

function input:keypressed(key)
    self.keysDown[key] = true
    self.keysPressed[key] = true
end

function input:keyreleased(key)
    self.keysDown[key] = false
    self.keysReleased[key] = true
end

-- Check if an input action is currently held down
function input:isDown(action)
    local keys = self.bindings[action]
    if not keys then return false end

    for _, k in ipairs(keys) do
        if self.keysDown[k] then
            return true
        end
    end
    return false
end

-- Check if an input action was just pressed this frame
function input:wasPressed(action)
    local keys = self.bindings[action]
    if not keys then return false end

    for _, k in ipairs(keys) do
        if self.keysPressed[k] then
            return true
        end
    end
    return false
end

-- Check if an input action was released this frame
function input:wasReleased(action)
    local keys = self.bindings[action]
    if not keys then return false end

    for _, k in ipairs(keys) do
        if self.keysReleased[k] then return true end
    end
    return false
end

function input:update()
    -- Reset at the end of each frame
    self.keysPressed = {}
    self.keysReleased = {}
end

return input
