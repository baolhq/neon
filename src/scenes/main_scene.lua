local moonshine     = require("lib.moonshine")
local colors        = require("src.globals.colors")
local consts        = require("src.globals.consts")
local drawer        = require("src.utils.drawer")
local input         = require("src.utils.input")

local player        = require("src.models.player")
local obstacle      = require("src.models.obstacle")

-- === Constants ===
local OBS_THRESHOLD = 0.5

local mainScene     = {}

function mainScene:load(assets, actions, configs)
    self.assets                     = assets
    self.actions                    = actions
    self.configs                    = configs
    self.obstacles                  = {}
    self.obsTimer                   = 0
    self.isPaused                   = false
    self.isGameOver                 = false

    self.cmsShader                  = moonshine(moonshine.effects.chromasep)
    self.cmsShader.chromasep.radius = 4

    player:init(self.assets.tileset)
end

function mainScene:reload()
    for i = #self.obstacles, 1, -1 do
        table.remove(self.obstacles, i)
    end
    self.obstacles = {}

    self.isGameOver = false
    self.actions.switchScene("main")
end

function mainScene:handleInputs()
    if input:wasPressed("back") then
        self.actions.switchScene("title")
    end

    if input:wasPressed("accept") and not self.isGameOver then
        self.isPaused = not self.isPaused
    end

    if input:wasPressed("accept") and self.isGameOver then
        self:reload()
    end

    if input:isDown("left") or input:isDown("right") then
        player:jumpStart()
    elseif input:keyreleased("left") or input:keyreleased("right") then
        player:jumpEnd()
    end
end

function mainScene:mousepressed(x, y, btn, isTouch, presses)
    if btn == 1 then
        if self.isGameOver then
            self:reload()
        else
            player:jumpStart()
        end
    end
end

function mainScene:mousereleased(x, y, btn, isTouch, presses)
    if btn == 1 then
        player:jumpEnd()
    end
end

function mainScene:update(dt)
    self:handleInputs()
    if self.isPaused or self.isGameOver then return end

    -- Spawn obstacles
    self.obsTimer = self.obsTimer + dt
    if self.obsTimer > OBS_THRESHOLD then
        local m = tonumber(self.configs.mode)
        local newObs = obstacle.get(m)
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
    self.cmsShader(function()
        love.graphics.clear(colors.SLATE_100)

        -- Draw lanes
        love.graphics.setColor(colors.SLATE_200)
        love.graphics.rectangle("fill", 0, 0, consts.LANE_WIDTH, consts.WINDOW_HEIGHT)
        local laneRightX = consts.WINDOW_WIDTH - consts.LANE_WIDTH
        love.graphics.rectangle("fill", laneRightX, 0, consts.LANE_WIDTH, consts.WINDOW_HEIGHT)

        -- Draw center line
        local cX = love.graphics.getWidth() / 2
        love.graphics.setColor(colors.SLATE_200)
        love.graphics.rectangle("line", cX, 0, 1, consts.WINDOW_HEIGHT)

        player:draw(self.assets.tileset)

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
    end)
end

return mainScene
