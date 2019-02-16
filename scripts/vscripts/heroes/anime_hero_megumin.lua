
megumin_explosion = class({})
function megumin_explosion:IsStealable() return true end
function megumin_explosion:IsHiddenWhenStolen() return false end
function megumin_explosion:GetManaCost(level)
    local manacost = self.BaseClass.GetManaCost(self, level)
    local manacost_percent = ( manacost / 100 ) * self:GetCaster():GetMaxMana()
    return manacost_percent
end
function megumin_explosion:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function megumin_explosion:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local pre_duration = self:GetSpecialValueFor("duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")

	EmitSoundOn("MEGU.Cast.Exp", caster)

	local enemies = FindUnitsInRadius(	caster:GetTeamNumber(),
										point,
										nil,
										radius,
										self:GetAbilityTargetTeam(),
										self:GetAbilityTargetType(),
										self:GetAbilityTargetFlags(),
										FIND_ANY_ORDER,
										false)

	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_Invoker.SunStrike.Charge", enemy)
		
		local pre_particle = 	ParticleManager:CreateParticle("particles/heroes/megumin/explosion/explosion_team.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
								ParticleManager:SetParticleControl(pre_particle, 0, enemy:GetAbsOrigin())
								ParticleManager:SetParticleControl(pre_particle, 1, Vector(radius, 0, 0))
				
		Timers:CreateTimer(pre_duration, function()
			if not enemy or enemy:IsMagicImmune() or enemy:IsInvulnerable() then return nil end
			EmitSoundOn("Hero_Invoker.SunStrike.Ignite", enemy)
			
			local post_particle = 	ParticleManager:CreateParticle("particles/heroes/megumin/explosion/explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
									ParticleManager:SetParticleControl(post_particle, 0, enemy:GetAbsOrigin())
									ParticleManager:SetParticleControl(post_particle, 1, Vector(radius, 0, 0))

		    local damage_table = {	victim = enemy,
		                          	damage = damage,
		                           	damage_type = self:GetAbilityDamageType(),
		                        	attacker = caster}		
			
			ApplyDamage(damage_table)

			enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})
		end)
	end
end
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
megumin_place = class({})
LinkLuaModifier("modifier_megumin_place", "heroes/anime_hero_megumin", LUA_MODIFIER_MOTION_NONE)
function megumin_place:IsStealable() return true end
function megumin_place:IsHiddenWhenStolen() return false end
function megumin_place:GetManaCost(level)
    local manacost = self.BaseClass.GetManaCost(self, level)
    local manacost_percent = ( manacost / 100 ) * self:GetCaster():GetMaxMana()
    return manacost_percent
end
function megumin_place:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function megumin_place:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("MEGU.Cast.Exp_Place", caster)

	CreateModifierThinker(caster, self, "modifier_megumin_place", {duration = duration}, point, caster:GetTeam(), false)
