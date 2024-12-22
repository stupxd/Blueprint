local function asset_path(filename)
    return Blueprint.path.."/assets/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..filename
end

local assets = {
    {name = 'blue_brainstorm', path = asset_path('brainstormnt.png'), px = 71, py = 95},
}

local game_set_render_settings = Game.set_render_settings

function Game:set_render_settings()
    game_set_render_settings(self)

    for i=1, #assets do
        G.ASSET_ATLAS[assets[i].name] = {}
        G.ASSET_ATLAS[assets[i].name].name = assets[i].name
        -- File load method using steamodded's code
        local file_data = assert(Blueprint.nfs.newFileData(assets[i].path), 'Failed to collect file data for '..assets[i].name)
        local image_data = assert(love.image.newImageData(file_data), 'Failed to initialize image data for '..assets[i].name)
        G.ASSET_ATLAS[assets[i].name].image = love.graphics.newImage(image_data, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
        G.ASSET_ATLAS[assets[i].name].px = assets[i].px
        G.ASSET_ATLAS[assets[i].name].py = assets[i].py
    end
end

function Blueprint.load_shaders()
    G.SHADERS['blueprint_shader'] = love.graphics.newShader(Blueprint.load_mod_file("assets/shaders/blueprint.fs", "blueprint-shader", true))
    G.SHADERS['brainstorm_shader'] = love.graphics.newShader(Blueprint.load_mod_file("assets/shaders/brainstorm.fs", "brainstorm-shader", true))
    Blueprint.log "Loaded shaders"
end
