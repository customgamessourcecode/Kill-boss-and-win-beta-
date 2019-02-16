
-------------------------------------------
--			  Icarus Dive
-------------------------------------------
LinkLuaModifier("modifier_imba_phoenix_icarus_dive_dash_dummy", "hero/hero_phoenix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_icarus_dive_extend_burn", "hero/hero_phoenix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_icarus_dive_ignore_turn_ray", "hero/hero_phoenix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_icarus_dive_slow_debuff", "hero/hero_phoenix", LUA_MODIFIER_MOTION_NONE)

imba_phoenix_icarus_dive = imba_phoenix_icarus_dive or class({})

function imba_phoenix_icarus_dive:IsHiddenWhenStolen() 		return false end
function imba_phoenix_icarus_dive:IsRefreshable() 			return true  end
function imba_phoenix_icarus_dive:IsStealable() 			return true  end
function imba_phoenix_icarus_dive:IsNetherWardStealable() 	return false end
function imba_phoenix_icarus_dive:GetAssociatedSecondaryAbilities() return "imba_phoenix_icarus_dive_stop" end

function imba_phoenix_icarus_dive:GetAbilityTextureName()   return "phoenix_icarus_dive" end

function imba_phoenix_icarus_dive:GetCastPoint()
	local caster= self:GetCaster()
	if caster:HasTalent("special_bonus_imba_phoenix_1") then
		return 0
	else
		return self:GetSpecialValueFor("cast_point")
	end
end

function imba_phoenix_icarus_dive:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function imba_phoenix_icarus_dive:OnAbilityPhaseStart()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	caster:AddNewModifier(caster, self, "modifier_imba_phoenix_icarus_dive_ignore_turn_ray", {} ) -- Add the ignore turn buff to cast dive when sun ray
	return true
end

function imba_phoenix_icarus_dive:OnSpellStart()
	if not IsServer() then
		return
	end
	local caster		= self:GetCaster()
	local ability		= self
	local target_point  = self:GetCursorPosition()
	local caster_point  = caster:GetAbsOrigin()

	self.dummy = CreateUnitByName("npc_phoenix_dummy",caster:GetAbsOrigin(),true,caster,caster,caster:GetTeam())
	dummy:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	local hpCost		= self:GetSpecialValueFor("hp_cost_perc")
	local dashLength	= self:GetSpecialValueFor("dash_length")
	local dashWidth		= self:GetSpecialValueFor("dash_width")
	local dashDuration	= self:GetSpecialValueFor("dash_duration")
	local effect_radius = self:GetSpecialValueFor("hit_radius")


	local dummy_modifier	= "modifier_imba_phoenix_icarus_dive_dash_dummy" -- This is used to determain if dive can countinue
	dummy:AddNewModifier(caster, self, dummy_modifier, { duration = dashDuration })

	local _direction = (target_point - caster:GetAbsOrigin()):Normalized()
	dummy:SetForwardVector(_direction)

	local casterOrigin	= caster:GetAbsOrigin()
	local casterAngles	= caster:GetAngles()
	local forwardDir	= caster:GetForwardVector()
	local rightDir		= caster:GetRightVector()

	--caster:SetAngles( casterAngles.x, yaw, casterAngles.z )

	local ellipseCenter	= casterOrigin + forwardDir * ( dashLength / 2 )

	local startTime = GameRules:GetGameTime()

	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf", PATTACH_WORLDORIGIN, nil )

	dummy:SetContextThink( DoUniqueString("updateIcarusDive"), function ( )

		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin() + caster:GetRightVector() * 32 )

		local elapsedTime = GameRules:GetGameTime() - startTime
		local progress = elapsedTime / dashDuration
		self.progress = progress


		-- check for interrupted
		if not dummy:HasModifier( dummy_modifier ) then
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)
			return nil
		end

		-- Calculate potision
		local theta = -2 * math.pi * progress
		local x =  math.sin( theta ) * dashWidth * 0.5
		local y = -math.cos( theta ) * dashLength * 0.5

		local pos = ellipseCenter + rightDir * x + forwardDir * y
		local yaw = casterAngles.y + 90 + progress * -360  

		pos = GetGroundPosition( pos, dummy )
		dummy:SetAbsOrigin( pos )
		dummy:SetAngles( casterAngles.x, yaw, casterAngles.z )

		-- Cut Trees
		GridNav:DestroyTreesAroundPoint(pos, 80, false)

		-- Find Enemies apply the debuff
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
	                                caster:GetAbsOrigin(),
	                                nil,
	                                effect_radius,
	                                DOTA_UNIT_TARGET_TEAM_BOTH,
	                                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_ANY_ORDER,
	                                false)
		for _,enemy in pairs(enemies) do
			if enemy ~= dummy then
				if enemy:GetTeamNumber() ~= dummy:GetTeamNumber() then
					enemy:AddNewModifier(caster, self, "modifier_imba_phoenix_icarus_dive_slow_debuff", {duration = self:GetSpecialValueFor("burn_duration")} )
				else
					enemy:AddNewModifier(caster, self, "modifier_imba_phoenix_burning_wings_ally_buff", {duration = 0.2})
				end
					enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.5} )
					
				end
			end
		end
		enemies = {}

		return 0.03
	end, 0 )

	-- Spend HP cost
	self.healthCost = caster:GetHealth() * hpCost / 100
		local AfterCastHealth = caster:GetHealth() - self.healthCost
		if AfterCastHealth <= 1 then
			caster:SetHealth(1)
		else
			caster:SetHealth(AfterCastHealth)
		end
	

	-- Swap sub ability
