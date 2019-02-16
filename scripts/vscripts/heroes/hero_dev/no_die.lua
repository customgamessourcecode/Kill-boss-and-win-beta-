function Check(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local caster_cur = caster:GetCursorPosition()
	local damage_type = ability:GetAbilityDamageType()
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster_cur, nil, radius, target_teams, target_types, target_flags, 0, false)
	for i,unit in ipairs(units) do
		ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = damage_type })
	end
end

function AgilityDamage( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local casterAG = caster:GetAgility()
	local AG = ability:GetLevelSpecialValueFor( "agilitydamage" , ability:GetLevel() - 1  ) * 0.01
	local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1  )
	local damageType = ability:GetAbilityDamageType()
	local return_damage = damage + ( casterAG * AG )
	ApplyDamage({ victim = target, attacker = caster, damage = return_damage, damage_type = damageType })
end

function PassiveRost(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability then
		local level = ability:GetLevel()
		local duration = 9999999
		
		if level == 1 then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_rost_one", {duration = duration})
		end
		if level == 2 then
			caster:RemoveModifierByName( "modifier_rost_one" )
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_rost_two", {duration = duration})
		end
		if level == 3 then
			caster:RemoveModifierByName( "modifier_rost_two" )
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_rost_free", {duration = duration})
		end
		if level == 4 then
			caster:RemoveModifierByName( "modifier_rost_free" )
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_rost_four", {duration = duration})
		end
	end
end

function PassiveRostOne(keys)
	local caster = keys.caster
	local model_scale = 1.25
	
	caster:SetModelScale(model_scale)
end
function PassiveRostTwo(keys)
	local caster = keys.caster
	local model_scale = 1.5
	
	caster:SetModelScale(model_scale)
end
function PassiveRostFree(keys)
	local caster = keys.caster
	local model_scale = 1.75
	
	caster:SetModelScale(model_scale)
end
function PassiveRostFour(keys)
	local caster = keys.caster
	local model_scale = 2
	
	caster:SetModelScale(model_scale)
end

function ConjureImage( event )
	print("Conjure Image")
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
	
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end
	if GetMapName() == "desert_solo_random_mode" then
		for j=0, 23 do
			if illusion:GetAbilityByIndex(j) then
				illusion:RemoveAbility(illusion:GetAbilityByIndex(j):GetAbilityName())
			end
		end	
		for h=0, 23 do
			if caster:GetAbilityByIndex(h) then
				illusion:AddAbility(caster:GetAbilityByIndex(h):GetAbilityName())
			end
		end
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

	-- Add our datadriven Metamorphosis modifier if appropiate
	-- You can add other buffs that want to be passed to illusions this way
	if caster:HasModifier("modifier_metamorphosis") then
		local meta_ability = caster:FindAbilityByName("terrorblade_metamorphosis_datadriven")
		meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_metamorphosis", nil)
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

end

function CheckHp(keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_hp = caster:GetHealth() / caster:GetMaxHealth()
	local min_hp = 40 / 100
	local dur = 5
	
	if caster_hp <= min_hp and ability:GetCooldownTimeRemaining() == 0 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_test", { duration = dur})
		ability:StartCooldown(24)
	else
		return nil
	end
end

function CheckHpBRB(keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_hp = caster:GetHealth() / caster:GetMaxHealth()
	if ability then
		local CDBRB = ability:GetLevelSpecialValueFor( "CDBRBN", ability:GetLevel() - 1)
		local min_hp = 1 / 100
		local dur = 3
		local Sdur = 0.5
		local mana_spend = ability:GetLevelSpecialValueFor( "ManaCostBRB", ability:GetLevel() - 1)
		
		if ability:GetCooldownTimeRemaining() == 0 and caster:GetMana() >= mana_spend then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_BRB_ND", { duration = inf})
		else
			caster:RemoveModifierByName("modifier_BRB_ND")
		end
		
		if caster_hp < min_hp and ability:GetCooldownTimeRemaining() == 0 and caster:GetMana() >= mana_spend then
			caster:Purge(false, true, false, true, false)
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_BRB_H", { duration = dur})
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_BRB_S", { duration = Sdur})
			ability:StartCooldown(CDBRB)
		else
			return nil
		end
	end
end

function HealHpBrb(keys)
	local caster = keys.caster
	local caster_hp = caster:GetHealth()
	local caster_hpMax = caster:GetMaxHealth()
	local NeedHeal = caster_hpMax / 100 * 90
	local HealPerMiniSec = math.floor(NeedHeal / 30)
	if caster_hp < NeedHeal then
		caster:Heal(HealPerMiniSec, caster)
	end
end

function CheckHpJesusFree(keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_hp = caster:GetHealth() / caster:GetMaxHealth()
	local min_hp = 20 / 100
	local dur = 4
	
	if caster_hp <= min_hp and ability:GetCooldownTimeRemaining() == 0 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_jesus_dont_die", { duration = dur})
		ability:StartCooldown(19)
	else
		return nil
	end
end

function CheckHpJesus(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local caster_hp = caster:GetHealth() / caster:GetMaxHealth()
	local min_hp = 10 / 100
	local dur = inf
	
	if ability then
		if ability:GetCooldownTimeRemaining() == 0 and caster:IsSilenced() == false and caster:IsHexed() == false and caster:IsIllusion() == false then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_jesus_look_targets", { duration = dur})
		else
			return nil
		end
	end
end

function CheckerCooldownChaos(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dur = inf
	
	if ability:GetCooldownTimeRemaining() == 0 and caster:IsSilenced() == false and caster:IsHexed() == false and caster:IsIllusion() == false then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_chaos_look_targets", { duration = dur})
	else
		return nil
	end
end

function RandomChaos(keys)
	local target = keys.target
	local r = RandomInt(1, 2)
	local ability = keys.ability
	local caster = keys.caster
	local damage_type = ability:GetAbilityDamageType()
	local CoolDown = ability:GetLevelSpecialValueFor( "cooldown_ability", ability:GetLevel())
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local casterPos = caster:GetAbsOrigin()
	local range = 700
	local units = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, range, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	
	if r == 1 then
		for i,unitChaos in ipairs(units) do
			ApplyDamage({ victim = unitChaos, attacker = caster, damage = 25, damage_type = damage_type })
		end
	end
	if r == 2 then
		target:EmitSound("Hero_WarlockGolem.Attack")
		target:AddNewModifier(target, nil, "modifier_stunned", {duration = 0.1})
	end
	ability:StartCooldown(CoolDown)
end

function SpendResourcesJesus(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cooldownJ = ability:GetLevelSpecialValueFor( "cooldown_ability", ability:GetLevel())
	ability:StartCooldown(cooldownJ)
end

function CheckCD(keys)
	local caster = keys.caster
	local ability = keys.ability
	local dur = 9999999
	
	if ability then
		if ability:GetCooldownTimeRemaining() == 0 and not caster:HasModifier("modifier_duel_datadriven") then
			ability:ApplyDataDrivenModifier( caster, caster, "jugger_parry_passive", { duration = dur})
		else
			return nil
		end
	end
end

function CheckerCdTroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if ability:GetCooldownTimeRemaining() == 0 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_crit_special_Vjlink", { duration = inf})
		caster:RemoveModifierByName("modifier_crit_Vjlink")
		caster:RemoveModifierByName("Vjlink_passive_crit")
	else
		return nil
	end
end

function StartCdTroll(keys)
	local ability = keys.ability
	local cd = ability:GetLevelSpecialValueFor( "cd", ability:GetLevel())
	ability:StartCooldown(cd)
end

function StartCooldownJugger(keys)
	local ability = keys.ability
	local caster = keys.caster
	if not caster:HasModifier("modifier_duel_datadriven") then
		ability:StartCooldown(8)
		caster:RemoveModifierByName( "jugger_parry_passive" )
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_ult_jugger", { duration = keys.Duration})
		caster:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
	end
end

function CheckHpBeast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_hp = caster:GetHealth() / caster:GetMaxHealth()
	local min_hp = 25 / 100
	local dur = 5
	
	if caster_hp <= min_hp and ability:GetCooldownTimeRemaining() == 0 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_bkb_beast", { duration = dur})
		ability:StartCooldown(24)
	else
		return nil
	end
end

function assassinate_register_target( keys )
	keys.caster.assassinate_target = keys.target
end

function assassinate_remove_target( keys )
	if keys.caster.assassinate_target then
		keys.caster.assassinate_target:RemoveModifierByName( "modifier_assassinate_target_datadriven" )
		keys.caster.assassinate_target = nil
	end
end

function StopCast(keys)
	local caster = keys.caster
	caster:Stop()
end

function ConjureImageDusha( event )
	print("Conjure Image")
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "illusion_life", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )
	
	if caster:HasModifier("modifier_satana_talent_dusha") then
		duration = 32
	end

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(target:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
	
	-- Level Up the unit to the casters level
	local targetLevel = target:GetLevel()
	for i=1,targetLevel-1 do
		illusion:HeroLevelUp(false)
	end
	if GetMapName() == "desert_solo_random_mode" then
		for j=0, 23 do
			if illusion:GetAbilityByIndex(j) then
				illusion:RemoveAbility(illusion:GetAbilityByIndex(j):GetAbilityName())
			end
		end	
		for h=0, 23 do
			if target:GetAbilityByIndex(h) then
				illusion:AddAbility(target:GetAbilityByIndex(h):GetAbilityName())
			end
		end
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = target:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Add our datadriven Metamorphosis modifier if appropiate
	-- You can add other buffs that want to be passed to illusions this way
	if caster:HasModifier("modifier_metamorphosis") then
		local meta_ability = caster:FindAbilityByName("terrorblade_metamorphosis_datadriven")
		meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_metamorphosis", nil)
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

end

function DamageHealthSatana(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local targetMaxHealth = target:GetMaxHealth()
	local damageHealth = ability:GetLevelSpecialValueFor( "damage_percent", ability:GetLevel()) / 100
	
	ApplyDamage({victim = target, attacker = caster, damage = targetMaxHealth * damageHealth, damage_type = ability:GetAbilityDamageType()})
end

function DamageMeAndTarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local casterPos = caster:GetAbsOrigin()
	local damage_type = ability:GetAbilityDamageType()
	local damage = ability:GetLevelSpecialValueFor("damage_exp", ability:GetLevel()) / 100
	local MaxCountAngels = ability:GetLevelSpecialValueFor("count_angels", ability:GetLevel() - 1)
	local AbilityAngelsGetLvl = caster:FindAbilityByName("Jesus_angels")
	local radius = 1000
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, radius, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false)
	local unitsFD = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, 350, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false)
	local FindSatana = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, 9999999, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	if caster:HasModifier("modifier_jesus_dont_die") then
		caster:RemoveModifierByName("modifier_jesus_dont_die")
	end
	for j,unitSatana in ipairs(FindSatana) do
		if unitSatana:GetUnitName() == "npc_dota_hero_doom_bringer" then
			unitSatana:Kill(ability, caster)
		end
	end
	for i,unit in ipairs(units) do
		local damageToTargets = unit:GetMaxHealth() * damage
		ApplyDamage({ victim = unit, attacker = caster, damage = damageToTargets, damage_type = damage_type })
	end
	for e,unitFDU in ipairs(unitsFD) do
		unitFDU:Kill(ability, caster)
	end
	if AbilityAngelsGetLvl then
		if AbilityAngelsGetLvl:GetLevel() > 0 then
			for jc=1,MaxCountAngels, 1 do
				JesusAngel = CreateUnitByName("npc_dota_creature_jesus_angel", casterPos, false, nil, nil, caster:GetTeamNumber())
				JesusAngel:AddNewModifier(caster, ability, "modifier_kill", {Duration = 40})
				JesusAngel:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
				FindClearSpaceForUnit(JesusAngel, casterPos, false)
				JesusAngel:CreatureLevelUp(ability:GetLevel() - 1)
				JesusAngel:SetOwner(caster)
			end
		end
	end
	caster:Kill(ability, caster)
end

function AngelProtect(event)
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local attackerDamage = attacker:GetAttackDamage()
	local healOnAttack = 55 / 100
	local healTargetFriend = attackerDamage * healOnAttack
	local target_teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local target_types = DOTA_UNIT_TARGET_BASIC
	local FindFriend = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 1100, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for i,unit in ipairs(FindFriend) do
		if unit:GetUnitName() == "npc_dota_creature_jesus_angel" then
			ApplyDamage({ victim = unit, attacker = attacker, damage = healTargetFriend, damage_type = DAMAGE_TYPE_MAGICAL })
		end
	end
end

LinkLuaModifier( "modifier_movespeed_cap_low", "modifier_movespeed_cap_low.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Renders the formation and marker particles over the radius]]
function RenderParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	
	ability.casterPos = caster:GetAbsOrigin()
	
	ability.TeleportPoint = Entities:FindByName( nil, "TeleportPointChaos" ):GetAbsOrigin()
	
	caster:SetAbsOrigin(ability.TeleportPoint)
	
	-- Plays the formation sound
	EmitSoundOn(keys.sound, caster)
	
	ability.formation_particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.formation_particle, 0, ability.TeleportPoint)
	ParticleManager:SetParticleControl(ability.formation_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.formation_particle, 2, ability.TeleportPoint)
	
	ability.marker_particle = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.marker_particle, 0, ability.TeleportPoint)
	ParticleManager:SetParticleControl(ability.marker_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.marker_particle, 2, ability.TeleportPoint)
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Checks if the target is facing against the field and applies an extreme slowing modifier if it is]]
function CheckPosition(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	
	-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
	local distance = (target:GetAbsOrigin() - ability.TeleportPoint):Length2D()
	local distance_from_border = distance - radius
	
	-- The target's angle in the world
	local target_angle = target:GetAnglesAsVector().y
	
	-- Solves for the target's angle in relation to the center of the circle in radians
	local origin_difference =  ability.TeleportPoint - target:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Converts the radians to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local angle_from_center = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	angle_from_center = angle_from_center + 180.0
	
	-- Checks if the target is inside the field, less than 20 units from the border, and facing it (within 90 degrees)
	if distance_from_border < 0 and math.abs(distance_from_border) <= 20 and (math.abs(target_angle - angle_from_center)<90 or math.abs(target_angle - angle_from_center)>270) then
		-- Removes the movespeed minimum
		if target:HasModifier("modifier_movespeed_cap_low") == false then
			target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
		end
		-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_kinetic_field_debuff",{})
	-- Checks if the target is outside the field, less than 30 units from the border, and facing it (within 90 degrees)
	elseif distance_from_border > 0 and math.abs(distance_from_border) <= 30 and (math.abs(target_angle - angle_from_center)>90) then
		-- Removes the movespeed minimum
		if target:HasModifier("modifier_movespeed_cap_low") == false then
			target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
		end
		-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_kinetic_field_debuff",{})
	else
		-- Removes the slowing debuffs, so the unit can move freely
		if target:HasModifier("modifier_kinetic_field_debuff") then
			target:RemoveModifierByName("modifier_kinetic_field_debuff")
			target:RemoveModifierByName("modifier_movespeed_cap_low")
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Ensures no units still have the slow modifiers after the field is gone]]
function RemoveModifiers(keys)
	local target = keys.target

	target:RemoveModifierByName("modifier_kinetic_field_debuff")
	target:RemoveModifierByName("modifier_movespeed_cap_low")
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Gives vision to the caster's team and renders the field particle]]
function GiveVision(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() -1) + 100
	local vision_duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	
	AddFOWViewer(caster:GetTeam(), ability.TeleportPoint, vision_radius, vision_duration, false)
	
	ParticleManager:DestroyParticle(ability.formation_particle, true)
	ParticleManager:DestroyParticle(ability.marker_particle, true)
	
	ability.field_particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.field_particle, 0, ability.TeleportPoint)
	ParticleManager:SetParticleControl(ability.field_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.field_particle, 2, ability.TeleportPoint)
end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Destroys the field particle]]
function DestroyParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:SetAbsOrigin(ability.casterPos)
	
	ParticleManager:DestroyParticle(ability.field_particle, true)
	
	-- Stops the field sound
	StopSoundEvent(keys.sound, caster)
end

function ReversePolarity(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local hero_stun_duration = ability:GetLevelSpecialValueFor("hero_stun_duration", ability:GetLevel() - 1)
	local creep_stun_duration = ability:GetLevelSpecialValueFor("creep_stun_duration", ability:GetLevel() - 1)
	
	-- The caster's position
	local caster_origin = caster:GetAbsOrigin()
	local dropRadiusF = RandomFloat( 1200, 2200 )
	local dropRadius = RandomVector( dropRadiusF )
	-- The vector from the caster to the target position
	local offset_vector = dropRadius
	-- The target's new position
	local new_location = caster_origin + offset_vector
	
	-- Moves all the targets to the position
	target:SetAbsOrigin(new_location)
	FindClearSpaceForUnit(target, new_location, true)
	
	-- Applies the stun modifier based on the unit's type
	if target:IsHero() ~= true then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = creep_stun_duration})
	end
end

function StopCaster(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:Stop()
	caster:Purge(false, true, false, true, false)
	ProjectileManager:ProjectileDodge(caster)
end

function RandomTeleportHero(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local caster_origin = caster:GetAbsOrigin()
	local dropRadiusF = RandomFloat( 700, 1700 )
	local dropRadius = RandomVector( dropRadiusF )
	-- The vector from the caster to the target position
	local offset_vector = dropRadius
	
	local new_location = caster_origin + offset_vector
	
	target:SetAbsOrigin(new_location)
	FindClearSpaceForUnit(target, new_location, true)
	
	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 1.2})
	
end

function HideHeroSpecial(keys)
	local target = keys.target
	
	target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,1500))
end

function HeartstopperAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth() / 100
	local aura_damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() - 1))
	local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = target_max_hp * -aura_damage * aura_damage_interval
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

	ApplyDamage(damage_table)
end

function VoronaHasBeen(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:SetModelScale(2.0)
	caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,450))
	caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
	local posToFOW = caster:GetAbsOrigin()
	AddFOWViewer(caster:GetTeam(), posToFOW, 1100, 0.04, false)
end

