local res = require("src.globals.res")

local file = { fontCache = {} }

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

return file
