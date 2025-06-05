local vector = require("lib.vector")
local colors = require("src.globals.colors")
local consts = require("src.globals.consts")

local obstacle = {}

-- === Constants ===
local POOL_SIZE = 20
local SCALE = 2
local FRAME_W, FRAME_H = 16, 16

-- === Pooling ===
local pool = {}

-- === Pseudo Random ===
local ptCasual = {
    "lllrlrrrllrlrlllrrlr",
    "rlrlrrrlrlllrrllrlrr",
    "llrrllrlrrlllrrrlrlr",
    "rrllrrrllrlrlrrlllrl",
    "lrlrrllrlrrlllrlrrlr",
    "rllrllrrrlrlrllrlrrl",
    "llrlrlrrllrrrllrlrlr",
    "rrlrrllrllrlrrllrlrl",
    "lrrllrrrlllrllrrrlrl",
    "rllrrllrlrrllrlrllrr",
}
local ptHard = {
    "llllrrllrrrllllrrllr",
    "rrrrllrrrllllrrllrlr",
    "lllrrrllllrrrlllrrrl",
    "rrrrrlllrllrrlllrrrl",
    "lllrrllllrrrlrrrllrl",
    "rrrrlllrrrlrrllllrrl",
    "llrrrllllrrlllrrrllr",
    "rrrlllrrrrllrrlllrrl",
    "llllrrrlllrrrllllrrl",
    "rrrllllrrrllllrrrllr",
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

local function spawn(side, mode, anim)
    local o = {
        w = FRAME_W * SCALE,
        h = FRAME_H * SCALE,
        anim = anim
    }

    if mode == 1 then
        o.speed = 200
    elseif mode == 2 then
        o.speed = 300
    else
        o.speed = 400
    end

    local lX = consts.LANE_WIDTH
    local rX = consts.WINDOW_WIDTH - consts.LANE_WIDTH - o.w
    if side == "l" then
        o.pos = vector(lX, -100)
    else
        o.pos = vector(rX, -100)
    end

    setmetatable(o, { __index = obstacle })
    return o
end

local function createPool(mode, anim)
    local presets = {}
    if mode == 1 then
        presets = ptCasual
    elseif mode == 2 then
        presets = ptHard
    end

    local rand = love.math.random(1, #presets)
    local pattern = {}
    for i = 1, #presets[rand] do
        pattern[i] = presets[rand]:sub(i, i)
    end

    for i = 1, POOL_SIZE do
        table.insert(pool, spawn(pattern[i], mode, anim))
    end

    validatePattern(pattern)
end

function obstacle.get(mode, anim)
    if #pool == 0 then createPool(mode, anim) end
    return table.remove(pool)
end

function obstacle:update(dt)
    self.pos.y = self.pos.y + self.speed * dt
    self.anim:update(dt)
end

function obstacle:draw(tileset)
    love.graphics.setColor(colors.SLATE_800)

    local oX, oY = self.w / 2, self.h / 2
    local rotation, facingDir
    if self.pos.x + oX > love.graphics.getWidth() / 2 then
        rotation = -math.pi / 2
        facingDir = 1
    else
        rotation = math.pi / 2
        facingDir = -1
    end
    self.anim:draw(
        tileset,
        -- Offset to fix visual
        self.pos.x + oX - 9 * facingDir,
        self.pos.y + oY,
        rotation,
        -- Scale up to match its collision box
        SCALE * facingDir * 1.5, SCALE * 1.5,
        FRAME_W / 2, FRAME_H / 2
    )
end

return obstacle
