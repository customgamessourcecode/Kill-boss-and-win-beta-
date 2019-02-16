function DisarmorPct( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local disarmor 			= keys.Disarmor
	local modifier_name 	= keys.ModifierName
	local duration 			= keys.Duration
	local disarmor 			= keys.Disarmor / 100
	local stack_count 		= target:GetModifierStackCount(modifier_name, caster) or 0
	local disarmor_standart = ability:GetSpecialValueFor("armor_reduction") or 0
	
	local target_armor_total 	= (target:GetPhysicalArmorValue() + stack_count + math.abs(disarmor_standart))*disarmor

	ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration } )

	target:SetModifierStackCount(modifier_name, caster, target_armor_total)

end