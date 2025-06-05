local anim8         = require("lib.anim8")
local moonshine     = require("lib.moonshine")
local colors        = require("src.globals.colors")
local consts        = require("src.globals.consts")
local res           = require("src.globals.res")
local drawer        = require("src.utils.drawer")
local file          = require("src.utils.file")
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

    -- === Shaders ===
    self.cmsShader                  = moonshine(moonshine.effects.chromasep)
    self.cmsShader.chromasep.radius = 4

    -- === Animations ===
    local tileW                     = self.assets.tileset:getWidth()
    local tileH                     = self.assets.tileset:getHeight()
    local grid                      = anim8.newGrid(16, 16, tileW, tileH)
    local playerAnim                = anim8.newAnimation(grid("1-4", 1), 0.1)
    self.enemyAnim                  = anim8.newAnimation(grid("1-3", 2), 0.2)
    player:init(playerAnim)
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

    if input:wasPressed("right") and player.lane == 1 or
        input:wasPressed("left") and player.lane == 2
    then
        player:jumpStart()
    end

    if input:wasReleased("right") or input:wasReleased("left") then
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
        local newObs = obstacle.get(m, self.enemyAnim)
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

        -- === Draw lanes ===
        love.graphics.setColor(colors.SLATE_200)
        love.graphics.rectangle("fill", 0, 0, consts.LANE_WIDTH, consts.WINDOW_HEIGHT)
        local laneRightX = consts.WINDOW_WIDTH - consts.LANE_WIDTH
        love.graphics.rectangle("fill", laneRightX, 0, consts.LANE_WIDTH, consts.WINDOW_HEIGHT)

        -- === Draw center line ===
        local centerX = love.graphics.getWidth() / 2
        love.graphics.setColor(colors.SLATE_200)
        love.graphics.rectangle("line", centerX, 0, 1, consts.WINDOW_HEIGHT)

        -- === Draw player ===
        player:draw(self.assets.tileset)

        -- === Draw obstacles ===
        for _, o in ipairs(self.obstacles) do
            o:draw(self.assets.tileset)
        end

        -- === Draw score ===
        local font = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
        local scoreY = -280
        local scoreW, scoreH = 150, 80
        local centerY = love.graphics.getHeight() / 2

        -- Draw score background
        love.graphics.setColor(colors.SLATE_100)
        love.graphics.rectangle(
            "fill",
            centerX - scoreH,
            centerY + scoreY - scoreH / 2,
            scoreW, scoreH
        )

        -- Draw score text
        love.graphics.setColor(colors.SLATE_200)
        drawer.drawCenteredText("99", font, 0, scoreY)

        -- === Draw pause screen ===
        if self.isPaused then
            drawer.drawOverlay(140, "PAUSED", {
                { text = "PRESS START", y = 0 },
            })
        end

        -- === Draw game over screen ===
        if self.isGameOver then
            drawer.drawOverlay(140, "GAME OVER", {
                { text = "PRESS START", y = 0 },
            })
        end
    end)
end

return mainScene