function CheckVoronaLeaqe(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("leaqe_vorona")
	
	if caster:HasModifier("modifier_heartstopper_aura_datadriven_vorona") then
		caster:RemoveModifierByName("modifier_heartstopper_aura_datadriven_vorona")
		caster:RemoveModifierByName("modifier_heartstopper_aura_datadriven_vorona_damage_all")
		caster:EmitSound("Hero_QueenOfPain.Blink_out")
		ability:ToggleAbility()
	end
end

function VoronaHasBeenOff(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local start_particle = ParticleManager:CreateParticle("particles/vorona_effect_type_one_full.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(start_particle, 0, caster:GetAbsOrigin()  + Vector(0,0,450))
	
	caster:SetModelScale(0.740000)
	caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
	local casterPos = caster:GetAbsOrigin()
	caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	FindClearSpaceForUnit(caster, casterPos, true)
end

function DestroyIfDistanceMore(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local targetPos = target:GetAbsOrigin()
	local casterPos = caster:GetAbsOrigin()
	
	local distance = (targetPos - casterPos):Length2D()
	
	if distance > 1075 then
		target:RemoveModifierByName("modifier_flames")
		caster:RemoveModifierByName("modifier_stun_roshan_special")
	end
	if caster:IsSilenced() or caster:IsStunned() or caster:IsHexed() or (not caster:IsAlive()) then
		target:RemoveModifierByName("modifier_flames")
		caster:RemoveModifierByName("modifier_stun_roshan_special")
	end
end

function CheckDeathUnits( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_hipe_stack"

	if (not caster:HasModifier("modifier_hipe_stack")) then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_hipe_stack",{})
	end
	if caster:HasModifier("modifier_hipe_stack") then
		local current_stack = caster:GetModifierStackCount( modifierStack, ability )
		caster:SetModifierStackCount( modifierStack, ability, current_stack + 1 )
	end
end

function UpgradeRecalculateHype(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_hipe_stack"
	
	ability.current_stack = caster:GetModifierStackCount( modifierStack, ability )
	
	if ability.current_stack > 0 then
		caster:RemoveModifierByName(modifierStack)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_hipe_stack",{})
		caster:SetModifierStackCount( modifierStack, ability, ability.current_stack )
	end
end

function DeathCasterNoz( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_hipe_stack"

	if caster:HasModifier("modifier_hipe_stack") then
		local current_stack = caster:GetModifierStackCount( modifierStack, ability )
		caster:SetModifierStackCount( modifierStack, ability, current_stack - 1 )
		if current_stack == 1 then
			caster:SetModifierStackCount( modifierStack, ability, 1 )
		end
	end
end

function ApplyStacksToCaster(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_pudge_cp_stack"

	if (not caster:HasModifier("modifier_pudge_cp_stack")) then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_pudge_cp_stack",{})
		caster:SetModifierStackCount( modifierStack, ability, 1)
	else
		local current_stack = caster:GetModifierStackCount( modifierStack, ability )
		caster:SetModifierStackCount( modifierStack, ability, current_stack + 1 )
	end
end

function RecalculateStacksPudge(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_pudge_cp_stack"
	
	local current_stack = caster:GetModifierStackCount( modifierStack, ability )
	
	if current_stack > 0 then
		if caster:IsAlive() then
			caster:RemoveModifierByName(modifierStack)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_pudge_cp_stack",{})
			caster:SetModifierStackCount( modifierStack, ability, current_stack )
		else
			local TimeToSpawn = caster:GetTimeUntilRespawn()
			Timers:CreateTimer(TimeToSpawn + 1, function()
				caster:RemoveModifierByName(modifierStack)
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_pudge_cp_stack",{})
				caster:SetModifierStackCount( modifierStack, ability, current_stack )
			end)
		end
	end
end

function CreateDarkSideDruzko(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abilitytoactiv = caster:FindAbilityByName("Druzko_tp_dark")
	abilitytoactiv:SetActivated(true)
	local casterPos = caster:GetAbsOrigin()
	local duration = ability:GetLevelSpecialValueFor("duration_life", ability:GetLevel())
	Timers:CreateTimer(duration, function()
		abilitytoactiv:SetActivated(false)
	end)
	local FindDarkSide = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, 9999999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for j,DarkSide in ipairs(FindDarkSide) do
		if DarkSide:GetUnitName() == "npc_dota_creature_druzko_dark_side1" then
			DarkSide:Kill(ability, DarkSide)
		end
		if DarkSide:GetUnitName() == "npc_dota_creature_druzko_dark_side2" then
			DarkSide:Kill(ability, DarkSide)
		end
		if DarkSide:GetUnitName() == "npc_dota_creature_druzko_dark_side3" then
			DarkSide:Kill(ability, DarkSide)
		end
	end
	
	if ability:GetLevel() == 1 then
		DarkSideDruzko = CreateUnitByName("npc_dota_creature_druzko_dark_side1", casterPos, false, nil, nil, caster:GetTeamNumber())
	end
	if ability:GetLevel() == 2 then
		DarkSideDruzko = CreateUnitByName("npc_dota_creature_druzko_dark_side2", casterPos, false, nil, nil, caster:GetTeamNumber())
	end
	if ability:GetLevel() == 3 then
		DarkSideDruzko = CreateUnitByName("npc_dota_creature_druzko_dark_side3", casterPos, false, nil, nil, caster:GetTeamNumber())
	end
		DarkSideDruzko:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration})
		DarkSideDruzko:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		DarkSideDruzko:SetOwner(caster)
		FindClearSpaceForUnit(DarkSideDruzko, casterPos, false)
		for item_id = 0, 5 do
			local item_in_caster = caster:GetItemInSlot(item_id)
			if item_in_caster ~= nil then
				local item_name = item_in_caster:GetName()
				if not (item_name == "item_aegis" or item_name == "item_smoke_of_deceit" or item_name == "item_ward_observer" or item_name == "item_ward_sentry") then
					local item_created = CreateItem( item_in_caster:GetName(), DarkSideDruzko, DarkSideDruzko)
					DarkSideDruzko:AddItem(item_created)
					item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
				end
			end
		end
		local FirstAbility = caster:FindAbilityByName("Druzko_kniga_rzd")
		if FirstAbility == nil then
			FirstAbility = caster:FindAbilityByName("Druzko_kniga_rzd_talent")
		end
		local FirstAbilityLvl = FirstAbility:GetLevel()
		local FirstAbilityDark = DarkSideDruzko:FindAbilityByName("Dark_kniga")
		local FirstAbilityDarkLvl = FirstAbilityDark:SetLevel(FirstAbilityLvl)
		local SecondAbility = caster:FindAbilityByName("Druzko_hipe")
		if SecondAbility == nil then
			SecondAbility = caster:FindAbilityByName("Druzko_hipe_talent")
		end
		local SecondAbilityLvl = SecondAbility:GetLevel()
		local SecondAbilityDark = DarkSideDruzko:FindAbilityByName("Dark_die")
		local SecondAbilityDarkLvl = SecondAbilityDark:SetLevel(SecondAbilityLvl)
		local FreeAbility = caster:FindAbilityByName("Druzko_tp_dark")
		local FreeAbilityLvl = FreeAbility:GetLevel()
		local FreeAbilityDark = DarkSideDruzko:FindAbilityByName("Dark_tp_druzko")
		local FreeAbilityDarkLvl = FreeAbilityDark:SetLevel(FreeAbilityLvl)
		local FourAbility = caster:FindAbilityByName("Druzko_dark_side")
		if FourAbility == nil then
			FourAbility = caster:FindAbilityByName("Druzko_dark_side_talent")
		end
		local FourAbilityLvl = FourAbility:GetLevel()
		local FourAbilityDark = DarkSideDruzko:FindAbilityByName("Dark_light")
		local FourAbilityDarkLvl = FourAbilityDark:SetLevel(FourAbilityLvl)
end

function DamageTargetAndStun(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageStart = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local stunDur = ability:GetLevelSpecialValueFor("duration_stun", ability:GetLevel() - 1)
	local modifierStack = "modifier_hipe_stack"
	local damageDop = ability:GetLevelSpecialValueFor("damage_per_stack", ability:GetLevel() - 1)
	
	if caster:HasModifier("modifier_hipe_stack") then
		local stackCount = caster:GetModifierStackCount( modifierStack, ability )
		damageDop = damageDop * stackCount
		damageStart = damageStart + damageDop
	end
	
	ApplyDamage({victim = target, attacker = caster, damage = damageStart, damage_type = DAMAGE_TYPE_PURE})
	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stunDur})
end

function SetNoActive(keys)
	keys.ability:SetActivated(false)
end

function SetLvl(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local abilitylvl = caster:FindAbilityByName("Druzko_dark_side")
	if abilitylvl == nil then
		abilitylvl = caster:FindAbilityByName("Druzko_dark_side_talent")
	end
	local abilitysetlvl = caster:FindAbilityByName("Druzko_tp_dark")
	local lvl = abilitylvl:GetLevel()
	
	abilitysetlvl:SetLevel(lvl)
end

function FindAndTpDark(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local casterPos = caster:GetAbsOrigin()
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local FindDark = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, 9999999, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for j,unitDark in ipairs(FindDark) do
		if unitDark:GetUnitName() == "npc_dota_creature_druzko_dark_side1" or unitDark:GetUnitName() == "npc_dota_creature_druzko_dark_side2" or unitDark:GetUnitName() == "npc_dota_creature_druzko_dark_side3" then
			unitDark:SetAbsOrigin(casterPos)
			FindClearSpaceForUnit(unitDark, casterPos, false)
			local particle = ParticleManager:CreateParticle("particles/druzkotpdark.vpcf", PATTACH_ABSORIGIN_FOLLOW, unitDark)
			ParticleManager:SetParticleControlEnt( particle, 0, unitDark, PATTACH_POINT_FOLLOW, "attach_origin" , unitDark:GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( particle, 1, unitDark, PATTACH_POINT_FOLLOW, "attach_origin" , unitDark:GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( particle, 2, unitDark, PATTACH_POINT_FOLLOW, "attach_origin" , unitDark:GetOrigin(), true )
		end
	end
end

function FindAndTpDruzko(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local casterPos = caster:GetAbsOrigin()
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local FindDruzko = FindUnitsInRadius(caster:GetTeamNumber(), casterPos, nil, 9999999, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for j,unitDruzko in ipairs(FindDruzko) do
		if unitDruzko:GetUnitName() == "npc_dota_hero_chen" then
			unitDruzko:SetAbsOrigin(casterPos)
			FindClearSpaceForUnit(unitDruzko, casterPos, false)
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, unitDruzko)
			ParticleManager:SetParticleControlEnt( particle, 0, unitDruzko, PATTACH_POINT_FOLLOW, "attach_origin" , unitDruzko:GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( particle, 1, unitDruzko, PATTACH_POINT_FOLLOW, "attach_origin" , unitDruzko:GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( particle, 2, unitDruzko, PATTACH_POINT_FOLLOW, "attach_origin" , unitDruzko:GetOrigin(), true )
		end
	end
end

function ArgAllMap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	ability.teamTarget = target:GetTeam()
	local teamCaster = caster:GetTeam()
	target:SetTeam(teamCaster)
	if not target:HasModifier("modifier_time_to_unagr") then
		target:SetTeam(ability.teamTarget)
	else
		ability.WeaveNegativeParticle = ParticleManager:CreateParticle("particles/testparticle.vpcf", PATTACH_OVERHEAD_FOLLOW, target)

		ParticleManager:SetParticleControlEnt(ability.WeaveNegativeParticle, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin() + Vector(0,0,800), true)
	end
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), target:GetAbsOrigin(), caster, 1800, targetTeam,
		targetType, targetFlag, FIND_CLOSEST, false
	)
	for j,unit in ipairs(units) do
		unit:SetForceAttackTarget(nil)
			
		if target:IsAlive() then
			local order = 
			{
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			}

			ExecuteOrderFromTable(order)
			unit:SetForceAttackTarget(target)
		else
			unit:Stop()
		end
	end
end

function UnAgrTargets(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target:SetTeam(ability.teamTarget)
	ParticleManager:DestroyParticle(ability.WeaveNegativeParticle, true)
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), target:GetAbsOrigin(), caster, 1800, targetTeam,
		targetType, targetFlag, FIND_CLOSEST, false
	)
	for j,unit in ipairs(units) do
		unit:SetForceAttackTarget(nil)
	end
end

function StartCooldownWater(keys)
	keys.ability:StartCooldown(keys.cd)
end

function CheckCdRiba(keys)
	if keys.ability then
		if keys.ability:GetCooldownTimeRemaining() == 0 then
			keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_riba_orb", { duration = inf})
		else
			return nil
		end
	end
end

function CasterStopRiba(keys)
	keys.caster:Stop()
end

function StopSoundLeaqe(keys)
	local caster = keys.caster
	caster:StopSound("Hero_Enigma.Black_Hole")
end

function StopSoundAlchemist(keys)
	local caster = keys.caster
	caster:StopSound("memes_of_dota.Krutilka")
end

function DamageInBkbLeaqe(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor( "damage_pod_bkb", ability:GetLevel() - 1)
	
	if target:IsMagicImmune() then
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
	end
end

function PlayParticleZeus(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local particle = ParticleManager:CreateParticle("particles/dark_light.vpcf", PATTACH_POINT, caster)
	-- Raise 1000 value if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 1, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,1500 ))
	ParticleManager:SetParticleControlEnt( particle, 0, caster, PATTACH_POINT, "attach_attack2" , caster:GetOrigin(), true )
	ParticleManager:SetParticleControlEnt( particle, 2, caster, PATTACH_POINT, "attach_attack2" , caster:GetOrigin(), true )
end

function PlayParticleZeusDie(event)
	local caster = event.caster
	local ability = event.ability
	local attacker = event.attacker
	
	if attacker ~= nil then
		local particle = ParticleManager:CreateParticle("particles/dark_light.vpcf", PATTACH_POINT, attacker)
		-- Raise 1000 value if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 1, Vector(attacker:GetAbsOrigin().x,attacker:GetAbsOrigin().y,1500 ))
		ParticleManager:SetParticleControlEnt( particle, 0, attacker, PATTACH_POINT, "attach_hitloc" , attacker:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( particle, 2, attacker, PATTACH_POINT, "attach_hitloc" , attacker:GetOrigin(), true )
		
		local particleZeus = ParticleManager:CreateParticle("particles/dark_light.vpcf", PATTACH_POINT, caster)
		-- Raise 1000 value if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particleZeus, 1, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,1500 ))
		ParticleManager:SetParticleControlEnt( particleZeus, 0, caster, PATTACH_POINT, "attach_hitloc" , caster:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( particleZeus, 2, caster, PATTACH_POINT, "attach_hitloc" , caster:GetOrigin(), true )
		
		ApplyDamage({victim = attacker, attacker = caster, damage = event.damage, damage_type = DAMAGE_TYPE_PURE})
	end
	
end

function GiveVisionHook(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), 350, 3.5, false)
	ParticleManager:DestroyParticle(ability.nChainParticleFXIndex, true)
end

function MoveToTargetHook(keys)
	local speed = 40
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	local vector_distance = target_location - caster_location
	local distance = vector_distance:Length2D()
	local direction = vector_distance:Normalized()
	if distance > 100 then
		caster:SetAbsOrigin(caster_location + direction * speed)
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
	end
	if distance < 100 then
		local findClear = caster:GetAbsOrigin()
		FindClearSpaceForUnit(caster, findClear, false)
		target:RemoveModifierByName("modifier_move_to_target")
	end
end

function VjlinkDamageTarget(keys)
	local caster = keys.caster
	local target = keys.target
	local Damage = keys.Damage
	local DamageTalent = keys.DamageTalent
	local Talent = caster:FindAbilityByName("special_bonus_unique_troll_warlord")
	local DamageAttack = caster:GetAverageTrueAttackDamage(caster) / 100 * keys.DamageAttack
	
	if Talent then
		if Talent:GetLevel() == 1 then
			Damage = DamageTalent
		end
	end
	
	Damage = Damage + DamageAttack
	
	ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_PURE })
end

function MoveToTargetPiton(keys)
	local speed = 8
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	ability.targetAg = target
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	local dur = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel())
	local fv = target:GetForwardVector()
	if caster:HasModifier("modifier_delete_Vjlink_PDM") then
		target:RemoveModifierByName("modifier_move_to_target_piton")
		target:RemoveModifierByName("modifier_damage_per_sec_troll_piton")
		FindClearSpaceForUnit(caster, caster_location, true)
	end
	if target:IsInvisible() or target:IsInvulnerable() then
		target:RemoveModifierByName("modifier_move_to_target_piton")
		target:RemoveModifierByName("modifier_damage_per_sec_troll_piton")
		caster:RemoveModifierByName("modifier_move_to_target_piton_caster")
		FindClearSpaceForUnit(caster, caster_location, true)
	end
	if target:HasModifier("modifier_damage_per_sec_troll_piton") then
		caster:SetAbsOrigin(target_location + Vector(0,0,150))
		caster:SetForwardVector(fv)
	end
	if (not caster:IsAlive()) then
		target:RemoveModifierByName("modifier_damage_per_sec_troll_piton")
		target:RemoveModifierByName("modifier_move_to_target_piton")
	end
	local vector_distance = target_location - caster_location
	local distance = vector_distance:Length2D()
	local direction = vector_distance:Normalized()
	if distance > 50 then
		caster:SetAbsOrigin(caster_location + direction * speed)
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
	end
	if distance < 50 then
		if target:HasModifier("modifier_move_to_target_piton") then
			if caster:HasScepter() then
				local CourierSpawns = Entities:FindAllByClassname( "info_courier_spawn" )
				for count, corierEnt in pairs(CourierSpawns) do
					local CourierTeam = corierEnt:GetTeamNumber()
					if caster:GetTeamNumber() == CourierTeam then
						local order = 
						{
							UnitIndex = target:entindex(),
							OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
							Position = corierEnt:GetAbsOrigin()
						}

						ExecuteOrderFromTable(order)
					end
				end
			end
			if (not target:HasModifier("modifier_damage_per_sec_troll_piton")) then
				ability:ApplyDataDrivenModifier( caster, target, "modifier_damage_per_sec_troll_piton", { duration = dur})
			end
		end
	end
end

function CheckDieTarget(keys)
	keys.caster:RemoveModifierByName("modifier_move_to_target_piton_caster")
end

function VjlinkDontMoveToTarget(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	
	caster:SwapAbilities( "Vjlink_piton", "Vjlink_PDM", false, true )
	if target:GetUnitName() == "npc_dota_hero_slark" then
		target:RemoveModifierByName("modifier_damage_per_sec_troll_piton")
		target:RemoveModifierByName("modifier_move_to_target_piton")
		caster:RemoveModifierByName("modifier_move_to_target_piton_caster")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		caster:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 1.0})
	end
end

function VjlinkDontMoveToTargetReverse(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	
	caster:SwapAbilities( "Vjlink_PDM", "Vjlink_piton", false, true )
end

function SetLevelVjlinkD(keys)
	local ability = keys.ability
	local caster = keys.caster
	local alvl = ability:GetLevel()
	local AbilityToDont = caster:FindAbilityByName("Vjlink_PDM")
	AbilityToDont:SetLevel(alvl)
end

function MoveParticle(keys)

	local caster = keys.caster
	local ability = keys.ability

	hook_speed = 2200
	hook_width = 100
	hook_distance = ability:GetLevelSpecialValueFor("range", ability:GetLevel())

	vStartPosition = caster:GetOrigin()
	vProjectileLocation = vStartPosition

	local vDirection = caster:GetCursorPosition() - vStartPosition
	vDirection.z = 0.0

	local vDirection = ( vDirection:Normalized() ) * hook_distance
	vTargetPosition = vStartPosition + vDirection

	vHookOffset = Vector( 0, 0, 96 )
	local vHookTarget = vTargetPosition + vHookOffset
	local vKillswitch = Vector( ( ( hook_distance / hook_speed ) * 2 ), 0, 0 )

	ability.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleAlwaysSimulate( ability.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( ability.nChainParticleFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin() + vHookOffset, true )
	ParticleManager:SetParticleControl( ability.nChainParticleFXIndex, 1, vHookTarget )
	ParticleManager:SetParticleControl( ability.nChainParticleFXIndex, 2, Vector( hook_speed, hook_distance, hook_width ) )
	ParticleManager:SetParticleControl( ability.nChainParticleFXIndex, 3, vKillswitch )
	ParticleManager:SetParticleControl( ability.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( ability.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( ability.nChainParticleFXIndex, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster:GetOrigin(), true )
end

function PlayGlobalSoundSatana(keys)
	EmitGlobalSound("memes_of_dota.JesusDie")
end

function CheckAbilityAndCast(keys)
	local ability = keys.ability
	local caster = keys.caster
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 400, targetTeam,
		targetType, targetFlag, FIND_CLOSEST, false
	)  
	if #units > 0 and ability:GetCooldownTimeRemaining() == 0 and caster:GetMana() > 170 and caster:IsHexed() == false  and caster:IsSilenced() == false and caster:IsStunned() == false then	
		Timers:CreateTimer(0.6, function()
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_start_punch_demon", { duration = 0.6})
		end)
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_anim_demon", { duration = 0.6})
		ability:StartCooldown(16)
	end
end

function RP(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local dropRadiusF = RandomFloat( 50, 115 )
	local dropRadius = RandomVector( dropRadiusF )
	-- The vector from the caster to the target position
	local offset_vector = dropRadius
	-- The target's new position
	local new_location = ability.TargetPos + offset_vector
	
	target:SetAbsOrigin(new_location)
	FindClearSpaceForUnit(target, new_location, true)
end

function SavePOS(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	
	ability.TargetPos = target:GetAbsOrigin()
end

function CheckLink(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local cd = ability:GetCooldown(ability:GetLevel() - 1)
	
	if target ~= nil and target ~= caster then
		if target:HasModifier("modifier_linken_sphere_stop") or target:HasModifier("modifier_linken_sphere_stop_friend") then
			if not target:IsIllusion() then
				caster:Stop()
				target:RemoveModifierByName("modifier_linken_sphere_stop")
				target:RemoveModifierByName("modifier_linken_sphere_stop_friend")
				if target:GetUnitName() ~= "npc_dota_hero_tiny" then
					local LStop = ParticleManager:CreateParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
					ParticleManager:SetParticleControlEnt(LStop, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
				else
					local LStop = ParticleManager:CreateParticle( "particles/roshan_sphere.vpcf", PATTACH_CUSTOMORIGIN, target )
					ParticleManager:SetParticleControlEnt(LStop, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
				end
				target:EmitSound("DOTA_Item.LinkensSphere.Activate")
				ability:StartCooldown(cd)
			end
		end
		if target:HasModifier("modifier_linken_sphere_stop_megumin") then
			caster:Stop()
			local AbilMegumin = target:FindAbilityByName("Megumin_ult")
			local current_stack = target:GetModifierStackCount( "modifier_linken_sphere_stop_megumin", AbilMegumin )
			if current_stack > 1 then
				target:SetModifierStackCount( "modifier_linken_sphere_stop_megumin", AbilMegumin, current_stack - 1 )
			else
				target:RemoveModifierByName("modifier_linken_sphere_stop_megumin")
			end
			local LStop = ParticleManager:CreateParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
			ParticleManager:SetParticleControlEnt(LStop, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
			target:EmitSound("DOTA_Item.LinkensSphere.Activate")
			ability:StartCooldown(cd)
		end
	end
end

function CheckCdLink(keys)
	local ability = keys.ability
	local caster = keys.caster
	
	if ability:GetCooldownTimeRemaining() == 0 then
		if (not caster:HasModifier("modifier_linken_sphere_stop")) then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_linken_sphere_stop", { duration = inf})
		end
	end
end

function CheckCdGl(keys)
	local ability = keys.ability
	local caster = keys.caster
	
	if ability:GetCooldownTimeRemaining() == 0 then
		if (not caster:HasModifier("modifier_item_gl_base")) and caster:GetAttackCapability() ~= 1 then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_gl_base", { duration = inf})
		end
	end
end

function HitUnitGl(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	ability:StartCooldown(2.5)
	local Damage = (keys.ADamage / 100) * 70
	
	caster:RemoveModifierByName("modifier_item_gl_base")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 650, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for i,unit in ipairs(units) do
		ApplyDamage({ victim = unit, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_PURE })
	end
end

function StartCdLink(keys)
	local ability = keys.ability
	local caster = keys.caster
	ability:StartCooldown(13)
end

function DeleteiAg(keys)
	local caster = keys.caster
	for i = 0, 5 do
		item = caster:GetItemInSlot(i)
		if item ~= nil then
			if item:GetAbilityName() == "item_iAg" then
				caster:RemoveItem(item)
			end
		end
	end	
end

function BacktrackHealth( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	if ability then
		ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
		ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

		ability.caster_hp_old = ability.caster_hp
		ability.caster_hp = caster:GetHealth()
	end
end

function BacktrackHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	if (not caster:IsIllusion()) then
		if ability then
			caster:SetHealth(ability.caster_hp_old)
		end
	end
end

function GoldPerKill( keys )
	local caster = keys.caster
	local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
	local target = keys.unit
	local ability = keys.ability
	local gold = ability:GetLevelSpecialValueFor("bonus_goldC", ability:GetLevel() - 1)
	local goldH = ability:GetLevelSpecialValueFor("bonus_goldH", ability:GetLevel() - 1)

	if target:GetTeamNumber() ~= caster:GetTeamNumber() and target:IsCreep() then
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
		local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
		ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( particle, 1, target:GetAbsOrigin() )

		local symbol = 0 -- "+" presymbol
		local color = Vector(255, 200, 33) -- Gold
		local lifetime = 2
		local digits = string.len(gold)
		local particleNameNew = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
		local particleNew = ParticleManager:CreateParticleForPlayer( particleNameNew, PATTACH_ABSORIGIN, target, player )
		ParticleManager:SetParticleControl(particleNew, 1, Vector(symbol, gold, symbol))
	    ParticleManager:SetParticleControl(particleNew, 2, Vector(lifetime, digits, 0))
	    ParticleManager:SetParticleControl(particleNew, 3, color)

		caster:ModifyGold(gold, false, 0)
	end
	if target:GetTeamNumber() ~= caster:GetTeamNumber() and target:IsHero() then
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
		local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
		ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( particle, 1, target:GetAbsOrigin() )

		local symbol = 0 -- "+" presymbol
		local color = Vector(255, 200, 33) -- Gold
		local lifetime = 2
		local digits = string.len(goldH)
		local particleNameNew = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
		local particleNew = ParticleManager:CreateParticleForPlayer( particleNameNew, PATTACH_ABSORIGIN, target, player )
		ParticleManager:SetParticleControl(particleNew, 1, Vector(symbol, goldH, symbol))
	    ParticleManager:SetParticleControl(particleNew, 2, Vector(lifetime, digits, 0))
	    ParticleManager:SetParticleControl(particleNew, 3, color)

		caster:ModifyGold(goldH, false, 0)
	end
end

function RefreshAbilityBRB(keys)
	local ability = keys.ability
	
	ability:EndCooldown()
end

function StartChekerBRB(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	ability:ApplyDataDrivenModifier(caster, target, "modifier_BRB_CHECKER", { duration = 0.1})
end

function ChekerBRB(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if (not target:IsAlive()) then
		ability:EndCooldown()
	end
end

LinkLuaModifier( "modifier_movespeed_cap_middle", "modifier_movespeed_cap_middle.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap_middleTalent", "modifier_movespeed_cap_middleTalent.lua" ,LUA_MODIFIER_MOTION_NONE )

function SlowCasterBRB(keys)
	local caster = keys.caster
	local ability = keys.ability
	local StartAbility = caster:FindAbilityByName("special_bonus_unique_sven")
	
	if StartAbility then
		if StartAbility:GetLevel() == 0 then
			caster:AddNewModifier(caster, caster, "modifier_movespeed_cap_middle", {Duration = 19.0})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_BRB_buff", {Duration = 19.0})
		else
			caster:AddNewModifier(caster, caster, "modifier_movespeed_cap_middleTalent", {Duration = 19.0})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_BRB_buffTalent", {Duration = 19.0})
		end
	end
end

function VjlinkHealPercent(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local targetHp = target:GetMaxHealth() - target:GetHealth()
	local healPerc = targetHp * 0.75
	target:Heal(healPerc, target)
	HealParticle = ParticleManager:CreateParticle("particles/vjlink_heal_full.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(HealParticle, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(HealParticle, 1, target:GetOrigin())
	ParticleManager:SetParticleControl(HealParticle, 2, target:GetOrigin())
	ParticleManager:SetParticleControl(HealParticle, 3, target:GetOrigin())
	ParticleManager:SetParticleControl(HealParticle, 4, target:GetOrigin())
	ParticleManager:SetParticleControl(HealParticle, 5, target:GetOrigin())
end

function MurzikAFG(keys)
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
	local modifierStack = "modifier_Murzik_DT_S"
	local casterGAP = PlayerResource:GetGold(player)
	local casterGA = PlayerResource:GetGold(player) / 400
	local stacks = math.floor(casterGA)
	for i=0, stacks, 1 do
		if (not caster:HasModifier("modifier_Murzik_DT_S")) then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_Murzik_DT_S", {Duration = inf})
		else
			local current_stack = caster:GetModifierStackCount( modifierStack, ability )
			caster:SetModifierStackCount( modifierStack, ability, current_stack + stacks )
			if current_stack >= stacks then
				current_stack = stacks
				caster:SetModifierStackCount( modifierStack, ability, current_stack)
			end
		end
	end
end

function AphoticShield( event )
	-- Variables
	local target = event.target
	local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	local shield_size = 75 -- could be adjusted to model scale

	-- Strong Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)

	-- Reset the shield
	target.AphoticShieldRemaining = max_damage_absorb

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	end)
end

function AphoticShieldAbsorb( event )
	-- Variables
	local damage = event.DamageTaken
	local unit = event.unit
	local ability = event.ability
	
	-- Track how much damage was already absorbed by the shield
	local shield_remaining = unit.AphoticShieldRemaining
	print("Shield Remaining: "..shield_remaining)
	print("Damage Taken pre Absorb: "..damage)

	-- Check if the unit has the borrowed time modifier
	if not unit:HasModifier("modifier_borrowed_time") then
		-- If the damage is bigger than what the shield can absorb, heal a portion
		if damage > shield_remaining then
			local newHealth = unit.OldHealth - damage + shield_remaining
			print("Old Health: "..unit.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..shield_remaining)
			unit:SetHealth(newHealth)
		else
			local newHealth = unit.OldHealth			
			unit:SetHealth(newHealth)
			print("Old Health: "..unit.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..damage)
		end

		-- Reduce the shield remaining and remove
		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining-damage
		if unit.AphoticShieldRemaining <= 0 then
			unit.AphoticShieldRemaining = nil
			unit:RemoveModifierByName("modifier_aphotic_shield")
			print("--Shield removed--")
		end

		if unit.AphoticShieldRemaining then
			print("Shield Remaining after Absorb: "..unit.AphoticShieldRemaining)
			print("---------------")
		end
	end

end

-- Destroys the particle when the modifier is destroyed. Also plays the sound
function EndShieldParticle( event )
	local target = event.target
	target:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	ParticleManager:DestroyParticle(target.ShieldParticle,false)
end


-- Keeps track of the targets health
function AphoticShieldHealth( event )
	local target = event.target

	target.OldHealth = target:GetHealth()
end

function HealAndDamageMurzik(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local SdamageAndHeal = ability:GetLevelSpecialValueFor("start_damage", ability:GetLevel() - 1 )
	local abilityStart = caster:FindAbilityByName("special_bonus_unique_mirana_2")
	local casterA = caster:GetAgility()
	local casterI = caster:GetIntellect()
	local casterS = caster:GetStrength()
	local casterAllA = casterA + casterI + casterS
	if abilityStart then
		if abilityStart:GetLevel() == 1 then
			casterAllA = (casterA + casterI + casterS) * 2
		end
	end
	if target:GetTeam() ~= caster:GetTeam() then
		ApplyDamage({ victim = target, attacker = caster, damage = SdamageAndHeal + casterAllA, damage_type = DAMAGE_TYPE_MAGICAL })
	else
		target:Heal(SdamageAndHeal + casterAllA, target)
	end
end

function ReturnDamageMurzik(event)
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local damage = event.DamageTaken
	local damageType = ability:GetAbilityDamageType()

	-- Damage
	if attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = attacker, attacker = caster, damage = damage, damage_type = damageType, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION })
	end
end

LinkLuaModifier( "modifier_max_movespeed_blood", "modifier_max_movespeed_blood.lua" ,LUA_MODIFIER_MOTION_NONE )

function SetMaxSpeed(keys)
	local caster = keys.caster
	caster:AddNewModifier(caster, caster, "modifier_max_movespeed_blood", {Duration = inf})
end

function SetMaxSpeedBeast(keys)
	local caster = keys.caster
	local Talent = caster:FindAbilityByName("special_bonus_unique_beastmaster_2")
	caster:AddNewModifier(caster, caster, "modifier_max_movespeed_blood", {Duration = 5})
	if Talent:GetLevel() == 1 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_bkb_beast_movespeed_talent", {Duration = 5})
	else
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_bkb_beast_movespeed", {Duration = 5})
	end
end

function CheckTargetToBoss(keys)
	local caster = keys.caster
	local target = keys.target
	print("Name:" .. target:GetName())
	if target:GetUnitName() == "npc_dota_creature_boss_dark" then
		caster:RemoveModifierByName("modifier_crit_pa")
	end
end

function GiveMoneyPerSeconds(keys)
	local caster = keys.caster
	local ability = keys.ability
	local gold = ability:GetLevelSpecialValueFor("goldperseconds", ability:GetLevel() - 1 )
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )

	local symbol = 0 -- "+" presymbol
	local color = Vector(255, 200, 33) -- Gold
	local lifetime = 2
	local digits = string.len(gold)
	local particleNameNew = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
	local particleNew = ParticleManager:CreateParticle( particleNameNew, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particleNew, 1, Vector(symbol, gold, symbol))
	ParticleManager:SetParticleControl(particleNew, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(particleNew, 3, color)
	
	caster:ModifyGold(gold, false, 0)
end

function JumpsNearTarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local targetPos = target:GetAbsOrigin()
	local iCountJumpsMax = ability:GetLevelSpecialValueFor("jumps", ability:GetLevel() - 1 )
	local iCountJumps = 0
	Timers:CreateTimer("jumpsFiramir", {
		useGameTime = true,
		endTime = 0,
		callback = function()
			iCountJumps = iCountJumps + 1
			if iCountJumps == 6 then
				Timers:RemoveTimer("jumpsFiramir")
			end
			local dropRadiusF = RandomFloat( 160, 170 )
			local dropRadius = RandomVector( dropRadiusF )
			local offset_vector = dropRadius
			local new_location = targetPos + offset_vector
			caster:SetAbsOrigin(new_location)
			FindClearSpaceForUnit(caster, new_location, true)
		  return 0.2
		end
	  })
end

function JumpsMakesIllusions( event )
	print("Conjure Image")
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "durationLife", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
	
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end
	if GetMapName() == "desert_solo_random_mode" then
		for j=0, 23 do
			if illusion:GetAbilityByIndex(j) then
				illusion:RemoveAbility(illusion:GetAbilityByIndex(j):GetAbilityName())
			end
		end	
		for h=0, 23 do
			if caster:GetAbilityByIndex(h) then
				illusion:AddAbility(caster:GetAbilityByIndex(h):GetAbilityName())
			end
		end
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,23 do
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

	-- Add our datadriven Metamorphosis modifier if appropiate
	-- You can add other buffs that want to be passed to illusions this way
	if caster:HasModifier("modifier_firamir_d") then
		local meta_ability = caster:FindAbilityByName("Firamir_D")
		if meta_ability == nil then
			meta_ability = caster:FindAbilityByName("Firamir_D_talent")
		end
		meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_firamir_d", nil)
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

end

function StopCasterF(keys)
	keys.caster:Stop()
end

function PimpRandomPrank(keys)
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	
	local r = RandomInt(1, 6)
	
	if r == 1 then
		print("Its minus armor")
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_pimp_p_target_armor", {Duration = 30})
		unit:RemoveModifierByName("modifier_pimp_p_target")
	end
	if r == 2 then
		print("Its euls")
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_pimp_p_target_euls", {Duration = 5})
		unit:RemoveModifierByName("modifier_pimp_p_target")
	end
	if r == 3 then
		print("Its silence")
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_pimp_p_target_silence", {Duration = 15})
		unit:RemoveModifierByName("modifier_pimp_p_target")
	end
	if r == 4 then
		print("Its disarm")
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_pimp_p_target_disarm", {Duration = 15})
		unit:RemoveModifierByName("modifier_pimp_p_target")
	end
	if r == 5 then
		print("Its hex")
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_pimp_p_target_hex", {Duration = 10})
		unit:RemoveModifierByName("modifier_pimp_p_target")
	end
	if r == 6 then
		print("Its just damage")
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_pimp_p_target_damage", {Duration = 0.4})
		unit:RemoveModifierByName("modifier_pimp_p_target")
	end
end

function PimpGlobalSoundUlt(keys)
	EmitGlobalSound("memes_of_dota.PimpP")
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local Talent = caster:FindAbilityByName("special_bonus_unique_shadow_shaman_3")
	
	if Talent:GetLevel() == 1 then
		local TalentUnits = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		for count, hero in ipairs(TalentUnits) do
			if hero ~= target then
				ability:ApplyDataDrivenModifier(caster, hero, "modifier_pimp_p_target",{Duration = keys.Dur})
				ability:ApplyDataDrivenModifier(caster, hero, "modifier_pimp_p_target_check",{Duration = keys.Dur})
			end
		end
	end
end

function StopSoundBRBR(keys)
	keys.caster:StopSound("memes_of_dota.BRBR")
end

function CheckUsedAbility(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	
	if (not target:HasModifier("modifier_pimp_p_target")) then
		return nil
	else
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
	end
end

function PimpMD(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local damageBonus = ability:GetLevelSpecialValueFor( "damage_bonus", ability:GetLevel() - 1 )
	local Talent = caster:FindAbilityByName("special_bonus_unique_shadow_shaman_1")
	
	if Talent then
		if Talent:GetLevel() == 1 then
			damage = damage + 150
		end
	end
	
	if (not target:HasModifier("modifier_pimp_stack")) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_pimp_stack", {Duration = 8})
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
		ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted", {Duration = 0.1})
	end
	if target:HasModifier("modifier_pimp_stack") then
		local stack_count = target:GetModifierStackCount( "modifier_pimp_stack", ability )
		ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted", {Duration = 0.1})
		local modifier_ui_handle = target:FindModifierByName("modifier_pimp_stack")
		target:SetModifierStackCount( "modifier_pimp_stack", ability, stack_count + 1 )
		modifier_ui_handle:SetDuration(8, true)
		ApplyDamage({ victim = target, attacker = caster, damage = damage + (damageBonus * stack_count), damage_type = DAMAGE_TYPE_MAGICAL })
	end
	
	local PimpEffect = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_wraith_cast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(PimpEffect, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(PimpEffect, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(PimpEffect)
end

function ApplyModifierPimp(keys)
	local caster = keys.caster
	local ability = keys.ability
	local Duration = keys.Dur
	local Talent = caster:FindAbilityByName("special_bonus_unique_shadow_shaman_2")
	
	if Talent:GetLevel() == 1 then
		Duration = Duration + 3
	end
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pimp_H", {Duration = Duration})
	caster:AddNewModifier(caster, ability, "modifier_invisible", {Duration = Duration})
end

function AxeAXE(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local damage_g = ability:GetLevelSpecialValueFor( "damage_g", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	
	if target:GetHealth() < damage_g then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 900, target_teams, target_types, target_flags, 0, false)
		target:Kill(ability, caster)
		ability:EndCooldown()
		local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(culling_kill_particle)
		caster:EmitSound("Hero_Axe.Culling_Blade_Success")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_movespeedAxe_AXE", {Duration = 6})
		for i,unit in ipairs(units) do
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_movespeedAxe_AXE", {Duration = 6})
		end
	else
		local culling_un_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(culling_un_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(culling_un_particle)
		caster:EmitSound("Hero_Axe.Culling_Blade_Fail")
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
	end
end

function SniperMGold(keys)
	local caster = keys.caster
	caster:ModifyGold(-15, false, 0)
end

function item_medallion_of_courage_datadriven_on_spell_start(keys)	
	if keys.caster:GetTeam() == keys.target:GetTeam() then  --If Medallion of Courage is cast on an ally.
		if keys.caster ~= keys.target then  --If Medallion of Courage wasn't self-casted.
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_medallion_of_courage_datadriven_debuff", nil)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_medallion_of_courage_datadriven_buff", nil)
			
			keys.caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
			keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		else  --If Medallion of Courage was self-casted, which it's not supposed to be able to do.
			keys.ability:RefundManaCost()
			keys.ability:EndCooldown()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", keys.caster:GetPlayerOwner())
			
			--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
			FireGameEvent('custom_error_show', {player_ID = keys.caster:GetPlayerID(), _error = "Ability Can't Target Self"})
		end
	else  --If Medallion of Courage is cast on an enemy.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_medallion_of_courage_datadriven_debuff", nil)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_medallion_of_courage_datadriven_debuff", nil)
		
		keys.caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
	end
end
function item_solar_crest_mod_on_spell_start(keys)	
	if keys.caster:GetTeam() == keys.target:GetTeam() then  --If Medallion of Courage is cast on an ally.
		if keys.caster ~= keys.target then  --If Medallion of Courage wasn't self-casted.
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_solar_crest_mod_debuff", nil)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_solar_crest_mod_buff", nil)
			
			keys.caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
			keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		else  --If Medallion of Courage was self-casted, which it's not supposed to be able to do.
			keys.ability:RefundManaCost()
			keys.ability:EndCooldown()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", keys.caster:GetPlayerOwner())
			
			--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
			FireGameEvent('custom_error_show', {player_ID = keys.caster:GetPlayerID(), _error = "Ability Can't Target Self"})
		end
	else  --If Medallion of Courage is cast on an enemy.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_solar_crest_mod_debuff", nil)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_solar_crest_mod_debuff", nil)
		
		keys.caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
	end
end

function SetStacksAttacks(event)
	local caster = event.caster
	local ability = event.ability
	local stack_count = caster:GetModifierStackCount( "modifier_stacks_boots", ability )
	
	if (not caster:HasModifier("modifier_stacks_boots")) then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_stacks_boots", {Duration = inf})
		caster:SetModifierStackCount( "modifier_stacks_boots", ability, 1 )
	else
		caster:SetModifierStackCount( "modifier_stacks_boots", ability, stack_count + 1 )
	end
	local stack_count_final = caster:GetModifierStackCount( "modifier_stacks_boots", ability )
	if stack_count_final == 3 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_boots_attacks_good", {Duration = 3})
		caster:RemoveModifierByName("modifier_stacks_boots")
	end
end

function MoveW(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	ability.Move_direction = caster:GetForwardVector()
	ability.Move_distance = 650
	ability.Move_speed = 1500 * 1/30

	ability.Move_traveled = 0
end
function MoveWe(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability.Move_traveled < ability.Move_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.Move_direction * ability.Move_speed)
		ability.Move_traveled = ability.Move_traveled + ability.Move_speed
	else
		caster:InterruptMotionControllers(true)
	end
end

function SpawnFireEntitys(keys)
	local caster = keys.caster
	local ability = keys.ability
	fireEntity = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
	fireEntity:AddNewModifier(caster, ability, "modifier_kill", {Duration = 4})
	fireEntity:SetOwner(caster)
end

function DimonHealthToDamage(event)
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local damageHp = ability:GetLevelSpecialValueFor( "hp_to_damage", ability:GetLevel() - 1 ) / 100
	local damageHpBoss = ability:GetLevelSpecialValueFor( "hp_to_damage_boss", ability:GetLevel() - 1 ) / 100
	
	local targetHpToDamage = target:GetMaxHealth() * damageHp
	local targetHpToDamageBoss = target:GetMaxHealth() * damageHpBoss
	
	if target:IsHero() or target:IsIllusion() then
		ApplyDamage({ victim = target, attacker = caster, damage = targetHpToDamage, damage_type = DAMAGE_TYPE_PHYSICAL })
	end
	if target:GetUnitName() == "npc_dota_creature_boss_dark" then
		ApplyDamage({ victim = target, attacker = caster, damage = targetHpToDamageBoss, damage_type = DAMAGE_TYPE_PHYSICAL })
	end
end

function LandMinesPlant( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_land_mine = keys.modifier_land_mine
	local modifier_tracker = keys.modifier_tracker
	local modifier_caster = keys.modifier_caster
	local modifier_land_mine_invisibility = keys.modifier_land_mine_invisibility

	-- Create the land mine and apply the land mine modifier
	land_mine = CreateUnitByName("npc_dummy_unit_trap", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine, {})

	-- Apply the tracker after the activation time
	Timers:CreateTimer(1.75, function()
		ability:ApplyDataDrivenModifier(caster, land_mine, modifier_tracker, {})
	end)

	-- Apply the invisibility after the fade time
	Timers:CreateTimer(1.0, function()
		ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine_invisibility, {})
	end)
end

--[[Author: Pizzalol
	Date: 24.03.2015.
	Tracks if any enemy units are within the mine radius]]
function LandMinesTracker( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local trigger_radius = 600 
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local damage_type = ability:GetAbilityDamageType()

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, trigger_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		Timers:CreateTimer(0.75, function()
			if target:IsAlive() then
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, Vector(600, 600, 600))
				ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
				target:EmitSound("Hero_Techies.LandMine.Detonate")
				for i,unit in ipairs(units) do
					ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = damage_type })
					unit:AddNewModifier(unit, caster, "modifier_rooted", {duration = 4})
				end
				target:ForceKill(true) 
			end
		end)
	end
end

function GetKillGoldAndModifyCaster(event)
	local caster = event.caster
	local target = event.unit
	local ability = event.ability
	local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
	local targetGold = target:GetGoldBounty()
	if target:GetTeamNumber() ~= caster:GetTeamNumber() and target:IsCreep() then
		SendOverheadEventMessage( target, OVERHEAD_ALERT_GOLD, target, targetGold, nil )
		
		caster:ModifyGold(targetGold, false, 0)
	end
end

function DimonPassiveStacks(event)
	local caster = event.caster
	local ability = event.ability
	
	local stack_count = caster:GetModifierStackCount( "modifier_passive_bonuses_dimon_p_stack", ability )
	
	if (not caster:HasModifier("modifier_passive_bonuses_dimon_p")) then
		if (not caster:HasModifier("modifier_passive_bonuses_dimon_p_stack")) then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_passive_bonuses_dimon_p_stack", {Duration = 16})
			caster:SetModifierStackCount( "modifier_passive_bonuses_dimon_p_stack", ability, 1 )
		else
			local modifier_ui_handle = caster:FindModifierByName("modifier_passive_bonuses_dimon_p_stack")
			caster:SetModifierStackCount( "modifier_passive_bonuses_dimon_p_stack", ability, stack_count + 1 )
			modifier_ui_handle:SetDuration(16, true)
		end
	end
	local stack_count_final = caster:GetModifierStackCount( "modifier_passive_bonuses_dimon_p_stack", ability )
	if stack_count_final == 4 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_passive_bonuses_dimon_p", {Duration = 4})
		caster:RemoveModifierByName("modifier_passive_bonuses_dimon_p_stack")
		local particle = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_ti7/invoker_ti7_alacrity_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,400 ))
		ParticleManager:SetParticleControl(particle, 3, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,400 ))
		ParticleManager:SetParticleControl(particle, 6, Vector(400, 0, 0))
		Timers:CreateTimer(4, function()
				ParticleManager:DestroyParticle(particle, true)
		end )
	end
end

function DimonAttr(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abilityStart = caster:FindAbilityByName("special_bonus_unique_phantom_lancer_2")
	
	local particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_kill_explosion.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
	
	local damage = 175
	
	if abilityStart then
		if abilityStart:GetLevel() == 1 then
			damage = 250
		end
	end
	
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 700, target_team, target_types, target_flags, FIND_CLOSEST, false) 
	
	Timers:CreateTimer(0.4, function()
		for i,unit in ipairs(units) do
			if (not unit:HasModifier("modifier_stack_dimon_a_target")) then
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_stack_dimon_a_target", {Duration = 16})
				unit:SetModifierStackCount( "modifier_stack_dimon_a_target", ability, 1)
				ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
			else
				local stack_count = unit:GetModifierStackCount( "modifier_stack_dimon_a_target", ability )
				local modifier_ui_handle = unit:FindModifierByName("modifier_stack_dimon_a_target")
				unit:SetModifierStackCount( "modifier_stack_dimon_a_target", ability, stack_count + 1)
				modifier_ui_handle:SetDuration(16, true)
				ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
			end
			if (not caster:HasModifier("modifier_stack_dimon_a")) then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_stack_dimon_a", {Duration = 16})
				caster:SetModifierStackCount( "modifier_stack_dimon_a", ability, i)
			else
				local stack_count = caster:GetModifierStackCount( "modifier_stack_dimon_a", ability )
				local modifier_ui_handle = caster:FindModifierByName("modifier_stack_dimon_a")
				caster:SetModifierStackCount( "modifier_stack_dimon_a", ability, stack_count + 1)
				modifier_ui_handle:SetDuration(16, true)
			end
		end
	end )
end

function DestroyIfTargetKilled(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveModifierByName("modifier_stun_roshan_special")
	caster:Stop()
	caster:SetForceAttackTarget(nil)
end

function DamageAllUnitsInRadiusZdun(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damagePerc = ability:GetLevelSpecialValueFor("damage_per_sec", ability:GetLevel() - 1) / 100
	local damage = target:GetHealth() * damagePerc
	
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })
end

function ZdunMovedOrNo(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if caster.position == nil then
		caster.position = caster:GetAbsOrigin()
	end
	local vector_distance = caster.position - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	if distance > 0 then
		caster:RemoveModifierByName("modifier_zdun_p_bonuses")
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_zdun_p_bonuses", {Duration = inf})
	end
	if caster:IsStunned() then
		caster:RemoveModifierByName("modifier_zdun_p_bonuses")
	end
	caster.position = caster:GetAbsOrigin()
end

function CheckTarget(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster.target = target
	
	if target ~= caster then
		if target:GetTeam() ~= caster:GetTeam() then
			ability:EndCooldown()
			caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
			local order = 
			{
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			}
			ExecuteOrderFromTable(order)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_zdun_check_move_to_target", {Duration = inf})
			caster:AddNewModifier(caster, caster, "modifier_max_movespeed_blood", {Duration = inf})
			ability:ApplyDataDrivenModifier(caster, target, "modifier_zdun_check_move_to_target_no_invis", {Duration = inf})
			
			Timers:CreateTimer("checktargetdie", {
				useGameTime = true,
				endTime = 0,
				callback = function()
					if target:IsAlive() == false then
						ability:StartCooldown(13)
						caster:Stop()
						caster:SetForceAttackTarget(nil)
						caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
						local findClear = caster:GetAbsOrigin()
						FindClearSpaceForUnit(caster, findClear, false)
						caster:RemoveModifierByName("modifier_zdun_check_move_to_target")
						caster:RemoveModifierByName("modifier_max_movespeed_blood")
						target:RemoveModifierByName("modifier_max_movespeed_blood")
						target:RemoveModifierByName("modifier_zdun_check_move_to_target_no_invis")
						Timers:RemoveTimer("checktargetdie")
					end
				  return 0.01
				end
			})

		else
			ability:RefundManaCost()
			ability:EndCooldown()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
		end
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_zdun_random_hero_move_to_me", {Duration = 0.1})
	end
end

function ZdunMoveToTarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target == nil then
		target = caster.target
	end
	ability:StartCooldown(13)
	caster:Stop()
	caster:SetForceAttackTarget(nil)
	caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	local findClear = caster:GetAbsOrigin()
	FindClearSpaceForUnit(caster, findClear, false)
	caster:RemoveModifierByName("modifier_zdun_check_move_to_target")
	caster:RemoveModifierByName("modifier_max_movespeed_blood")
	target:RemoveModifierByName("modifier_zdun_check_move_to_target_no_invis")
end
function TargetMoveToCaster(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:EndCooldown()
	target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
	AddFOWViewer(target:GetTeamNumber(), caster:GetAbsOrigin(), 250, 1.0, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_zdun_check_move_to_target_target", {Duration = inf})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_zdun_check_die_caster", {Duration = inf})
	target:AddNewModifier(caster, target, "modifier_max_movespeed_blood", {Duration = inf})
	local order = 
	{
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = caster:entindex()
	}
	Timers:CreateTimer("checkdiecaster", {
		useGameTime = true,
		endTime = 0,
		callback = function()
			if caster:IsAlive() == false then
				ability:StartCooldown(13)
				target:Stop()
				target:SetForceAttackTarget(nil)
				target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
				local findClear = target:GetAbsOrigin()
				FindClearSpaceForUnit(target, findClear, false)
				target:RemoveModifierByName("modifier_zdun_check_move_to_target_target")
				target:RemoveModifierByName("modifier_max_movespeed_blood")
				caster:RemoveModifierByName("modifier_max_movespeed_blood")
				Timers:RemoveTimer("checkdiecaster")
			end
		  return 0.01
		end
	})
	Timers:CreateTimer("checkdietarget", {
		useGameTime = true,
		endTime = 0,
		callback = function()
			if target:IsAlive() == false then
				ability:StartCooldown(13)
				target:Stop()
				target:SetForceAttackTarget(nil)
				target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
				local findClear = target:GetAbsOrigin()
				FindClearSpaceForUnit(target, findClear, false)
				target:RemoveModifierByName("modifier_zdun_check_move_to_target_target")
				target:RemoveModifierByName("modifier_max_movespeed_blood")
				caster:RemoveModifierByName("modifier_max_movespeed_blood")
				Timers:RemoveTimer("checkdietarget")
			end
		  return 0.01
		end
	})

	ExecuteOrderFromTable(order)
	target:SetForceAttackTarget(caster)
end
function TargetToCaster(event)
	local caster = event.caster
	local target = event.attacker
	local ability = event.ability
	ability:StartCooldown(13)
	target:Stop()
	target:SetForceAttackTarget(nil)
	target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	local findClear = target:GetAbsOrigin()
	FindClearSpaceForUnit(target, findClear, false)
	target:RemoveModifierByName("modifier_zdun_check_move_to_target_target")
	target:RemoveModifierByName("modifier_max_movespeed_blood")
	caster:RemoveModifierByName("modifier_max_movespeed_blood")
	caster:RemoveModifierByName("modifier_zdun_check_die_caster")
end
function ApplyStacksZdun(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cd = ability:GetLevelSpecialValueFor("cd", ability:GetLevel() - 1)
	
	if ability:GetCooldownTimeRemaining() == 0 then
		if (not caster:HasModifier("modifier_stacks_zdun")) then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_stacks_zdun", {Duration = inf})
			caster:SetModifierStackCount( "modifier_stacks_zdun", ability, 1)
			ability:StartCooldown(cd)
		else
			local stack_count = caster:GetModifierStackCount( "modifier_stacks_zdun", ability )
			caster:SetModifierStackCount( "modifier_stacks_zdun", ability, stack_count + 1)
			ability:StartCooldown(cd)
		end
	end
end

function ReApplyStacksZdun(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stack_count = caster:GetModifierStackCount( "modifier_stacks_zdun", ability )
	
	if caster:IsAlive() == true then
		if caster:HasModifier("modifier_stacks_zdun") then
			caster:RemoveModifierByName("modifier_stacks_zdun")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_stacks_zdun", {Duration = inf})
			caster:SetModifierStackCount( "modifier_stacks_zdun", ability, stack_count)
		end
	else
		Timers:CreateTimer("checklivecaster", {
		useGameTime = true,
		endTime = 0,
		callback = function()
			if caster:IsAlive() == true then
				if caster:HasModifier("modifier_stacks_zdun") then
					caster:RemoveModifierByName("modifier_stacks_zdun")
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_stacks_zdun", {Duration = inf})
					caster:SetModifierStackCount( "modifier_stacks_zdun", ability, stack_count)
				end
				Timers:RemoveTimer("checklivecaster")
			end
		  return 0.01
		end
	})
	end
end

function CheckModifAndApplyModifier(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 560, target_teams, target_types, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for i,unit in ipairs(units) do
		if (not unit:HasModifier("modifier_modif_for_dont_apply")) then
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_modif_for_dont_apply", {Duration = 2.8})
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_zdun_do_target", {Duration = 2.3})
		end
	end
end

function ONODIE(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if (not caster:HasModifier("modifier_stacks_ono")) then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_stacks_ono", {Duration = inf})
		caster:SetModifierStackCount( "modifier_stacks_ono", ability, 1)
	else
		local stack_count = caster:GetModifierStackCount( "modifier_stacks_ono", ability )
		caster:SetModifierStackCount( "modifier_stacks_ono", ability, stack_count + 1)
	end
end

function ONODIEREAPPLY(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stack_count = caster:GetModifierStackCount( "modifier_stacks_ono", ability )
	
	if caster:HasModifier("modifier_stacks_ono") then
		caster:RemoveModifierByName("modifier_stacks_ono")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_stacks_ono", {Duration = inf})
		caster:SetModifierStackCount( "modifier_stacks_ono", ability, stack_count)
	end
end

function SetStacksOno(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Talent = caster:FindAbilityByName("special_bonus_unique_dazzle_3")
	local modifAbility = caster:FindAbilityByName("AttackSounds")
	local stacks = ability:GetLevelSpecialValueFor("stacks", ability:GetLevel() - 1)
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	if Talent:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_ono_debuff", {Duration = 4})
	end
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
	if (not target:HasModifier("modifier_fear_ono")) then
		modifAbility:ApplyDataDrivenModifier(caster, target, "modifier_fear_ono", {Duration = inf})
		target:SetModifierStackCount( "modifier_fear_ono", modifAbility, stacks)
	else
		local stack_count = target:GetModifierStackCount( "modifier_fear_ono", modifAbility )
		target:SetModifierStackCount( "modifier_fear_ono", modifAbility, stack_count + stacks)
		local checkstacks = target:GetModifierStackCount( "modifier_fear_ono", modifAbility )
		if checkstacks >= 18 then
			target:SetModifierStackCount( "modifier_fear_ono", modifAbility, 18)
		end
	end
end

function CheckStacksOnTarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifAbility = caster:FindAbilityByName("AttackSounds")
	
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for i,unit in ipairs(units) do
		if unit:HasModifier("modifier_fear_ono") then
			local stack_count = unit:GetModifierStackCount( "modifier_fear_ono", modifAbility )
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_stacks_ono_reduction", {Duration = inf})
			unit:SetModifierStackCount( "modifier_stacks_ono_reduction", ability, stack_count)
			local finallystack = unit:GetModifierStackCount( "modifier_fear_ono", modifAbility )
			if finallystack >= 18 then
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_stacks_ono_reduction", {Duration = inf})
				unit:SetModifierStackCount( "modifier_stacks_ono_reduction", ability, 18)
			end
		end
	end
end
function CheckColStacksOnTarget(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local statsToApplyAg = 0
	local statsToApplyInt = 0
	local statsToApplyStr = 0
	local modifAbility = caster:FindAbilityByName("AttackSounds")
	local stack_count = target:GetModifierStackCount( "modifier_fear_ono", modifAbility )
	local targetstatsAg = target:GetAgility()
	local targetstatsInt = target:GetIntellect()
	local targetstatsStr = target:GetStrength()
	
	if target:HasModifier("modifier_fear_ono") then
		if stack_count == 18 then
			target:Kill(ability, caster)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_stun_ono_caster", {Duration = 8})
			target:RemoveModifierByName("modifier_fear_ono")
			target:RemoveModifierByName("modifier_stacks_ono_reduction")
			local culling_un_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(culling_un_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
			ParticleManager:ReleaseParticleIndex(culling_un_particle)
			Timers:CreateTimer("onotimerS", {
			useGameTime = true,
			endTime = 8,
			callback = function()
				statsToApplyAg = targetstatsAg * 0.2
				statsToApplyInt = targetstatsInt * 0.2
				statsToApplyStr = targetstatsStr * 0.2
				caster:ModifyAgility(statsToApplyAg)
				caster:ModifyIntellect(statsToApplyInt)
				caster:ModifyStrength(statsToApplyStr)
			end
		  })
		  Timers:CreateTimer("onodiecheck", {
			useGameTime = true,
			endTime = 0,
			callback = function()
				if caster:IsAlive() == false then
					Timers:RemoveTimer("onotimerS")
					Timers:RemoveTimer("onodiecheck")
				end
			  return 0.01
			end
		})
		else
			statsToApplyAg = targetstatsAg * 0.0
			statsToApplyInt = targetstatsInt * 0.0
			statsToApplyStr = targetstatsStr * 0.0
			caster:ModifyAgility(statsToApplyAg)
			caster:ModifyIntellect(statsToApplyInt)
			caster:ModifyStrength(statsToApplyStr)
			local damage = ability:GetLevelSpecialValueFor("damagenokill", ability:GetLevel() - 1)
			ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
		end
	else
		statsToApplyAg = targetstatsAg * 0.0
		statsToApplyInt = targetstatsInt * 0.0
		statsToApplyStr = targetstatsStr * 0.0
		caster:ModifyAgility(statsToApplyAg)
		caster:ModifyIntellect(statsToApplyInt)
		caster:ModifyStrength(statsToApplyStr)
		local damage = ability:GetLevelSpecialValueFor("damagenokill", ability:GetLevel() - 1)
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
	end
end

function RemovePermanentInvisibility(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("cloak_and_dagger_datadriven")
	
	if caster:HasModifier("modifier_permanent_invisibility_datadriven") then
		if caster:HasModifier("modifier_invisibility_fade_datadriven") then
			caster:RemoveModifierByName("modifier_invisibility_fade_datadriven")
		end
		caster:RemoveModifierByName("modifier_permanent_invisibility_datadriven")
		caster:RemoveModifierByName("modifier_invisible")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_invisibility_fade_datadriven", {})
	end
end
if GetMapName() ~= "desert_solo_random_mode" then
function CheckTalentRiki(keys)
	local talent2 = keys.caster:FindAbilityByName("special_bonus_unique_riki_1")
	local bTalent = keys.caster:FindAbilityByName("riki_bonus")
	if talent2:GetLevel() == 1 then
		bTalent:SetLevel(1)
		keys.caster:RemoveModifierByName("modifier_talent_riki")
	end
end
end

function CheckBackstab(params)
	
	local ability = params.ability
	if ability then
		local agility_damage_multiplier = ability:GetLevelSpecialValueFor("agility_damage", ability:GetLevel() - 1)
		local caster = params.caster
		local talent1 = caster:FindAbilityByName("special_bonus_unique_riki_2")
		local talent2 = caster:FindAbilityByName("special_bonus_unique_riki_1")
		local bTalent = caster:FindAbilityByName("riki_bonus")
		
		if talent1 then
			if talent1:GetLevel() ~= 1 then
				caster:RemoveModifierByName("modifier_permanent_invisibility_datadriven")
				caster:RemoveModifierByName("modifier_invisible")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_invisibility_fade_datadriven", {})
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_permanent_invisibility_datadriven", {Duration = inf})
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_invisible", {Duration = inf})
			end
		else
			caster:RemoveModifierByName("modifier_permanent_invisibility_datadriven")
			caster:RemoveModifierByName("modifier_invisible")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_invisibility_fade_datadriven", {})
		end
		if talent2 then
			if talent2:GetLevel() == 1 then
				agility_damage_multiplier = agility_damage_multiplier + 0.9
			end
		end
		
		-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
		local victim_angle = params.target:GetAnglesAsVector().y
		local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()

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
			-- Play the sound on the victim.
			EmitSoundOn(params.sound, params.target)
			-- Create the back particle effect.
			local particle = ParticleManager:CreateParticle(params.particle, PATTACH_ABSORIGIN_FOLLOW, params.target) 
			-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
			ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 
			-- Apply extra backstab damage based on Riki's agility
			ApplyDamage({victim = params.target, attacker = params.attacker, damage = params.attacker:GetAgility() * agility_damage_multiplier, damage_type = ability:GetAbilityDamageType()})
		else
			--EmitSoundOn(params.sound2, params.target)
			-- uncomment this if regular (non-backstab) attack has no sound
		end
	end
end

LinkLuaModifier( "modifier_m_prc", "modifier_m_prc.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_m_bottle_prc", "modifier_m_bottle_prc.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_d_prc", "modifier_d_prc.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invoker_passive", "modifier_invoker_passive.lua" ,LUA_MODIFIER_MOTION_NONE )

refreshAbilMegumin = nil

function AddModifierMegumin(keys)
	local caster = keys.caster
	local target = keys.target
	target:AddNewModifier(caster, nil, "modifier_m_prc", {duration = 0.1})
end
function AddModifierDianaMc(keys)
	local caster = keys.caster
	local target = keys.target
	target:AddNewModifier(caster, nil, "modifier_d_prc", {duration = 0.1})
end
function RefreshAbilityMegumin(keys)
	local caster = keys.caster
	local ability = keys.ability
	if refreshAbilMegumin ~= nil then
		refreshAbilMegumin:EndCooldown()
		refreshAbilMegumin = nil
	end
end

function AddModifierMeguminRefresh(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ab = caster:FindAbilityByName("Megumin_povazka")
	if ab == nil then
		ab = caster:FindAbilityByName("Megumin_povazka_arcana")
	end
	if ab then
		local chance = ab:GetLevelSpecialValueFor("chane_uncd_ability_tooltip", ability:GetLevel() - 1 )
		local ChanceReal = 100.0 - chance
		if chance ~= 0 or chance ~= nil then
			local rInt = RandomFloat(1.0,100.0)
			if rInt > ChanceReal and caster:HasModifier("modifier_megumin_povazka") then
				refreshAbilMegumin = ability
				EmitSoundOn("Hero_ObsidianDestroyer.SanityEclipse.Cast", caster)
				local CdRefresh = ParticleManager:CreateParticle("particles/megumincd.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(CdRefresh, 0, caster:GetAbsOrigin())
			end
		end
	end
end

function DamageMeguminTargets(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local DamagePrc = keys.DamagePrc / 100
	local Damage = keys.Damage
	local DamagAtHealth = target:GetMaxHealth() * DamagePrc
	
	local TotalDamage = Damage + DamagAtHealth
	
	ApplyDamage({victim = target, attacker = caster, damage = TotalDamage, damage_type = DAMAGE_TYPE_MAGICAL})
end

function MeguminCheckCastable(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterMana = caster:GetMana() / caster:GetMaxMana()
	local Talent = caster:FindAbilityByName("special_bonus_unique_phoenix_1")
	local NeedMana = 0.75
	if Talent:GetLevel() == 1 then
		NeedMana = 0.0
	end
	if casterMana >= NeedMana then
		caster:SpendMana(NeedMana*caster:GetMaxMana(),ability)
		local playerID = caster:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)
		if steamID == 188428188 or steamID == 264646604 or steamID == 255592337 or steamID == 849889850 or steamID == 413452525 or steamID == 399279735 or steamID == 190098075 or steamID == 843939574 then
			EmitGlobalSound("memes_of_dota.MeguminUltArcana")
		else
			EmitGlobalSound("memes_of_dota.megumin_explosion_1")
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_linken_sphere_stop_megumin", {Duration = 6.0 })
		caster:SetModifierStackCount( "modifier_linken_sphere_stop_megumin", ability, 3)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_magical_resist_megumin", {Duration = 6.0 })
		if caster:HasScepter() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_megumin_magic_immune", {Duration = 6.0 })
		end
	else
		caster:Stop()
		ability:EndCooldown()
	end
end

function DamageAll(keys)
	local caster = keys.caster
	local ability = keys.ability
	local MeguminDamageFindUlt = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 3500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false)
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 ) / 100
	for count, unit in ipairs(MeguminDamageFindUlt) do
		local damageToUnit = unit:GetMaxHealth() * damage
		ApplyDamage({victim = unit, attacker = caster, damage = damageToUnit, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

function HealPhoenix(keys)
	local caster = keys.caster
	caster:Heal(caster:GetMaxHealth(), caster)
end

function EmitMeguminSound(keys)
	EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")
end

function PhantomMassAttack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local PAFind = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false)
	if #PAFind > 0 then
		local TimeNeed = -1
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage_pa", {Duration = keys.interval * #PAFind})
		for count,unit in ipairs(PAFind) do
			TimeNeed = TimeNeed + 1
			Timers:CreateTimer(TimeNeed*keys.interval, function()
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_bonus_damage_pa_target", {Duration = inf})
				caster:PerformAttack(unit, true, true, true, false, false, false, true)
				unit:RemoveModifierByName("modifier_bonus_damage_pa_target")
			end)
		end
	end
end

function swap_to_item(keys, ItemName, oldItem)
	for i=0, 5 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == oldItem then
				keys.caster:RemoveItem(current_item)
				local newItem = keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster))
				local oldItemSlot = i
				for j=0,5 do
					local current_itemTwo = keys.caster:GetItemInSlot(j)
					if current_itemTwo:GetName() == ItemName then
						keys.caster:SwapItems(j, oldItemSlot)
						break
					end
				end
			end
		end
	end
end

function item_power_treads_strength_datadriven_on_spell_start(keys)
	swap_to_item(keys, "item_intelect_boots", "item_smash_boots")
end

function item_power_treads_agility_datadriven_on_spell_start(keys)
	swap_to_item(keys, "item_smash_boots", "item_agility_boots")
end

function item_power_treads_intelligence_datadriven_on_spell_start(keys)
	swap_to_item(keys, "item_agility_boots", "item_intelect_boots")
end

function ApplyBonusGucci(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	for i=0, 5 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_gucci" then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_gucci_bonuses_passive", {Duration = inf })
				caster:RemoveItem(current_item)
			end
		end
	end
end

function RemoveVPN(keys)
	local caster = keys.caster
	
	caster:RemoveItem(caster:FindItemInInventory("item_vpn"))
end

function SunStrikeParticle(keys)
	local caster = keys.caster
	local ability = keys.ability
	local Talent = caster:FindAbilityByName("special_bonus_unique_phoenix_3")
	local Talent2 = caster:FindAbilityByName("special_bonus_unique_phoenix_2")
	local point = ability:GetCursorPosition()
	local DamageRadius = keys.DamageRadius
	local Damage = keys.Damage
	local DamageTalent = keys.DamageTalent
	if Talent then
		if Talent:GetLevel() == 1 then
			Damage = DamageTalent
		end
	end
	local playerID = caster:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)
	if steamID == 188428188 or steamID == 264646604 or steamID == 255592337 or steamID == 849889850 or steamID == 413452525 or steamID == 399279735 or steamID == 190098075 or steamID == 843939574 then
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, point)
		ParticleManager:SetParticleControl(particle, 1, Vector(375,375,375))
	else
		local particle = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, point)
		ParticleManager:SetParticleControl(particle, 1, Vector(375,375,375))
	end
	local DamageFind = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, DamageRadius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for count,unit in pairs(DamageFind) do
		ApplyDamage({victim = unit, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
		if Talent2:GetLevel() == 1 then
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_megumin_talent_root", {Duration = keys.RDurT })
		end
	end
end

function AgrTargetToMe(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = keys.Duration
	ability:ApplyDataDrivenModifier(caster, target, "modifier_agent_fuck_target", {Duration = duration })
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_agent_fuck_caster", {Duration = duration })
	
	local Talent = caster:FindAbilityByName("special_bonus_unique_templar_assassin_3")
	local Talent2 = caster:FindAbilityByName("special_bonus_unique_templar_assassin_4")
	if Talent2 then
		if Talent2:GetLevel() == 1 then
			caster:Purge(false, true, false, false, false)
		end
	end
	if Talent then
		if Talent:GetLevel() == 1 then
			local AgrFind = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 250, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
			caster.AgrFindAgent = #AgrFind
			for count,unit in pairs(AgrFind) do
				local order = 
				{
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = caster:entindex()
				}	
				ExecuteOrderFromTable(order)
				unit:SetForceAttackTarget(caster)
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_agent_fuck_target", {Duration = duration })
				caster:SetModifierStackCount( "modifier_agent_fuck_caster", ability, #AgrFind )
			end
		else
			local order = 
			{
				UnitIndex = target:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = caster:entindex()
			}	
			ExecuteOrderFromTable(order)
			target:SetForceAttackTarget(caster)
		end
	else
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}	
		ExecuteOrderFromTable(order)
		target:SetForceAttackTarget(caster)
	end
end

function UnAgrTargetToMe(keys)
	keys.target:SetForceAttackTarget(nil)
end

function SetSlowStacksAgent(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Talent = caster:FindAbilityByName("special_bonus_unique_templar_assassin_6")
	local Damage = keys.damage
	if Talent:GetLevel() == 1 then
		Damage = keys.talentDamage
	end
	ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
	if (not target:HasModifier("modifier_slow_stack")) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slow_stack",{})
	else
		local current_stack = target:GetModifierStackCount( "modifier_slow_stack", ability )
		target:SetModifierStackCount( "modifier_slow_stack", ability, current_stack + 1 )
		local current_stackFinnaly = target:GetModifierStackCount( "modifier_slow_stack", ability )
		if current_stackFinnaly >= 4 then
			target:SetModifierStackCount( "modifier_slow_stack", ability, 4 )
		end
	end
end

function SetInvisTalent(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Talent = caster:FindAbilityByName("special_bonus_unique_templar_assassin_2")
	if Talent:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_invisible",{Duration = 0.3})
	end
end

function PassiveAttacksAgent(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local Talent = caster:FindAbilityByName("special_bonus_unique_templar_assassin_5")
	if Talent:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_agent_passive_attacks_target",{Duration = 0.1})
	end
end

function SpawnAlexAndSergey(keys)
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local lvl = ability:GetLevel()
	
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = 150
	local distanceForIvan = 215
	local ang_right = QAngle(0, -30, 0)
	local front_position = origin + fv * distance
	local front_positionIvan = origin + fv * distanceForIvan
	local point_right = RotatePosition(origin, ang_right, front_position)	
	local ang_left = QAngle(0, 30, 0)
	local point_left = RotatePosition(origin, ang_left, front_position)	
	local particle = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_WORLDORIGIN, caster)
	-- Raise 1000 if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 0, point_left)
	local particle2 = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_WORLDORIGIN, caster)
	-- Raise 1000 if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle2, 0, point_right)
	
	local SpawnPoints = {point_right,point_left}
	local UnitsName = {"npc_dota_creature_alex","npc_dota_creature_serg"}
	
	for i=1, 2 do
		local unit = CreateUnitByName(UnitsName[i], SpawnPoints[i], true, caster, nil, caster:GetTeamNumber())
		unit:AddNewModifier(caster, unit, "modifier_kill", {Duration = keys.duration})
		unit:SetForwardVector(fv)
		unit:SetControllableByPlayer(player, true)
		unit:SetOwner(caster)
		if unit:GetUnitName() == "npc_dota_creature_alex" then
			local abilityUnitOne = unit:FindAbilityByName("Alex_CHSV")
			abilityUnitOne:SetLevel(lvl)
		end
		if unit:GetUnitName() == "npc_dota_creature_serg" then
			local abilityUnitOne = unit:FindAbilityByName("Serg_Mem")
			abilityUnitOne:SetLevel(lvl)
		end
	end
	if caster:HasScepter() then
		local Creator = CreateUnitByName("npc_dota_creature_ivan", front_positionIvan, true, caster, nil, caster:GetTeamNumber())
		Creator:AddNewModifier(caster, Creator, "modifier_kill", {Duration = keys.duration})
		Creator:SetForwardVector(fv)
		Creator:SetControllableByPlayer(player, true)
		Creator:SetOwner(caster)
	end
end

LastAbility = 0
LastAbilityName = "agent_ability_slot"

function RandomAAA(keys)
	local caster = keys.caster
	local ability = keys.ability
	local lvl = ability:GetLevel()
	
	for i=1,500 do
		local rInt = RandomInt(1,4)
		if rInt == 1 and LastAbility ~= 1 then
			LastAbility = 1
			caster:SwapAbilities( LastAbilityName, "temple_guardian_wrath", false, true )
			LastAbilityName = "temple_guardian_wrath"
			local abilityOne = caster:FindAbilityByName("temple_guardian_wrath")
			abilityOne:SetLevel(lvl)
			break
		end
		if rInt == 2 and LastAbility ~= 2 then
			LastAbility = 2
			caster:SwapAbilities( LastAbilityName, "sniper_assassinate", false, true )
			LastAbilityName = "sniper_assassinate"
			local abilityOne = caster:FindAbilityByName("sniper_assassinate")
			abilityOne:SetLevel(lvl)
			break
		end
		if rInt == 3 and LastAbility ~= 3 then
			LastAbility = 3
			caster:SwapAbilities( LastAbilityName, "president_naval", false, true )
			LastAbilityName = "president_naval"
			local abilityOne = caster:FindAbilityByName("president_naval")
			abilityOne:SetLevel(lvl)
			break
		end
		if rInt == 4 and LastAbility ~= 4 then
			LastAbility = 4
			caster:SwapAbilities( LastAbilityName, "Train_Thomas", false, true )
			LastAbilityName = "Train_Thomas"
			local abilityOne = caster:FindAbilityByName("Train_Thomas")
			abilityOne:SetLevel(lvl)
			break
		end
	end
end

function RemoveAAA(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	LastAbility = 0
	caster:SwapAbilities( LastAbilityName, "agent_ability_slot", false, true )
	LastAbilityName = "agent_ability_slot"
end

function ApplyGoldToSobolev(keys)
	local caster = keys.caster
	local ability = keys.ability
	local startGold = keys.startGold
	local GoldToAdd = (startGold + GoldMinuteBonus) / 60
	caster:ModifyGold(GoldToAdd, false, DOTA_ModifyGold_SellItem)
end

function ApplyXpToSobolev(keys)
	local caster = keys.caster
	local ability = keys.ability
	local startXp = keys.startXp
	local XpToAdd = startXp + XpMinuteBonus
	caster:AddExperience(XpToAdd, 1, false, false)
end

StartBonusGold = 0
StartBonusXP = 0
GoldMinuteBonus = 0
XpMinuteBonus = 0

function BonusGoldAndXp(keys)
	local caster = keys.caster
	local ability = keys.ability
	local BonusGold = keys.BonusGold
	local BonusXp = keys.BonusXp
	
	GoldMinuteBonus = StartBonusGold + BonusGold
	XpMinuteBonus = StartBonusXP + BonusXp
end

function PassiveAgrSobolev(keys)
	local attacker = keys.attacker
	local caster = keys.caster
	attacker:AddNewModifier(caster, attacker, "modifier_stunned", {Duration = keys.duration})
end

function ApplyModifierSobolev(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local Talent = caster:FindAbilityByName("special_bonus_unique_pangolier_4")
	local Duration = keys.Dur
	if Talent then
		if Talent:GetLevel() == 1 then
			Duration = Duration - 1.5
		end
	end
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sobolev_invis_delay",{Duration = Duration})
	AddFOWViewer(caster:GetTeamNumber(), point, 600, Duration, false)
	if Talent then
		if Talent:GetLevel() == 1 then
			EmitSoundOnLocationWithCaster(point, "memes_of_dota.SobolevUltTalent", caster)
		else
			EmitSoundOnLocationWithCaster(point, "memes_of_dota.SobolevUlt", caster)
		end
	else
		EmitSoundOnLocationWithCaster(point, "memes_of_dota.SobolevUlt", caster)
	end
	TeleportHeroToPoint(caster, point)
	caster:AddNoDraw()
end

function TeleportHeroToPoint(hero, point)
	hero:SetAbsOrigin(point)
	FindClearSpaceForUnit(hero, point, false)
	hero:Stop()
end

function RemoveDraw(keys)
	keys.caster:RemoveNoDraw()
end

function DamageTargetsSobolev(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local Mult = keys.Mult
	local TotalDamage = 0
	local targetStrength = 0
	
	if target:IsHero() then
		targetStrength = target:GetStrength()
	end
	local casterStrength = caster:GetStrength()
	
	local Raznica = casterStrength - targetStrength
	
	if Raznica > 0 then
		TotalDamage = Raznica * Mult
		ApplyDamage({victim = target, attacker = caster, damage = TotalDamage, damage_type = ability:GetAbilityDamageType()})
	end
end

LinkLuaModifier( "modifier_player_leave", "modifier_player_leave.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyModifierSobolevTP(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local Talent2 = caster:FindAbilityByName("special_bonus_unique_pangolier_3")
	local stacks = 0
	if caster:HasModifier("modifier_charges") then
		stacks = caster:GetModifierStackCount( "modifier_charges", ability )
		print(stacks)
	end
	if Talent2:GetLevel() == 1 and stacks > 0 then
		ability:EndCooldown()
	end
	
	local Talent = caster:FindAbilityByName("special_bonus_unique_pangolier_2")
	if Talent:GetLevel() == 1 then
		target:AddNewModifier(caster, target, "modifier_player_leave", {Duration = 2})
	end
end

function FindPidorsVision(keys)
	AddFOWViewer(keys.caster:GetTeamNumber(), keys.target:GetAbsOrigin(), 250, 0.15, true)
end

function ReturnDamageMOD(event)
	print(dump(event))
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local damage = event.DamageTaken
	local Mult = event.Mult / 100
	local TotalDamage = damage * Mult
	
	if attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = attacker, attacker = caster, damage = TotalDamage, damage_type = DAMAGE_TYPE_PURE })
	end
end

function bletMailSilence(event)
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability

	if (not attacker:HasModifier("modifier_blet_mail_silence_stack")) then
		ability:ApplyDataDrivenModifier(caster, attacker, "modifier_blet_mail_silence_stack",{Duration = inf})
		attacker:SetModifierStackCount( "modifier_blet_mail_silence_stack", ability, 1 )
	else
		local current_stack = attacker:GetModifierStackCount( "modifier_blet_mail_silence_stack", ability )
		attacker:SetModifierStackCount( "modifier_blet_mail_silence_stack", ability, current_stack + 1 )
		local current_stackFinnaly = attacker:GetModifierStackCount( "modifier_blet_mail_silence_stack", ability )
		if current_stackFinnaly >= 6 then
			attacker:SetModifierStackCount( "modifier_blet_mail_silence_stack", ability, 6 )
		end
	end
end

function bletMailSilenceApply(keys)
	local caster = keys.caster
	local ability = keys.ability 

	local SilenceThisTarget = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for count, hero in ipairs(SilenceThisTarget) do
		if hero:HasModifier("modifier_blet_mail_silence_stack") then
			local current_stack = hero:GetModifierStackCount( "modifier_blet_mail_silence_stack", ability )
			local Duration = current_stack * keys.attackDur
			ability:ApplyDataDrivenModifier(caster, hero, "modifier_blet_mail_silence",{Duration = Duration})
			hero:RemoveModifierByName("modifier_blet_mail_silence_stack")
		end
	end
end
	
function GlobalPidors(keys)
	EmitGlobalSound("memes_of_dota.FindPidors")
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function CubeVars(keys)
	local ability = keys.ability
	
	ability.DamageToTarget = 0
end

function CubeDebuff(event)
	print(dump(event))
	local unit = event.unit
	local attacker = event.attacker
	local ability = event.ability
	local damage = event.DamageTaken
	ability.DamageToTarget = ability.DamageToTarget + damage
	
	unit:SetHealth(ability.target_hp_old)
end

function CubeDebuffHealth( keys )
	local target = keys.target
	local ability = keys.ability

	ability.target_hp_old = ability.target_hp_old or target:GetMaxHealth()
	ability.target_hp = ability.target_hp or target:GetMaxHealth()

	ability.target_hp_old = ability.target_hp
	ability.target_hp = target:GetHealth()
end

function CubeApplyDamage(keys)
	local target = keys.target
	local ability = keys.ability
	local caster = keys.caster
	
	if ability.DamageToTarget ~= 0 then
		ApplyDamage({ victim = target, attacker = caster, damage = ability.DamageToTarget * 2, damage_type = DAMAGE_TYPE_MAGICAL })
	end
end

function RandomGivePresent(keys)
	local caster = keys.caster
	local ability = keys.ability
	local RandomDropFromPresents = 
	{
		"item_chain",
		"item_hook",
		"item_branches",
		"item_magic_stick",
		"item_dinamit",
		"item_boots_of_elves",
		"item_gauntlets",
		"item_robe",
		"item_stout_shield",
		"item_blades_of_attack",
		"item_orb_of_venom",
		"item_quelling_blade",
		"item_wraith_band",
		"item_bounty",
		"item_flask",
		"item_sobi_mask",
		"item_enchanted_mango"
	}
	local rInt = RandomInt(1,#RandomDropFromPresents)
	caster:AddItem(CreateItem(RandomDropFromPresents[rInt], caster, caster))
	for i=0, 14 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_new_year_present" then
				caster:RemoveItem(current_item)
				local oldItemSlot = i
				for j=0,14 do
					local current_itemTwo = caster:GetItemInSlot(j)
					if current_itemTwo ~= nil then
						if current_itemTwo:GetName() == RandomDropFromPresents[rInt] then
							caster:SwapItems(j, oldItemSlot)
							break
						end
					end
				end
			end
		end
	end
end

function StartZalpRaket(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:HasScepter() then
		local info = {
			Target = target,
			Source = caster,
			Ability = ability,
			EffectName = particle_name,
			bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = 700,
			iVisionRadius = 175,
			iVisionTeamNumber = caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		}
		ProjectileManager:CreateTrackingProjectile( info )
		local info2 = {
			Target = target,
			Source = caster,
			Ability = ability,
			EffectName = particle_name,
			bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = 500,
			iVisionRadius = 175,
			iVisionTeamNumber = caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		}
		ProjectileManager:CreateTrackingProjectile( info2 )
	end
end

function StunTargetInvoker(keys)
	local caster = keys.caster
	local target = keys.target
	local StunDur = keys.Stun
	if caster:FindAbilityByName("special_bonus_unique_invoker_2"):GetLevel() == 1 then
		StunDur = keys.StunTalent
	end
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = StunDur})
end

function CheckerInvoker(keys)
	local caster = keys.caster
	if caster:FindAbilityByName("special_bonus_unique_invoker_3") then
		if caster:FindAbilityByName("special_bonus_unique_invoker_3"):GetLevel() == 1 then
			caster:RemoveModifierByName("modifier_bonus_check_talent")
			caster:RemoveModifierByName("modifier_invoker_passive")
			caster:AddNewModifier(caster, caster, "modifier_invoker_passive", {Duration = inf})
			caster:RemoveModifierByName("modifier_bonus_check_talent")
		end
	end
end

ThisBananaUpgrade = false

function LevelUpAbilityMakakaBanana(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_level = ability:GetLevel()
	
	if ThisBananaUpgrade == false then
		local ability_handle = caster:FindAbilityByName("Makaka_banan")	
		if ability_handle then
			ability_handle:SetLevel(ability_level)
		end
	end
end

function MakakaBanana(keys)
	local ability = keys.ability
	local caster = keys.caster
	caster:FindAbilityByName("Makaka_tp_to_target_banana"):SetActivated(false)
	ability.target = nil
end

function LevelUpAbilityMakakaBananaTp(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_level = ability:GetLevel()
	ThisBananaUpgrade = true
	local ability_handle = caster:FindAbilityByName("Makaka_tp_to_target_banana")	
	if ability_handle then
		ability_handle:SetLevel(ability_level)
	end
	ThisBananaUpgrade = false
end

function MakakaBananTp(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abilityTarget = caster:FindAbilityByName("Makaka_banan")
	caster:SetAbsOrigin(abilityTarget.target:GetAbsOrigin() + RandomVector(100))
	ability:SetActivated(false)
	if not caster.banana_illusions then
		caster.banana_illusions = {}
	end

	-- Kill the old images
	for k,v in pairs(caster.banana_illusions) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
		end
	end

	-- Start a clean illusion table
	caster.banana_illusions = {}
end

function SpawnIllusions(event)
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local target = event.target
	local unit_name = caster:GetUnitName()
	local duration = ability:GetLevelSpecialValueFor( "duration_life", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "damage_illusions", ability:GetLevel() - 1 )
	local maxCountIllusions = ability:GetLevelSpecialValueFor( "max_illusions", ability:GetLevel() - 1 )
	caster:FindAbilityByName("Makaka_tp_to_target_banana"):SetActivated(true)
	
	ability.target = target
	
	caster.banana_illusions = {}

	for i=1,maxCountIllusions do
		local origin = target:GetAbsOrigin() + RandomVector(100)
		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, true)
		local order = 
		{
			UnitIndex = illusion:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}

		ExecuteOrderFromTable(order)
		illusion:SetForceAttackTarget(target)
		
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
				if abilitySlot ~= 4 then
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion:FindAbilityByName(abilityName)
					illusionAbility:SetLevel(abilityLevel)
				else
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion:FindAbilityByName(abilityName)
					illusionAbility:SetLevel(0)
				end
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
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 100 })
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		
		ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_illusion_makaka", nil)
		table.insert(caster.banana_illusions, illusion)
	end
end

function CheckAghanimDrowRage(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_drow_imba_rage_aghanim", {Duration = keys.Dur})
	end
end

LinkLuaModifier( "modifier_min_movespeed_papic", "modifier_min_movespeed_papic.lua" ,LUA_MODIFIER_MOTION_NONE )

function PapicGovnoStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if (not target:HasModifier("modifier_stack_slow")) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_stack_slow",{Duration = inf})
		target:SetModifierStackCount( "modifier_stack_slow", ability, 1 )
	else
		local current_stack = target:GetModifierStackCount( "modifier_stack_slow", ability )
		target:SetModifierStackCount( "modifier_stack_slow", ability, current_stack + 1 )
	end
end

function PapicGovnoStartEnd(keys)
	local caster = keys.caster
	local target = keys.target
	
	target:AddNewModifier(caster, target, "modifier_min_movespeed_papic", { Duration = 2.0 })
end

function PapicGovnoEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local current_stack = target:GetModifierStackCount( "modifier_stack_slow", ability )
	target:SetModifierStackCount( "modifier_stack_slow", ability, current_stack - 1 )
	if current_stack == 1 then
		target:RemoveModifierByName("modifier_stack_slow")
	end
end

function PapicGovnoEndStart(keys)
	local caster = keys.caster
	local target = keys.target
	
	target:RemoveModifierByName("modifier_min_movespeed_papic")
end

function CheckHealthPA(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local casterHealthPrc = caster:GetHealth() / caster:GetMaxHealth()
	local casterNoHealth = ((caster:GetMaxHealth() - caster:GetHealth()) / caster:GetMaxHealth()) / 0.01
	if casterNoHealth > 0 then
		if (not caster:HasModifier("modifier_PA_PASSIVE_stacks_miss")) then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_PA_PASSIVE_stacks_miss", {Duration = inf})
		end
		caster:SetModifierStackCount( "modifier_PA_PASSIVE_stacks_miss", ability, casterNoHealth )
	else
		caster:RemoveModifierByName("modifier_PA_PASSIVE_stacks_miss")
	end
end

function GoodwinDistanceDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local DistanceDamage = keys.DDPrc
	local vector_distance = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local damage = (distance / 100) * DistanceDamage
	
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
end

function LevelUpAbilityKnuckSpit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local Tability = caster:FindAbilityByName("Knuckles_knuck_knuck")
	Tability:SetLevel(ability:GetLevel())
end

LinkLuaModifier( "modifier_goodwin_cast_range", "modifier_goodwin_cast_range.lua" ,LUA_MODIFIER_MOTION_NONE )

function OnGoodwinCastRange(keys)
	local caster = keys.caster
	caster:AddNewModifier(caster, caster, "modifier_goodwin_cast_range", { Duration = inf })
end

function OffGoodwinCastRange(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_goodwin_cast_range")
end

function OffGoodwinCastRangeCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mana = caster:GetMana()
	local manacost = ability:GetManaCost(ability:GetLevel())
	
	if mana < manacost then
		caster:RemoveModifierByName("modifier_goodwin_cast_range")
		ability:ToggleAbility()
	end
end

LinkLuaModifier( "modifier_agent_block_damage", "modifier_agent_block_damage.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyModifierAgent(keys)
	local caster = keys.caster
	local ability = keys.ability
	local Talent = caster:FindAbilityByName("special_bonus_unique_templar_assassin_3")
	local Dur = keys.Dur
	caster.targetBlockDamageAgent = keys.Block
	if Talent:GetLevel() == 1 then
		local stacks = caster:GetModifierStackCount( "modifier_agent_fuck_caster", ability )
		caster.targetBlockDamageAgent = caster.targetBlockDamageAgent * stacks
	end
	caster:AddNewModifier(caster, caster, "modifier_agent_block_damage", { Duration = Dur })
end

function CheckDeathUnitsTuzPik( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_item_tuz_pik_stack"

	local bloodstone_in_highest_slot = nil
	for i=0, 5  do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then			
			if current_item:GetName() == "item_tuz_pik" then
				bloodstone_in_highest_slot = current_item
			end
		end
	end

	if bloodstone_in_highest_slot ~= nil then
		bloodstone_in_highest_slot:SetCurrentCharges(bloodstone_in_highest_slot:GetCurrentCharges() + 1)
		local total_charge_count = bloodstone_in_highest_slot:GetCurrentCharges()
		caster:SetModifierStackCount( modifierStack, ability, total_charge_count )
	end
end

function SetChargesBoth( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierStackSet = "modifier_item_tuz_pik_stack"
	ability:ApplyDataDrivenModifier( caster, caster, modifierStackSet, { Duration = inf })

	local bloodstone_in_highest_slot_set = nil
	Timers:CreateTimer(0.01, function()
		for i=0, 5 do
			local current_item_set = caster:GetItemInSlot(i)
			if current_item_set ~= nil then			
				if current_item_set:GetName() == "item_tuz_pik" then
					bloodstone_in_highest_slot_set = current_item_set
				end
			end
		end

		if bloodstone_in_highest_slot_set ~= nil then
			local current_charges = bloodstone_in_highest_slot_set:GetCurrentCharges()
			if current_charges > 1 then
				bloodstone_in_highest_slot_set:SetCurrentCharges(bloodstone_in_highest_slot_set:GetCurrentCharges() + 0)
				local total_charge_count_set = bloodstone_in_highest_slot_set:GetCurrentCharges()
				caster:SetModifierStackCount( modifierStackSet, ability, total_charge_count_set )
			end
			if current_charges < 1 or current_charges == 1 then
				bloodstone_in_highest_slot_set:SetCurrentCharges(1)
				caster:SetModifierStackCount( modifierStackSet, ability, 1 )
			end
		end
	end)
end

function DeathCasterTuzPik( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_item_tuz_pik_stack"

	local bloodstone_in_highest_slot = nil
	for i=0, 8 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then			
			if current_item:GetName() == "item_tuz_pik" then
				bloodstone_in_highest_slot = current_item
			end
		end
	end

	if bloodstone_in_highest_slot ~= nil then
		bloodstone_in_highest_slot:SetCurrentCharges(math.floor(bloodstone_in_highest_slot:GetCurrentCharges()/1.2))
		local total_charge_count = bloodstone_in_highest_slot:GetCurrentCharges()
		caster:SetModifierStackCount( modifierStack, ability, total_charge_count )
	end
end

function ApplyHealTuzPik(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_item_tuz_pik_stack"
	local Hp = caster:GetMaxHealth() - caster:GetHealth()
	local healPerc = Hp * 0.75

	local bloodstone_in_highest_slot = nil
	for i=0, 5 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then			
			if current_item:GetName() == "item_tuz_pik" then
				bloodstone_in_highest_slot = current_item
			end
		end
	end
	local ChargesCount = bloodstone_in_highest_slot:GetCurrentCharges()
	
	if ChargesCount > 0 then
		if bloodstone_in_highest_slot ~= nil then
			bloodstone_in_highest_slot:SetCurrentCharges(bloodstone_in_highest_slot:GetCurrentCharges() - 1)
			local total_charge_count = bloodstone_in_highest_slot:GetCurrentCharges()
			caster:SetModifierStackCount( modifierStack, ability, total_charge_count )
		end
		caster:Heal(healPerc, caster)
	else
		ability:RefundManaCost()
		ability:EndCooldown()
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
	end
end

function SetUpStackMo(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_item_mo_stacks"
	local abilityUSED = keys.event_ability
	
	if abilityUSED:GetName() ~= "Sobolev_U" and abilityUSED:GetName() ~= "phoenix_icarus_dive_datadriven" and abilityUSED:GetName() ~= "phoenix_icarus_dive_stop_datadriven" and abilityUSED:GetName() ~= "Techies_vihr" and abilityUSED:GetName() ~= "Techies_vihr_talent" and abilityUSED:GetName() ~= "leaqe_vorona" and abilityUSED:GetName() ~= "Goodwin_wywern" and abilityUSED:GetName() ~= "Durov_recode" and abilityUSED:GetName() ~= "satana_rage" and abilityUSED:GetName() ~= "lalka_gen" then
		if not abilityUSED:IsItem() then
			if (not caster:HasModifier(modifierStack)) then
				ability:ApplyDataDrivenModifier(caster, caster, modifierStack,{Duration = 9})
				caster:SetModifierStackCount( modifierStack, ability, 1)
			else
				local modifier_ui_handle = caster:FindModifierByName(modifierStack)
				modifier_ui_handle:SetDuration(9, true)
				local current_stack = caster:GetModifierStackCount( modifierStack, ability )
				caster:SetModifierStackCount( modifierStack, ability, current_stack + 1 )
				local current_stackFinal = caster:GetModifierStackCount( modifierStack, ability )
				if current_stackFinal >= 80 then
					caster:SetModifierStackCount( modifierStack, ability, 80 )
				end
			end
		end
	end
end

function PurgeAllAlcore(keys)
	keys.caster:Purge(false, true, false, true, false)
end

function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = ability:GetLevelSpecialValueFor("leap_distance", ability_level)
	ability.leap_speed = ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end
	
function SlowBloodseeker(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	if target:GetUnitName() == "npc_dota_hero_bloodseeker" then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_blood_slow",{Duration = inf})
	end
end

if GetMapName() ~= "desert_solo_random_mode" then
function CheckTalentCreator(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local Talent = caster:FindAbilityByName("special_bonus_unique_omniknight_1")
	
	if Talent:GetLevel() == 1 then
		if ability:GetCooldownTimeRemaining() ~= 0 then
			ability:EndCooldown()
			ability:StartCooldown(30)
		end
		if caster.creatorhastalented == nil then
			caster.creatorhastalented = true
			caster:RemoveModifierByName("modifier_charges")
			caster:AddNewModifier(caster, ability, "modifier_charges",
				{
					max_count = 2,
					start_count = 2,
					replenish_time = 30
				}
			)
		end
	end
end
end
	
function AlchemistObryad(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local Units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for count, hero in ipairs(Units) do
		if hero:GetUnitName() ~= "npc_dota_hero_alchemist" then
			ability:ApplyDataDrivenModifier(caster, hero, "modifier_rotating",{Duration = 1.0})
			ability:ApplyDataDrivenModifier(caster, hero, "modifier_weed",{Duration = 1.0})
		end
	end
end

function HitPhantomAssassin(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ADamage = keys.ADamage
	local HeroDamage = keys.HeroDamage / 100
	local HDamage = caster:GetAverageTrueAttackDamage(caster) * HeroDamage
	local StandartDamage = ADamage + HDamage
	local MainAbility = caster:FindAbilityByName("phantom_assassin_crit_passive")
	if MainAbility == nil then
		MainAbility = caster:FindAbilityByName("phantom_assassin_crit_passive_talent")
	end
	local MainAbilityLvl = MainAbility:GetLevel() - 1
	local chance = MainAbility:GetLevelSpecialValueFor("crit_chance", MainAbilityLvl)
	local mult = MainAbility:GetLevelSpecialValueFor("mult_crit", MainAbilityLvl)
	if MainAbilityLvl < 1 then
		chance = 0
		mult = 0
	end
	local MultDamage = (StandartDamage / 100) * mult
	
	caster:PerformAttack(target, true, true, false, false, false, true, true)
	if RollPercentage(chance) then
		ApplyDamage({ victim = target, attacker = caster, damage = MultDamage, damage_type = DAMAGE_TYPE_PHYSICAL })
		local Crit = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_impact_dagger_arcana.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(Crit, 0, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(Crit, 1, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(Crit, 6, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(Crit)
	else
		ApplyDamage({ victim = target, attacker = caster, damage = StandartDamage, damage_type = DAMAGE_TYPE_PHYSICAL })
	end
end
	
function STARTAPOCALIPSIS(keys)
	local caster = keys.caster
	local Nears_blink_ranged = caster:FindAbilityByName("Nears_blink_ranged")
	local Nears_blink = caster:FindAbilityByName("Nears_blink")
	caster:SetModelScale(keys.modelscale)
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	GameRules:SetTimeOfDay(0.75)
	EmitGlobalSound("memes_of_dota.NearsUlt")
	if Nears_blink_ranged then
		Nears_blink_ranged:SetActivated(true)
	end
	if Nears_blink then
		Nears_blink:SetActivated(false)
	end
end
	
function ENDAPOCALIPSIS(keys)
	local caster = keys.caster
	local Nears_blink_ranged = caster:FindAbilityByName("Nears_blink_ranged")
	local Nears_blink = caster:FindAbilityByName("Nears_blink")
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	caster:SetModelScale(1.0)
	GameRules:SetTimeOfDay(0.25)
	if Nears_blink_ranged then
		Nears_blink_ranged:SetActivated(false)
	end
	if Nears_blink then
		Nears_blink:SetActivated(true)
	end
end
	
function BlinkCustom(keys)
	local caster = keys.caster
	local target = keys.target
	local point = target:GetAbsOrigin()
	local BlinkStart = ParticleManager:CreateParticle("particles/econ/events/ti6/blink_dagger_start_ti6_lvl2.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(BlinkStart, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
	
	caster:SetAbsOrigin(point)
	FindClearSpaceForUnit(caster, point, false)
	local BlinkStart = ParticleManager:CreateParticle("particles/econ/events/ti6/blink_dagger_end_ti6_lvl2.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(BlinkStart, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
end
	
function LevelUpAbilityNearsBlink(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_level = ability:GetLevel()
	local ability_handle = caster:FindAbilityByName("Nears_blink_ranged")	
	ability_handle:SetLevel(ability_level)
end
	
function OnHitAttackNears(event)
	local ability = event.ability
	local caster = event.caster
	local target = event.target
	local manaburnpersoul = event.manaburnpersoul
	local ability_handle = caster:FindAbilityByName("Nears_souls")	
	local abilityHandleLvl = ability_handle:GetLevel() - 1
	local souls = ability_handle:GetLevelSpecialValueFor("souls", abilityHandleLvl)
	local mana_drain = manaburnpersoul * souls
	local target_mana = target:GetMana()

	if target_mana >= mana_drain then
		target:ReduceMana(mana_drain)
	else
		target:ReduceMana(target_mana)
	end
	if target_mana < 0 then
		target_mana:SetMana(0)
	end
end
	
function NearsMove(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local Dur = keys.Dur
	local Talent2 = caster:FindAbilityByName("special_bonus_unique_tidehunter_3")	
	if Talent2:GetLevel() == 1 then
		Dur = Dur + 1
	end
	local Dura = Dur + 0.1
	
	if not target:HasModifier("modifier_prop_nears") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_prop_nears",{Duration = Dura})
		ApplyDamage({ victim = target, attacker = caster, damage = keys.damage, damage_type = DAMAGE_TYPE_PURE })
		local DamageP = ParticleManager:CreateParticle("particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_damage.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(DamageP, 0, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(DamageP, 1, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
	end
end

function NearsMoveEnd(keys)
	local caster = keys.caster
	local Units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for count, hero in ipairs(Units) do
		if hero:HasModifier("modifier_prop_nears") then
			hero:RemoveModifierByName("modifier_prop_nears")
		end
	end
end

function NearsDamageTeleport(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local Talent = caster:FindAbilityByName("special_bonus_unique_tidehunter")
	caster:EmitSound("Hero_Riki.Blink_Strike.Immortal")
	if Talent then
		if Talent:GetLevel() == 1 then
			ApplyDamage({ victim = target, attacker = caster, damage = keys.damage, damage_type = DAMAGE_TYPE_PURE })
		end
	end
end

function NearsRangedParticle(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = ability:GetCursorPosition()
	local Meteor = ParticleManager:CreateParticle("particles/nears_teleport.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl(Meteor, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,3000))
	ParticleManager:SetParticleControl(Meteor, 1, target)
	ParticleManager:SetParticleControl(Meteor, 2, Vector(0.5,0,0))
end

function NearsMoveInvis(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local Dur = keys.Dur
	local Talent = caster:FindAbilityByName("special_bonus_unique_tidehunter_2")	
	local Talent2 = caster:FindAbilityByName("special_bonus_unique_tidehunter_3")	
	if Talent2:GetLevel() == 1 then
		Dur = Dur + 1
	end
	local Start = ParticleManager:CreateParticle("particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_portal.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(Start, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_nears_move",{Duration = Dur})
	if Talent:GetLevel() == 1 then
		caster:EmitSound("Hero_Weaver.Shukuchi")
		caster:AddNewModifier(caster, ability, "modifier_invisible", {Duration = Dur})
	else
		caster:EmitSound("Ability.Focusfire")
	end
end

function FukaMove(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local dur = 1.0
	local damage = keys.damage
	local Talent = caster:FindAbilityByName("special_bonus_unique_crystal_maiden_4")	
	local Talent2 = caster:FindAbilityByName("special_bonus_unique_crystal_maiden_3")
	if Talent2 then
		if Talent2:GetLevel() == 1 then
			damage = damage + 60
		end
	end
	if Talent then
		if Talent:GetLevel() == 1 then
			dur = 2.0
		end
	end
	
	if not target:HasModifier("modifier_prop_fuka") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_prop_fuka",{Duration = 4.1})
		local Bash = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(Bash, 0, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetOrigin(), true)
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
		local knockbackModifierTable =  {
			should_stun = 1,
			knockback_duration = 0.4,
			duration = 0.4,
			knockback_distance = 200,
			knockback_height = 150,
			center_x = caster:GetAbsOrigin(),
			center_y = caster:GetAbsOrigin(),
			center_z = caster:GetAbsOrigin()
			}
		target:AddNewModifier( caster, ability, "modifier_knockback", knockbackModifierTable )
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = dur})
	end
end

function FukaMoveEnd(keys)
	local caster = keys.caster
	local Units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for count, hero in ipairs(Units) do
		if hero:HasModifier("modifier_prop_fuka") then
			hero:RemoveModifierByName("modifier_prop_fuka")
		end
	end
end

function FukaGroup(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	
	local casterPoint = caster:GetAbsOrigin()
	local front_position = casterPoint + caster:GetForwardVector() * 150
	local RandPoint = front_position + RandomVector(RandomFloat(50,75))
	target:SetAbsOrigin(RandPoint)
	FindClearSpaceForUnit(target, RandPoint, false)
	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 1.0})
end

function FukaGroupEffect(keys)
	local caster = keys.caster
	local Rp = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl(Rp, 0, Vector(0.2,0,0))
	ParticleManager:SetParticleControl(Rp, 1, Vector(650,0,0))
	ParticleManager:SetParticleControl(Rp, 2, Vector(0.4,0,0))
	ParticleManager:SetParticleControl(Rp, 3, caster:GetAbsOrigin())
end

function FukaSound(keys)
	EmitGlobalSound("memes_of_dota.FukaFairWind")
end
	
LinkLuaModifier( "modifier_double_putin", "modifier_double_putin.lua", LUA_MODIFIER_MOTION_NONE )	
	
function PutinAganimDvoinik(keys)
	local ability = keys.ability
	local caster = keys.caster
	local spawn_location = caster:GetAbsOrigin()
	local duration = keys.Duration
	local health_after_cast = caster:GetHealth()
	local mana_after_cast = caster:GetMana()
	local player = caster:GetPlayerID()

	local double = CreateUnitByName(caster:GetUnitName(), spawn_location, true, caster, nil, caster:GetTeamNumber())
	double:SetPlayerID(player)
	double:SetControllableByPlayer(player, true)

	local caster_level = caster:GetLevel()
	for i = 2, caster_level do
		double:HeroLevelUp(false)
	end


	for ability_id = 0, 15 do
		local abilityH = double:GetAbilityByIndex(ability_id)
		if abilityH then
			abilityH:SetLevel(caster:GetAbilityByIndex(ability_id):GetLevel())
			if abilityH:GetName() == "Putin_aganim_dvoinik" or abilityH:GetName() == "Putin_Dimon" then
				abilityH:SetActivated(false)
			end
		end
	end


	for item_id = 0, 5 do
		local item_in_caster = caster:GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			local item_name = item_in_caster:GetName()
			if not (item_name == "item_aegis" or item_name == "item_smoke_of_deceit" or item_name == "item_recipe_refresher" or item_name == "item_refresher" or item_name == "item_ward_observer" or item_name == "item_ward_sentry") then
				local item_created = CreateItem( item_in_caster:GetName(), double, double)
				local item = double:AddItem(item_created)
				if item_in_caster:GetCurrentCharges() ~= nil then
					item:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
				end
			end
		end
	end

	double:SetHealth(health_after_cast)
	double:SetMana(mana_after_cast)

	double:SetMaximumGoldBounty(0)
	double:SetMinimumGoldBounty(0)
	double:SetDeathXP(0)
	double:SetAbilityPoints(0) 

	double:SetHasInventory(false)
	double:SetCanSellItems(false)
	
	double:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration})
	
	double:MakeIllusion()
end	
	
function CheckAghanimPutin(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if ability.HandleHui ~= nil then
		if caster:HasScepter() then
			if ability.handleP == nil then
				ability.handleP = true
				ability:SetHidden(false)
			end
		else
			if ability.handleP == true then
				ability.handleP = nil
				ability:SetHidden(true)
			end
		end
	end
end
	
function TowersMoveAghanim(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local TowerAttack = CreateUnitByName("npc_dota_creature_tower_attack1", point, true, caster, nil, caster:GetTeamNumber())
	TowerAttack:AddNewModifier(caster, TowerAttack, "modifier_kill", {Duration = keys.duration})
	TowerAttack:SetOwner(caster)
	TowerAttack:SetControllableByPlayer(caster:GetPlayerID(), false)
	local lvl = ability:GetLevel() - 1
	TowerAttack:CreatureLevelUp(lvl)
	ability:ApplyDataDrivenModifier(caster, TowerAttack, "modifier_beastmaster_boar",{Duration = inf})
end
	
function MultiAttacksTower(keys)
	local caster = keys.caster
	local casterC = caster:GetOwner()
	if casterC:HasScepter() then
		local caster_location = caster:GetAbsOrigin()
		local ability = keys.ability
		local target_type = DOTA_UNIT_TARGET_ALL
		local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
		local target_flags = DOTA_UNIT_TARGET_FLAG_NONE
		local attack_target = caster:GetAttackTarget()
		if not ability.IsAttacking then
			local split_shot_targets = FindUnitsInRadius(casterC:GetTeam(), caster_location, nil, 700, target_team, target_type, target_flags, FIND_CLOSEST, false)
			ability.IsAttacking = true
			for _,v in pairs(split_shot_targets) do
				if v ~= attack_target then
					caster:PerformAttack(v, true, true, true, false, true, false, false)
					v = nil
				end
			end
			ability.IsAttacking = false
		end
	end
end

function SniperAghanim(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_blinding_light_sniper_ag",{Duration = keys.dur})
	end
end
	
function TrueSightTalent(keys)
	local caster = keys.caster
	local casterC = caster:GetOwner()
	if casterC then
		local Talent = casterC:FindAbilityByName("special_bonus_unique_omniknight_2")	
	
		if Talent:GetLevel() == 1 then
			local target_type = DOTA_UNIT_TARGET_ALL
			local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
			local target_flags = DOTA_UNIT_TARGET_FLAG_NONE
			local caster_location = caster:GetAbsOrigin()
			local split_shot_targets = FindUnitsInRadius(casterC:GetTeam(), caster_location, nil, 700, target_team, target_type, target_flags, FIND_CLOSEST, false)
			for count, unit in ipairs(split_shot_targets) do
				unit:AddNewModifier(caster, ability, "modifier_truesight", {Duration = 0.5})
			end
		end
	end
end
	
function SetStackToTheRoshan(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_stack_ag_roshan"
	if ability.agRoshanHandle == nil then
		ability.agRoshanHandle = 0
	end
	ability.agRoshanHandle = ability.agRoshanHandle + 1
	if caster:HasScepter() then
		if (not caster:HasModifier(modifierStack)) then
			ability:ApplyDataDrivenModifier(caster, caster, modifierStack,{Duration = inf})
			caster:SetModifierStackCount( modifierStack, ability, 1)
		end
		if caster:HasModifier(modifierStack) then
			caster:SetModifierStackCount( modifierStack, ability, ability.agRoshanHandle )
		end
	end
end

function SetColorRoshan(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_stack_ag_roshan"
	
	if caster:HasScepter() then
		if ability.handleAg == nil then
			ability.handleAg = true
			caster:SetMaterialGroup("1")
			if ability.agRoshanHandle ~= nil then
				if (not caster:HasModifier(modifierStack)) then
					ability:ApplyDataDrivenModifier(caster, caster, modifierStack,{Duration = inf})
					caster:SetModifierStackCount( modifierStack, ability, 1)
				end
				if caster:HasModifier(modifierStack) then
					caster:SetModifierStackCount( modifierStack, ability, ability.agRoshanHandle )
				end
			end
		end
	else
		if ability.handleAg == true then
			ability.handleAg = nil
			caster:SetMaterialGroup("0")
			if caster:HasModifier(modifierStack) then
				caster:RemoveModifierByName(modifierStack)
			end
		end
	end
end
	
function AghanimChaosRandom(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local RandInt = RandomInt(1,14)
	
	if caster:HasScepter() then
		if RandInt == 1 then
			print("Is Eul")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_eul_cyclone",{Duration = 2.5})
			target:EmitSound("DOTA_Item.Cyclone.Activate")
		elseif RandInt == 2 then
			print("Is Rod of Atos")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_rod_of_atos_debuff",{Duration = 2})
			target:EmitSound("DOTA_Item.RodOfAtos.Target")
		elseif RandInt == 3 then
			print("Is Urn")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_urn_damage",{Duration = 8})
			target:EmitSound("DOTA_Item.UrnOfShadows.Activate")
		elseif RandInt == 4 then
			print("Is SpiritVessel")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_spirit_vessel_damage",{Duration = 8})
			target:EmitSound("DOTA_Item.SpiritVessel.Target.Enemy")
		elseif RandInt == 5 then
			print("Is cube")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_cube_debuff",{Duration = 3})
			target:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.Cast")
			target:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment")
		elseif RandInt == 6 then
			print("Is nullifier")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_nullifier_mute",{Duration = 5})
			target:EmitSound("DOTA_Item.Nullifier.Target")
		elseif RandInt == 7 then
			print("Is abyssal")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_stunned",{Duration = 2})
			target:EmitSound("DOTA_Item.AbyssalBlade.Activate")
		elseif RandInt == 8 then
			print("Is medallion")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_medallion_of_courage_datadriven_debuff",{Duration = 7})
			target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		elseif RandInt == 9 then
			print("Is solar crest")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_solar_crest_mod_debuff",{Duration = 7})
			target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		elseif RandInt == 10 then
			print("Is orchid")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_orchid_malevolence_debuff",{Duration = 5})
			target:EmitSound("DOTA_Item.Orchid.Activate")
		elseif RandInt == 11 then
			print("Is ethereal")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_ethereal_blade_ethereal",{Duration = 3})
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_ethereal_blade_slow",{Duration = 3})
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_ethereal_blade_mod",{Duration = 3})
			target:EmitSound("DOTA_Item.EtherealBlade.Target")
			local Damage = 2*caster:GetPrimaryStatValue() + 75
	
			ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_MAGICAL })
		elseif RandInt == 12 then
			print("Is diffusal")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_diffusal_blade_slow",{Duration = 4})
			target:EmitSound("DOTA_Item.DiffusalBlade.Target")
		elseif RandInt == 13 then
			print("Is dagon")
			local Dagon = ParticleManager:CreateParticle("particles/econ/events/ti5/dagon_ti5.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(Dagon, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
			ParticleManager:SetParticleControlEnt(Dagon, 1, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetOrigin(), true)
			local Damage = 800
	
			ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_MAGICAL })
			target:EmitSound("DOTA_Item.Dagon.Activate")
		elseif RandInt == 14 then
			print("Is alebarda")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_heavens_halberd_debuff",{Duration = 3})
			target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
		end
	end
end
	
function DAmageSpiritVessel(keys)
	local caster = keys.caster
	local target = keys.target
	local Damage = (target:GetHealth() / 100) * 4.5 + 20
	
	ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_MAGICAL })
end
	
function DAmageUrn(keys)
	local caster = keys.caster
	local target = keys.target
	local Damage = 25
	
	ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_PURE })
end
	
function OrchidDamageN(event)
	local unit = event.unit
	local attacker = event.attacker
	local ability = event.ability
	local damage = event.DamageTaken
	if ability.DamageToTargetOr == nil then
		ability.DamageToTargetOr = 0
	end
	ability.DamageToTargetOr = ability.DamageToTargetOr + damage
end

function OrchidDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Damage = ability.DamageToTargetOr / 100 * 30
	ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_MAGICAL })
	ability.DamageToTargetOr = 0
end
	
function AdBootsDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local TargetDamage = (target:GetMaxHealth() / 100) * 2.5
	ApplyDamage({ victim = target, attacker = caster, damage = keys.Damage + TargetDamage, damage_type = DAMAGE_TYPE_MAGICAL })
end
	
function DamageDurovAirplanes(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability.Handle == nil then
		ability.Handle = true
		target:EmitSound("Hero_WarlockGolem.Attack")
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_durov_agr",{Duration = 0.9})
end

function DurovAgrUp(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:SetForceAttackTarget(nil)
	local order = 
	{
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = caster:entindex()
	}

	ExecuteOrderFromTable(order)
	target:SetForceAttackTarget(caster)
end

function DurovAgrDown(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:SetForceAttackTarget(nil)
end

function DurovHandle(keys)
	local ability = keys.ability
	ability.Handle = nil
end

function DurovRecode(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	for i=0, 8 do
		local current_item = caster:GetItemInSlot(i)
		if current_item and not current_item:IsCooldownReady() then
			if current_item:GetName() ~= "item_refresher" then
				current_item:EndCooldown()
			end
		end
	end
	for i=0,5 do
		local abilityF = caster:GetAbilityByIndex(i)
		if abilityF and not abilityF:IsCooldownReady() then
			abilityF:EndCooldown()
		end
	end
	caster:StopSound("memes_of_dota.durov_ult")
end

function DurovParticleRes(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local Particle = ParticleManager:CreateParticle("particles/durov_aoe.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(Particle, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(Particle, 1, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetOrigin(), true)
	ParticleManager:SetParticleControl(Particle, 2, Vector(600,1,1))
end

function DurovResMiss(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local Talent = keys.caster:FindAbilityByName("special_bonus_unique_earth_spirit")
	if Talent:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_durov_talent_miss",{Duration = 1.75})
	end
end
	
function CalculateDamageKod( keys )
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

function RemoveDamageKod ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local backtrack_time = keys.BacktrackTime
	local damage_sum = 0
	local caster_index = 0
	
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
end
	
function ZTDAmageIT(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local Damage = keys.Damage
	if target.DamagePluss == nil then
		target.DamagePluss = 0
	end
	local DamageEnd = Damage + target.DamagePluss
	
	ApplyDamage({ victim = target, attacker = caster, damage = DamageEnd, damage_type = DAMAGE_TYPE_PURE })
	
	if target:GetTeam() ~= caster:GetTeam() then
		target.DamagePluss = target.DamagePluss + keys.DamagePlus
	end
end
	
function ZTDAmageITValue(keys)
	local target = keys.target
	target.DamagePluss = 0
end
	
function ZTApplyMOD(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	if target ~= caster then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_ZT_it_enemy",{Duration = 1.0})
	end
end

function GiveXpGoldMOD(keys)
	local split_shot_targets = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	for count, Unit in ipairs(split_shot_targets) do
		if Unit ~= nil and Unit ~= keys.caster and Unit:IsRealHero() then
			Unit:ModifyGold(keys.Gold, false, 0)
			Unit:AddExperience(keys.Xp, 0, false, false)
		end
	end
end

function GiveGoldKnigaSoboleva(keys)
	keys.caster:ModifyGold(keys.Gold, false, 0)
end

function ZTAttacksChance(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local chance = keys.chance
	if caster:HasModifier("modifier_ZT_s") then
		chance = 100
	end
	
	if RollPercentage(chance) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_ZT_it_attack_enemy",{Duration = keys.duration})
		EmitSoundOn("DOTA_Item.Maim", target)
	end
end
	
function ApplyModifSlardar(keys)
	local Talent = keys.caster:FindAbilityByName("special_bonus_unique_slardar")
	local Dur = keys.Duration
	if Talent:GetLevel() == 1 then
		Dur = Dur - 6
	end
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_damage_sk_suicide",{Duration = Dur})
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_effect_sk_suicide",{Duration = Dur})
end
	
function ApplyDamageSkIp(keys)
	local Talent = keys.caster:FindAbilityByName("special_bonus_unique_slardar_2")
	if Talent:GetLevel() == 1 then
		ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = keys.Damage, damage_type = DAMAGE_TYPE_PHYSICAL })
	end
end

function ApplyOrchidAxe(keys)
	local Talent = keys.caster:FindAbilityByName("special_bonus_unique_axe_2")
	if Talent:GetLevel() == 1 then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_orchid_malevolence_debuff",{Duration = 5})
		keys.target:EmitSound("DOTA_Item.Orchid.Activate")
	end
end

function SetStacksZT(keys)
	local attacks = keys.attacks
	local Talent = keys.caster:FindAbilityByName("special_bonus_unique_legion_commander_4")
	if Talent:GetLevel() == 1 then
		attacks = attacks + 2
	end
	if keys.caster:HasModifier("modifier_ZT_rage") then
		keys.caster:SetModifierStackCount( "modifier_ZT_rage", keys.ability, attacks )
	end
end

function ZTSprintActivate(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_handle = caster:FindAbilityByName("ZT_sprint")	
	ability_handle:SetActivated(true)
	caster:SetModelScale(2.050000)
end

function ZTSprintDeActivate(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_handle = caster:FindAbilityByName("ZT_sprint")	
	ability_handle:SetActivated(false)
	caster:SetModelScale(1.025000)
end
	
function StackDownZT( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_ZT_rage"
	local current_stack = caster:GetModifierStackCount( modifierStack, ability )
	if caster:HasModifier(modifierStack) and current_stack > 0 then
		caster:SetModifierStackCount( modifierStack, ability, current_stack - 1 )
	end
	local current_stackF = caster:GetModifierStackCount( modifierStack, ability )
	if current_stackF <= 0 then
		caster:RemoveModifierByName(modifierStack)
	end
end

function ZTSprint( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	
	local point = ability:GetCursorPosition()

	ProjectileManager:ProjectileDodge(caster)
	
	local distance = (caster:GetAbsOrigin() - point):Length2D()

	-- Ability variables
	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = distance
	ability.leap_speed = 90
	ability.leap_traveled = 0
	ability.leap_z = 0
	local duration = distance/ability.leap_speed
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ZT_moving_damage",{Duration = duration})
	if ability.leap_distance > 900 then
		ability.leap_distance = 900
	end
end

function ZTSprintH( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		caster:RemoveModifierByName("modifier_ZT_moving_damage")
	end
end
	
function UpgradeZTSTELIZA(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_level = ability:GetLevel()
	local ability_handle = caster:FindAbilityByName("ZT_sprint")	
	ability_handle:SetLevel(ability_level)
end

function UndyingInvisibleTalent(keys)
	local caster = keys.caster
	local Talent = caster:FindAbilityByName("special_bonus_unique_undying_3")	
	
	if Talent then
		if Talent:GetLevel() == 1 then
			caster:AddNewModifier(caster, ability, "modifier_invisible", {Duration = inf})
		end
	end
end

function ZTDAmageITAttacks(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local Damage = keys.Damage
	local Talent = caster:FindAbilityByName("special_bonus_unique_legion_commander_2")	
	
	if Talent:GetLevel() == 1 then
		Damage = Damage + 90
	end
	ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_PURE })
end
	
function RandomItemGive(keys)
	local caster = keys.caster
	local ability = keys.ability
	local RandomDropFromPresents = 
	{
		"item_arcane_boots",
		"item_tranquil_boots",
		"item_phase_boots",
		"item_smash_boots",
		"item_medallion_of_courage_datadriven",
		"item_bottle_ass",
		"item_mini_hook_5",
		"item_blink",
		"item_force_staff",
		"item_cyclone",
		"item_ghost",
		"item_vanguard",
		"item_mask_of_madness",
		"item_blade_mail",
		"item_vladmir",
		"item_yasha",
		"item_mekansm",
		"item_hood_of_defiance",
		"item_veil_of_discord",
		"item_glimmer_cape",
		"item_shivas_guard",
		"item_diffusal_blade",
		"item_maelstrom",
		"item_basher",
		"item_invis_sword",
		"item_desolator",
		"item_ultimate_scepter",
		"item_bfury",
		"item_pipe",
		"item_heavens_halberd",
		"item_crimson_guard",
		"item_black_king_bar",
		"item_bloodstone",
		"item_moon_shard",
		"item_sange_and_yasha",
		"item_orchid",
		"item_ethereal_blade",
		"item_monkey_king_bar"
	}
	local rInt = RandomInt(1,#RandomDropFromPresents)
	caster:AddItem(CreateItem(RandomDropFromPresents[rInt], caster, caster))
end
	
function NepgearSlashWaveDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local casterAgility = caster:GetAgility()
	local DamageMult = keys.DM
	local Talent = caster:FindAbilityByName("special_bonus_unique_kunkka_2")
	if Talent then
		if Talent:GetLevel() == 1 then
			DamageMult = DamageMult + 3
		end
	end
	local Damage = casterAgility * DamageMult
	
	ApplyDamage({ victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_PHYSICAL })
end

function NepgearSlashWaveSounds(keys)
	local caster = keys.caster
	
	if caster:HasModifier("modifier_purple_sister") then
		EmitSoundOn("memes_of_dota.hddslash_wave", caster)
	else
		EmitSoundOn("memes_of_dota.slash_wave", caster)
	end
end
	
function ChangePageBogNext(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abil = caster:FindAbilityByName("Bog_back_page")
	
	if ability.Page == 1 then
		ability.Page = 2
		abil.Page = 2
		local Ability1 = "Bog_dusha"
		local Ability2 = "Bog_bad_weather"
		local Ability3 = "Bog_stun"
		local Ability4 = "Bog_weapon_control"
		local Ability5 = "Bog_eyes"
		
		local NeedAbility1 = "Bog_heal"
		local NeedAbility2 = "Bog_shield"
		local NeedAbility3 = "Bog_invul"
		local NeedAbility4 = "Bog_bonus_damage"
		local NeedAbility5 = "Bog_back_page"
		
		caster:SwapAbilities( Ability1, NeedAbility1, false, true )
		caster:SwapAbilities( Ability2, NeedAbility2, false, true )
		caster:SwapAbilities( Ability3, NeedAbility3, false, true )
		caster:SwapAbilities( Ability4, NeedAbility4, false, true )
		caster:SwapAbilities( Ability5, NeedAbility5, false, true )
	elseif ability.Page == 2 then
		ability.Page = 3
		abil.Page = 3
		local Ability1 = "Bog_heal"
		local Ability2 = "Bog_shield"
		local Ability3 = "Bog_invul"
		local Ability4 = "Bog_bonus_damage"
		
		local NeedAbility1 = "Bog_agility"
		local NeedAbility2 = "Bog_slow"
		local NeedAbility3 = "Bog_silence"
		local NeedAbility4 = "Bog_stun_s"
		
		caster:SwapAbilities( Ability1, NeedAbility1, false, true )
		caster:SwapAbilities( Ability2, NeedAbility2, false, true )
		caster:SwapAbilities( Ability3, NeedAbility3, false, true )
		caster:SwapAbilities( Ability4, NeedAbility4, false, true )
	end
end

function ChangePageBogBack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local abil = caster:FindAbilityByName("Bog_next_page")
	
	if ability.Page == 2 then
		ability.Page = 1
		abil.Page = 1
		local Ability1 = "Bog_dusha"
		local Ability2 = "Bog_bad_weather"
		local Ability3 = "Bog_stun"
		local Ability4 = "Bog_weapon_control"
		local Ability5 = "Bog_eyes"
		
		local NeedAbility1 = "Bog_heal"
		local NeedAbility2 = "Bog_shield"
		local NeedAbility3 = "Bog_invul"
		local NeedAbility4 = "Bog_bonus_damage"
		local NeedAbility5 = "Bog_back_page"
		
		caster:SwapAbilities( Ability1, NeedAbility1, true, false )
		caster:SwapAbilities( Ability2, NeedAbility2, true, false )
		caster:SwapAbilities( Ability3, NeedAbility3, true, false )
		caster:SwapAbilities( Ability4, NeedAbility4, true, false )
		caster:SwapAbilities( Ability5, NeedAbility5, true, false )
	elseif ability.Page == 3 then
		ability.Page = 2
		abil.Page = 2
		local Ability1 = "Bog_heal"
		local Ability2 = "Bog_shield"
		local Ability3 = "Bog_invul"
		local Ability4 = "Bog_bonus_damage"
		
		local NeedAbility1 = "Bog_agility"
		local NeedAbility2 = "Bog_slow"
		local NeedAbility3 = "Bog_silence"
		local NeedAbility4 = "Bog_stun_s"
		
		caster:SwapAbilities( Ability1, NeedAbility1, true, false )
		caster:SwapAbilities( Ability2, NeedAbility2, true, false )
		caster:SwapAbilities( Ability3, NeedAbility3, true, false )
		caster:SwapAbilities( Ability4, NeedAbility4, true, false )
	end
end
	
function SunStrikeParticleBog(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local DamageRadius = keys.DamageRadius
	local Damage = keys.Damage
	local DamageTalent = keys.DamageTalent
	local playerID = caster:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)
	local particle = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	ParticleManager:SetParticleControl(particle, 1, Vector(375,375,375))
	local DamageFind = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, DamageRadius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for count,unit in pairs(DamageFind) do
		ApplyDamage({victim = unit, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
	end
end
	
function BogDamageAtHealth(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	target:EmitSound("Hero_DoomBringer.Devour")
	
	ApplyDamage({victim = target, attacker = caster, damage = target:GetMaxHealth() / 100 * keys.Damage, damage_type = ability:GetAbilityDamageType()})
end

function BogHealAtHealth(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	target:Heal(target:GetMaxHealth() / 100 * keys.Heal, target)
end

function BogArmorReduce(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifierStack = "modifier_bog_armor_reduce"
	local Damage = keys.Damage
	local Interval = keys.Interval
	if caster:FindAbilityByName("special_bonus_unique_shadow_demon_2") then
		if caster:FindAbilityByName("special_bonus_unique_shadow_demon_2"):GetLevel() == 1 then
			Interval = Interval - 0.2
		end
	end
	
	Timers:CreateTimer(keys.Duration, function()
		Timers:RemoveTimer("BogReduceArmor")
	end)
	
	Timers:CreateTimer("BogReduceArmor", {
		useGameTime = true,
		endTime = 0,
		callback = function()
			local DamageFind = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	
			for count,target in pairs(DamageFind) do
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
				-- Raise 1000 value if you increase the camera height above 1000
				ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1500 ))
				ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( particle, 2, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
				if (not target:HasModifier(modifierStack)) then
					ability:ApplyDataDrivenModifier(caster, target, modifierStack,{Duration = 15})
					target:SetModifierStackCount( modifierStack, ability, 1)
				else
					local current_stack = target:GetModifierStackCount( modifierStack, ability )
					target:SetModifierStackCount( modifierStack, ability, current_stack + 1 )
					local modifier_ui_handle = target:FindModifierByName(modifierStack)
					modifier_ui_handle:SetDuration(15, true)
				end
				ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
			end
			return Interval
		end
	  })
end
	
function BoltParticle(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Damage = keys.Damage
	if caster:FindAbilityByName("special_bonus_unique_shadow_demon_6"):GetLevel() == 1 then
		Damage = Damage + 175
	end
	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
	-- Raise 1000 value if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1500 ))
	ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
	ParticleManager:SetParticleControlEnt( particle, 2, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
	
	ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.Stun})
	
	target:EmitSound("Hero_Zuus.LightningBolt")
	
	if caster:FindAbilityByName("special_bonus_unique_shadow_demon_1"):GetLevel() == 1 then
		Timers:CreateTimer(3, function()
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
			-- Raise 1000 value if you increase the camera height above 1000
			ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1500 ))
			ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( particle, 2, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
			
			ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.Stun})
		end)
		Timers:CreateTimer(6, function()
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
			-- Raise 1000 value if you increase the camera height above 1000
			ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1500 ))
			ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( particle, 2, target, PATTACH_POINT, "attach_hitloc" , target:GetOrigin(), true )
			
			ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.Stun})
		end)
	end
	if caster:FindAbilityByName("special_bonus_unique_shadow_demon_7"):GetLevel() == 1 then
		local DamageFind = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		for count,unit in pairs(DamageFind) do
			if unit ~= target then
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
				-- Raise 1000 value if you increase the camera height above 1000
				ParticleManager:SetParticleControl(particle, 1, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,1500 ))
				ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT, "attach_hitloc" , unit:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( particle, 2, unit, PATTACH_POINT, "attach_hitloc" , unit:GetOrigin(), true )
				
				ApplyDamage({victim = unit, attacker = caster, damage = Damage, damage_type = ability:GetAbilityDamageType()})
				unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.Stun})
			end
		end
	end
end
	
function BogPurge(keys)
	local target = keys.target
	
	target:Purge(false, true, false, true, false)
end
	
function BogWeaponControl(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	ApplyDamage({victim = target, attacker = caster, damage = target:GetAverageTrueAttackDamage(target) / 100 * keys.Damage, damage_type = ability:GetAbilityDamageType()})
end

function BogSetNightAndRain(keys)
	local caster = keys.caster
	GameRules:SetTimeOfDay(0.75)
	if caster.particleRainBog ~= nil then
		ParticleManager:DestroyParticle(caster.particleRainBog, true)
	end
	caster.particleRainBog = ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_rain.vpcf", PATTACH_EYES_FOLLOW, caster, PlayerResource:GetPlayer(caster:GetPlayerID()))
	EmitGlobalSound("lightning.thunder")
	EmitGlobalSound("memes_of_dota.Bog_bad_weather")
	Timers:CreateTimer(10.0, function()
		DestroyNightAndRain(keys)
	end)
end

function BogSetRainWeather(keys)
	local target = keys.target
	if target.particleRainBog ~= nil then
		ParticleManager:DestroyParticle(target.particleRainBog, true)
	end
	target.particleRainBog = ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_rain.vpcf", PATTACH_EYES_FOLLOW, target, PlayerResource:GetPlayer(target:GetPlayerID()))
end

function DestroyNightAndRain(keys)
	local caster = keys.caster
	GameRules:SetTimeOfDay(0.25)
	ParticleManager:DestroyParticle(caster.particleRainBog, true)
end

function DestroyRainTarget(keys)
	local target = keys.target
	ParticleManager:DestroyParticle(target.particleRainBog, true)
end
	
function BogKill(keys)
	local caster = keys.caster
	local DamageFind = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	
	for count,unit in pairs(DamageFind) do
		if unit:GetUnitName() == "npc_dota_hero_shadow_demon" then
			unit:Kill(keys.ability, caster)
		end
	end
end
	
function BogEyes(keys)
	AddFOWViewer(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), 9999999, 0.04, false)
end
	
function ScepterDruzko(keys)
	local caster = keys.caster
	if caster:HasScepter() then
		for knig=1, keys.ScepterKnigs do
			local DamageFind = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 1100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
			local RandomUnit = RandomInt(1, #DamageFind)
			
			for count,unit in pairs(DamageFind) do
					if count == RandomUnit then
						Timers:CreateTimer(0.1*ScepterKnigs, function()
							local info2 = {
								Target = unit,
								Source = caster,
								Ability = keys.ability,
								EffectName = "particles/kniga_razdora.vpcf",
								bDodgeable = false,
								bProvidesVision = true,
								iMoveSpeed = 1000,
								iVisionRadius = 250,
								iVisionTeamNumber = caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
								iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
							}
							ProjectileManager:CreateTrackingProjectile( info2 )
						end)
					end
			end
		end
	end
end
	
function BogGlobalSilence(keys)
	EmitGlobalSound("memes_of_dota.Bog_silence")
end
	
function SaveFv( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.casterFv = caster:GetForwardVector()
end

function KnockBackMagicStick( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel()

	target:Stop()
	ProjectileManager:ProjectileDodge(target)

	ability.leap_distance = 900
	ability.leap_speed = 1500 * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

function LeapHorizonalMagic( keys )
	local target = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.casterFv * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		target:InterruptMotionControllers(true)
	end
end

function LeapVerticalMagic( keys )
	local target = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance/2 then
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z))
	else
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z))
	end
end
	
function UpgradeStatsAll( keys )
	local caster = keys.caster
	local ability = keys.ability
	local AllStats = keys.allstats

	caster:ModifyAgility(AllStats)
	caster:ModifyStrength(AllStats)
	caster:ModifyIntellect(AllStats)
end

function GenocideDReturn( keys )
	local caster = keys.caster
	local ability = keys.ability
	local DReturn = keys.DReturn
	local DamageTaken = keys.DamageTaken
	local Returned = DamageTaken / 100 * DReturn
	caster:Heal(Returned, caster)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for i,unit in ipairs(units) do
		if not unit:HasModifier("modifier_return_Murzik") then
			ApplyDamage({ victim = unit, attacker = caster, damage = Returned, damage_type =  DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, ability = ability})
		end
	end
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	