--[[Author: Pizzalol
	Date: 11.03.2015.
	Increases attack speed if attacking the same target over and over]]
function Fervor( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local modifier2 = keys.modifier2
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)
    local stack_count = caster:GetModifierStackCount(modifier, ability)

			if caster:HasModifier(modifier2) then
				-- Get the current stacks
				

				-- Check if the current stacks are lower than the maximum allowed
				if stack_count < max_stacks then
					-- Increase the count if they are
					caster:SetModifierStackCount(modifier, ability, stack_count + 1)
				end
				if stack_count == max_stacks then
					-- Increase the count if they are
				ability:RemoveModifierByName(modifier2)
				caster:SetModifierStackCount(modifier, ability, 1)
				end
			else
				-- Apply the attack speed modifier and set the starting stack number
				ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
				caster:SetModifierStackCount(modifier, ability, 1)
			end

end



--[[
	Author: kritth
	Date: 10.01.2015.
	Reflect damage
]]
function spiked_carapace_reflect( keys )
	-- Variables
	local caster = keys.caster
	local attacker = keys.attacker
	local reflectdamage = keys.DamageTaken
    local target = keys.target
	local ability = keys.ability
	local particleName = "particles/units/heroes/hero_vengeful/vengeful_base_attack.vpcf"
	local projectileSpeed = 1200
	local projectileDodgable = false
	local projectileProvidesVision = false
	ability.radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)

	caster:SetHealth(caster:GetHealth() + reflectdamage)
	
	-- Check if it's not already been hit
	--[[local units = FindUnitsInRadius(caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil,
		ability.radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY,
	    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_ANY_ORDER,
	   false)
	reflecttarget = units 
	local count = 0
	for k, v in pairs( units ) do
		if count < 1 then
			local projTable = {
				Target = v,
				Source = caster,
				Ability = ability,
				EffectName = particleName,
				bDodgeable = projectileDodgable,
				bProvidesVision = projectileProvidesVision,
				iMoveSpeed = projectileSpeed, 
				vSpawnOrigin = caster:GetAbsOrigin()
			}
			ProjectileManager:CreateTrackingProjectile( projTable )
			count = count + 1
		else
			break
		end
end]]

end

function reflectHit( keys )
	local caster = keys.caster
	local target = reflecttarget
	local ability = keys.ability

	local damage = reflectdamage



		-- Initialize the damage table and deal damage to the target
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage

		ApplyDamage(damage_table)
	end

function CalculateDamage( keys )
	local ability = keys.ability
	local damage_taken = keys.DamageTaken
	local backtrack_time = keys.BacktrackTime
	
	-- Temporary damage array and index
	local temp = {}
	local temp_index = 0
	
	-- Global damage array and index
	local caster_index = 0
	if ability.caster_damage == nil then
		ability.caster_damage = {}
	end
	
	-- Sets the damage and game time values in the tempororary array, if void was attacked within 2 seconds of current time
	while ability.caster_damage do
		if ability.caster_damage[caster_index] == nil then
		break
		elseif Time() - ability.caster_damage[caster_index+1] <= backtrack_time then
			temp[temp_index] = ability.caster_damage[caster_index]
			temp[temp_index+1] = ability.caster_damage[caster_index+1]
			temp_index = temp_index + 2
		end
		caster_index = caster_index + 2
	end
	
	-- Places most recent damage and current time in the temporary array
	temp[temp_index] = damage_taken
	temp[temp_index+1] = Time()
	
	-- Sets the global array as the temporary array
	ability.caster_damage = temp
