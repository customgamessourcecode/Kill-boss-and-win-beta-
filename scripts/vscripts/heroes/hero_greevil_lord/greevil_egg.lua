unit_upgrade = 0




function CreateGreevilEgg( event )
	local point = event.target_points[1]
	local caster = event.caster
--	local point = caster:GetAbsOrigin()
	local player = caster:GetPlayerID()
	local ability = event.ability

	print("vse rabotaet!")
	local unit_name = event.unit_name
	local base_hp = ability:GetSpecialValueFor("egg_hp")
	local base_armor = ability:GetSpecialValueFor("egg_armor")
	local egg_duration = ability:GetSpecialValueFor("egg_duration")
	
	local tower = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())

	tower:SetControllableByPlayer(player, true)
	if egg_duration ~= 0 then
		tower:AddNewModifier(caster,ability,"modifier_kill",{duration = egg_duration})
	end
	tower:AddNewModifier(caster,ability,"modifier_phased",{duration = 0.1})
	
	local strenght = caster:GetStrength()
	local agility = caster:GetAgility()
	local intellegence = caster:GetIntellect()
	local new_hp = base_hp 

	tower:SetPhysicalArmorBaseValue( base_armor )
	tower:SetMaxHealth( new_hp )
	tower:SetBaseMaxHealth( new_hp )
	tower:SetHealth( new_hp )

	ability:ApplyDataDrivenModifier(caster, tower, "modifier_greevil_egg_thinker", nil)
	
end

function CreateMainGreevilEgg( event )
	local point = event.target_points[1]
	local caster = event.caster
--	local point = caster:GetAbsOrigin()
	local player = caster:GetPlayerID()
	local ability = event.ability

	local unit_name = event.unit_name
	local base_hp = ability:GetSpecialValueFor("egg_hp")
	local base_armor = ability:GetSpecialValueFor("egg_armor")
	local egg_duration = ability:GetSpecialValueFor("egg_duration")

	if caster.egg and IsValidEntity(caster.egg) then
		caster.egg:RemoveSelf()
	end

	caster.egg = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())

	caster.egg:SetControllableByPlayer(player, true)
	if egg_duration ~= 0 then
		caster.egg:AddNewModifier(caster,ability,"modifier_kill",{duration = egg_duration})
	end
	caster.egg:AddNewModifier(caster,ability,"modifier_phased",{duration = 0.1})
	
	local strenght = caster:GetStrength()
	local agility = caster:GetAgility()
	local intellegence = caster:GetIntellect()
	local new_hp = base_hp 

	caster.egg:SetPhysicalArmorBaseValue( base_armor )
	caster.egg:SetMaxHealth( new_hp )
	caster.egg:SetBaseMaxHealth( new_hp )
	caster.egg:SetHealth( new_hp )
end


function SpawnGreevil( event )
	local caster = event.target
	local point = caster:GetAbsOrigin()
	local player = caster:GetPlayerOwnerID()
	local ability = event.ability

	local unit_name = event.unit_name
	local base_hp = ability:GetSpecialValueFor("base_hp")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local base_armor = ability:GetSpecialValueFor("base_armor")
	local hp_per_upgrade = ability:GetSpecialValueFor("hp_per_upgrade")
	local dmg_per_upgrade = ability:GetSpecialValueFor("dmg_per_upgrade")
	local armor_per_upgrade = ability:GetSpecialValueFor("armor_per_upgrade") 
	local duration = ability:GetSpecialValueFor("spawn_duration") 

	unit = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())
	unit:AddNewModifier(caster,ability,"modifier_kill",{duration = duration})
	unit:AddNewModifier(caster,ability,"modifier_phased",{duration = 0.1})
	unit:SetControllableByPlayer(player, true)

	local new_hp = base_hp + unit_upgrade*hp_per_upgrade

	unit:SetBaseDamageMin(base_dmg + unit_upgrade*dmg_per_upgrade )
	unit:SetBaseDamageMax(base_dmg + unit_upgrade*dmg_per_upgrade )				
	unit:SetPhysicalArmorBaseValue(base_armor + unit_upgrade*armor_per_upgrade )
	unit:SetMaxHealth( new_hp )
	unit:SetBaseMaxHealth( new_hp )
	unit:SetHealth( new_hp )
	
	ability:ApplyDataDrivenModifier(caster, unit, "modifier_greevil_egg_bonus", nil)
	
end

function CreateUnit ( event )
	local caster = event.caster
	local point = caster:GetAbsOrigin()
	local player = caster:GetPlayerOwnerID()
	local ability = event.ability

	local unit_name = event.unit_name
	local base_hp = ability:GetSpecialValueFor("base_hp")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local base_armor = ability:GetSpecialValueFor("base_armor")
	local hp_per_upgrade = ability:GetSpecialValueFor("hp_per_upgrade")
	local dmg_per_upgrade = ability:GetSpecialValueFor("dmg_per_upgrade")
	local armor_per_upgrade = ability:GetSpecialValueFor("armor_per_upgrade")

	local gold_cost = ability:GetSpecialValueFor("gold_cost")
	local player_gold = PlayerResource:GetGold(player)
	local player_reliable_gold = PlayerResource:GetReliableGold(player)
			
	if player_gold < gold_cost then
		return
	end
	
	if player_reliable_gold < gold_cost then
		PlayerResource:ModifyGold(player, -player_reliable_gold, true, 0)
		PlayerResource:ModifyGold(player, player_reliable_gold - gold_cost, false, 0)
	else
		PlayerResource:ModifyGold(player, -gold_cost, true, 0)
	end
		
	unit = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())
	unit:SetControllableByPlayer(player, true)
	unit:AddNewModifier(caster,ability,"modifier_phased",{duration = 0.1})

	local new_hp = base_hp + unit_upgrade*hp_per_upgrade

	unit:SetBaseDamageMin(base_dmg + unit_upgrade*dmg_per_upgrade )
	unit:SetBaseDamageMax(base_dmg + unit_upgrade*dmg_per_upgrade )				
	unit:SetPhysicalArmorBaseValue(base_armor + unit_upgrade*armor_per_upgrade )
	unit:SetMaxHealth( new_hp )
	unit:SetBaseMaxHealth( new_hp )
	unit:SetHealth( new_hp )
	
	ability:ApplyDataDrivenModifier(caster, unit, "modifier_greevil_egg_bonus", nil)

end
function UpgradeGreevil( event )
	local player = event.caster:GetPlayerOwnerID()
	local ability = event.ability
	local gold_cost = ability:GetSpecialValueFor("gold_cost")
	local player_gold = PlayerResource:GetGold(player)
	local player_reliable_gold = PlayerResource:GetReliableGold(player)
			
	if player_gold < gold_cost then
		return
	end
	
	if player_reliable_gold< gold_cost then
		PlayerResource:ModifyGold(player, -player_reliable_gold, true, 0)
		PlayerResource:ModifyGold(player, player_reliable_gold - gold_cost, false, 0)
	else
		PlayerResource:ModifyGold(player, -gold_cost, true, 0)
	end
	
	unit_upgrade = unit_upgrade + 1

end


