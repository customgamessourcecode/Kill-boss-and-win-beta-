
--[[
        By: MouJiaoZi
        Date: 01.08.2017
        Updated:  01.08.2017	FindTalentValue("special_bonus_imba_pudge_1","damage")
        						FindTalentValue("special_bonus_imba_pudge_8")  
    ]]



-------------------------------------------
--			  Super Nova
-------------------------------------------

LinkLuaModifier("modifier_imba_phoenix_supernova_egg_thinker", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_supernova_caster_dummy", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_supernova_bird_thinker", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_supernova_dmg", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_supernova_scepter_passive", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_supernova_scepter_passive_cooldown", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_phoenix_supernova_egg_double", "heroes/hero_phoenix/supernova", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kill_no_timer", "modifiers/modifier_kill_no_timer", LUA_MODIFIER_MOTION_NONE)

phoenix_supernova_custom = phoenix_supernova_custom or class({})

function phoenix_supernova_custom:IsHiddenWhenStolen() 	return false end
function phoenix_supernova_custom:IsRefreshable() 			return true end
function phoenix_supernova_custom:IsStealable() 			return true end
function phoenix_supernova_custom:IsNetherWardStealable() 	return false end
--

function phoenix_supernova_custom:GetCastRange() 	return self:GetSpecialValueFor("cast_range") end


function phoenix_supernova_custom:GetIntrinsicModifierName()
	return "modifier_imba_phoenix_supernova_scepter_passive"
end


modifier_imba_phoenix_supernova_scepter_passive = modifier_imba_phoenix_supernova_scepter_passive or class({})

function modifier_imba_phoenix_supernova_scepter_passive:IsDebuff()					return false end

function modifier_imba_phoenix_supernova_scepter_passive:IsPurgable() 				return false end
function modifier_imba_phoenix_supernova_scepter_passive:IsPurgeException() 		return false end
function modifier_imba_phoenix_supernova_scepter_passive:IsStunDebuff() 			return false end
function modifier_imba_phoenix_supernova_scepter_passive:RemoveOnDeath()
	if self:GetCaster():IsRealHero() then
		return false 
	else
		return true
	end
end
function modifier_imba_phoenix_supernova_scepter_passive:IsPermanent() 				return true end
function modifier_imba_phoenix_supernova_scepter_passive:AllowIllusionDuplicate() 	return true end

function modifier_imba_phoenix_supernova_scepter_passive:DeclareFunctions()
    local decFuncs = 	{
		  MODIFIER_EVENT_ON_DEATH,
		  MODIFIER_PROPERTY_REINCARNATION,                      
		  MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
						}

    return decFuncs
end

function modifier_imba_phoenix_supernova_scepter_passive:OnCreated()    
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()    
        -- Ability specials
        self.reincarnate_delay = self.ability:GetSpecialValueFor("duration")

--	self.reincarnate_delay = self:GetAbility:GetSpecialValueFor("duration")
    if IsServer() then
        -- Set WK as immortal!
        self.can_die = false

        -- Start interval think
        self:StartIntervalThink(0.05)
    end
end

function modifier_imba_phoenix_supernova_scepter_passive:OnIntervalThink()
    -- If caster has sufficent mana and the ability is ready, apply
    if (self.caster:GetMana() >= self.ability:GetManaCost(-1)) and (self.ability:IsCooldownReady()) and (not self.caster:HasModifier("modifier_item_imba_aegis")) then
        self.can_die = false
    else
        self.can_die = true
    end

end

function modifier_imba_phoenix_supernova_scepter_passive:ReincarnateTime()
    if IsServer() then  
        if not self.can_die and self.caster:IsRealHero() then
            return self.reincarnate_delay
--            return FrameTime()
        end

        return nil
    end
end

function modifier_imba_phoenix_supernova_scepter_passive:GetActivityTranslationModifiers()
    if self.reincarnation_death then
        return "reincarnate"
    end

    return nil
end


function modifier_imba_phoenix_supernova_scepter_passive:OnDeath(keys)
    if IsServer() then
        local unit = keys.unit
        local reincarnate = keys.reincarnate

        -- Only apply if the caster is the unit that died
        if self:GetParent() == unit then            
            Timers:CreateTimer(0.1, function() modifier_imba_phoenix_supernova_scepter_passive:PhoenixEggTrigger( keys , self) end)
            
        end
    end
end

function modifier_imba_phoenix_supernova_scepter_passive:PhoenixEggTrigger( keys ,self)
	if not  IsServer() then 
		return
	end
	if keys.unit ~= self:GetCaster() then
		return
	end
--	if not self:GetCaster():HasScepter() then
--		return
--	end
	if self:GetCaster():FindModifierByName("modifier_imba_phoenix_supernova_caster_dummy") or self:GetCaster():HasModifier("modifier_imba_phoenix_supernova_scepter_passive_cooldown") then
		return
	end
	if  not self:GetCaster():IsRealHero() then
		return
	end
	local reincarnate = keys.reincarnate
	-- Check if it was a reincarnation death
	if reincarnate and (not self:GetCaster():HasModifier("modifier_item_imba_aegis")) then

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local manaHave = caster:GetMana()
		local manaCost = ability:GetManaCost(-1)
		
		if not ability:IsCooldownReady() or manaHave < manaCost then
			self.reincarnation_death = false
		else
			self.reincarnation_death = true
		
			ability:UseResources(true,false,true)
			local location = caster:GetAbsOrigin()
			local egg_duration = ability:GetSpecialValueFor("duration")
			local extend_duration --= ability:GetSpecialValueFor("scepter_additional_duration")

--			local max_attack = ability:GetSpecialValueFor("max_hero_attacks")

--			caster:AddNewModifier(caster, ability, "modifier_imba_phoenix_supernova_caster_dummy", {duration = egg_duration  })
--			caster:AddNoDraw()

			local egg = CreateUnitByName("npc_dota_phoenix_sun",location,false,caster,caster:GetOwner(),caster:GetTeamNumber())
			egg:AddNewModifier(caster, ability, "modifier_kill", {duration = egg_duration  })
--			egg:AddNewModifier(caster, ability, "modifier_invulnerable",{duration = egg_duration + extend_duration })
			egg:AddNewModifier(caster, ability, "modifier_imba_phoenix_supernova_egg_thinker", {duration = egg_duration +0.1 })

			egg.max_attack = max_attack
			egg.current_attack = 0
			
			local egg_playback_rate = 6 / (egg_duration )
			egg:StartGestureWithPlaybackRate(ACT_DOTA_IDLE , egg_playback_rate)

			caster.egg = egg
		end
		
	end

end


--[[
function imba_phoenix_supernova:OnSpellStart()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	local ability = self
	local location = caster:GetAbsOrigin()
	local egg_duration = self:GetSpecialValueFor("duration")

	local max_attack = self:GetSpecialValueFor("max_hero_attacks")

	caster:AddNewModifier(caster, ability, "modifier_imba_phoenix_supernova_caster_dummy", {duration = egg_duration })
	caster:AddNoDraw()

	local egg = CreateUnitByName("npc_dota_phoenix_sun",location,false,caster,caster:GetOwner(),caster:GetTeamNumber())
	egg:AddNewModifier(caster, ability, "modifier_kill_no_timer", {duration = egg_duration })
	egg:AddNewModifier(caster, ability, "modifier_imba_phoenix_supernova_egg_thinker", {duration = egg_duration + 0.3 })

	egg.max_attack = max_attack
	egg.current_attack = 0

	local egg_playback_rate = 6 / egg_duration
	egg:StartGestureWithPlaybackRate(ACT_DOTA_IDLE , egg_playback_rate)

	caster.egg = egg
	caster.HasDoubleEgg = false

	caster.ally = self:GetCursorTarget()
	if caster.ally == caster then
		caster.ally = nil
	else
		local ally = caster.ally
		if not caster:HasTalent("special_bonus_imba_phoenix_6") then
			ally:AddNewModifier(caster, ability, "modifier_imba_phoenix_supernova_caster_dummy", {duration = egg_duration})
			ally:AddNoDraw()
			ally:SetAbsOrigin(caster:GetAbsOrigin())
		else
			-- Talent: Double Super Nova
			ally:AddNewModifier(ally, ability, "modifier_imba_phoenix_supernova_caster_dummy", {duration = egg_duration})
			ally:AddNoDraw()
			local _direction = (ally:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
			caster:SetForwardVector(_direction)
			local loaction = caster:GetForwardVector() * 192 + caster:GetAbsOrigin()
			local egg2 = CreateUnitByName("npc_dota_phoenix_sun", loaction, false, ally, ally:GetOwner(), ally:GetTeamNumber())
			
			egg2:AddNewModifier(ally, ability, "modifier_kill_no_timer", {duration = egg_duration })
			egg2:AddNewModifier(caster, ability, "modifier_imba_phoenix_supernova_egg_double", { } )
			egg2:AddNewModifier(ally, ability, "modifier_imba_phoenix_supernova_egg_thinker", {duration = egg_duration + 0.3 })

			max_attack = max_attack * ( (100 - caster:FindTalentValue("special_bonus_imba_phoenix_6","attack_reduce_pct") ) / 100)

			egg.max_attack = max_attack
			egg.current_attack = 0

			egg2.max_attack = max_attack
			egg2.current_attack = 0

			local info = 
			{
				Target = egg2,
				Source = ally,
				Ability = ability,	
				EffectName = "particles/hero/phoenix/phoenix_super_nova_double_egg_projectile.vpcf",
        		iMoveSpeed = 1400,
				bDrawsOnMinimap = false,                          -- Optional
        		bDodgeable = false,                                -- Optional
        		bIsAttack = false,                                -- Optional
        		bVisibleToEnemies = true,                         -- Optional
        		bReplaceExisting = false,                         -- Optional
        		flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
				bProvidesVision = false,                           -- Optional
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			}
			ProjectileManager:CreateTrackingProjectile(info)

			caster.HasDoubleEgg = true
			ally:SetAbsOrigin(egg2:GetAbsOrigin())
			local egg_playback_rate = 6 / egg_duration
			egg2:StartGestureWithPlaybackRate(ACT_DOTA_IDLE , egg_playback_rate)
		end
	end


end
]]
modifier_imba_phoenix_supernova_caster_dummy = modifier_imba_phoenix_supernova_caster_dummy or class({})

function modifier_imba_phoenix_supernova_caster_dummy:IsDebuff()				return false end
function modifier_imba_phoenix_supernova_caster_dummy:IsHidden() 				return false end
function modifier_imba_phoenix_supernova_caster_dummy:IsPurgable() 				return false end
function modifier_imba_phoenix_supernova_caster_dummy:IsPurgeException() 		return false end
function modifier_imba_phoenix_supernova_caster_dummy:IsStunDebuff() 			return false end
function modifier_imba_phoenix_supernova_caster_dummy:RemoveOnDeath() 			return true end
function modifier_imba_phoenix_supernova_caster_dummy:IgnoreTenacity() 			return true end

function modifier_imba_phoenix_supernova_caster_dummy:GetTexture() return "phoenix_supernova" end

function modifier_imba_phoenix_supernova_caster_dummy:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
    return decFuns
end

function modifier_imba_phoenix_supernova_caster_dummy:CheckState()
	local state = 
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
	return state
end

function modifier_imba_phoenix_supernova_caster_dummy:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_imba_phoenix_supernova_caster_dummy:OnCreated()
	if not IsServer() then
		return 
	end
	if self:GetAbility():IsStolen() then
		return
	end
	local caster = self:GetCaster()
	local abi = caster:FindAbilityByName("imba_phoenix_launch_fire_spirit")
	if abi then
		if self:GetParent() == self:GetCaster() and abi:IsTrained() then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_phoenix_supernova_bird_thinker", {duration = self:GetDuration()}) 
		end
	end
	local innate = caster:FindAbilityByName("imba_phoenix_burning_wings")
	if innate then
		if innate:GetToggleState() then
			innate:ToggleAbility()
		end
	end
end

function modifier_imba_phoenix_supernova_caster_dummy:OnDeath( keys )
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		if keys.unit ~= self:GetCaster() then
			local caster = self:GetCaster()
			caster.ally = nil
		end
		local eggs = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
									self:GetParent():GetAbsOrigin(),
									nil,
									2500,
									DOTA_UNIT_TARGET_TEAM_BOTH,
									DOTA_UNIT_TARGET_ALL,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false )
		for _, egg in pairs(eggs) do
			if egg:GetUnitName() == "npc_dota_phoenix_sun" and egg:GetTeamNumber() == self:GetParent():GetTeamNumber() and egg:GetOwner() == self:GetParent():GetOwner() then
				egg:Kill(self:GetAbility(), keys.attacker)
			end
		end
	end
end

function modifier_imba_phoenix_supernova_caster_dummy:OnDestroy()
	if not IsServer() then
		return
	end
	if self:GetCaster():GetUnitName() == "npc_imba_hero_phoenix" or self:GetCaster():GetUnitName() == "npc_dota_hero_phoenix" then
		self:GetCaster():StartGesture(ACT_DOTA_INTRO)
	end
end

modifier_imba_phoenix_supernova_egg_thinker = modifier_imba_phoenix_supernova_egg_thinker or class({})

function modifier_imba_phoenix_supernova_egg_thinker:IsDebuff()					return false end
function modifier_imba_phoenix_supernova_egg_thinker:IsHidden() 				return false end
function modifier_imba_phoenix_supernova_egg_thinker:IsPurgable() 				return false end
function modifier_imba_phoenix_supernova_egg_thinker:IsPurgeException() 		return false end
function modifier_imba_phoenix_supernova_egg_thinker:IsStunDebuff() 			return false end
function modifier_imba_phoenix_supernova_egg_thinker:RemoveOnDeath() 			return true end
function modifier_imba_phoenix_supernova_egg_thinker:IgnoreTenacity() 			return true end
function modifier_imba_phoenix_supernova_egg_thinker:IsAura() 					return true end
function modifier_imba_phoenix_supernova_egg_thinker:GetAuraSearchTeam() 		return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_phoenix_supernova_egg_thinker:GetAuraSearchType() 		return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_imba_phoenix_supernova_egg_thinker:GetAuraRadius() 			return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_phoenix_supernova_egg_thinker:GetModifierAura()			return "modifier_imba_phoenix_supernova_dmg" end

function modifier_imba_phoenix_supernova_egg_thinker:GetTexture() return "phoenix_supernova" end

function modifier_imba_phoenix_supernova_egg_thinker:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
 --       MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_DEATH,
    }
    return decFuns