end
	function RemoveDamage ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local backtrack_time = keys.backtracktime
	local damage_sum = 0
	local caster_index = 0
	local reflect_duration = ability:GetLevelSpecialValueFor( "reflect_duration", ability:GetLevel() - 1 )
	local add_duration = ability:GetLevelSpecialValueFor("add_duration", ability:GetLevel() - 1)
	
	-- Sums damage over the last 2 seconds
	while ability.caster_damage do
		if ability.caster_damage[caster_index] == nil then
		break
		elseif Time() - ability.caster_damage[caster_index+1] <= backtrack_time then
			damage_sum = damage_sum + ability.caster_damage[caster_index]
		end
		caster_index = caster_index + 2
	end
	
	-- Adds damage to caster's current health
	caster:SetHealth(caster:GetHealth() + damage_sum)

	if caster:HasModifier("modifier_kanade_talent_1") then
		local duration = reflect_duration + add_duration
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_spiked_carapace_buff_datadriven", { duration = duration })

	else
	local duration = reflect_duration
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_spiked_carapace_buff_datadriven", { duration = duration })
	end
end

function BlinkStrike( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	-- local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", ability_level)
	local victim_angle = target:GetAnglesAsVector()
	local victim_forward_vector = target:GetForwardVector()
	
	-- Angle and positioning variables
	local victim_angle_rad = victim_angle.y*math.pi/180
	local victim_position = target:GetAbsOrigin()
	local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
	-- print( "dummydealykilling" )
	-- dummydealy:RemoveSelf()
	
	-- Sets Riki behind the victim and facing it
	caster:SetAbsOrigin(attacker_new)
	FindClearSpaceForUnit(caster, attacker_new, true)
	caster:SetForwardVector(victim_forward_vector)
	
	
	-- Order the caster to attack the target
	-- Necessary on jumps to allies as well (does not actually attack), otherwise Riki will turn back to his initial angle
	order = 
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = ability,
		Queue = true
	}

	ExecuteOrderFromTable(order)
end

function quickattack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	
	-- Order the caster to attack the target
	-- Necessary on jumps to allies as well (does not actually attack), otherwise Riki will turn back to his initial angle
	order = 
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = ability,
		Queue = true
	}

	ExecuteOrderFromTable(order)
end

function DoppelgangerStart( keys )
	local target = keys.target
    local caster = keys.caster
	local ability = keys.ability
	-- Basic Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	local origin = caster:GetAbsOrigin()
	local dummyModifierName = "modifier_dealy_dummy"
	local castert = caster:GetAbsOrigin()
	caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
    local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	local modifierName = "modifier_dealy_counter"
	-- Removes the unit's model
	target:AddNoDraw()

	-- dummydealy = CreateUnitByName( caster:GetName(), castert, false, caster, nil, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )

	-- Deplete charge
		local next_charge = caster.shrapnel_charges - 1
		if caster.shrapnel_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			shrapnel_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.shrapnel_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.shrapnel_charges == 0 then
			-- Start Cooldown from caster.shrapnel_cooldown
			ability:StartCooldown( caster.shrapnel_cooldown )
		else
			ability:EndCooldown()
		end
		-- Hide the hero underground
	local underground_position = Vector(origin.x, origin.y, origin.z - 322)
	caster:SetAbsOrigin(underground_position)
end

function dealy_charge( keys )
	-- Only start charging at level 1
	if keys.ability:GetLevel() ~= 1 then return end

	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_dealy_counter"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.shrapnel_charges = maximum_charges
	caster.start_charge = false
	caster.shrapnel_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, maximum_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.shrapnel_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.shrapnel_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
					shrapnel_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
				-- Update stack
				caster.shrapnel_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.shrapnel_charges ~= maximum_charges then
				caster.start_charge = true
				return charge_replenish_time
			else
				return 0.5
			end
		end
	)
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Helper: Create timer to track cooldown
]]
function shrapnel_start_cooldown( caster, charge_replenish_time )
	caster.shrapnel_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.shrapnel_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.shrapnel_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function shrapnel_fire( keys )
	-- Reduce stack if more than 0 else refund mana
	if keys.caster.shrapnel_charges > 0 then
		-- variables
		local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		local casterLoc = caster:GetAbsOrigin()
		local modifierName = "modifier_shrapnel_stack_counter_datadriven"
		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
		local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		
		-- Deplete charge
		local next_charge = caster.shrapnel_charges - 1
		if caster.shrapnel_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			shrapnel_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.shrapnel_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.shrapnel_charges == 0 then
			-- Start Cooldown from caster.shrapnel_cooldown
			ability:StartCooldown( caster.shrapnel_cooldown )
		else
			ability:EndCooldown()
		end
		
		-- Create particle at caster
		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
		StartSoundEvent( launch_sound_name, caster )
		
		-- Deal damage
		shrapnel_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )
	else
		keys.ability:RefundManaCost()
	end
