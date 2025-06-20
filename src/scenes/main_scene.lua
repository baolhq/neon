local anim8 = require("lib.anim8")
local colors = require("src.globals.colors")
local consts = require("src.globals.consts")
local res = require("src.globals.res")
local drawer = require("src.utils.drawer")
local file = require("src.utils.file")
local input = require("src.utils.input")

local player = require("src.models.player")
local enemy = require("src.models.enemy")

local mainScene = {}

-- === Constants ===
local ENEMY_THRESHOLD = 0.6

function mainScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs
    self.enemies = {}
    self.eTimer = 0
    self.isPaused = false
    self.isGameOver = false

    -- === Scoring ===
    self.score = { name = configs.name, value = 0 }
    self.highScores = file.loadScores()
    self.scoreSaved = false

    -- === Animations ===
    local tileW = self.assets.tileset:getWidth()
    local tileH = self.assets.tileset:getHeight()
    self.anims = anim8.newGrid(16, 16, tileW, tileH)

    player:init(self.anims)
    self.assets.bgSound:play()
end

function mainScene:unload()
    for i = #self.enemies, 1, -1 do
        table.remove(self.enemies, i)
    end
    self.enemies = {}

    self.isGameOver = false
    self.scoreSaved = false
    self.assets.bgSound:stop()
end

function mainScene:handleInputs()
    if input:wasPressed("back") then
        self.assets.bgSound:stop()
        self.actions.switchScene("title")
    end

    if not self.isGameOver and input:wasPressed("accept") then
        self.isPaused = not self.isPaused
    end

    if self.isGameOver and (input:wasPressed("accept") or input:wasPressed("jump")) then
        self:unload()
        self.actions.switchScene("main")
    end

    if input:wasPressed("jump") then
        player:jumpStart()
    elseif input:wasReleased("jump") then
        player:jumpEnd()
    end
end

function mainScene:mousepressed(x, y, btn)
    if btn == 1 then
        if self.isGameOver then
            self:unload()
            self.actions.switchScene("main")
        else
            player:jumpStart()
        end
    end
end

function mainScene:mousereleased(x, y, btn)
    if btn == 1 then
        player:jumpEnd()
    end
end

function mainScene:update(dt)
    self:handleInputs()

    if self.isGameOver and not self.scoreSaved then
        table.insert(self.highScores, self.score)
        table.sort(self.highScores, function(a, b)
            return a.value > b.value
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
        local e = enemy.get(m, self.anims)
        table.insert(self.enemies, e)
        self.eTimer = 0
    end

    -- Update enemies
    for _, e in ipairs(self.enemies) do
        e:update(dt)
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
            self.score.value = self.score.value + 1
        end
    end
end

function mainScene:draw()
    lg.clear(colors.SLATE_100)
    local w, h = lg.getDimensions()

    -- === Draw lanes ===
    lg.setColor(colors.SLATE_200)
    lg.rectangle("fill", 0, 0, w, consts.GROUND_H)
    local groundBx = lg.getHeight() - consts.GROUND_H
    lg.rectangle("fill", 0, groundBx, w, consts.GROUND_H)

    -- === Draw center line ===
    lg.setColor(colors.SLATE_200)
    lg.rectangle("line", 0, h / 2, w, 1)

    -- === Draw player ===
    player:draw(self.assets.tileset)

    -- === Draw enemies ===
    for _, e in ipairs(self.enemies) do
        e:draw(self.assets.tileset)
    end

    -- === Draw score ===
    local font = file:getFont(res.MONO_FONT, consts.FONT_HEADER_SIZE)
    local scoreText = string.format("%02d", self.score.value)
    local scoreW, scoreH = font:getWidth(scoreText) + 16, font:getHeight()

    -- Draw score background
    lg.setColor(colors.SLATE_100)
    lg.rectangle(
        "fill",
        w / 2 - scoreW / 2,
        h / 2 - scoreH / 2,
        scoreW, scoreH
    )

    -- Draw score text
    lg.setColor(colors.SLATE_200)
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
            { text = "CONTINUE?", y = 0 },
        })
    end
end

return mainScene
