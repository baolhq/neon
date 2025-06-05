local anim8    = require("lib.anim8")
local vector   = require("lib.vector")
local colors   = require("src.globals.colors")
local consts   = require("src.globals.consts")
local collider = require("src.utils.collider")

local player   = {}

function player:init(tileset)
    self.w, self.h = 48, 48
    self.speed     = 200
    self.lane      = 1 -- 1=left, 2=right
    self.maxJumps  = 2
    self.jumpsLeft = self.maxJumps
    self.jumpDir   = 0 -- 0=normal, -1=jump left, 1=jump right
    self.pos       = vector(
        consts.LANE_WIDTH,
        consts.WINDOW_HEIGHT * 0.75
    )

    -- Animation
    local grid     = anim8.newGrid(16, 16, tileset:getWidth(), tileset:getHeight())
    self.animation = anim8.newAnimation(grid("1-4", 1), 0.1)
end

-- === Behavior ===
function player:update(dt)
    self.pos.x = self.pos.x + self.speed * dt * self.jumpDir

    local leftW = consts.LANE_WIDTH
    local rightW = consts.WINDOW_WIDTH - consts.LANE_WIDTH
    if self.pos.x <= leftW or
        self.pos.x + self.w >= rightW
    then
        self.jumpDir = 0
        self.jumpsLeft = self.maxJumps
        self.animation:update(dt)
    end
end

function player:jumpStart()
    if self.jumpsLeft <= 0 then return end
    self.jumpsLeft = self.jumpsLeft - 1

    if self.lane == 1 then
        if self.pos.x + self.w < consts.WINDOW_WIDTH - consts.LANE_WIDTH then
            self.jumpDir = 1
        end

        if self.pos.x > love.graphics.getWidth() / 2 then
            self.jumpDir = -1
            self.lane = 2
        end
    else
        if self.pos.x + self.w > consts.LANE_WIDTH then
            self.jumpDir = -1
        end

        if self.pos.x < love.graphics.getWidth() / 2 then
            self.jumpDir = -1
            self.lane = 1
        end
    end
end

function player:jumpEnd()
    local leftW = consts.LANE_WIDTH
    local rightW = consts.WINDOW_WIDTH - consts.LANE_WIDTH

    -- Only change jumpDir if not touching wall
    if self.pos.x <= leftW or self.pos.x + self.w >= rightW then
        self.jumpDir = 0
        return
    end

    -- Snap to closest wall
    if self.pos.x + self.w / 2 < love.graphics.getWidth() / 2 then
        self.jumpDir = -1
        self.lane = 1
    else
        self.jumpDir = 1
        self.lane = 2
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
    local rotation, facingDir
    if self.pos.x + oX > love.graphics.getWidth() / 2 then
        rotation = -math.pi / 2
        facingDir = 1
    else
        rotation = math.pi / 2
        facingDir = -1
    end

    self.animation:draw(
        tileset,
        self.pos.x + oX,
        self.pos.y + oY,
        rotation,
        3 * facingDir, 3,
        8, 8
    )
end

return player
