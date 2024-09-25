local function blueprint_sprite(blueprint, card)
    if blueprint.blueprint_sprite_key == card.config.center.key then
        return
    end

    -- Not copying any other joker's sprite at the moment. Cache current sprite before updating
    if not blueprint.blueprint_sprite_copy then
        print "caching sprite"
        blueprint.blueprint_sprite_copy = blueprint.children.center
    end

    blueprint.blueprint_sprite_key = card.config.center.key
    print("copying card "..card.config.center.key)

    blueprint.children.center = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, G.ASSET_ATLAS[card.children.center.atlas.name], card.children.center.sprite_pos)
    blueprint.children.center.states.hover = blueprint.states.hover
    blueprint.children.center.states.click = blueprint.states.click
    blueprint.children.center.states.drag = blueprint.states.drag
    blueprint.children.center.states.collide.can = false
    blueprint.children.center:set_role({major = blueprint, role_type = 'Glued', draw_major = blueprint})

end

local function restore_sprite(blueprint)
    if not blueprint.blueprint_sprite_copy then
        return
    end

    print("restoring blueprint sprite from "..blueprint.blueprint_sprite_key)

    blueprint.children.center:remove()
    blueprint.children.center = blueprint.blueprint_sprite_copy
    blueprint.blueprint_sprite_copy = nil
    blueprint.blueprint_sprite_key = nil
end

local cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards()
    local ret = cardarea_align_cards(self)

    if self == G.jokers then
        local previous_joker = nil
        local current_joker = nil
        for i = 1, #G.jokers.cards do
            current_joker = G.jokers.cards[i]
            if previous_joker and previous_joker.config and previous_joker.config.center and previous_joker.config.center.key == 'j_blueprint' then
                if current_joker.config.center.blueprint_compat then
                    blueprint_sprite(previous_joker, current_joker)
                else
                    restore_sprite(previous_joker)
                end
            end
            previous_joker = current_joker
        end

        -- make sure to update sprite for blueprint if it's last on the list
        restore_sprite(previous_joker)
    end

    return ret
end