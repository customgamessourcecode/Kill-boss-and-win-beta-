if item_desolator_custom == nil then item_desolator_custom = class({}) end

LinkLuaModifier("modifier_desolator_custom_passive","items/item_desolator_custom.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_desolator_custom_corrupt","items/item_desolator_custom.lua",LUA_MODIFIER_MOTION_NONE)

function item_desolator_custom:GetIntrinsicModifierName(  )
	return "modifier_desolator_custom_passive"
end

if modifier_desolator_custom_passive == nil then modifier_desolator_custom_passive = class({}) end

function modifier_desolator_custom_passive:IsHidden(  )
	return true
end

function modifier_desolator_custom_passive:IsPurgable(  )
	return false
end

function modifier_desolator_custom_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_desolator_custom_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_desolator_custom_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_desolator_custom_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target

	if target ~= caster and params.attacker == caster and not target:IsMagicImmune() and self:IsActiveOrb() then
		target:AddNewModifier(caster,ability,"modifier_desolator_custom_corrupt",{duration = ability:GetSpecialValueFor("duration")})
	end
end

if modifier_desolator_custom_corrupt == nil then modifier_desolator_custom_corrupt = class({}) end

function modifier_desolator_custom_corrupt:GetTexture(  )
	return "item_desolator_custom"
end

function modifier_desolator_custom_corrupt:IsDebuff(  )
	return true
end

function modifier_desolator_custom_corrupt:OnCreated(  )
 	self.disarmor = self:GetAbility():GetSpecialValueFor("disarmor")
end

function modifier_desolator_custom_corrupt:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_desolator_custom_corrupt:GetModifierPhysicalArmorBonus(  )
	return -self.disarmor
end