end

function CheckBackstab(params)
	
	local ability = params.ability
	local caster = params.caster
	local target = params.target
	local attackspeed = caster:GetAttackSpeed()
	print(caster:GetAttackSpeed())
	-- Get the maximum attack speed for units.
	local attackspeeddamage = 1.6 * caster:GetAttackSpeed() - 1
	if attackspeeddamage < 0 then
	local attackspeeddamage = 0
	end
	local agility_damage_multiplier = ability:GetLevelSpecialValueFor("agility_damage", ability:GetLevel() - 1) 
	local agility_damage_echo_sabre = ability:GetLevelSpecialValueFor("echo_sabre", ability:GetLevel() - 1) 
	local sonic_damge = caster:GetBaseAgility() * agility_damage_echo_sabre  
	local damge = attackspeeddamage * agility_damage_multiplier
	if caster:HasItemInInventory("item_echo_sabre") or caster:HasModifier("modifier_kanade_talent_2")  then
	ApplyDamage({victim = target, attacker = caster, damage = sonic_damge, damage_type = ability:GetAbilityDamageType()})     
	print("sonic_damge =",sonic_damge)                                          
	else
    ApplyDamage({victim = target, attacker = caster, damage = damge, damage_type = ability:GetAbilityDamageType()})
	print("damge =",damge)
	end
	print("attackspeeddamage =",attackspeeddamage)
	
	local random = RandomFloat(0, 1)
	print(random)
	local modifier_hand_sonic_3 = params.modifier_hand_sonic_3
	local modifier_hand_sonic_4 = params.modifier_hand_sonic_4
	local modifier_hand_sonic_5 = params.modifier_hand_sonic_5
	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	--local victim_angle = params.target:GetAnglesAsVector().y
	--local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	--local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	--origin_difference_radian = origin_difference_radian * 180
	--local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	--attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	--local result_angle = attacker_angle - victim_angle
	--result_angle = math.abs(result_angle)
	
	-- Check for the backstab angle.
	--if result_angle >= (180 - (ability:GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("backstab_angle") / 2)) then 
		-- Play the sound on the victim.
		-- EmitSoundOn(params.sound, params.target)
		-- Create the back particle effect.
		local particle = ParticleManager:CreateParticle(params.particle, PATTACH_ABSORIGIN_FOLLOW, params.target) 
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
		ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 
		--Apply extra backstab damage based on Riki's agility
	--else
		--EmitSoundOn(params.sound2, params.target)
		-- uncomment this if regular (non-backstab) attack has no sound
	--end
	if caster:HasItemInInventory("item_echo_sabre") or caster:HasModifier("modifier_kanade_talent_2")  then
   if random < 0.5 then
   ability:ApplyDataDrivenModifier(caster, caster, modifier_hand_sonic_3, {})
    end
	 if random < 0.6 and 0.5 < random then
   ability:ApplyDataDrivenModifier(caster, caster, modifier_hand_sonic_4, {})
    end
	if 0.85 < random then
   ability:ApplyDataDrivenModifier(caster, caster, modifier_hand_sonic_5, {})
    end
 end
	
end

--[[
	Author: Noya
	Date: 21.01.2015.
	Primal Split
]]