end

function imba_phoenix_icarus_dive:OnUpgrade()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()

	-- The ability to level up
	local ability_name = "imba_phoenix_icarus_dive_stop"
	local ability_handle = caster:FindAbilityByName(ability_name)	
	if ability_handle then
		ability_handle:SetLevel(1)
	end
end

modifier_imba_phoenix_icarus_dive_dash_dummy = modifier_imba_phoenix_icarus_dive_dash_dummy or class({})

function modifier_imba_phoenix_icarus_dive_dash_dummy:IsDebuff()			return false end
function modifier_imba_phoenix_icarus_dive_dash_dummy:IsHidden() 			return true  end
function modifier_imba_phoenix_icarus_dive_dash_dummy:IsPurgable() 			return false end
function modifier_imba_phoenix_icarus_dive_dash_dummy:IsPurgeException() 	return false end
function modifier_imba_phoenix_icarus_dive_dash_dummy:IsStunDebuff() 		return false end
function modifier_imba_phoenix_icarus_dive_dash_dummy:RemoveOnDeath() 		return true  end

function modifier_imba_phoenix_icarus_dive_dash_dummy:GetEffectName() return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance_streak_light.vpcf" end

function modifier_imba_phoenix_icarus_dive_dash_dummy:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
    }
    return decFuns
end

function modifier_imba_phoenix_icarus_dive_dash_dummy:GetModifierIgnoreCastAngle() return 360 end

function modifier_imba_phoenix_icarus_dive_dash_dummy:GetTexture()
	return "phoenix_icarus_dive"
end

function modifier_imba_phoenix_icarus_dive_dash_dummy:OnCreated()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	EmitSoundOn("Hero_Phoenix.IcarusDive.Cast", caster)

	-- Disable Sun Ray spell
	local sun_ray = caster:FindAbilityByName("imba_phoenix_sun_ray")
	if sun_ray then
		sun_ray:SetActivated(false)
	end
end

