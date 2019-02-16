--[[
	Author: Noya
	Date: 18.01.2015.
	Creates Illusions, making use of the built in modifier_illusion
	Note: The positions weren't random in the original ability. Fix later
]]
--[[
	Author: Ractidous
	Date: 27.01.2015.
	Fixed the random spawn positions.
]]
function MirrorImage( event )
	local caster = event.caster
	local player = caster:GetPlayerOwnerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor( "images_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "incoming_damage", ability:GetLevel() - 1 )

	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()

	print("Illusion[1]")
	-- Stop any actions of the caster otherwise its obvious which unit is real
	caster:Stop()

	-- Initialize the illusion table to keep track of the units created by the spell
	if not caster.mirror_image_illusions then
		caster.mirror_image_illusions = {}
	end

	-- Kill the old images
	for k,v in pairs(caster.mirror_image_illusions) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
		end
	end
	print("Illusion[2]")
	-- Start a clean illusion table
	caster.mirror_image_illusions = {}

	-- Setup a table of potential spawn positions
	local vRandomSpawnPos = {
		Vector( 72, 0, 0 ),		-- North
		Vector( 0, 72, 0 ),		-- East
		Vector( -72, 0, 0 ),	-- South
		Vector( 0, -72, 0 ),	-- West
	}

	for i=#vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
		local j = RandomInt( 1, i )
		vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
	end
	print("Illusion[3]")
	-- Insert the center position and make sure that at least one of the units will be spawned on there.
	table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )

	-- At first, move the main hero to one of the random spawn positions.
	FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )
	print("Illusion[4]")
	-- Spawn illusions
	for i=1, images_count do
		print("Illusion[5]_" .. i)
		local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )
		print("Illusion[5_1]_" .. i)
		-- handle_UnitOwner needs to be nil, else it will crash the game.
		--PrecacheUnitByNameAsync(unit_name, function()
			--local illusion = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
			print("illusion[6_1]_"..i)
			--CreateUnitByName("npc_dota_neutral_ghost", Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
			local illusion = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
			print("illusion[6_2]_"..i)
			print("illusion[6_3]_"..i)
			illusion:SetPlayerID(caster:GetPlayerOwnerID())
			illusion:SetControllableByPlayer(player, true)
			illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
			
			-- Level Up the unit to the casters level
			local casterLevel = caster:GetLevel()
			for i=1,casterLevel-1 do
				illusion:HeroLevelUp(false)
			end
			
			-- Set the skill points to 0 and learn the skills of the caster
			illusion:SetAbilityPoints(0)
			
			for abilitySlot=0,15 do
				local ability = caster:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion:FindAbilityByName(abilityName)
					illusionAbility:SetLevel(abilityLevel)
				end
			end
			
			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					local newItem = CreateItem(itemName, illusion, illusion)
					illusion:AddItem(newItem)
				end
			end
			
		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
			illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
			--illusion:AddNewModifier(caster, ability, "modifier_medical_tractate", null)
			illusion:SetBaseStrength( caster:GetBaseStrength() )
			illusion:SetBaseAgility( caster:GetBaseAgility() )
			illusion:SetBaseIntellect( caster:GetBaseIntellect() )
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
			illusion:MakeIllusion()
		-- Set the illusion hp to be the same as the caster
			illusion:SetHealth(caster:GetHealth())
			--hero:AddNewModifier(hero, nil, "modifier_stun", {duration = DUEL_NOBODY_WINS})
			illusion:RemoveModifierByName("modifier_stun")
		-- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
			print("Illusion[7]_" .. i)
			table.insert(caster.mirror_image_illusions, illusion)
	--	end)
	end
end