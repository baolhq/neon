local vector = require("lib.vector")
local colors = require("src.globals.colors")
local consts = require("src.globals.consts")

local obstacle = {}

-- === Constants ===
local POOL_SIZE = 20

-- === Pooling ===
local pool = {}

local function spawn()
    local o = {
        speed = 300,
        w = 32,
        h = 16,
    }

    -- Spawn on random side
    local lX = consts.LANE_WIDTH
    local rX = consts.WINDOW_WIDTH - consts.LANE_WIDTH - o.w
    if love.math.random(2) == 1 then
        o.pos = vector(lX, -100)
    else
        o.pos = vector(rX, -100)
    end

    setmetatable(o, { __index = obstacle })
    return o
end

local function createPool()
    for i = 1, POOL_SIZE do
        local o = spawn()
        table.insert(pool, o)
    end
end

function obstacle.get()
    if #pool == 0 then createPool() end
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
