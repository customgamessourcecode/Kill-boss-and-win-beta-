tower_upgrade = 0

function BuildUpgradeTower( event )
	local point = event.target_points[1]
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local origin = caster:GetAbsOrigin() + RandomVector(100)

	local base_hp = ability:GetSpecialValueFor("base_hp")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local base_armor = ability:GetSpecialValueFor("base_armor")
	local hp_per_upgrade = ability:GetSpecialValueFor("hp_per_upgrade")
	local dmg_per_upgrade = ability:GetSpecialValueFor("dmg_per_upgrade")
	local armor_per_upgrade = ability:GetSpecialValueFor("armor_per_upgrade") 
	
	-- Set the unit name, concatenated with the level number
	local unit_name = "npc_dota_greevil_lord_upgradable_tower"

	if caster.tower and IsValidEntity(caster.tower) then
		caster.tower:RemoveSelf()
	end
	
	-- Check if the bear is alive, heals and spawns them near the caster if it is
	-- Create the unit and make it controllable
	caster.tower = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())
	caster.tower:SetControllableByPlayer(player, true)
	caster.tower:AddNewModifier(caster,ability,"modifier_phased",{duration = 0.1})

	local new_hp = base_hp + tower_upgrade*hp_per_upgrade

	caster.tower:SetBaseDamageMin(base_dmg + tower_upgrade*dmg_per_upgrade )
	caster.tower:SetBaseDamageMax(base_dmg + tower_upgrade*dmg_per_upgrade )				
	caster.tower:SetPhysicalArmorBaseValue(base_armor + tower_upgrade*armor_per_upgrade )
	caster.tower:SetMaxHealth( new_hp )
	caster.tower:SetBaseMaxHealth( new_hp )
	caster.tower:SetHealth( new_hp )
end

function BuildTower( event )
	local point = event.target_points[1]
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local unit_name = "npc_dota_greevil_lord_tower"

	
	local base_hp = ability:GetSpecialValueFor("base_hp")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local base_armor = ability:GetSpecialValueFor("base_armor")
	local hp_per_upgrade = ability:GetSpecialValueFor("hp_per_upgrade")
	local dmg_per_upgrade = ability:GetSpecialValueFor("dmg_per_upgrade")
	local armor_per_upgrade = ability:GetSpecialValueFor("armor_per_upgrade") 
	local duration = ability:GetSpecialValueFor("duration") 
	
	
	local tower = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())
	tower:SetControllableByPlayer(player, true)
	tower:AddNewModifier(caster,ability,"modifier_kill",{duration = duration})
	tower:AddNewModifier(caster,ability,"modifier_phased",{duration = 0.1})

	local strenght = caster:GetStrength()
	local agility = caster:GetAgility()
	local intellegence = caster:GetIntellect()
	local new_hp = base_hp + tower_upgrade*hp_per_upgrade

	tower:SetBaseDamageMin(base_dmg + tower_upgrade*dmg_per_upgrade )
	tower:SetBaseDamageMax(base_dmg + tower_upgrade*dmg_per_upgrade )				
	tower:SetPhysicalArmorBaseValue(base_armor + tower_upgrade*armor_per_upgrade )
	tower:SetMaxHealth( new_hp )
	tower:SetBaseMaxHealth( new_hp )
	tower:SetHealth( new_hp )

	ability:ApplyDataDrivenModifier(caster, tower, "modifier_tower_bonus", nil)
	
end

function UpgradeTowers( event )
	local caster = event.caster
	local ability = event.ability
		
	local hp_per_upgrade = ability:GetSpecialValueFor("hp_per_upgrade")
	local dmg_per_upgrade = ability:GetSpecialValueFor("dmg_per_upgrade")
	local armor_per_upgrade = ability:GetSpecialValueFor("armor_per_upgrade") 

	local player = caster:GetPlayerOwnerID()
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
	
	tower_upgrade = tower_upgrade + 1
	
	local new_hp = caster:GetMaxHealth() + hp_per_upgrade

	caster:SetBaseDamageMin(caster:GetBaseDamageMin() + dmg_per_upgrade )
	caster:SetBaseDamageMax(caster:GetBaseDamageMax() + dmg_per_upgrade )				
	caster:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorBaseValue() + armor_per_upgrade )
	caster:SetMaxHealth( new_hp )
	caster:SetBaseMaxHealth( new_hp )
end

function KillWolves( event )
	local caster = event.caster
	local targets = caster.wolves or {}
for _,unit in pairs(targets) do	
	if unit and IsValidEntity(unit) then
		unit:ForceKill(true)
		end
	end
-- Reset table
caster.wolves = {}
end

