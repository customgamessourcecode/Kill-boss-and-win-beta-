function GiveGold(kv)
	local caster = kv.caster
	local ability = kv.ability
	local greed = nil
	local midas1 = nil
	local midas2 = nil
	local multiplier = 1
	local gold_min = ability:GetSpecialValueFor("gold_min")
	local gold_max = ability:GetSpecialValueFor("gold_max")
	local gold_mul = 1
	local gold_mul_greed = 0
	local gold_mul_midas1 = 0
	local gold_mul_midas2 = 0
	local gold_rnd = RandomInt(gold_min,gold_max)

	if caster:FindAbilityByName("alchemist_goblins_greed") then 
		greed = caster:FindAbilityByName("alchemist_goblins_greed")
		gold_mul_greed = greed:GetSpecialValueFor("bounty_multiplier_tooltip")
	else
		gold_mul_greed = 0
	end

	if caster:FindItemByName("item_hand_of_midas_custom") then
		midas1 = caster:FindItemByName("item_hand_of_midas_custom")
		gold_mul_midas1 = midas1:GetSpecialValueFor("rune")*0.01
	else
		gold_mul_midas1 = 0
	end

	if caster:FindItemByName("item_hand_of_midas_custom_two") then
		midas2 = caster:FindItemByName("item_hand_of_midas_custom_two")
		gold_mul_midas2 = midas2:GetSpecialValueFor("rune")*0.01
	else
		gold_mul_midas2 = 0
	end

	local gold_mul = gold_mul + gold_mul_greed/2 + gold_mul_midas1/2 + gold_mul_midas2/2
	local gold = (20 + (gold_rnd*0.5*TIME/60) )* gold_mul
    caster:ModifyGold(gold, false, 0)
    SendOverheadEventMessage( caster,  OVERHEAD_ALERT_GOLD , caster, gold, nil )
end