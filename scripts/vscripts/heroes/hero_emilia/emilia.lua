--[[
	Author: Ractidous
	Date: 28.01.2015.
	Remove fire spirits' FX.
]]
function RemoveFireSpirits( event )
	local caster	= event.caster
	local ability	= event.ability
    
	local pfx = caster.pfx
	print("pfx =",caster.pfx)
	ParticleManager:DestroyParticle( pfx, false )
end

--[[
	冰锥
]]
function CastIllusoryOrb( event )
	
	local caster	= event.caster
	local ability	= event.ability
	local point		= event.target_points[1]

	local radius			= event.radius
	local maxDist			= event.max_distance
	local orbSpeed			= event.orb_speed
	local visionRadius		= event.orb_vision
	local visionDuration	= event.vision_duration
	local numExtraVisions	= event.num_extra_visions

	local travelDuration	= maxDist / orbSpeed
	local extraVisionInterval = travelDuration / numExtraVisions

	local casterOrigin		= caster:GetAbsOrigin()
	local targetDirection	= ( ( point - casterOrigin ) * Vector(1,1,0) ):Normalized()
	local projVelocity		= targetDirection * orbSpeed

	local startTime		= GameRules:GetGameTime()
	local endTime		= startTime + travelDuration

	local numExtraVisionsCreated = 0
	local isKilled		= false

	local modifierName	= event.modifier_stack_name

    if caster:HasModifier( "modifier_temperature_mastery") then
	ability.pfx = event.red
	else
	ability.pfx = event.proj_particle
	end

	print("pfx =",ability.pfx)
	-- Make Ethereal Jaunt active
	-- local etherealJauntAbility = ability.illusory_orb_etherealJauntAbility
	-- etherealJauntAbility:SetActivated( true )

	-- Create linear projectile
	local projID = ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= ability.pfx,
		vSpawnOrigin		= casterOrigin,
		fDistance			= maxDist,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= endTime,
		bDeleteOnHit		= false,
		vVelocity			= projVelocity,
		bProvidesVision		= true,
		iVisionRadius		= visionRadius,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

end
--冰盾
function iceshield( event )
	-- Variables
	local caster	= event.caster
	local attacker = event.attacker
	local ability	= event.ability
	local attacker = event.attacker
	local damage = event.damagetaken

	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = caster:GetAnglesAsVector().y
	local origin_difference = caster:GetAbsOrigin() - attacker:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)
	
	-- Check for the backstab angle.
	if result_angle >= (180 - (ability:GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("backstab_angle") / 2)) then 
		print("islose")
	else
		-- Play the sound on the victim.
		EmitSoundOn(event.sound, caster)
		caster:SetHealth(caster:GetHealth() + damage)
	end

end
-- 冰封结界
function setpfx( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
	local target	= event.target
    local vector = event.target_points[1]
	local modifier_burn_area_eff = event.modifier_burn_area_eff
	local modifier_frozen_area_eff = event.modifier_frozen_area_eff
	local modifier_frozen_area_2 = event.modifier_frozen_area_2
       print("vector",vector)
   local flying_vision = ability:GetLevelSpecialValueFor( "flying_vision", ability:GetLevel() - 1 )
   local vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
   local maxStack = ability:GetLevelSpecialValueFor("max", (ability:GetLevel() - 1))
	local remaxStack = 0 - maxStack

	   AddFOWViewer(caster:GetTeam(), vector, flying_vision, vision_duration, false)
     if caster:HasModifier("modifier_temperature_mastery") then
	   if caster.pfx ~= nil then
	    ParticleManager:DestroyParticle( caster.pfx , false )
		end
	   local particleName = "particles/units/heroes/emiliya/fire_acid_spray.vpcf"
	   caster.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, target )
	   --print("caster.pfx",caster.pfx)
	   ParticleManager:SetParticleControl( caster.pfx , 0, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 1, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 15, Vector(255, 255, 255) )
	   ParticleManager:SetParticleControl( caster.pfx , 16, vector )
	   else
	   if caster.pfx ~= nil then
	    ParticleManager:DestroyParticle( caster.pfx , false )
		end
		
	   local particleName = "particles/units/heroes/emiliya/ice_acid_spray.vpcf"
	  -- print("particleName =",particleName)
	   caster.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, target )
	   --print("caster.pfx",caster.pfx)
	   ParticleManager:SetParticleControl( caster.pfx , 0, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 1, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 15, Vector(255, 255, 255) )
	   ParticleManager:SetParticleControl( caster.pfx , 16, vector )
	   end
