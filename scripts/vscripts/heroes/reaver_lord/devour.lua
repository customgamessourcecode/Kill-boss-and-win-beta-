function OnIntervalThink( keys )
	local caster 		= keys.caster
	local target 		= keys.target
	local damage 		= keys.Damage 
	local damage_pct 	= keys.DamagePct / 100
	local modifier_name = keys.ModifierName
	local range 		= keys.Range 
	local soul_name 	= keys.SoulName 

	local distantion = (caster:GetAbsOrigin() - target:GetAbsOrigin() ):Length2D() 

	print("distantion", distantion, " range = ", range)
	if distantion-50 > range then
		target:RemoveModifierByName(modifier_name)

		local stack_count = caster:GetModifierStackCount(soul_name, caster)
		if stack_count then
			caster:SetModifierStackCount(soul_name, caster, stack_count - 1)
		end
		
	end

	ApplyDamage({ victim = target, attacker = caster, damage = (damage + target:GetMaxHealth()*damage_pct)/2, damage_type = DAMAGE_TYPE_MAGICAL })
	caster:Heal((damage + target:GetMaxHealth()*damage_pct)/2, keys.ability)
end

function OnDestroy( keys )
	local caster 		= keys.caster
	local target 		= keys.target
	local soul_name 	= keys.ModifierName 

	local stack_count = caster:GetModifierStackCount(soul_name, caster)
	
	caster:RemoveModifierByName(soul_name)

	if caster.soul_ability then
		caster.soul_ability:ApplyDataDrivenModifier(caster, caster, soul_name, {duration = 90})
		local soul_ability 	= caster.soul_ability
		local max_souls 	= soul_ability:GetSpecialValueFor("max_souls") or 0
		
		if stack_count + 1 >= max_souls then
			stack_count = max_souls - 1
		end

		
	else
		print(" caster.soul_ability is nil!")
	end
	
	caster:SetModifierStackCount(soul_name, caster, stack_count + 1)

end