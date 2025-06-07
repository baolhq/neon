local moonshine = require("lib.moonshine")
local sceneManager = require("src.managers.scene_manager")
local consts = require("src.globals.consts")
local res = require("src.globals.res")
local file = require("src.utils.file")
local input = require("src.utils.input")

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

-- === Abbreviations ===
lg = love.graphics
lf = love.filesystem
lm = love.mouse

local assets = {}       -- Shared assets
local configs = {}      -- Game configs
local scanlinesTime = 0 -- Scanlines delta time

function love.load()
    lg.setDefaultFilter("nearest", "nearest")
    -- Set game title and icon
    local gameIcon = love.image.newImageData(res.GAME_ICON)
    love.window.setIcon(gameIcon)
    love.window.setTitle(consts.GAME_TITLE)

    -- === Load sprites ===
    assets.tileset = lg.newImage(res.TILESET)

    -- === Load sounds ===
    assets.titleSound = love.audio.newSource(res.EDIT_SOUND, "stream")
    assets.titleSound:setLooping(true)
    assets.titleSound:setVolume(0.5)

    assets.bgSound = love.audio.newSource(res.MAIN_SOUND, "stream")
    assets.bgSound:setLooping(true)
    assets.bgSound:setVolume(0.5)

    assets.clickSound = love.audio.newSource(res.CLICK_SOUND, "static")
    assets.clickSound:setVolume(0.5)

    -- === Load shaders ===
    assets.glowShader = moonshine(moonshine.effects.glow)
    assets.sclShader = moonshine(moonshine.effects.scanlines)
    assets.sclShader.scanlines.thickness = 0.1

    -- Load configs and start game
    configs = file.loadConfigs()
    sceneManager:load(assets, configs)
end

function love.keypressed(key)
    sceneManager:keypressed(key)
    input:keypressed(key)
end

function love.keyreleased(key)
    input:keyreleased(key)
end

function love.textinput(t)
    sceneManager:textinput(t)
end

function love.mousemoved(x, y, dx, dy)
    -- Ignore small movements
    local min = 2
    if math.abs(dx) < min and math.abs(dy) < min then return end

    sceneManager:mousemoved(x, y)
end

function love.mousepressed(x, y, btn)
    sceneManager:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
    sceneManager:mousereleased(x, y, btn)
end

function love.update(dt)
    scanlinesTime = scanlinesTime + dt * 40
    assets.sclShader.scanlines.phase = scanlinesTime

    sceneManager:update(dt)
    input:update()
end

-- Draw game screen with scanlines
function love.draw()
    assets.sclShader(function()
        sceneManager:draw()
    end)
end
