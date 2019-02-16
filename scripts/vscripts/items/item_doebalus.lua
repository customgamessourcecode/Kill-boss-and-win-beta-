if item_doebalus == nil then item_doebalus = class({}) end

LinkLuaModifier("modifier_doebalus_passive","items/item_doebalus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doebalus_crit","items/item_doebalus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stun","libraries/modifiers/modifier_stun.lua",LUA_MODIFIER_MOTION_NONE)

function item_doebalus:GetIntrinsicModifierName(  )
	return "modifier_doebalus_passive"
end

--------------------------

if modifier_doebalus_passive == nil then modifier_doebalus_passive = class({}) end

function modifier_doebalus_passive:IsPurgable(  )
	return false
end

function modifier_doebalus_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_doebalus_passive:IsHidden(  )
	return true
end

function modifier_doebalus_passive:DeclareFunctions(  )
	local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
	return funcs
end

function modifier_doebalus_passive:CheckState()
	local states = { [MODIFIER_STATE_CANNOT_MISS] = true }
	return states
end

function modifier_doebalus_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_CUSTOM
end

function modifier_doebalus_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then
		caster:RemoveModifierByName("modifier_doebalus_crit")
		local ability = self:GetAbility()
		if RollPercentage(ability:GetSpecialValueFor("chance")) then
			caster:AddNewModifier(caster,ability,"modifier_doebalus_crit",{})
		end
		if RollPercentage(ability:GetSpecialValueFor("chance_b")) and self:IsActiveOrb() and not IsBoss(params.target) and ability:IsCooldownReady() then
			params.target:AddNewModifier(caster,ability,"modifier_stun",{duration = 0.1})
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function modifier_doebalus_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("damage")
	self.atk = ability:GetSpecialValueFor("atk_speed")
end

function modifier_doebalus_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_doebalus_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

if modifier_doebalus_crit == nil then modifier_doebalus_crit = class({}) end

function modifier_doebalus_crit:IsPurgable(  )
	return false
end

function modifier_doebalus_crit:IsHidden(  )
	return true
end

function modifier_doebalus_crit:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_doebalus_crit:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then caster:RemoveModifierByName(self:GetName()) end
end

function modifier_doebalus_crit:OnCreated(  )
	self.crit = self:GetAbility():GetSpecialValueFor("multiplier")
end

function modifier_doebalus_crit:GetModifierPreAttack_CriticalStrike(  )
	return self.crit
end