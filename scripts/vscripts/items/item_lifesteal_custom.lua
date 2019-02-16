if item_lifesteal_custom == nil then item_lifesteal_custom = class({}) end

LinkLuaModifier("modifier_lifesteal_custom_passive","items/item_lifesteal_custom.lua",LUA_MODIFIER_MOTION_NONE)

function item_lifesteal_custom:GetIntrinsicModifierName(  )
	return "modifier_lifesteal_custom_passive"
end

if modifier_lifesteal_custom_passive == nil then modifier_lifesteal_custom_passive = class({}) end

function modifier_lifesteal_custom_passive:IsHidden(  )
	return true
end

function modifier_lifesteal_custom_passive:IsPurgable(  )
	return false
end

function modifier_lifesteal_custom_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_lifesteal_custom_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_lifesteal_custom_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker == caster and params.target ~= caster and not params.target:IsMagicImmune() and self:IsActiveOrb() then
		local heal = params.damage * ability:GetSpecialValueFor("lifesteal") * 0.01
		caster:HealCustom(heal,caster,true)
	end
end