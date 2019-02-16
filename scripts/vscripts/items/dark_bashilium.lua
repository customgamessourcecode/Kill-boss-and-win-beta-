function purge(event)
event.caster:Purge(false, true, false, true, false)
local caster = event.caster
event.ability:StartCooldown(event.ability:GetCooldown(event.ability:GetLevel()))  --This is just for visual purposes.
local particle = ParticleManager:CreateParticle("particles/items/darkbashilium/lina_spell_light_strike_array_sphere.vpcf", PATTACH_POINT, caster)
 ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, 0))
end