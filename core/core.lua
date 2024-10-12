--------------------------------------------------
--------- Incredible mod configuration -----------
--------------------------------------------------

local copy_when_highlighted
-- Blueprint will stop copying texture when highlighted (by clicking on it)
-- Remove -- in front of next line to disable this behaviour
-- copy_when_highlighted = true

local inverted_colors = false
-- Blueprint shader normally inverts sprite colors
-- Remove -- in front of next line to disable this behaviour
-- inverted_colors = false

local use_brainstorm_logic = true
-- Normally blueprint copying brainstorm will show sprite of joker copied by brainstorm
-- Remove -- in front of next line to disable this behaviour
-- use_brainstorm_logic = false

-- Decreasing this value makes blueprinted sprites darker, going above 0.28 is not recommended.
local lightness_offset = 0.131

-- Change coloring mode
-- 1 = linear (1 or less)
-- 2 = exponent
-- 3 = parabola
-- 4 = sin
local coloring_mode = 1

-- Change pow for exponent and parabola modes
local power = 1



--------------------------------------------------

-- Avg blueprint color
local canvas_background_color = {
    (62 + 198) / 255 / 2,
    (96 + 210) / 255 / 2,
    (212 + 252) / 255 / 2,
    0
}

-- Blueprinted border color
canvas_background_color = {
    76 / 255,
    108 / 255,
    216 / 255,
    0
}

local function process_texture(image)
    local h, w = image:getDimensions()
    local canvas = love.graphics.newCanvas(h, w, {type = '2d', readable = true})

    love.graphics.push()
    
    
    
    local oldCanvas = love.graphics.getCanvas()
    --local old_filter1, old_filter2 = image:getFilter()
    --local old_filter11, old_filter22 = love.graphics.getDefaultFilter()
    
    -- I dont think changing filter does anything.. the image still looks blurry
    --image:setFilter("nearest", "nearest")
    --canvas:setFilter("nearest", "nearest")
    --love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setCanvas( canvas )
    love.graphics.clear(canvas_background_color)
    
    love.graphics.setColor(1, 1, 1, 1)

    G.SHADERS['blueprint_shader']:send('inverted', inverted_colors)
    G.SHADERS['blueprint_shader']:send('lightness_offset', lightness_offset)
    G.SHADERS['blueprint_shader']:send('mode', coloring_mode)
    G.SHADERS['blueprint_shader']:send('expo', power)
    love.graphics.setShader( G.SHADERS['blueprint_shader'] )
    
    -- Draw image with blueprint shader on new canvas
    love.graphics.draw( image )


    love.graphics.setShader()
    love.graphics.setCanvas(oldCanvas)
    --image:setFilter(old_filter1, old_filter2)
    --canvas:setFilter(image:getFilter())
    --love.graphics.setDefaultFilter(old_filter11, old_filter22)

    love.graphics.pop()

    --local fileData = canvas:newImageData():encode('png', 'imblueeeeeedabudeedabudai.png')

    if true then
        return love.graphics.newImage(canvas:newImageData()) --, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling}
    end

    return canvas
end

local function blueprint_atlas(atlas)
    local blueprinted = atlas.."_blueprinted"

    if not G.ASSET_ATLAS[blueprinted] then
        G.ASSET_ATLAS[blueprinted] = {}
        G.ASSET_ATLAS[blueprinted].blueprint = true
        G.ASSET_ATLAS[blueprinted].name = G.ASSET_ATLAS[atlas].name
        G.ASSET_ATLAS[blueprinted].type = G.ASSET_ATLAS[atlas].type
        G.ASSET_ATLAS[blueprinted].px = G.ASSET_ATLAS[atlas].px
        G.ASSET_ATLAS[blueprinted].py = G.ASSET_ATLAS[atlas].py
        G.ASSET_ATLAS[blueprinted].image = process_texture(G.ASSET_ATLAS[atlas].image)
    end

    return G.ASSET_ATLAS[blueprinted]
end

local function equal_sprites(first, second)
    -- Dynamically update sprite for animated jokers & multiple blueprint copies
    return first.atlas.name == second.atlas.name and first.sprite_pos.x == second.sprite_pos.x and first.sprite_pos.y == second.sprite_pos.y
end


local function align_sprite(self, card, restore)
    if restore then
        if self.blueprint_T then
            self.T.h = self.blueprint_T.h
            self.T.w = self.blueprint_T.w
