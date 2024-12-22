--[[ -- I wanted to add settings for when you click on a joker to highlight it

local card_highlight = Card.highlight
function Card:highlight(is_higlighted)



    return card_highlight(self, is_higlighted)
end


local card_focus_ui = G.UIDEF.card_focus_ui

function G.UIDEF.card_focus_ui(card)
    local name = "I dunno"
    if card.config and card.config.center then
        name = card.config.center.key
    end
    Blueprint.log("hi hello im " .. tostring(name).. ". highlighed: "..tostring(card.highlighted))
    return card_focus_ui(card)
end
]]