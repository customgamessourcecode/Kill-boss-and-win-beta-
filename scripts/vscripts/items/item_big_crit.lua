if item_big_crit == nil then item_big_crit = class({}) end

LinkLuaModifier("modifier_big_crit_passive","items/item_big_crit.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_big_crit_crit","items/item_big_crit.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stun","libraries/modifiers/modifier_stun.lua",LUA_MODIFIER_MOTION_NONE)

function item_big_crit:GetIntrinsicModifierName(  )
	return "modifier_big_crit_passive"
end

--------------------------

if modifier_big_crit_passive == nil then modifier_big_crit_passive = class({}) end

function modifier_big_crit_passive:IsPurgable(  )
	return false
end

function modifier_big_crit_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_big_crit_passive:IsHidden(  )
	return true
end

function modifier_big_crit_passive:DeclareFunctions(  )
	local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
	return funcs
end

function modifier_big_crit_passive:CheckState()
	local states = { [MODIFIER_STATE_CANNOT_MISS] = true }
	return states
end

function modifier_big_crit_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_CUSTOM
end

require('libraries/IsBoss')

function modifier_big_crit_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then
		local stun_recover
		caster:RemoveModifierByName("modifier_big_crit_crit")
		local ability = self:GetAbility()
		if RollPercentage(ability:GetSpecialValueFor("chance")) then
			caster:AddNewModifier(caster,ability,"modifier_big_crit_crit",{})
		end
		if RollPercentage(ability:GetSpecialValueFor("chance_b")) and self:IsActiveOrb() and not IsBoss(params.target) and ability:IsCooldownReady() then
			params.target:AddNewModifier(caster,ability,"modifier_stun",{duration = 0.1})
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function modifier_big_crit_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("damage")
	self.atk = ability:GetSpecialValueFor("atk_speed")
end

function modifier_big_crit_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_big_crit_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

if modifier_big_crit_crit == nil then modifier_big_crit_crit = class({}) end

function modifier_big_crit_crit:IsPurgable(  )
	return false
end

function modifier_big_crit_crit:IsHidden(  )
	return true
end

function modifier_big_crit_crit:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_big_crit_crit:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then caster:RemoveModifierByName(self:GetName()) end
end

function modifier_big_crit_crit:OnCreated(  )
	self.crit = self:GetAbility():GetSpecialValueFor("multiplier")
end

function modifier_big_crit_crit:GetModifierPreAttack_CriticalStrike(  )
	return self.crit
end