-- Starts the ability
function PrimalSplit( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1 )
	local level = ability:GetLevel()
	local levelup = ability:GetLevel() - 1
    local levelup = ability:GetLevel() - 1
	local casterAngles = caster:GetAngles()
	local outgoingDamage = ability:GetLevelSpecialValueFor( "outgoing_damage", ability:GetLevel() - 1 ) - 100
	local incomingDamage = ability:GetLevelSpecialValueFor( "incoming_damage", ability:GetLevel() - 1 ) - 100
	--[[ Ability variables
	 local red_eye_damage = ability:GetLevelSpecialValueFor("red_eye_damage", levelup) 
	 local red_eye_hp = ability:GetLevelSpecialValueFor("red_eye_hp", levelup) 
	local red_eye_armor = ability:GetLevelSpecialValueFor("red_eye_armor", levelup) 
	local sred_eye_attack_range = ability:GetLevelSpecialValueFor("sred_eye_range", levelup) 
	 local red_eye_mana = ability:GetLevelSpecialValueFor("red_eye_mana", levelup) 
	 local red_eye_duration = ability:GetLevelSpecialValueFor("red_eye_duration", levelup) 
	 local red_eye_count_quas = ability:GetLevelSpecialValueFor("red_eye_count", levelup)
	local red_eye_count_exort = ability:GetLevelSpecialValueFor("red_eye_count", levelup)
]]

	-- Set the unit names to create,concatenated with the level number

	-- STORM
	local unit_name = caster:GetUnitName()
 

	-- Set the positions
	local forwardV = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local distance = 100
	local ang_right = QAngle(0, -90, 0)
    local ang_left = QAngle(0, 90, 0)
	local model = event.model
	local howlling = "howlling"
	local redeye_angel = "redeye_angel"
    local thisabilityLevel = ability:GetLevel()

    local origin = caster:GetAbsOrigin() + RandomVector(100)
	local howlling_handle = caster:FindAbilityByName(howlling)
    howlling_handle:SetLevel(thisabilityLevel)

	if not caster.phantasm_illusions then
		caster.phantasm_illusions = {}
	end

	-- Kill the old images
	for k,v in pairs(caster.phantasm_illusions) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
		end
	end

	-- Start a clean illusion table
	caster.phantasm_illusions = {}
    
	local vRandomSpawnPos = {
		Vector( 72, 0, 0 ),		-- North
		Vector( 0, 72, 0 ),		-- East
		Vector( -72, 0, 0 ),	-- South
		Vector( 0, -72, 0 ),	-- West
	}
	-- Create the units
	red_eye = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    red_eye:SetPlayerID(caster:GetPlayerID())
	
	-- Make them controllable
	red_eye:SetControllableByPlayer(player, true)

	-- Set all of them looking at the same point as the caster
	red_eye:SetForwardVector(forwardV)

	red_eye:SetOriginalModel(model)

	local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			red_eye:HeroLevelUp(false)
		end
        red_eye:SetCanSellItems(false)
		
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, red_eye, red_eye)
				red_eye:AddItem(newItem)
			end
		end

	red_eye:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = red_eye:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
				if illusionAbility == redeye_angel then 
                red_eye:SwapAbilities(howlling, redeye_angel, true, false) 
				howlling:SetLevel(abilityLevel)
				print("SwapAbilities")
				end
			end
		end
        red_eye:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_double", nil)
		red_eye:SwapAbilities(howlling, redeye_angel, true, false)
		caster:SwapAbilities("absorb", "redeye_angel", true, false)
		--red_eye:MakeIllusion()
  if caster:HasModifier("modifier_kanade_talent_3") then
    for i=1,4 do

		local origin1 = origin + table.remove( vRandomSpawnPos, 1 )

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin1, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
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
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Set the illusion hp to be the same as the caster
		illusion:SetHealth(caster:GetHealth())

		-- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
		table.insert(caster.phantasm_illusions, illusion)
	end
  end

end

function LearnAllAbilities( unit, level )

	for i=0,15 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(level)
			print("Set Level "..level.." on "..ability:GetAbilityName())
		end
	end
end