end

function modifier_imba_phoenix_supernova_egg_thinker:CheckState()
	local state = 
	{
--		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	return state
end

function modifier_imba_phoenix_supernova_egg_thinker:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_imba_phoenix_supernova_egg_thinker:OnCreated()
	if not IsServer() then
		return
	end
	local egg = self:GetParent()
	local caster = self:GetCaster()
	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_ABSORIGIN_FOLLOW, egg )
	ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( pfx )
	StartSoundEvent( "Hero_Phoenix.SuperNova.Begin", egg)
	StartSoundEvent( "Hero_Phoenix.SuperNova.Cast", egg)

	local ability = self:GetAbility()
	GridNav:DestroyTreesAroundPoint(egg:GetAbsOrigin(), ability:GetSpecialValueFor("cast_range") * 1.5 , false)
--	self:StartIntervalThink(1)
end

function modifier_imba_phoenix_supernova_egg_thinker:OnIntervalThink()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	if not egg:IsAlive() or egg:HasModifier("modifier_imba_phoenix_supernova_egg_double") then
		return
	end
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
									egg:GetAbsOrigin(),
									nil,
									ability:GetSpecialValueFor("aura_radius"),
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false )
	for _, enemy in pairs(enemies) do
		local damageTable = {
        victim = enemy,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage_per_sec"),
        damage_type = DAMAGE_TYPE_MAGICAL,
    	}
    	ApplyDamage(damageTable)
    end
