function SoulBurnStart( keys )
	local caster 		= keys.caster 
	local target 		= keys.target
	local damage 		= keys.Damage 
	local damage_pct 	= keys.DamagePct / 100
	local modifier_name = keys.ModifierName

	local soul_count = caster:GetModifierStackCount(modifier_name, caster) or 0

	local damage_int_pct_add = 1
	if caster:IsRealHero() then
		damage_int_pct_add = caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 
	
	local damage = damage*soul_count + (damage_pct*target:GetMaxHealth() / damage_int_pct_add )

	caster:RemoveModifierByName(modifier_name)

	if IsUnitBossGlobal(target) then
		damage = damage / 5
	end
	
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
end