-- When the spell ends, the Brewmaster takes Earth's place. 
-- If Earth is dead he takes Storm's place, and if Storm is dead he takes Fire's place.
function SplitUnitDied( event )
	local caster = event.caster
	local attacker = event.attacker
	local unit = event.unit

	-- Chech which spirits are still alive
	if IsValidEntity(caster.Earth) and caster.Earth:IsAlive() then
		caster.ActiveSplit = caster.Earth
	elseif IsValidEntity(red_eye) and red_eye:IsAlive() then
		caster.ActiveSplit = red_eye
	elseif IsValidEntity(caster.Fire) and caster.Fire:IsAlive() then
		caster.ActiveSplit = caster.Fire
	else
		-- Check if they died because the spell ended, or where killed by an attacker
		-- If the attacker is the same as the unit, it means the summon duration is over.
		if attacker == unit then
			print("Primal Split End Succesfully")
		elseif attacker ~= unit then
			-- Kill the caster with credit to the attacker.
			caster:Kill(nil, attacker)
			caster.ActiveSplit = nil
		end
	end

	if caster.ActiveSplit then
		print(caster.ActiveSplit:GetUnitName() .. " is active now")
	else
		print("All Split Units were killed!")
	end

end

-- While the main spirit is alive, reposition the hero to its position so that auras are carried over.
-- This will also help finding the current Active primal split unit with the hero hotkey
function PrimalSplitAuraMove( event )
	-- Hide the hero underground on the Active Split position
	local caster = event.caster
	local active_split_position = caster.ActiveSplit:GetAbsOrigin()
	local underground_position = Vector(active_split_position.x, active_split_position.y, active_split_position.z - 322)
	caster:SetAbsOrigin(underground_position)

end

-- Ends the the ability, repositioning the hero on the latest active split unit
function PrimalSplitEnd( event )
    local caster = event.caster
	red_eye:RemoveSelf()
	caster:SwapAbilities("absorb", "redeye_angel", false, true)
end

function EchoSlam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local echo_slam_damage_range = ability:GetLevelSpecialValueFor("rage", (ability:GetLevel() -1))
	local echo_slam_echo_search_range = ability:GetLevelSpecialValueFor("rage", (ability:GetLevel() -1))
	local echo_slam_echo_range = ability:GetLevelSpecialValueFor("rage", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	local particle1 = ParticleManager:CreateParticle(keys.particle1, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle1, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle1, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle1, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
			
	-- Renders the echoslam start particle around the caster
	local particle2 = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle2, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle2, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	
	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, echo_slam_damage_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	-- ability:ApplyDataDrivenModifier(caster, initial_units, modifier, {duration = duration})
	--[[
	local is_target = false
	local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
		-- Applies the initial damage to the target
		ApplyDamage({victim = initial_unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
		
		-- Units to receive echo damage
		local units = FindUnitsInRadius(caster:GetTeamNumber(), initial_unit:GetAbsOrigin(), nil, echo_slam_echo_search_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		
		-- Loops through the targets
		for j,unit in ipairs(units) do
			-- Sends the echo projectiles from the initial targets to the echo targets
			local info = 
			{
				Target = unit,
				Source = initial_unit,
				Ability = ability,	
				iMoveSpeed = echo_slam_echo_range,
				vSourceLoc= initial_unit:GetAbsOrigin(),
				bDodgeable = true,
			}
			projectile = ProjectileManager:CreateTrackingProjectile(info)
			is_echo_target = true
		end
		is_target = true
	end
	
	-- Plays the appropriate sounds
	if is_target == true then
		EmitSoundOn(keys.sound1, caster)
	else
		EmitSoundOn(keys.sound2, caster)
	end
	
	if is_echo_target == true then
		EmitSoundOn(keys.sound3, caster)
	else
		EmitSoundOn(keys.sound3, caster)
	end
	]]
end

--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Applies the echo damage to the targets]]
function ApplyEchoDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local echo_slam_echo_damage = ability:GetLevelSpecialValueFor("echo_slam_echo_damage", (ability:GetLevel() -1))
	
	ApplyDamage({victim = target, attacker = caster, damage = echo_slam_echo_damage, damage_type = ability:GetAbilityDamageType()})
end


