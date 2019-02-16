function sacrifice(event)
local caster = event.caster
local damage = caster:GetMaxHealth()/2
if caster:GetHealth() > damage then
	ApplyDamage({ victim = caster, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
	else caster:SetHealth(1)
end

local targets = FindUnitsInRadius( caster:GetTeamNumber(),
									  caster:GetAbsOrigin(),
									  nil,
									  250, --radius
									  DOTA_UNIT_TARGET_TEAM_ENEMY,
									  DOTA_UNIT_TARGET_ALL,
									  DOTA_UNIT_TARGET_FLAG_NONE,
									  FIND_ANY_ORDER,
									  false )

	for _,v in pairs( targets ) do --эффект крепить сюда, в переменную v
	ApplyDamage({ victim = v, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
	end 
  local particle = ParticleManager:CreateParticle("particles/items/grandcross/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_POINT, caster)
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, 0))
  caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")

end