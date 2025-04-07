--- STEAMODDED HEADER
--- MOD_NAME: Blueprint
--- MOD_ID: blueprint
--- MOD_AUTHOR: [stupxd aka stupid, Jonathan]
--- MOD_DESCRIPTION: Dynamically change Blueprint & Brainstorm textures.
--- PRIORITY: 69
--- BADGE_COLOR: 4B69CF
--- DISPLAY_NAME: Blueprint
--- VERSION: 3.2

----------------------------------------------
------------MOD CODE -------------------------



SMODS.DrawStep {
    key = 'blueprint_sprite_copy',
    order = 100,
    func = function(self, layer)
        if self.blueprint_sprite_copy and self.children.floating_sprite then
            local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2
    
            if self.blueprint_copy_key == 'j_hologram' then
                self.hover_tilt = self.hover_tilt*1.5
                self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 2*scale_mod, 2*rotate_mod)
                self.hover_tilt = self.hover_tilt/1.5
            else
                self.children.floating_sprite:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
                self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
            end
            --self.children.floating_sprite:draw_shader('dissolve',   0, nil, nil, self.children.center, scale_mod, rotate_mod, nil, 0.1 + 0.03 * math.sin(1.8 * G.TIMERS.REAL), nil, 0.6)
            --self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
        end
    end,
    conditions = { vortex = false, facing = 'front', blueprint_sprite_copy = true },
}

----------------------------------------------
------------MOD CODE END----------------------
