local tween         = require("lib.tween")
local vector        = require("lib.vector")
local colors        = require("src.globals.colors")
local consts        = require("src.globals.consts")
local collider      = require("src.utils.collider")

local player        = {}

-- === Constants ===
local FLIP_DURATION = 0.5

function player:init()
    self.w, self.h  = 32, 16
    self.speed      = 400
    self.lane       = 1 -- 1=left, 2=right
    self.isFlipping = false
    self.flipTimer  = FLIP_DURATION
    self.pos        = vector(
        consts.LANE_WIDTH - self.w / 2,
        consts.WINDOW_HEIGHT * 0.75
    )
end

-- === Behavior ===
function player:update(dt)
    if self.isFlipping then
        self.flipTimer = self.flipTimer - dt

        -- Flip animation
        if self.posTween then
            self.posTween:update(dt)
        end

        -- Animation timed out
        if self.flipTimer <= 0 then
            self.isFlipping = false
            self.flipTimer = 1
            self.lane = self.lane == 1 and 2 or 1
        end
    end
end

function player:jump()
    if not self.isFlipping then
        self.isFlipping = true
        self.flipTimer = FLIP_DURATION

        local newX
        if self.lane == 1 then
            newX = consts.WINDOW_WIDTH - consts.LANE_WIDTH - self.w * 1.5
        else
            newX = consts.LANE_WIDTH - self.w / 2
        end

        self.posTween = tween.new(FLIP_DURATION, self.pos, { x = newX }, "outQuart")
    end
end

function player:checkCollision(obstacles)
    local hit = false
    for _, o in ipairs(obstacles) do
        if collider.aabb(self, o) then
            hit = true
            break
        end
    end
    return hit
end

function player:draw()
    love.graphics.setColor(colors.SLATE_800)

    local origin = self.pos + vector(self.w / 2, self.h / 2)
    love.graphics.rectangle("fill", origin.x, origin.y, self.w, self.h)
end

return player
