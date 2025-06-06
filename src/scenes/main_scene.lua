local anim8           = require("lib.anim8")
local moonshine       = require("lib.moonshine")
local colors          = require("src.globals.colors")
local consts          = require("src.globals.consts")
local res             = require("src.globals.res")
local drawer          = require("src.utils.drawer")
local file            = require("src.utils.file")
local input           = require("src.utils.input")

local player          = require("src.models.player")
local enemy           = require("src.models.enemy")

-- === Constants ===
local ENEMY_THRESHOLD = 0.6

local mainScene       = {}

function mainScene:load(assets, actions, configs)
    self.assets                     = assets
    self.actions                    = actions
    self.configs                    = configs
    self.enemies                    = {}
    self.eTimer                     = 0
    self.isPaused                   = false
    self.isGameOver                 = false

    -- === Scoring ===
    self.score                      = 0
    self.highScores                 = file.loadScores()
    self.scoreSaved                 = false

    -- === Shaders ===
    self.cmsShader                  = moonshine(moonshine.effects.chromasep)
    self.cmsShader.chromasep.radius = 4

    -- === Animations ===
    local tileW                     = self.assets.tileset:getWidth()
    local tileH                     = self.assets.tileset:getHeight()
    self.anims                      = anim8.newGrid(16, 16, tileW, tileH)

    player:init(self.anims)
end

function mainScene:reload()
    for i = #self.enemies, 1, -1 do
        table.remove(self.enemies, i)
    end
    self.enemies = {}

    self.isGameOver = false
    self.scoreSaved = false
    self.actions.switchScene("main")
end

function mainScene:handleInputs()
    if input:wasPressed("back") then
        self.actions.switchScene("title")
    end

    if not self.isGameOver and input:wasPressed("accept") then
        self.isPaused = not self.isPaused
    end

    if self.isGameOver and
        (input:wasPressed("accept") or input:wasPressed("jump"))
    then
        self:reload()
        return
    end

    if input:wasPressed("jump") then
        player:jumpStart()
    elseif input:wasReleased("jump") then
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

    if self.isGameOver and not self.scoreSaved then
        table.insert(self.highScores, self.score)
        table.sort(self.highScores, function(a, b)
            return a > b
        end)

        while #self.highScores > 5 do
            table.remove(self.highScores)
        end
        file.saveScores(self.highScores)
        self.scoreSaved = true
    end

    if self.isPaused or self.isGameOver then return end

    -- Spawn enemies
    self.eTimer = self.eTimer + dt
    if self.eTimer > ENEMY_THRESHOLD then
        local m = tonumber(self.configs.mode) or 1
        local newObs = enemy.get(m, self.anims)
        table.insert(self.enemies, newObs)
        self.eTimer = 0
    end

    -- Update enemies
    for _, o in ipairs(self.enemies) do
        o:update(dt)
    end

    player:update(dt)
    local collided = player:checkCollision(self.enemies)
    if collided then
        local isOnTop = player:checkOnTop(collided)
        if not isOnTop then
            self.isGameOver = true
        else
            player.velY = player.lane == 2 and player.impulse or -player.impulse
            collided.dead = true
            self.score = self.score + 1
        end
    end
end

function mainScene:draw()
    self.cmsShader(function()
        love.graphics.clear(colors.SLATE_100)
        local w, h = love.graphics.getDimensions()

        -- === Draw lanes ===
        love.graphics.setColor(colors.SLATE_200)
        love.graphics.rectangle("fill", 0, 0, w, consts.GROUND_H)
        local groundBx = consts.WINDOW_H - consts.GROUND_H
        love.graphics.rectangle("fill", 0, groundBx, w, consts.GROUND_H)

        -- === Draw center line ===
        love.graphics.setColor(colors.SLATE_200)
        love.graphics.rectangle("line", 0, h / 2, w, 1)

        -- === Draw player ===
        player:draw(self.assets.tileset)

        -- === Draw enemies ===
        for _, e in ipairs(self.enemies) do
            e:draw(self.assets.tileset)
        end

        -- === Draw score ===
        local font = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
        local scoreText = string.format("%02d", self.score)
        local scoreW, scoreH = font:getWidth(scoreText) + 16, font:getHeight()

        -- Draw score background
        love.graphics.setColor(colors.SLATE_100)
        love.graphics.rectangle(
            "fill",
            w / 2 - scoreW / 2,
            h / 2 - scoreH / 2,
            scoreW, scoreH
        )

        -- Draw score text
        love.graphics.setColor(colors.SLATE_200)
        drawer.drawCenteredText(scoreText, font, 0, 0)

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