end

function modifier_imba_phoenix_supernova_egg_thinker:OnDeath( keys )
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	local killer = keys.attacker
	if egg ~= keys.unit then
		return
	end
	if egg.IsDoubleNova then
		egg.IsDoubleNova = nil
	end
	if egg.NovaCaster then
		egg.NovaCaster = nil
	end

	caster:RemoveNoDraw()
	if caster.ally and not caster.HasDoubleEgg then
		caster.ally:RemoveNoDraw()
	end
	egg:AddNoDraw()

	StopSoundEvent("Hero_Phoenix.SuperNova.Begin", egg)
	StopSoundEvent( "Hero_Phoenix.SuperNova.Cast", egg)
	if egg == killer then
		-- Phoenix reborns
		StartSoundEvent( "Hero_Phoenix.SuperNova.Explode", egg)
		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl( pfx, 0, egg:GetAbsOrigin() )
		ParticleManager:SetParticleControl( pfx, 1, Vector(1.5,1.5,1.5) )
		ParticleManager:SetParticleControl( pfx, 3, egg:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(pfx)
		self:ResetUnit(caster)
		caster:SetHealth( caster:GetMaxHealth() )
		caster:SetMana( caster:GetMaxMana() )
		if caster.ally and not caster.HasDoubleEgg and caster.ally:IsAlive() then
			self:ResetUnit(caster.ally)
			caster.ally:SetHealth( caster.ally:GetMaxHealth() )
			caster.ally:SetMana( caster.ally:GetMaxMana() )
		end
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
									egg:GetAbsOrigin(),
									nil,
									ability:GetSpecialValueFor("aura_radius"),
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
									FIND_ANY_ORDER,
									false )
		for _, enemy in pairs(enemies) do
			local item = CreateItem( "item_imba_dummy", caster, caster)
			item:ApplyDataDrivenModifier( caster, enemy, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration")} )
			UTIL_Remove(item)
    	end
	else
		-- Phoenix killed
		StartSoundEventFromPosition( "Hero_Phoenix.SuperNova.Death", egg:GetAbsOrigin())
		if not caster:HasTalent("special_bonus_imba_phoenix_5") then
			if caster:IsAlive() then  caster:Kill(ability, killer) end
			if caster.ally and not caster.HasDoubleEgg and caster.ally:IsAlive() then
				caster.ally:Kill(ability, killer)
			end
		elseif caster:IsAlive() then
			self:ResetUnit(caster)
			caster:SetHealth( caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_imba_phoenix_5","reborn_pct") / 100 )
			caster:SetMana( caster:GetMaxMana() * caster:FindTalentValue("special_bonus_imba_phoenix_5","reborn_pct") / 100)
			local egg_buff = caster:FindModifierByNameAndCaster("modifier_imba_phoenix_supernova_caster_dummy", caster)
			if egg_buff then
				egg_buff:Destroy()
			end
			if caster.ally and caster.ally:IsAlive() then
				self:ResetUnit(caster.ally)
				caster.ally:SetHealth( caster.ally:GetMaxHealth() * caster:FindTalentValue("special_bonus_imba_phoenix_5","reborn_pct") / 100 )
				caster.ally:SetMana( caster.ally:GetMaxMana() * caster:FindTalentValue("special_bonus_imba_phoenix_5","reborn_pct") / 100 )
				local egg_buff2 = caster.ally:FindModifierByNameAndCaster("modifier_imba_phoenix_supernova_caster_dummy", caster)
				if egg_buff2 then
					egg_buff2:Destroy()
				end
			end
		end
		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_death.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_WORLDORIGIN, nil )
		local attach_point = caster:ScriptLookupAttachment( "attach_hitloc" )
		ParticleManager:SetParticleControl( pfx, 0, caster:GetAttachmentOrigin(attach_point) )
		ParticleManager:SetParticleControl( pfx, 1, caster:GetAttachmentOrigin(attach_point) )
		ParticleManager:SetParticleControl( pfx, 3, caster:GetAttachmentOrigin(attach_point) )
		ParticleManager:ReleaseParticleIndex(pfx)
	end
	caster.ally = nil
	caster.egg = nil
	FindClearSpaceForUnit(caster, egg:GetAbsOrigin(), false)
	if caster.ally then
		FindClearSpaceForUnit(caster.ally, egg:GetAbsOrigin(), false)
	end
	self.bIsFirstAttacked = nil
end

function modifier_imba_phoenix_supernova_egg_thinker:ResetUnit( unit )
	for i=0,10 do
		local abi = unit:GetAbilityByIndex(i)
		if abi then
			if abi:GetAbilityType() ~= 1 and not abi:IsItem() then
				abi:EndCooldown()
			end
		end
	end
	unit:Purge( true, true, true, true, true )
end

function modifier_imba_phoenix_supernova_egg_thinker:OnAttacked( keys )
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	local attacker = keys.attacker

	if keys.target ~= egg then
		return
	end

	local max_attack = egg.max_attack
	local current_attack = egg.current_attack

	if attacker:IsRealHero() then
		egg.current_attack = egg.current_attack + 1
	else
		egg.current_attack = egg.current_attack + 1 --0.25
	end
	if egg.current_attack >= egg.max_attack then
		egg:Kill(ability, attacker)
	else
		egg:SetHealth( (egg:GetMaxHealth() * ((egg.max_attack-egg.current_attack)/egg.max_attack)) )
	end
	local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_hit.vpcf"
	local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_POINT_FOLLOW, egg )
	local attach_point = egg:ScriptLookupAttachment( "attach_hitloc" )
	ParticleManager:SetParticleControlEnt( pfx, 0, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAttachmentOrigin(attach_point), true )
	ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAttachmentOrigin(attach_point), true )
	--ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_imba_phoenix_supernova_dmg = modifier_imba_phoenix_supernova_dmg or class({})