-- Find all the valid units in radius
	local units = FindUnitsInRadius(caster:GetTeamNumber(), vector, nil, flying_vision, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, FIND_CLOSEST, false)
    --print("setpfx unit")
	--DeepPrintTable(units)
	for _,unit in ipairs(units) do
	   if unit.emiliatm == nil then
	   unit.emiliatm = 0
	   end

       print("unit",unit:GetUnitName())
	   ability:ApplyDataDrivenModifier(caster, unit, modifier_frozen_area_eff, {})
     if caster:HasModifier("modifier_temperature_mastery") then
	   EmitSoundOn('Hero_Ancient_Apparition.ColdFeetTick', unit)
	   unit:RemoveModifierByName("modifier_frozen_area_eff") 
	   unit:RemoveModifierByName("modifier_frozen_area_2") 
			unit.emiliatm = unit.emiliatm + 1
			print("unit.emiliatm",unit.emiliatm)
			if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
			print("maxStack",maxStack)
			if remaxStack <= unit.emiliatm and unit.emiliatm <= maxStack then
	        ability:ApplyDataDrivenModifier(caster, unit, modifier_burn_area_eff, {})
            end
			end
	   else
	   unit:RemoveModifierByName("modifier_burn_area_eff") 
			unit.emiliatm = unit.emiliatm - 1
			EmitSoundOn('Hero_Huskar.Burning_Spear', unit)
			print("unit.emiliatm",unit.emiliatm)
			if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
			print("remaxStack",remaxStack)
			if remaxStack <= unit.emiliatm and unit.emiliatm <= maxStack then
            print("unit",unit:GetUnitName())
			print("modifier_frozen_area_eff",modifier_frozen_area_eff)
	        ability:ApplyDataDrivenModifier(caster, unit, "modifier_frozen_area_eff", {})
			elseif unit.emiliatm < remaxStack then
			print("unit",unit:GetUnitName())
			ability:ApplyDataDrivenModifier(caster, unit, modifier_frozen_area_2, {})
			unit.emiliatm = remaxStack
			elseif unit.emiliatm > maxStack then
			unit.emiliatm = maxStack
            end
			end
	   end
	end
end

function GiveVision(keys)
	caster = keys.caster
	ability = keys.ability
	local flying_vision = ability:GetLevelSpecialValueFor( "flying_vision", ability:GetLevel() - 1 )
	local vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	
	AddFOWViewer(caster:GetTeam(), ability:GetCursorPosition(), flying_vision, vision_duration, false)
end

function fireice( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target
	local ability	= event.ability
	local manamutilate = ability:GetLevelSpecialValueFor("manamutilate", (ability:GetLevel() -1))
	local mana = caster:GetMana()
	local manadamage = mana * manamutilate
  if caster:HasModifier("modifier_emilia_talent_2") then
   ApplyDamage(
                        {
                            victim = target, 
                            attacker = caster, 
                            damage = manadamage, 
                            damage_type = ability:GetAbilityDamageType()}
                        )

       end
     if caster:HasModifier("modifier_temperature_mastery") then
	        ability:ApplyDataDrivenModifier(caster, target, "modifier_control_temperature_4", {})
	   else
	        ability:ApplyDataDrivenModifier(caster, target, "modifier_control_temperature_5", {})
	   end
end


function shotfireice( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability

       
     if caster:HasModifier("modifier_temperature_mastery") then
	   --EmitSoundOn('Hero_Ancient_Apparition.ColdFeetTick', target)
	   caster:RemoveModifierByName("modifier_control_temperature") 
	        ability:ApplyDataDrivenModifier(caster, caster, "modifier_control_temperature_2", {})
	   else
			--EmitSoundOn('Hero_Huskar.Burning_Spear', target)
			 caster:RemoveModifierByName("modifier_control_temperature_2") 
	        ability:ApplyDataDrivenModifier(caster, caster, "modifier_control_temperature", {})
	   end
end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Upgrade the sub ability and make inactive it.
]]
function OnUpgrade( event )
	local caster	= event.caster
	local ability	= event.ability
	local etherealJauntAbility = caster:FindAbilityByName( event.sub_ability )
	ability.illusory_orb_etherealJauntAbility = etherealJauntAbility

	if not etherealJauntAbility then
		print( "Ethereal jaunt not found. at heroes/hero_puck/illusory_orb.lua # OnUpgrade" )
		return
	end

	etherealJauntAbility:SetLevel( ability:GetLevel() )

	if etherealJauntAbility:GetLevel() == 1 then
		etherealJauntAbility:SetActivated( false )
	end
