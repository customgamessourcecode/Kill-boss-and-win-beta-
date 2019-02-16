if item_skadi_custom == nil then item_skadi_custom = class({}) end

LinkLuaModifier("modifier_skadi_custom_passive","items/item_skadi_custom.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skadi_custom_slow","items/item_skadi_custom.lua",LUA_MODIFIER_MOTION_NONE)

function item_skadi_custom:GetIntrinsicModifierName(  )
	return "modifier_skadi_custom_passive"
end

if modifier_skadi_custom_passive == nil then modifier_skadi_custom_passive = class({}) end

function modifier_skadi_custom_passive:IsHidden(  )
	return true
end

function modifier_skadi_custom_passive:IsPurgable(  )
	return false
end

function modifier_skadi_custom_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_skadi_custom_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_skadi_custom_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target

	if target ~= caster and params.attacker == caster and not target:IsMagicImmune() and self:IsActiveOrb() then
		local duration = 0
		if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			duration = ability:GetSpecialValueFor("melee_slow")
		else
			duration = ability:GetSpecialValueFor("range_slow")
		end
		target:AddNewModifier(caster,ability,"modifier_skadi_custom_slow",{duration = duration})
	end
end

function modifier_skadi_custom_passive:GetModifierHealthBonus(  )
	return self:GetAbility():GetSpecialValueFor("hp")
end
function modifier_skadi_custom_passive:GetModifierManaBonus(  )
	return self:GetAbility():GetSpecialValueFor("mp")
end

function modifier_skadi_custom_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_skadi_custom_passive:GetModifierBonusStats_Strength(  )
	return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_skadi_custom_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("all")
end

if modifier_skadi_custom_slow == nil then modifier_skadi_custom_slow = class({}) end

function modifier_skadi_custom_slow:IsDebuff(  )
	return true
end

function modifier_skadi_custom_slow:GetTexture(  )
	return "item_skadi_custom"
end

function modifier_skadi_custom_slow:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_skadi_custom_slow:OnCreated(  )
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.atk_slow = self:GetAbility():GetSpecialValueFor("atk_slow")
end

function modifier_skadi_custom_slow:GetModifierMoveSpeedBonus_Percentage(  )
	return -self.slow
end

function modifier_skadi_custom_slow:GetModifierAttackSpeedBonus_Constant(  )
	return -self.atk_slow
end