--        else
--            self.T.h = G.CARD_H
--            self.T.w = G.CARD_W
        end
        return
    end

    if not self.blueprint_T then
        self.blueprint_T = {h = self.T.h, w = self.T.w}
    end

    self.T.h = card.T.h
    self.T.w = card.T.w
    self.children.center.scale.y = card.children.center.scale.y
end

local function blueprint_sprite(blueprint, card)
    if equal_sprites(blueprint.children.center, card.children.center) then
        return
    end

    -- Not copying any other joker's sprite at the moment. Cache current sprite before updating
    if not blueprint.blueprint_sprite_copy then
        blueprint.blueprint_sprite_copy = blueprint.children.center
    end
    blueprint.blueprint_copy_key = card.config.center.key

    -- Make sure to remove floating sprite before applying new one
    if blueprint.children.floating_sprite then
        blueprint.children.floating_sprite:remove()
        blueprint.children.floating_sprite = nil
    end

    align_sprite(blueprint, nil, true)

    blueprint.children.center = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, blueprint_atlas(card.children.center.atlas.name), card.children.center.sprite_pos)
    blueprint.children.center.states.hover = blueprint.states.hover
    blueprint.children.center.states.click = blueprint.states.click
    blueprint.children.center.states.drag = blueprint.states.drag
    blueprint.children.center.states.collide.can = false
    blueprint.children.center:set_role({major = blueprint, role_type = 'Glued', draw_major = blueprint})

    if card.children.floating_sprite then
        blueprint.children.floating_sprite = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, blueprint_atlas(card.children.floating_sprite.atlas.name), card.children.floating_sprite.sprite_pos)
        blueprint.children.floating_sprite.role.draw_major = blueprint
        blueprint.children.floating_sprite.states.hover.can = false
        blueprint.children.floating_sprite.states.click.can = false
    end

    --if card.children.floating_sprite2 then
    --    blueprint.children.floating_sprite2 = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, G.ASSET_ATLAS[card.children.floating_sprite2.atlas.name], card.children.floating_sprite2.sprite_pos)
    --    blueprint.children.floating_sprite2.role.draw_major = blueprint
    --    blueprint.children.floating_sprite2.states.hover.can = false
    --    blueprint.children.floating_sprite2.states.click.can = false
    --end
    align_sprite(blueprint, card)
end

local function restore_sprite(blueprint)
    if not blueprint.blueprint_sprite_copy then
        return
    end

    blueprint.children.center:remove()
    blueprint.children.center = blueprint.blueprint_sprite_copy
    blueprint.blueprint_sprite_copy = nil
blueprint.blueprint_copy_key = nil

    if blueprint.children.floating_sprite then
        blueprint.children.floating_sprite:remove()
        blueprint.children.floating_sprite = nil
    end

    --if blueprint.children.floating_sprite2 then
    --    blueprint.children.floating_sprite2:remove()
    --    blueprint.children.floating_sprite2 = nil
    --end

    align_sprite(blueprint, nil, true)
end

return function ()


local sprite_reset = Sprite.reset
function Sprite:reset()
    if self.atlas.blueprint then
        if type(self.atlas.release) == "function" then
            self.atlas:release()
        end
        self.atlas = blueprint_atlas(self.atlas.name)
        self:set_sprite_pos(self.sprite_pos)
        return
    end
    
    return sprite_reset(self)
end


local cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards()
    local ret = cardarea_align_cards(self)

    if self == G.jokers then
        local previous_joker = nil
        local current_joker = nil
        for i = #G.jokers.cards, 1, -1  do
            current_joker = G.jokers.cards[i]
            if current_joker.config and current_joker.config.center and current_joker.config.center.key == 'j_blueprint' then
                if use_brainstorm_logic and previous_joker and previous_joker.config.center.key == 'j_brainstorm' then
                    previous_joker = G.jokers.cards[1]
                end
                local should_copy = previous_joker and previous_joker.config.center.blueprint_compat and not current_joker.states.drag.is and (copy_when_highlighted or not current_joker.highlighted)

                -- leftmost brainstorm, is not copying anything.
                if use_brainstorm_logic and should_copy and previous_joker.config.center.key == 'j_brainstorm' then
                    should_copy = false
                end

                if should_copy then
                    blueprint_sprite(current_joker, previous_joker)
                else
                    restore_sprite(current_joker)
                end
            end
            if not (current_joker.config.center.key == 'j_blueprint') then
                previous_joker = current_joker
            end
        end

    end

    return ret
end





end
