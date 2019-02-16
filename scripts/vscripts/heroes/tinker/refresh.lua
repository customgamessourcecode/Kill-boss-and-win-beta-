local not_refreshing_items = {
	["item_black_king_bar"] = 1,
	["item_hand_of_midas"] = 1,
	["item_advanced_midas"] = 1,
	["item_necronomicon"] = 1,
	["item_necronomicon_2"] = 1,
	["item_necronomicon_3"] = 1,
	["item_black_king_bar"] = 1,
	["item_refresher"] = 1,
	["item_sphere"] = 1,
	["item_sphere_2"] = 1,
	["item_helm_of_the_dominator"] = 1,
	["item_arcane_boots"] = 1,
	["item_strange_amulet"] = 1,
	["item_mystic_amulet"] = 1,
	["item_power_amulet"] = 1,
	["item_eclipse_amphora"] = 1,
	["item_kings_bar"] = 1,
	["item_octarine_core_2"] = 1,
	--["item_snake_boots"] = 1,
	["item_recovery_orb"]	= 1,
	["faceless_void_chronosphere"] = 1,
	["item_potion_immune"] = 1,
	["item_aeon_disk"]				= 1,
	["item_aegis_aa"]					= 1,
}


function Refresh(event)
	local caster = event.caster

	-- refreshing abilities
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex( i )
		if ability and ability ~= event.ability then
			ability:EndCooldown()
		end
	end

	-- refreshing items
	for i = 0, 5 do
		local item = caster:GetItemInSlot( i )
		if item and not not_refreshing_items[item:GetAbilityName()] then
			item:EndCooldown()
		end
	end

end

function Refresh_tinker_animation( keys )
	local caster = keys.caster
	local ability = keys.ability
	local abilityLevel = ability:GetLevel()
	
	if abilityLevel > 3 then
		abilityLevel = 3 
	end 

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_tinker_rearm_level_" .. abilityLevel, {} )
end