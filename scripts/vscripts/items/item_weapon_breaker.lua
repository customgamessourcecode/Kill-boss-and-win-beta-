if item_weapon_breaker == nil then item_weapon_breaker = class({}) end

LinkLuaModifier("modifier_weapon_breaker_passive","items/item_weapon_breaker.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_disarm","libraries/modifiers/modifier_generic_disarm.lua",LUA_MODIFIER_MOTION_NONE)

function item_weapon_breaker:GetIntrinsicModifierName(  )
	return "modifier_weapon_breaker_passive"
end

if modifier_weapon_breaker_passive == nil then modifier_weapon_breaker_passive = class({}) end

function modifier_weapon_breaker_passive:IsPurgable(  )
	return false
end

function modifier_weapon_breaker_passive:IsHidden(  )
	return true
end

function modifier_weapon_breaker_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.str = ability:GetSpecialValueFor("str")
	self.int = ability:GetSpecialValueFor("int")
	self.agi = ability:GetSpecialValueFor("agi")
	self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_weapon_breaker_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_weapon_breaker_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then
		local ability = self:GetAbility()
		local chance = 0
		if caster:IsRealHero() then
			if caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then chance = ability:GetSpecialValueFor("chance_ranged") else chance = ability:GetSpecialValueFor("chance") end
			if caster:GetAttacksPerSecond() > 2.5 then chance = chance * 0.5 end
			if RollPercentage(chance) then
				params.target:AddNewModifier(caster,ability,"modifier_generic_disarm",{duration = self.duration})
			end
		else
			if caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then chance = ability:GetSpecialValueFor("chance_ranged") else chance = ability:GetSpecialValueFor("chance") end
			if caster:GetAttacksPerSecond() > 2.5 then chance = chance * 0.5 end
			if RollPercentage(chance/10) then
				caster:SetHealth(caster:GetHealth() * 0.60)
				params.target:AddNewModifier(caster,ability,"modifier_generic_disarm",{duration = self.duration})
			end
		end
	end
end

function modifier_weapon_breaker_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_weapon_breaker_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_weapon_breaker_passive:GetModifierBonusStats_Agility(  )
	return self.agi
end

function modifier_weapon_breaker_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end