function think(keys)
  local caster = keys.caster
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_feet_effects_embers.vpcf", PATTACH_POINT, caster)
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, 50))
  ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() + Vector(0, 0, 50))
end