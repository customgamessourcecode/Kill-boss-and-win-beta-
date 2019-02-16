function healing_ring(event)
local caster = event.caster
local heal1 = event.heal
local heal2 = event.add + event.heal
local target = event.target
if target:GetHealth() < target:GetMaxHealth() * 0.3 then 
  target:Heal(heal2,caster)
else
  target:Heal(heal1,caster)
end
local particle = ParticleManager:CreateParticle("particles/items/healing_ring/zuus_arc_lightning.vpcf", PATTACH_POINT, caster)
 ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, 40))
 ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() + Vector(0, 0, 40))
 caster:EmitSound("Hero_Zuus.ArcLightning.Cast")
end