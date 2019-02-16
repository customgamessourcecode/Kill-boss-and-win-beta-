function Attacked(keys)
  local caster = keys.attacker
  local target = keys.target
  local particle = ParticleManager:CreateParticle("particles/items/mazdah/templar_assassin_refract_hit.vpcf", PATTACH_POINT, target)
  ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(0, 0, 40))
  ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin() + Vector(0, 0, 40))
  ParticleManager:SetParticleControlForward(particle, 1, caster:GetForwardVector() * 1)
  target:EmitSound("Hero_TemplarAssassin.Refraction.Absorb")
end
