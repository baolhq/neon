local res  = require("src.globals.res")

local file = { fontCache = {} }

-- Load font from provided path with fixed size <br/>
-- Also cache them and change to the new font
function file:getFont(path, size)
    self.fontCache[path] = self.fontCache[path] or {}

    self.fontCache[path][size] =
        self.fontCache[path][size] or
        love.graphics.newFont(path, size)

    local newFont = self.fontCache[path][size]
    love.graphics.setFont(newFont)

    return newFont
end

-- Save game configurations
function file.saveConfigs(configs)
    local lines = {}
    for k, v in pairs(configs) do
        table.insert(lines, k .. "=" .. tostring(v))
    end

    local content = table.concat(lines, "\n")
    love.filesystem.write(res.CONFIG_PATH, content)
end

-- Load game configurations
function file.loadConfigs()
    local configs = {}

    if love.filesystem.getInfo(res.CONFIG_PATH) then
        for line in love.filesystem.lines(res.CONFIG_PATH) do
            -- Split each config by the `=` sign
            local k, v = line:match("([^=]+)=([^=]+)")
            configs[k] = v
        end
    end

    return configs
end

-- Save only the five highest scores
function file.saveScores(scores)
    -- Sort and keep top 5
    table.sort(scores, function(a, b)
        return a.value > b.value
    end)

    -- Build the list to save
    local lines = {}
    for i = 1, math.min(5, #scores) do
        table.insert(lines, scores[i].name .. "=" .. tostring(scores[i].value))
    end

    local content = table.concat(lines, "\n")
    love.filesystem.write(res.SAVE_PATH, content)
end

-- Load previous highscores
function file.loadScores()
    local result = {}

    if love.filesystem.getInfo(res.SAVE_PATH) then
        for line in love.filesystem.lines(res.SAVE_PATH) do
            local name, score = line:match("([^=]+)=%s*(%d+)")
            if name and score then
                table.insert(result, { name = name, value = tonumber(score) })
            end
        end
    end

    return result
end

return file