function modifier_imba_phoenix_supernova_dmg:IsHidden() return false end
function modifier_imba_phoenix_supernova_dmg:IsDebuff() return true end
function modifier_imba_phoenix_supernova_dmg:IsPurgable() return false end

function modifier_imba_phoenix_supernova_dmg:DeclareFunctions()
	local decFuns = {
--					MODIFIER_PROPERTY_MISS_PERCENTAGE,
					}
	return decFuns
end

function modifier_imba_phoenix_supernova_dmg:GetHeroEffectName() return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf" end

function modifier_imba_phoenix_supernova_dmg:GetEffectAttachType() return PATTACH_WORLDORIGIN end

function modifier_imba_phoenix_supernova_dmg:OnCreated()
	if not IsServer() then
		return
	end
	local target = self:GetParent()
	local caster = self:GetCaster()
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_radiance_streak_light.vpcf", PATTACH_POINT_FOLLOW, target)
	-- The fucking particle I can't do
	ParticleManager:SetParticleControlEnt( self.pfx, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
	self:StartIntervalThink(0.9)
end

function modifier_imba_phoenix_supernova_dmg:OnIntervalThink()
		local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
		ability = self:GetAbility(),
        damage = self:GetAbility():GetSpecialValueFor("damage_per_sec"),
        damage_type = DAMAGE_TYPE_MAGICAL,
    	}
    	ApplyDamage(damageTable)
    
