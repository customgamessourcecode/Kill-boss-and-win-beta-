function Give_exp( keys )
	if keys.ability and not keys.event_ability:IsItem() then
		local caster = keys.caster
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local experience = ability:GetLevelSpecialValueFor("exp_per_cast", level)
		local bonus = ability:GetLevelSpecialValueFor("exp_lvl_bonus", level)
		local cd = keys.event_ability:GetCooldown(level)
		local coef = 0
		if keys.event_ability:GetManaCost(-1) > 50 then
			
			if cd > 10 
				then 
					coef = 1 
				else 
					coef = cd * 0.1 
			end
			experience = experience + bonus * caster:GetLevel() * coef
			caster:AddExperience(experience, false,false)
		end
	end
end