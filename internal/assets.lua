local function asset_path(filename)
    return Blueprint.path.."/assets/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/"..filename
end

local game_set_render_settings = Game.set_render_settings

function Game:set_render_settings()
    game_set_render_settings(self)

    -- G.SETTINGS.GRAPHICS.texture_scaling is not guaranteed to be correct outside of this function - Jonathan
    local assets = {
        {name = 'blue_brainstorm', path = asset_path('brainstormnt.png'), px = 71, py = 95},
        {name = 'blue_brainstorm_single', path = asset_path('brainstormnt_single.png'), px = 71, py = 95},
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
    for k, atlas in pairs(G.ASSET_ATLAS) do
        if k:match("_blueprinted$") or k:match("_brainstormed$") then
            atlas.released = true
            atlas.image:release()
            G.ASSET_ATLAS[k] = nil
        end
    end

    if Blueprint.brainstorm_sprite then
        Blueprint.brainstorm_sprite:remove()
    end

    -- using some extra padding to fix this issue where the sticking out parts on the brainstormnt are pixelated
    -- because they are right on the edge of the image - Jonathan
    Blueprint.brainstorm_sprite = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["blue_brainstorm"], {x=1, y=1})
end

function Blueprint.load_shaders()
    G.SHADERS['blueprint_shader'] = love.graphics.newShader(Blueprint.load_mod_file("assets/shaders/blueprint.fs", "blueprint-shader", true))
    local success, err = pcall(function ()
        G.SHADERS['brainstorm_shader'] = love.graphics.newShader(Blueprint.load_mod_file("assets/shaders/brainstorm.fs", "brainstorm-shader", true))
    end)
    if success then
        print "Loaded all Blueprint mod shaders successfully"
        Blueprint.brainstorm_enabled = true
    else
        Blueprint.brainstorm_enabled = false
        print (
[[

=========================================================================
Loaded Blueprint shader, but Brainstorm seems to be unsupported by your system!

]]..err..[[

=========================================================================

]])
    end
end