end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Cast Ethereal Jaunt.
]]
function CastEtherealJaunt( event )
	local ability = event.ability
	if ability.etherealJaunt_cast then
		ability.etherealJaunt_cast()
	end
end



--[[
	Author: Ractidous
	Date: 13.02.2015.
	Stop a sound on the target unit.
]]
function intdamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local damage = caster:GetIntellect()
	print("damage =",damage)
	if caster:HasModifier("modifier_emilia_talent_2") then
	local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage

		ApplyDamage(damage_table)
	end

end
---治疗
function waterheal( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
    local vector = caster:GetAbsOrigin()

	   local particleName = "particles/units/heroes/emiliya/ti7_radiant_tower_lvl11_orb.vpcf"
	  -- print("particleName =",particleName)
	   caster.pfx = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	   ParticleManager:SetParticleControlEnt(caster.pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", vector, true)
	   ParticleManager:SetParticleControlEnt(caster.pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hand", vector, true)
	   ParticleManager:SetParticleControl( caster.pfx , 2, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 3, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 4, vector )
end

---千里冰封

function ApplyFFFModifier (keys)

    local caster = keys.caster
	local ability = keys.ability
	local max_range = ability:GetLevelSpecialValueFor("max_radius", (ability:GetLevel() -1))
	local incrsing = ability:GetLevelSpecialValueFor("incrsing", (ability:GetLevel() -1))
	-- local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	if caster.emt_range == nil then
	caster.emt_range = 800
    else
	if caster.emt_range < 3000 then
    caster.emt_range = caster.emt_range + incrsing
	else
	caster.emt_range = 3000
	end
    end

    local startPos = caster:GetAbsOrigin()

    
    if caster.fmpfx ~= nil then
	ParticleManager:DestroyParticle( caster.fmpfx, false )
	end

	local particleName1 = "particles/units/heroes/emiliya/alchemist_acid_spray_j.vpcf"
    local particleName2 = "particles/units/heroes/emiliya/fire_acid_spray_j.vpcf"
	if caster:HasModifier("modifier_temperature_mastery") then
	caster.fmpfx = ParticleManager:CreateParticle( particleName2, PATTACH_CUSTOMORIGIN, caster )
	else
	caster.fmpfx = ParticleManager:CreateParticle( particleName1, PATTACH_CUSTOMORIGIN, caster )
	end
	ParticleManager:SetParticleControl( caster.fmpfx, 0, startPos )
	ParticleManager:SetParticleControl( caster.fmpfx, 1, Vector( caster.emt_range, caster.emt_range, caster.emt_range ) )
	ParticleManager:SetParticleControl( caster.fmpfx, 2, Vector( 255, 255, 255 ) )
	ParticleManager:SetParticleControl( caster.fmpfx, 16, Vector( 1, 0, 0 ) )

--[[
    local particleName1 = "particles/units/leshrac_split_earth.vpcf"
	local pfx1 = ParticleManager:CreateParticle( particleName1, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx1, 0, startPos )
	ParticleManager:SetParticleControl( pfx1, 1, Vector( fff_range, fff_range, fff_range ) )
    -- ParticleManager:SetParticleControl( pfx1, 15, Vector( 1, 1, 1 ) )
	-- ParticleManager:SetParticleControl( pfx1, 16, Vector( 0, 0, 0 ) )
]]
	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, caster.emt_range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() , 0, false)
    -- ApplyDamage({victim = units, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- local is_target = false
	-- local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
	if initial_unit ~= caster then
	if caster:HasModifier("modifier_temperature_mastery") then
	    if not initial_unit:HasModifier("modifier_burn") then
	   ability:ApplyDataDrivenModifier( caster, initial_unit, "modifier_burn", {} )
	   end
       else
		if not initial_unit:HasModifier("modifier_frozen") then
	   ability:ApplyDataDrivenModifier( caster, initial_unit, "modifier_frozen", {} )
	   end
      end
	  end
	end  

	--ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
end

function removeFModifier (keys)

    local caster = keys.caster
	local ability = keys.ability
	local max_range = ability:GetLevelSpecialValueFor("max_radius", (ability:GetLevel() -1))
    local startPos = caster:GetAbsOrigin()
    if caster.fmpfx ~= nil then
	ParticleManager:DestroyParticle( pfx, false )
	end

	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, max_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() , 0, false)
    -- ApplyDamage({victim = units, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- local is_target = false
	-- local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
        initial_unit:RemoveModifierByName("modifier_frozen") 
		initial_unit:RemoveModifierByName("modifier_burn") 

	end  

	--ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
end
function emt_range (keys)
local caster = keys.caster
caster.emt_range = nil
ParticleManager:DestroyParticle( caster.fmpfx, false )
caster.fmpfx = nil
end


function WeaveIncrement( keys )
    local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local modifier = "modifier_frozen"
	local modifier1 = "modifier_burn"
	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()
	local casterDir = casterOrigin - targetOrigin
	local distToAlly = casterDir:Length2D()
    local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	local max = ability:GetLevelSpecialValueFor("max", (ability:GetLevel() -1))
	local current_stack = target:GetModifierStackCount(modifier,caster)
	local current_stack1 = target:GetModifierStackCount(modifier1,caster)
	print("caster.emt_range",caster.emt_range)
	print("distToAlly",distToAlly)
	if  caster.emt_range == nil then
	if target:HasModifier(modifier1) then
	print("current_stack1",target:GetModifierStackCount(modifier1,caster))
	print("current_stack",target:GetModifierStackCount(modifier,caster))
  if current_stack1 < 1 then
  target:RemoveModifierByName(modifier1) 
  else
  target:SetModifierStackCount(modifier1,caster,current_stack1 - 1)
  end
  end

  if target:HasModifier(modifier) then
  print("current_stack1",target:GetModifierStackCount(modifier,target))
  if current_stack < 1 then
  target:RemoveModifierByName(modifier) 
  else
  target:SetModifierStackCount(modifier,caster,current_stack - 1)
  target:RemoveModifierByName("modifier_frozen_miles_2") 
  end
  end
	else  
  if caster.emt_range >= distToAlly then
	if caster:HasModifier("modifier_temperature_mastery") then
	    if target:HasModifier(modifier1) then
		print("current_stack1",current_stack1)
		   if current_stack1 < 1 then
		    target:SetModifierStackCount(modifier1,caster,2)
			print("target",target:GetUnitName())
		    ApplyDamage({victim = target, attacker = caster, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
	       else
		   print("max",max)
		   if current_stack1 < max then
		    target:SetModifierStackCount(modifier1,caster,current_stack1 + 1)
			ApplyDamage({victim = target, attacker = caster, ability = ability, damage = damage * current_stack1, damage_type = ability:GetAbilityDamageType()})
			else
			target:SetModifierStackCount(modifier1,caster,max)
			ApplyDamage({victim = target, attacker = caster, ability = ability, damage = damage *  max, damage_type = ability:GetAbilityDamageType()})
			end
	       end
		 else
		 if current_stack < 1 then
		    target:RemoveModifierByName("modifier_frozen") 
			ability:ApplyDataDrivenModifier( caster, target, "modifier_burn", {} )
	       else
		   target:RemoveModifierByName("modifier_frozen_miles_2") 
		    target:SetModifierStackCount(modifier,caster,current_stack - 1)
	       end
		end
	else
	if target:HasModifier(modifier) then
	print("current_stack",current_stack)
		   if current_stack < 1 then
		    target:SetModifierStackCount(modifier,caster,2)
		
	       else
		   if current_stack < max then
		    target:SetModifierStackCount(modifier,caster,current_stack + 1)
			else
			target:SetModifierStackCount(modifier,caster,max)
			ability:ApplyDataDrivenModifier( caster, target, "modifier_frozen_miles_2", {} )
			end
	       end
		 else
		 if current_stack1 < 1 then
		    target:RemoveModifierByName("modifier_burn") 
			ability:ApplyDataDrivenModifier( caster, target, "modifier_frozen", {} )
	       else
		    target:SetModifierStackCount(modifier,caster,current_stack1 - 1)
	       end
		end
	end
  else
  if caster:HasModifier(modifier1) then
  if current_stack1 < 1 then
  target:RemoveModifierByName(modifier1) 
  else
  target:SetModifierStackCount(modifier1,caster,current_stack1 - 1)
  end
  end

  if caster:HasModifier(modifier) then
  if current_stack < 1 then
  target:RemoveModifierByName(modifier) 
  else
  target:SetModifierStackCount(modifier,caster,current_stack - 1)
  end
  end
end
end

end

---近战法师

function meelattack( keys )
	local caster = keys.caster

	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function blockdamage( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
	local damage = event.attackdamage


		EmitSoundOn(event.sound, caster)
		caster:SetHealth(caster:GetHealth() + damage)


end