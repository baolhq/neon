local colors        = require("src.globals.colors")
local consts        = require("src.globals.consts")
local drawer        = require("src.utils.drawer")
local input         = require("src.utils.input")

local player        = require("src.models.player")
local obstacle      = require("src.models.obstacle")

-- === Constants ===
local OBS_THRESHOLD = 2

local mainScene     = {}

function mainScene:load(assets, actions, configs)
    self.assets     = assets
    self.actions    = actions
    self.configs    = configs
    self.obstacles  = {}
    self.obsTimer   = 0
    self.isPaused   = false
    self.isGameOver = false

    player:init()
end

function mainScene:unload()
    for i = #self.obstacles, 1, -1 do
        table.remove(self.obstacles, i)
    end
    self.obstacles = {}
end

function mainScene:mousepressed(x, y, btn)
    if btn == 1 then
        player:jump()
    end
end

function mainScene:handleInputs()
    if input:wasPressed("back") then
        self.actions.switchScene("title")
    end

    if input:wasPressed("space") then
        self.isPaused = not self.isPaused
    end

    if input:wasPressed("accept") and self.isGameOver then
        self.isGameOver = false
        self:unload()
    end

    if input:wasPressed("left") and player.lane == 2 then
        player:jump()
    elseif input:wasPressed("right") and player.lane == 1 then
        player:jump()
    end
end

function mainScene:update(dt)
    self:handleInputs()
    if self.isPaused or self.isGameOver then return end

    -- Spawn obstacles
    self.obsTimer = self.obsTimer + dt
    if self.obsTimer > OBS_THRESHOLD then
        local newObs = obstacle.get()
        table.insert(self.obstacles, newObs)
        self.obsTimer = 0
    end

    -- Update obstacles
    for _, o in ipairs(self.obstacles) do
        o:update(dt)
    end

    player:update(dt)
    local wasHit = player:checkCollision(self.obstacles)
    if wasHit then self.isGameOver = true end
end

function mainScene:draw()
    love.graphics.clear(colors.SLATE_100)

    -- Draw lanes
    love.graphics.setColor(colors.SLATE_200)
    love.graphics.rectangle("fill", 0, 0, consts.LANE_WIDTH, consts.WINDOW_HEIGHT)
    local laneRightX = consts.WINDOW_WIDTH - consts.LANE_WIDTH
    love.graphics.rectangle("fill", laneRightX, 0, consts.LANE_WIDTH, consts.WINDOW_HEIGHT)

    player:draw()

    -- Draw obstacles
    for _, o in ipairs(self.obstacles) do
        o:draw()
    end

    -- Draw pause screen
    if self.isPaused then
        drawer.drawOverlay(140, "PAUSED", {
            { text = "PRESS START", y = 0 },
        })
    end

    -- Draw game over screen
    if self.isGameOver then
        drawer.drawOverlay(140, "GAME OVER", {
            { text = "PRESS START", y = 0 },
        })
    end
end

return mainScene
