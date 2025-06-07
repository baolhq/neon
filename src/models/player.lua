local anim8 = require("lib.anim8")
local vector = require("lib.vector")
local colors = require("src.globals.colors")
local consts = require("src.globals.consts")
local collider = require("src.utils.collider")

-- === Constants ===
local GRAVITY = 1200
local STR_GRAVITY = 3600 -- Stronger gravity if not holding jump

local player = {}

function player:init(anims)
    self.anim = anim8.newAnimation(anims("1-4", 1), 0.1)
    self.w, self.h = 48, 48
    self.lane = 2 -- 1=top, 2=bottom
    self.maxJumps = 2
    self.jumpsLeft = self.maxJumps
    self.holdingJump = false
    self.velY = 0       -- Current Y-axis velocity
    self.prevY = 0      -- Store preivous Y-axis location
    self.impulse = -650 -- How high the jump
    self.pos = vector(
        consts.WINDOW_W * 0.2,
        consts.WINDOW_H - consts.GROUND_H - self.w
    )
end

-- === Behavior ===
function player:update(dt)
    self.prevY = self.pos.y

    -- Apply gravity
    local gravity = self.holdingJump and GRAVITY or STR_GRAVITY
    local gravityDir = self.lane == 1 and -1 or 1
    self.velY = self.velY + gravity * gravityDir * dt
    self.pos.y = self.pos.y + self.velY * dt

    -- If player crosses the middle of the screen, flip the lane
    local midY = consts.WINDOW_H / 2
    local curY = self.pos.y + self.h / 2
    if (self.prevY + self.h / 2 < midY and curY >= midY) or
        (self.prevY + self.h / 2 > midY and curY <= midY)
    then
        self.lane = 3 - self.lane
    end

    local topY = consts.GROUND_H
    local botY = consts.WINDOW_H - consts.GROUND_H
    local landed = false

    -- Snap to the ground when landed
    if self.pos.y <= topY then
        self.pos.y = topY
        self.velY = 0
        landed = true
    elseif self.pos.y + self.h >= botY then
        self.pos.y = botY - self.h
        self.velY = 0
        landed = true
    end

    -- Reset jump and stop movement if landed
    if landed then
        self.jumpsLeft = self.maxJumps
        self.anim:update(dt)
    end
end

-- Begin the jump, if keep calling, the player will
-- gradually falls off
function player:jumpStart()
    if self.jumpsLeft <= 0 then return end

    self.holdingJump = true
    self.jumpsLeft = self.jumpsLeft - 1
    self.velY = self.lane == 1 and -self.impulse or self.impulse
end

-- Release the jump, gravity pull stronger
function player:jumpEnd()
    self.holdingJump = false
end

-- Check if the player is landing on top of an enemy's head
function player:checkOnTop(enemy)
    -- Player bottom or top depending on gravity
    local gravityDir = self.lane == 1 and -1 or 1
    local pEdge = self.lane == 1 and self.pos.y or (self.pos.y + self.h)
    local pPrevEdge = self.lane == 1 and self.prevY or (self.prevY + self.h)
    local eEdge = self.lane == 1 and (enemy.pos.y + enemy.h) or enemy.pos.y

    -- Check horizontal overlap
    local pLeft = self.pos.x
    local pRight = self.pos.x + self.w
    local eLeft = enemy.pos.x
    local eRight = enemy.pos.x + enemy.w
    local hOverlap = pRight > eLeft and pLeft < eRight

    -- Check if player moved past enemy edge in direction of gravity
    local vOverlap = gravityDir > 0
        and pPrevEdge <= eEdge and pEdge >= eEdge
        or pPrevEdge >= eEdge and pEdge <= eEdge

    return hOverlap and vOverlap
end

function player:checkCollision(enemies)
    local target = nil
    for _, e in ipairs(enemies) do
        if not e.dead and collider.aabb(self, e) then
            target = e
            break
        end
    end
    return target
end

function player:draw(tileset)
    lg.setColor(colors.SLATE_800)

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
