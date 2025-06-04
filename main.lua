local sceneManager      = require("src.managers.scene_manager")
local consts            = require("src.globals.consts")
local res               = require("src.globals.res")
local file              = require("src.utils.file")
local input             = require("src.utils.input")

--#region Debugger setup

local love_errorhandler = love.errorhandler
-- Enables code debugger via launch.json
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Tell Love to throw an error instead of showing it on screen
function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end

--#endregion

-- Shared assets and configs
local assets = {}
local configs = {}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Set game title and icon
    local gameIcon = love.image.newImageData(res.GAME_ICON)
    love.window.setIcon(gameIcon)
    love.window.setTitle(consts.GAME_TITLE)

    -- === Load sounds ===
    assets.titleSound = love.audio.newSource(res.EDIT_SOUND, "stream")
    assets.titleSound:setLooping(true)
    assets.titleSound:setVolume(0.5)

    assets.bgSound = love.audio.newSource(res.MAIN_SOUND, "stream")
    assets.bgSound:setLooping(true)
    assets.bgSound:setVolume(0.5)

    assets.clickSound = love.audio.newSource(res.CLICK_SOUND, "static")
    assets.clickSound:setVolume(0.5)

    -- Load configs and start game
    configs = file.loadConfigs()
    sceneManager:load(assets, configs)
end

function love.keypressed(key)
    input:keypressed(key)
end

function love.keyreleased(key)
    input:keyreleased(key)
end

function love.mousemoved(x, y, dx, dy, isTouch)
    -- Ignore small movements
    local min = 2
    if math.abs(dx) < min and math.abs(dy) < min then return end

    sceneManager:mousemoved(x, y, dx, dy, isTouch)
end

function love.mousepressed(x, y, btn)
    sceneManager:mousepressed(x, y, btn)
end

function love.update(dt)
    sceneManager:update(dt)
    input:update()
end

function love.draw()
    sceneManager:draw()
end