end

function modifier_imba_phoenix_supernova_dmg:GetModifierMiss_Percentage()
	if not IsServer() then 
		return 
	end
	local enemy = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	-- Get the miss pct
	local egg = caster.egg
	if egg then
		local miss_pct = ability:GetSpecialValueFor("miss_pct_base") + ability:GetSpecialValueFor("miss_pct_perHit") * egg.current_attack 
		local miss_radius = self:GetAbility():GetSpecialValueFor("cast_range")
		local miss_angle = self:GetAbility():GetSpecialValueFor("miss_angle")
		local caster_location = caster:GetAbsOrigin()
		local enemy_location = enemy:GetAbsOrigin()
		local distance = CalcDistanceBetweenEntityOBB(caster, enemy)
		if distance <= miss_radius then
			local enemy_to_caster_direction = (caster_location - enemy_location):Normalized()
			local enemy_forward_vector =  enemy:GetForwardVector()
			local view_angle = math.abs(RotationDelta(VectorToAngles(enemy_to_caster_direction), VectorToAngles(enemy_forward_vector)).y)
			if view_angle <= ( miss_angle / 2 ) and enemy:CanEntityBeSeenByMyTeam(caster) then
				return miss_pct
			else
				return 0
			end
		else
			return 0
		end
	else
		return 0
	end
end

function modifier_imba_phoenix_supernova_dmg:OnDestroy()
	if not IsServer() then
		return
	end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
end

