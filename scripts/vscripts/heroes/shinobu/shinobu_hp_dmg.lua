function hp_damage( keys )
	if keys.ability ~= nil then
		local target = keys.target
		local caster = keys.caster
		local ability = keys.ability
		local hp_damage = ability:GetSpecialValueFor("damage")
		local armor = target:GetPhysicalArmorValue()
		local armor_dmg = ability:GetSpecialValueFor("armor_damage")/100
		local talent = caster:FindAbilityByName("special_bonus_shinobu_3")
		local talent1 = caster:FindAbilityByName("special_bonus_shinobu_4")
		if talent then
			if talent:GetLevel() == 1 then
				local value = talent:GetSpecialValueFor("value")
				hp_damage = hp_damage + value
			end
		end	
		if talent1 then
			if talent1:GetLevel() == 1 then
				local value1 = talent1:GetSpecialValueFor("value")
				armor_dmg = armor_dmg + (value1/100)
			end
		end
		local damageTable = {}
		damageTable.attacker = caster
		damageTable.victim = target
		damageTable.damage_type = ability:GetAbilityDamageType()
		damageTable.damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
		damageTable.ability = ability
		
			if target:GetHealth() >= caster:GetHealth() then
				damageTable.damage = hp_damage + (armor * armor_dmg)
			end
			
			if target:GetHealth() <= caster:GetHealth() then
				damageTable.damage = hp_damage
			end

			ApplyDamage(damageTable)	
	end		
end