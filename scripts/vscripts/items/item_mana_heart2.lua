function modifier_item_mana_heart2_regen_on_take_damage(keys)
	if keys.caster:IsRangedAttacker()	then
		keys.ability:StartCooldown(keys.CooldownRanged)
	else
		keys.ability:StartCooldown(keys.CooldownMelee)
	end
	
	if	keys.caster:HasModifier("modifier_item_mana_heart2_regen_visible") then
		keys.caster:RemoveModifierByNameAndCaster("modifier_item_mana_heart2_regen_visible", keys.caster)
	end
end

function modifier_item_mana_heart2_regen_on_cast_spell(keys)

	if keys.event_ability:GetCooldown(-1) > 1 and keys.event_ability:GetManaCost(-1) > 30 then
		keys.ability:StartCooldown(keys.CooldownMelee)
		if	keys.caster:HasModifier("modifier_item_mana_heart2_regen_visible") then
			keys.caster:RemoveModifierByNameAndCaster("modifier_item_mana_heart2_regen_visible", keys.caster)
		end
	end
end

function modifier_item_mana_heart2_regen_on_interval_think(keys)
	if keys.ability:IsCooldownReady() and keys.caster:IsRealHero() then
		keys.caster:GiveMana(keys.caster:GetMaxMana() * (keys.ManaRegenPercentPerSecond / 100) * keys.RegenInterval)
		if not keys.caster:HasModifier("modifier_item_mana_heart2_regen_visible") then
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_mana_heart2_regen_visible", {duration = -1})
		end
	elseif	keys.caster:HasModifier("modifier_item_mana_heart2_regen_visible") then
		keys.caster:RemoveModifierByNameAndCaster("modifier_item_mana_heart2_regen_visible", keys.caster)
	end
end


function modifier_item_mana_heart2_regen_on_destroy(keys)
	keys.caster:RemoveModifierByNameAndCaster("modifier_item_mana_heart2_regen_visible", keys.caster)
end	