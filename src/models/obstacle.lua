local vector = require("lib.vector")
local colors = require("src.globals.colors")
local consts = require("src.globals.consts")

local obstacle = {}

-- === Constants ===
local POOL_SIZE = 20

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

local function spawn(side, mode)
    local o = { w = 32, h = 16, }

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

local function createPool(mode)
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
        table.insert(pool, spawn(pattern[i], mode))
    end

    validatePattern(pattern)
end

function obstacle.get(mode)
    if #pool == 0 then createPool(mode) end
    return table.remove(pool)
end

function obstacle:update(dt)
    self.pos.y = self.pos.y + self.speed * dt
end

function obstacle:draw()
    love.graphics.setColor(colors.SLATE_400)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
end

return obstacle
