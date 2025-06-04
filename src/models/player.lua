local anim8         = require("lib.anim8")
local tween         = require("lib.tween")
local vector        = require("lib.vector")
local colors        = require("src.globals.colors")
local consts        = require("src.globals.consts")
local collider      = require("src.utils.collider")

local player        = {}

-- === Constants ===
local FLIP_DURATION = 0.5

function player:init(tileset)
    self.w, self.h  = 48, 48
    self.speed      = 400
    self.lane       = 1 -- 1=left, 2=right
    self.isFlipping = false
    self.flipTimer  = FLIP_DURATION
    self.pos        = vector(
        consts.LANE_WIDTH,
        consts.WINDOW_HEIGHT * 0.75
    )

    -- Animation
    local grid      = anim8.newGrid(16, 16, tileset:getWidth(), tileset:getHeight())
    self.animation  = anim8.newAnimation(grid("1-4", 1), 0.1)
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
    else
        self.animation:update(dt)
    end
end

function player:jump()
    if not self.isFlipping then
        self.isFlipping = true
        self.flipTimer = FLIP_DURATION

        local newX
        if self.lane == 1 then
            newX = consts.WINDOW_WIDTH - consts.LANE_WIDTH - self.w
        else
            newX = consts.LANE_WIDTH
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

function player:draw(tileset)
    love.graphics.setColor(colors.SLATE_800)

    local oX, oY = self.w / 2, self.h / 2
    local rotation = self.lane == 1 and math.pi / 2 or -math.pi / 2
    self.animation:draw(tileset, self.pos.x + oX, self.pos.y + oY, rotation, 3, 3, 8, 8)
end

return player