function modifier_imba_phoenix_icarus_dive_dash_dummy:OnDestroy()
	if not IsServer() then
		return
	end

	local caster = self:GetAbility().dummy
	local point = caster:GetAbsOrigin()
	local ability = self:GetAbility()
	local hpCost = ability.healthCost
	local dmg_heal_max = ability:GetSpecialValueFor("stop_dmg_heal_max")
	local radius = ability:GetSpecialValueFor("stop_radius")
	local stop_dmg_heal

	-- IMBA: when finish cast, deal dmg and heal to near by units, number is equal to the hp cost
	if hpCost > dmg_heal_max then
		stop_dmg_heal = dmg_heal_max
	else
		stop_dmg_heal = hpCost
	end

	local units = FindUnitsInRadius(caster:GetTeamNumber(),
                              point,
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_BOTH,
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	for _, unit in pairs(units) do -- It's an ally, heal
		if  unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit ~= caster then -- It's  an enemy, dmg
			local damageTable = {
        			victim = unit,
        			attacker = caster,
        			damage = stop_dmg_heal,
        			damage_type = DAMAGE_TYPE_MAGICAL,
        			ability = self:GetAbility(),
    				}
    		ApplyDamage(damageTable)
    	end
    end

    -- IMBA: when finish cast, deal dmg and heal to near by units, number is equal to the hp cost
    caster:AddNewModifier(caster, ability, "modifier_imba_phoenix_icarus_dive_extend_burn", { duration = ability:GetSpecialValueFor("extend_burn_duration") } ) -- IMBA: Extend the burn effect after cast finish

	local sun_ray = caster:FindAbilityByName("imba_phoenix_sun_ray")
	if sun_ray then
		sun_ray:SetActivated(true) -- Re-activa the SUN RAY
	end
	
	-- Switch the dive abilities
	local sub_ability_name	= "imba_phoenix_icarus_dive"
	local main_ability_name	= "imba_phoenix_icarus_dive_stop"
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
	caster:RemoveModifierByName("modifier_imba_phoenix_icarus_dive_ignore_turn_ray")

	-- Audio-visual effects
	StopSoundOn("Hero_Phoenix.IcarusDive.Cast", caster)
	EmitSoundOn("Hero_Phoenix.IcarusDive.Stop", caster)
	caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	-- Anti-stuck
	caster:SetContextThink( DoUniqueString("waitToFindClearSpace"), function ( )
		if not caster:HasModifier("modifier_naga_siren_song_of_the_siren") then
			FindClearSpaceForUnit(caster, point, false)
			return nil
		end
		return 0.1
	end, 0 )

end

modifier_imba_phoenix_icarus_dive_ignore_turn_ray = modifier_imba_phoenix_icarus_dive_ignore_turn_ray or class({})

function modifier_imba_phoenix_icarus_dive_ignore_turn_ray:IsDebuff()			return false end
function modifier_imba_phoenix_icarus_dive_ignore_turn_ray:IsHidden() 			return true  end
function modifier_imba_phoenix_icarus_dive_ignore_turn_ray:IsPurgable() 			return false end
function modifier_imba_phoenix_icarus_dive_ignore_turn_ray:IsPurgeException() 	return false end
function modifier_imba_phoenix_icarus_dive_ignore_turn_ray:IsStunDebuff() 		return false end
function modifier_imba_phoenix_icarus_dive_ignore_turn_ray:RemoveOnDeath() 		return true  end

modifier_imba_phoenix_icarus_dive_slow_debuff = modifier_imba_phoenix_icarus_dive_slow_debuff or class({})

function modifier_imba_phoenix_icarus_dive_slow_debuff:IsDebuff()			return true  end

function modifier_imba_phoenix_icarus_dive_slow_debuff:IsHidden()
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return false 
	else
		return true
	end
end

function modifier_imba_phoenix_icarus_dive_slow_debuff:IsPurgable() 		
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return true 
	else
		return false
	end
end

function modifier_imba_phoenix_icarus_dive_slow_debuff:IsPurgeException()
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return true 
	else
		return false
	end
end

function modifier_imba_phoenix_icarus_dive_slow_debuff:IsStunDebuff() 		return false end
function modifier_imba_phoenix_icarus_dive_slow_debuff:RemoveOnDeath() 		return true  end

function modifier_imba_phoenix_icarus_dive_slow_debuff:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
    return decFuns
end

function modifier_imba_phoenix_icarus_dive_slow_debuff:GetTexture()
	return "phoenix_icarus_dive"
end

function modifier_imba_phoenix_icarus_dive_slow_debuff:GetEffectName()	return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf" end

function modifier_imba_phoenix_icarus_dive_slow_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_phoenix_icarus_dive_slow_debuff:GetModifierMoveSpeedBonus_Percentage()	return self:GetAbility():GetSpecialValueFor("slow_movement_speed_pct") * (-1)  end
function modifier_imba_phoenix_icarus_dive_slow_debuff:GetModifierDamageOutgoing_Percentage()	return self:GetAbility():GetSpecialValueFor("decrease_dmg_pct") * (-1)  end

function modifier_imba_phoenix_icarus_dive_slow_debuff:OnCreated()
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	local tick = ability:GetSpecialValueFor("burn_tick_interval")
	self:StartIntervalThink( tick )
end


function modifier_imba_phoenix_icarus_dive_slow_debuff:OnIntervalThink()
	if not IsServer() then
		return
	end
	if not self:GetParent():IsAlive() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local tick = ability:GetSpecialValueFor("burn_tick_interval")
	local dmg = ability:GetSpecialValueFor("damage_per_second") * ( tick / 1.0 )
	local damageTable = {
        victim = self:GetParent(),
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end

modifier_imba_phoenix_icarus_dive_extend_burn = modifier_imba_phoenix_icarus_dive_extend_burn or class({})

function modifier_imba_phoenix_icarus_dive_extend_burn:IsDebuff()			return false end
function modifier_imba_phoenix_icarus_dive_extend_burn:IsHidden() 			return false  end
function modifier_imba_phoenix_icarus_dive_extend_burn:IsPurgable() 		return false end
function modifier_imba_phoenix_icarus_dive_extend_burn:IsPurgeException() 	return false end
function modifier_imba_phoenix_icarus_dive_extend_burn:IsStunDebuff() 		return false end
function modifier_imba_phoenix_icarus_dive_extend_burn:RemoveOnDeath() 		return true  end

function modifier_imba_phoenix_icarus_dive_extend_burn:GetTexture() return "phoenix_icarus_dive" end
function modifier_imba_phoenix_icarus_dive_extend_burn:GetEffectName() return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance_streak_light.vpcf" end

function modifier_imba_phoenix_icarus_dive_extend_burn:OnCreated()
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	local caster = self:GetAbility().dummy
	ability.extPfx = ParticleManager:CreateParticle("particles/econ/courier/courier_greevil_red/courier_greevil_red_ambient_3.vpcf",PATTACH_POINT_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(ability.extPfx,0,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ability.extPfx,1,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),true)
	self:StartIntervalThink(0.1)
end

function modifier_imba_phoenix_icarus_dive_extend_burn:OnIntervalThink()
	if not IsServer() then
		return
	end
	local caster = self:GetAbility().dummy
	local ability = self:GetAbility()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
	                                caster:GetAbsOrigin(),
	                                nil,
	                                ability:GetSpecialValueFor("hit_radius"),
	                                DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_ANY_ORDER,
	                                false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, ability, "modifier_imba_phoenix_icarus_dive_slow_debuff", {duration = ability:GetSpecialValueFor("burn_duration")} )
	end
end

function modifier_imba_phoenix_icarus_dive_extend_burn:OnDestroy()
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	ParticleManager:DestroyParticle(ability.extPfx, false)
	ParticleManager:ReleaseParticleIndex(ability.extPfx)
end