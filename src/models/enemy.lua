local anim8     = require("lib.anim8")
local vector    = require("lib.vector")
local colors    = require("src.globals.colors")
local consts    = require("src.globals.consts")

local enemy     = {}

-- === Constants ===
local POOL_SIZE = 20
local SCALE     = 2
local FRAME_W   = 16
local FRAME_H   = 16

-- === Pooling ===
local pool      = {}

-- === Pseudo Random ===
local ptCasual  = {
    "bbbtbtttbbtbtbbbttbt",
    "tbtbtttbtbbbttbbtbtt",
    "bbttbbtbttbbbtttbtbt",
    "ttbbtttbbtbtbttbbbtb",
    "btbttbbtbttbbbtbttbt",
    "tbbtbbtttbtbtbbtbttb",
    "bbtbtbttbbtttbbtbtbt",
    "ttbttbbtbbtbttbbtbtb",
    "bttbbtttbbbtbbtttbtb",
    "tbbttbbtbttbbtbtbbtt",
}
local ptHard    = {
    "bbbbttbbtttbbbbttbbt",
    "ttttbbtttbbbbttbbtbt",
    "bbbtttbbbbtttbbbtttb",
    "tttttbbbtbbttbbbtttb",
    "bbbttbbbbtttbtttbbtb",
    "ttttbbbtttbttbbbbttb",
    "bbtttbbbbttbbbtttbbt",
    "tttbbbttttbbttbbbttb",
    "bbbbtttbbbtttbbbbttb",
    "tttbbbbtttbbbbtttbbt",
}

---Validate pattern length and randomness
---@param p table
local function validatePattern(p)
    assert(#p == POOL_SIZE, "Pattern length must be the same as POOL_SIZE")

    local count = 1
    for i = 2, #p do
        if p[i] == p[i + 1] then
            count = count + 1
            if count > 5 then
                error("Too many of the same side in a row: " .. p)
            end
        else
            count = 1
        end
    end
end

local function spawn(side, mode, anims)
    local e = {
        w = FRAME_W * SCALE,
        h = FRAME_H * SCALE,
        dead = false,
        baseAnim = anim8.newAnimation(anims("1-3", 2), 0.2),
        deathAnim = anim8.newAnimation(anims("4-4", 2), 1),
    }

    if mode == 1 then
        e.speed = 200
    elseif mode == 2 then
        e.speed = 300
    else
        e.speed = 400
    end

    local topY = consts.GROUND_H
    local botY = consts.WINDOW_H - consts.GROUND_H - e.h
    e.pos = vector(love.graphics.getWidth() + 100, 0)
    e.pos.y = side == "t" and topY or botY

    setmetatable(e, { __index = enemy })
    return e
end

local function createPool(mode, anims)
    local presets = {}
    if mode == 1 then
        presets = ptCasual
    else
        -- Use the same preset, only changes speed
        presets = ptHard
    end

    local rand = love.math.random(1, #presets)
    local pattern = {}
    for i = 1, #presets[rand] do
        pattern[i] = presets[rand]:sub(i, i)
    end

    for i = 1, POOL_SIZE do
        table.insert(pool, spawn(pattern[i], mode, anims))
    end

    validatePattern(pattern)
end

function enemy.get(mode, anims)
    if #pool == 0 then createPool(mode, anims) end
    return table.remove(pool)
end

function enemy:update(dt)
    self.pos.x = self.pos.x - self.speed * dt
    self.baseAnim:update(dt)
end

function enemy:draw(tileset)
    love.graphics.setColor(colors.SLATE_800)

    local oX, oY = self.w / 2, self.h / 2
    local facingDir
    if self.pos.y + oY > consts.WINDOW_H / 2 then
        facingDir = 1
    else
        facingDir = -1
    end

    if self.dead then
        self.deathAnim:draw(
            tileset,
            self.pos.x + oX,
            -- Offset to fix visual
            self.pos.y + oY - 1 * facingDir,
            0,
            -- Scale up to match its collision box
            SCALE * 1.5, SCALE * facingDir * 1.5,
            FRAME_W / 2, FRAME_H / 2
        )
    else
        self.baseAnim:draw(
            tileset,
            self.pos.x + oX,
            -- Offset to fix visual
            self.pos.y + oY - 1 * facingDir,
            0,
            -- Scale up to match its collision box
            SCALE * 1.5, SCALE * facingDir * 1.5,
            FRAME_W / 2, FRAME_H / 2
        )
    end
end

return enemy
