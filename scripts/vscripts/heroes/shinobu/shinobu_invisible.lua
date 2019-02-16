function shinobu_attack( keys )
	if keys.ability ~= nil and not keys.target:IsUnselectable() then
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
        local talent = caster:FindAbilityByName("special_bonus_shinobu_1")
		local abilityDamage = ability:GetSpecialValueFor( "bonus_damage")
		local DamageBonus = ability:GetSpecialValueFor( "bonus_damage_mult")
		local modifier_dmg = ability:GetSpecialValueFor( "mult_dmg_modifier")
		modifier_dmg = caster:BonusTalentValue("special_bonus_shinobu_6",modifier_dmg)
		local abilityDamageType = ability:GetAbilityDamageType()
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
		if talent then
			if talent:GetLevel() == 1 then
				local value_damage = talent:GetSpecialValueFor("value")
				abilityDamage = abilityDamage + value_damage
			end
		end
		if caster:HasModifier("modifier_shinobi_hp_damage_activate") then
			abilityDamage = abilityDamage * modifier_dmg
		end
		if caster:HasScepter() == true then
			abilityDamage =  abilityDamage * DamageBonus
		end
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = abilityDamage,
			damage_type = abilityDamageType
		}
		ApplyDamage( damageTable )
		keys.caster:RemoveModifierByName( "modifier_shinobu_invisible" )
	elseif keys.ability == nil then
		keys.caster:RemoveModifierByName( "modifier_shinobu_invisible" )
	end
end
