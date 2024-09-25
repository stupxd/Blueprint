--------------------------------------------------
--------- Incredible mod configuration -----------
--------------------------------------------------

local copy_when_highlighted

-- Blueprint will stop copying texture when highlighted (by clicking on it)
-- Remove -- in front of next line to disable this behaviour
-- local copy_when_highlighted = true

--------------------------------------------------




local function equal_sprites(first, second)
    -- Dynamically update sprite for animated jokers & multiple blueprint copies
    return first.atlas.name == second.atlas.name and first.sprite_pos.x == second.sprite_pos.x and first.sprite_pos.y == second.sprite_pos.y
end


local function align_sprite(self, card, restore)
    if restore then
        if self.blueprint_T then
            self.T.h = self.blueprint_T.h
            self.T.w = self.blueprint_T.w
        else
            self.T.h = G.CARD_H
            self.T.w = G.CARD_W
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

    blueprint.children.center = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, G.ASSET_ATLAS[card.children.center.atlas.name], card.children.center.sprite_pos)
    blueprint.children.center.states.hover = blueprint.states.hover
    blueprint.children.center.states.click = blueprint.states.click
    blueprint.children.center.states.drag = blueprint.states.drag
    blueprint.children.center.states.collide.can = false
    blueprint.children.center:set_role({major = blueprint, role_type = 'Glued', draw_major = blueprint})

    align_sprite(blueprint, card)
end

local function restore_sprite(blueprint)
    if not blueprint.blueprint_sprite_copy then
        return
    end

    blueprint.children.center:remove()
    blueprint.children.center = blueprint.blueprint_sprite_copy
    blueprint.blueprint_sprite_copy = nil
    align_sprite(blueprint, nil, true)
end

return function ()
    local cardarea_align_cards = CardArea.align_cards
    function CardArea:align_cards()
        local ret = cardarea_align_cards(self)
    
        if self == G.jokers then
            local previous_joker = nil
            local current_joker = nil
            for i = #G.jokers.cards, 1, -1  do
                current_joker = G.jokers.cards[i]
                if current_joker.config and current_joker.config.center and current_joker.config.center.key == 'j_blueprint' then
                    local should_copy = previous_joker and previous_joker.config.center.blueprint_compat and not current_joker.states.drag.is and (copy_when_highlighted or not current_joker.highlighted)
                    if should_copy and previous_joker.config.center.key == 'j_blueprint' and not previous_joker.blueprint_sprite_copy then
                        should_copy = false
                    end
    
                    if should_copy then
                        blueprint_sprite(current_joker, previous_joker)
                    else
                        restore_sprite(current_joker)
                    end
                end
                previous_joker = current_joker
            end
    
            -- make sure to update sprite for blueprint if it's last on the list
            restore_sprite(previous_joker)
        end
    
        return ret
    end
end