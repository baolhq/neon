local tween         = require("lib.tween")
local colors        = require("src.globals.colors")
local res           = require("src.globals.res")

local sceneManager  = {}
local canvas        = {}
local shader        = {}
local scanlinePhase = 0

-- === Game scenes ===
local scenes        = {
    title = require("src.scenes.title_scene"),
    main = require("src.scenes.main_scene"),
    lboard = require("src.scenes.lboard_scene"),
    settings = require("src.scenes.settings_scene"),
}

function sceneManager:load(assets, configs)
    self.assets = assets
    self.configs = configs
    self.current = "title"
    self.next = nil
    self.transitioning = false
    self.coverX = nil -- For black rectangle
    self.stage = nil  -- 'in' -> switch -> 'out'
    self.tween = nil
    self.actions = {
        switchScene = function(newScene)
            self:switch(newScene)
        end,
        quit = function() love.event.quit() end
    }

    canvas = lg.newCanvas()
    shader = lg.newShader(res.SD_SCANLINE)
    shader:send("width", 3)
    shader:send("opacity", 0.4)
    ---@diagnostic disable-next-line: missing-fields
    shader:send("color", { 0.2, 0.2, 0.2 })

    -- Don't use transition on initial load
    scenes[self.current]:load(self.assets, self.actions, self.configs)
end

function sceneManager:switch(name)
    if self.transitioning then return end

    self.transitioning = true
    self.next = name
    self.coverX = lg.getWidth()
    self.stage = "in"

    self.tween = tween.new(0.4, self, { coverX = 0 }, "outQuad")
end

function sceneManager:keypressed(key)
    if scenes[self.current].keypressed then
        scenes[self.current]:keypressed(key)
    end
end

function sceneManager:textinput(t)
    if scenes[self.current].textinput then
        scenes[self.current]:textinput(t)
    end
end

function sceneManager:mousemoved(x, y)
    if scenes[self.current].mousemoved then
        scenes[self.current]:mousemoved(x, y)
    end
end

function sceneManager:mousepressed(x, y, btn)
    if scenes[self.current].mousepressed then
        scenes[self.current]:mousepressed(x, y, btn)
    end
end

function sceneManager:mousereleased(x, y, btn)
    if scenes[self.current].mousereleased then
        scenes[self.current]:mousereleased(x, y, btn)
    end
end

function sceneManager:update(dt)
    scanlinePhase = scanlinePhase + dt * 10
    shader:send("phase", scanlinePhase)

    if self.transitioning and self.tween then
        local complete = self.tween:update(dt)
        if complete then
            if self.stage == "in" then
                -- Now switch scenes under the black cover
                self.current = self.next
                scenes[self.current]:load(self.assets, self.actions, self.configs)

                -- Start swipe out
                self.stage = "out"
                self.coverX = 0
                self.tween = tween.new(0.4, self, { coverX = -lg.getWidth() }, "inQuad")
            else
                -- Finished transition
                self.transitioning = false
                self.tween = nil
                self.stage = nil
                self.next = nil
                self.coverX = nil
            end
        end
    end

    if scenes[self.current].update then
        scenes[self.current]:update(dt)
    end
end

function sceneManager:draw()
    lg.setCanvas(canvas)
    if scenes[self.current].draw then
        scenes[self.current]:draw()
    end

    -- Draw the curtain if in transition
    if self.transitioning and self.coverX then
        lg.setColor(colors.SLATE_100)
        lg.rectangle("fill", self.coverX, 0, lg.getWidth(), lg.getHeight())
    end
    lg.setCanvas()

    lg.setShader(shader)
    lg.draw(canvas)
    lg.setShader()
end

return sceneManager
