
Blueprint.dump = function (o, level, prefix)
    level = level or 1
    prefix = prefix or '  '
    if type(o) == 'table' and level <= 5 then
        local s = '{ \n'
        for k, v in pairs(o) do
            local format
            if type(k) == 'number' then
                format = '%s[%d] = %s,\n'
            else
                format = '%s["%s"] = %s,\n'
            end
            s = s .. string.format(
                    format,
                    prefix,
                    k,
                    -- Compact parent & draw_major to avoid recursion and huge dumps.
                    (k == 'parent' or k == 'draw_major') and string.format("'%s'", tostring(v)) or Blueprint.dump(v, level + 1, prefix..'  ')
            )
        end
        return s..prefix:sub(3)..'}'
    else
        if type(o) == "string" then
            return string.format('"%s"', o)
        end

        if type(o) == "function" or type(o) == "table" then
            return string.format("'%s'", tostring(o))
        end

        return tostring(o)
    end
end

local config_loaded = false

Blueprint.save_config = function ()
    if not config_loaded then
        Blueprint.log "Cannot save config as it was never loaded"
        return
    end

    Blueprint.log "Saving blueprint config..."
    love.filesystem.write('config/blueprint.jkr', "return " .. Blueprint.dump(Blueprint.SETTINGS))
end


Blueprint.load_config = function ()
    config_loaded = true

    Blueprint.log "Starting to load config"
    if not love.filesystem.getInfo('config') then
        Blueprint.log("Creating config folder...")
        love.filesystem.createDirectory('config')
    end

    -- Steamodded config file location
    local config_file = love.filesystem.read('config/blueprint.jkr')

    local latest_default_config = Blueprint.load_mod_file('config.lua', 'default-config')

    if config_file then
        Blueprint.log "Reading config file: "
        Blueprint.log(config_file)
        Blueprint.SETTINGS = STR_UNPACK(config_file) -- Use STR_UNPACK to avoid code injectons via config files
    else
        Blueprint.log "Creating default settings"
        Blueprint.SETTINGS = latest_default_config
        Blueprint.save_config()
    end

    -- Remove unused settings
    for k, v in pairs(Blueprint.SETTINGS) do
        if latest_default_config[k] == nil then
            Blueprint.log("Removing setting `"..k.. "` because it is not in default config")
            Blueprint.SETTINGS[k] = nil
        end
    end

    for k, v in pairs(latest_default_config) do
        if Blueprint.SETTINGS[k] == nil then
            Blueprint.log("Adding setting `"..k.. "` because it is missing in latest config")
            Blueprint.SETTINGS[k] = v
        end
    end

    Blueprint.INTERNAL_debugging = Blueprint.SETTINGS.INTERNAL_debug
end

local cart_options_ref = G.FUNCS.options
G.FUNCS.options = function(e)
    if Blueprint.INTERNAL_in_config then
        Blueprint.INTERNAL_in_config = false
        Blueprint.save_config()
    end
    return cart_options_ref(e)
end
