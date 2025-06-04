local sceneManager = {
    assets  = {},
    configs = {},
    current = "title",
}

local scenes = {
    title = require("src.scenes.title_scene"),
    main = require("src.scenes.main_scene"),
    lboard = require("src.scenes.lboard_scene"),
    settings = require("src.scenes.settings_scene"),
}

function sceneManager:load(assets, configs)
    self.assets = assets
    self.configs = configs

    self:switch(self.current, assets, configs)
end

function sceneManager:switch(name, assets, configs)
    if scenes[name].load then
        local actions = {
            switchScene = function(newScene)
                self:switch(newScene, assets, configs)
            end,
            quit = function()
                love.event.quit()
            end
        }
        self.current = name
        scenes[name]:load(assets, actions, configs)
    end
end

function sceneManager:mousemoved(x, y, dx, dy, isTouch)
    if scenes[self.current].mousemoved then
        scenes[self.current]:mousemoved(x, y, dx, dy, isTouch)
    end
end

function sceneManager:mousepressed(x, y, btn)
    if scenes[self.current].mousepressed then
        scenes[self.current]:mousepressed(x, y, btn)
    end
end

function sceneManager:update(dt)
    if scenes[self.current].update then
        scenes[self.current]:update(dt)
    end
end

function sceneManager:draw()
    if scenes[self.current].draw then
        scenes[self.current]:draw()
    end
end

return sceneManager
