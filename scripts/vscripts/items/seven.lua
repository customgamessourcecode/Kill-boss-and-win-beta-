function effectgo(event)
local caster = event.caster
 local particle = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_flame_immortal1.vpcf", PATTACH_POINT, caster)
 ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, 0))
 local particle2 = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_ground_immortal1.vpcf", PATTACH_POINT, caster)
 ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin() + Vector(0, 0, 0))
end

