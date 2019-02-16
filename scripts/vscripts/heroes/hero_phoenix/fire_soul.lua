
function CheckHealth( keys )

	local caster = keys.caster
	local ability = keys.ability
	local health_proc = ability:GetSpecialValueFor("health_proc")
	local modifier_name = "modifier_phenix_fire_soul_buff"
	
	if caster:GetHealth()/caster:GetMaxHealth()*100 < health_proc then
		if not caster:HasModifier(modifier_name) then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_name, nil)
		end
	else
		caster:RemoveModifierByName(modifier_name)
	end
end