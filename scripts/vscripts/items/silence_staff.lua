function damage(event)
local caster = event.caster
local target = event.target
local damage = caster:GetIntellect() * 10
print("damage= ",damage)
ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_explosion_white_d_arcana1.vpcf", PATTACH_POINT, target)
 ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(0, 0, 0))

 local particle2 = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_g_cowlofice_b.vpcf", PATTACH_POINT, target)
 ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin() + Vector(0, 0, 0))
 target:EmitSound("Hero_Crystal.CrystalNova")
end