end
--------------------------------------------------------------------------------------------------------------
modifier_megumin_place = class({})
function modifier_megumin_place:IsHidden() return true end
function modifier_megumin_place:IsDebuff() return false end
function modifier_megumin_place:IsPurgable() return false end
function modifier_megumin_place:IsPurgeException() return false end
function modifier_megumin_place:RemoveOnDeath() return true end
function modifier_megumin_place:OnCreated()
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.interval = self:GetAbility():GetSpecialValueFor("interval")

		self.place_particle = 	ParticleManager:CreateParticle("particles/heroes/megumin/pre_explosion/pre_big_exp_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
								ParticleManager:SetParticleControl(self.place_particle, 0, self:GetParent():GetAbsOrigin())
								ParticleManager:SetParticleControl(self.place_particle, 1, Vector(self.radius, 0, 0))

		self:StartIntervalThink(self.interval)
	end
end
function modifier_megumin_place:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInRadius(	self:GetCaster():GetTeam(),
											self:GetParent():GetAbsOrigin(),
											nil,
											self.radius,
											self:GetAbility():GetAbilityTargetTeam(),
											self:GetAbility():GetAbilityTargetType(),
											self:GetAbility():GetAbilityTargetFlags(),
											FIND_ANY_ORDER, 
											false)

		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Invoker.SunStrike.Ignite", enemy)

			self.blow_particle = 	ParticleManager:CreateParticle("particles/heroes/megumin/explosion_big.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
									ParticleManager:SetParticleControl(self.blow_particle, 0, enemy:GetAbsOrigin())
									ParticleManager:SetParticleControl(self.blow_particle, 1, Vector(200, 0, 0))

		    local damage_table = {	victim = enemy,
		                          	damage = self.damage,
		                           	damage_type = self:GetAbility():GetAbilityDamageType(),
		                        	attacker = self:GetCaster()}		
			
			ApplyDamage(damage_table)

		end
	end
end
function modifier_megumin_place:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.place_particle, false)
		ParticleManager:ReleaseParticleIndex(self.place_particle)
	end
end
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
megumin_mastery = class({})
LinkLuaModifier("modifier_megumin_mastery", "heroes/anime_hero_megumin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_megumin_mastery_aura", "heroes/anime_hero_megumin", LUA_MODIFIER_MOTION_NONE)

function megumin_mastery:IsStealable() return true end
function megumin_mastery:IsHiddenWhenStolen() return false end
function megumin_mastery:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA
end
function megumin_mastery:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function megumin_mastery:GetManaCost(level)
    local manacost = self.BaseClass.GetManaCost(self, level)
    local manacost_percent = ( manacost / 100 ) * self:GetCaster():GetMaxMana()
    return manacost_percent
end
function megumin_mastery:GetIntrinsicModifierName()
	return "modifier_megumin_mastery"
end
function megumin_mastery:OnSpellStart()
	local caster = self:GetCaster()

end
--------------------------------------------------------------------------------------------------------------
modifier_megumin_mastery = class({})
function modifier_megumin_mastery:IsHidden() return true end
function modifier_megumin_mastery:IsDebuff() return false end
function modifier_megumin_mastery:IsPurgable() return false end
function modifier_megumin_mastery:IsPurgeException() return false end
function modifier_megumin_mastery:RemoveOnDeath() return false end
function modifier_megumin_mastery:IsAura() return true end
function modifier_megumin_mastery:GetAuraEntityReject(hEntity)
	if self:GetParent():PassivesDisabled() then
		return true
	end
end
function modifier_megumin_mastery:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_megumin_mastery:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_megumin_mastery:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_megumin_mastery:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end
function modifier_megumin_mastery:GetModifierAura()
	return "modifier_megumin_mastery_aura"
end
--------------------------------------------------------------------------------------------------------------
modifier_megumin_mastery_aura = class({})
function modifier_megumin_mastery_aura:IsHidden() return false end
function modifier_megumin_mastery_aura:IsDebuff() return false end
function modifier_megumin_mastery_aura:IsPurgable() return false end
function modifier_megumin_mastery_aura:IsPurgeException() return false end
function modifier_megumin_mastery_aura:RemoveOnDeath() return true end
function modifier_megumin_mastery_aura:DeclareFunctions()
	local func = {	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,}
	return func
end
function modifier_megumin_mastery_aura:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("amplify")
end
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
megumin_meteors = class({})
LinkLuaModifier("modifier_megumin_meteors", "heroes/anime_hero_megumin", LUA_MODIFIER_MOTION_NONE)
function megumin_meteors:IsStealable() return true end
function megumin_meteors:IsHiddenWhenStolen() return false end
function megumin_meteors:GetManaCost(level)
    local manacost = self.BaseClass.GetManaCost(self, level)
    local manacost_percent = ( manacost / 100 ) * self:GetCaster():GetMaxMana()
    return manacost_percent
end
function megumin_meteors:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function megumin_meteors:GetAbilityDamageType()
		return DAMAGE_TYPE_MAGICAL
end
function megumin_meteors:OnSpellStart()
	local caster = self:GetCaster()

	self.time = 0
	
	EmitSoundOn("MEGU.Cast.Exp_Meteors", caster)

	if not self.particle_meteors then
		self.particle_meteors = ParticleManager:CreateParticle("particles/custom/megumin/skill_5/megumin_skill_5_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
								ParticleManager:SetParticleControl(self.particle_meteors, 0, caster:GetAbsOrigin())
	end

end
function megumin_meteors:OnChannelThink(flInterval)
	AnimeMeguminCastMeteors(self:GetCaster(), self)
end

--------------------------------------------------------------------------------------------------------------
modifier_megumin_meteors = class({})
function modifier_megumin_meteors:IsHidden() return true end
function modifier_megumin_meteors:IsDebuff() return false end
function modifier_megumin_meteors:IsPurgable() return false end
function modifier_megumin_meteors:IsPurgeException() return false end
function modifier_megumin_meteors:RemoveOnDeath() return true end
function modifier_megumin_meteors:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_megumin_meteors:OnIntervalThink()
	AnimeMeguminCastMeteors(self:GetCaster(),self:GetAbility())
end
function modifier_megumin_meteors:OnDestroy()
	StopSoundOn("MEGU.Cast.Exp_Meteors", self:GetCaster())
end

function AnimeMeguminCastMeteors(caster, ability)
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local exp_radius = ability:GetSpecialValueFor("explosion_radius")
	local interval = ability:GetSpecialValueFor("explosion_interval")
	local min_dist = ability:GetSpecialValueFor("explosion_min_dist")
	local max_dist = ability:GetSpecialValueFor("explosion_max_dist")

	ability.time = ability.time + FrameTime()

	if ability.time >= interval then
		ability.time = 0

		local quadrant = 1
		local castDistance = RandomInt(min_dist, max_dist)
		local angle = RandomInt( 0, 100 )
		local dy = castDistance * math.sin( angle )
		local dx = castDistance * math.cos( angle )
		local attackPoint = Vector( 0, 0, 0 )
		local target_loc = caster:GetAbsOrigin()

		if quadrant == 1 then			-- NW
			attackPoint = Vector( target_loc.x - dx, target_loc.y + dy, target_loc.z )
		elseif quadrant == 2 then		-- NE
			attackPoint = Vector( target_loc.x + dx, target_loc.y + dy, target_loc.z )
		elseif quadrant == 3 then		-- SE
			attackPoint = Vector( target_loc.x + dx, target_loc.y - dy, target_loc.z )
		else							-- SW
			attackPoint = Vector( target_loc.x - dx, target_loc.y - dy, target_loc.z )
		end

		quadrant = 4 % (quadrant + 1)

		Timers:CreateTimer(1.3,function()
			if not ability then
				return nil
			end
			local enemies = FindUnitsInRadius(	caster:GetTeam(),
												attackPoint, 
												nil,
												exp_radius,
												ability:GetAbilityTargetTeam(),
												ability:GetAbilityTargetType(),
												ability:GetAbilityTargetFlags(),
												FIND_ANY_ORDER,
												false)

			for _,enemy in pairs(enemies) do
			    local damage_table = {	victim = enemy,
			                          	damage = damage,
			                           	damage_type = ability:GetAbilityDamageType(),
			                        	attacker = caster,
			                        	ability = ability}		
				
				ApplyDamage(damage_table)
			end

			EmitSoundOnLocationWithCaster(attackPoint, "Hero_Invoker.ChaosMeteor.Impact", caster)
		end)

		local caster_point = attackPoint
		local target_point = attackPoint
	
		local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
		local target_point_temp = Vector(target_point.x, target_point.y, 0)

		local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
		local velocity_per_second = point_difference_normalized * 1000

		local meteor_fly_original_point = (target_point - (velocity_per_second * 0.1)) + Vector (0, 0, 1000)

		local chaos_meteor_fly_particle_effect = 	ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, caster)
													ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
													ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, attackPoint)
													ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))

		--EmitSoundOnLocationWithCaster(attackPoint, "Hero_Invoker.ChaosMeteor.Loop", caster)
	end
end