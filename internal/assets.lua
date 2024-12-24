local function asset_path(filename)
    return Blueprint.path.."/assets/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..filename
end

local function unblueprint_atlas(a)
    local atlas = a.name or a.key
    local blueprinted = atlas.."_blueprinted"
    if G.ASSET_ATLAS[blueprinted] then
        G.ASSET_ATLAS[blueprinted] = nil
    end
end

local function unbrainstorm_atlas(a)
    local atlas = a.name or a.key
    local brainstormed = atlas.."_brainstormed"
    if G.ASSET_ATLAS[brainstormed] then
        G.ASSET_ATLAS[brainstormed] = nil
    end
end

local game_set_render_settings = Game.set_render_settings

function Game:set_render_settings()
    game_set_render_settings(self)

    -- G.SETTINGS.GRAPHICS.texture_scaling is not guaranteed to be correct outside of this function - Jonathan
    local assets = {
        {name = 'blue_brainstorm', path = asset_path('brainstormnt.png'), px = 71, py = 95},
    }

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

    -- the blueprint and brainstorm atlases might not be valid anymore - Jonathan
    for k, v in pairs(G.ASSET_ATLAS) do
        unblueprint_atlas(v)
        unbrainstorm_atlas(v)
    end

    if Blueprint.brainstorm_sprite then
        Blueprint.brainstorm_sprite:remove()
    end

    Blueprint.brainstorm_sprite = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["blue_brainstorm"], {x=0, y=0})
end

function Blueprint.load_shaders()
    G.SHADERS['blueprint_shader'] = love.graphics.newShader(Blueprint.load_mod_file("assets/shaders/blueprint.fs", "blueprint-shader", true))
    G.SHADERS['brainstorm_shader'] = love.graphics.newShader(Blueprint.load_mod_file("assets/shaders/brainstorm.fs", "brainstorm-shader", true))
    Blueprint.log "Loaded shaders"
end
