if item_rune_gold == nil then item_rune_gold = class({}) end

function item_rune_gold:OnSpellStart(  )
	local caster = self:GetCaster()
	if not caster:HasItem("item_bottle_small") then
		bounty_gold_bonus_table = {
			[item_hand_of_midas_custom] = 125,
			[item_hand_of_midas_custom_two] = 350,
			[item_hand_of_midas_custom_two_item_hand_of_midas_custom] = 500	
		}
		local gold = self:GetSpecialValueFor("gold")
		local gpm = self:GetSpecialValueFor("gpm")
		local start_gold = self:GetSpecialValueFor("gold_start")
		local m = 1
		if caster:HasAbility("alchemist_goblins_greed") then
			local greevel = caster:FindAbilityByName("alchemist_goblins_greed")
			local gr_lvl = greevel:GetLevel()
			if gr_lvl == 1 then m = 3 elseif gr_lvl == 2 then m = 4 elseif gr_lvl == 3 then m = 5 elseif gr_lvl == 4 then m = 6 elseif gr_lvl == 5 then m = 6 elseif gr_lvl == 6 then m = 7 else m = 8 end
		end
		if caster:HasItem("item_hand_of_midas_custom") and caster:HasItem("item_hand_of_midas_custom_two") then gold = gold + item_hand_of_midas_custom_two_item_hand_of_midas_custom elseif caster:HasItem("item_hand_of_midas_custom_two") then gold = gold + item_hand_of_midas_custom_two elseif caster:HasItem("item_hand_of_midas_custom") then gold = gold + item_hand_of_midas_custom end
		if self.is_first == true then gold = (gold + gpm + start_gold) * m else gold = (gold + gpm) * m end
		caster:ModifyGold(gold,true,0)
	end
end

function item_rune_gold:IsCastOnPickup(  )
	return true
end


