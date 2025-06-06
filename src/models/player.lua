local vector   = require("lib.vector")
local colors   = require("src.globals.colors")
local consts   = require("src.globals.consts")
local collider = require("src.utils.collider")

local player   = {}

function player:init(anim)
    self.anim      = anim
    self.w, self.h = 48, 48
    self.speed     = 400
    self.lane      = 2 -- 1=top, 2=bottom
    self.maxJumps  = 2
    self.jumpsLeft = self.maxJumps
    self.jumpDir   = 0 -- 0=none, -1=down, 1=up
    self.pos       = vector(
        consts.GROUND_H,
        consts.WINDOW_H - consts.GROUND_H - self.w
    )
end

-- === Behavior ===
function player:update(dt)
    -- Move player
    self.pos.y = self.pos.y + self.speed * dt * self.jumpDir

    local topH = consts.GROUND_H
    local botH = consts.WINDOW_H - consts.GROUND_H
    local landed = false

    if self.pos.y <= topH then
        -- Snap to top
        self.pos.y = topH
        self.lane = 1
        landed = true
    elseif self.pos.y + self.h >= botH then
        -- Snap to bottom
        self.pos.y = botH - self.h
        self.lane = 2
        landed = true
    end

    -- Reset jump and stop movement if landed
    if landed then
        self.jumpDir = 0
        self.jumpsLeft = self.maxJumps
        self.anim:update(dt)
    end
end

function player:jumpStart()
    if self.jumpsLeft <= 0 then return end
    self.jumpsLeft = self.jumpsLeft - 1

    if self.lane == 1 then
        self.jumpDir = 1
        self.lane = 2
    else
        self.jumpDir = -1
        self.lane = 1
    end
end

function player:jumpEnd()
    local topH = consts.GROUND_H
    local botH = consts.WINDOW_H - consts.GROUND_H

    local touchingWall = self.pos.y <= topH or self.pos.y + self.h >= botH
    if touchingWall then
        self.jumpDir = 0
        return
    end

    -- Snap to closest lane
    if self.pos.y + self.h / 2 < consts.WINDOW_H / 2 then
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
    local facingDir
    if self.pos.y + oY > consts.WINDOW_H / 2 then
        facingDir = 1
    else
        facingDir = -1
    end

    self.anim:draw(
        tileset,
        self.pos.x + oX,
        self.pos.y + oY + 8 * facingDir,
        0,
        3, 3 * facingDir,
        8, 8
    )
end

return player
