if item_deso2 == nil then item_deso2 = class({}) end

LinkLuaModifier("modifier_deso2_passive","items/item_deso2.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("deso2_modifier_corrupt","items/item_deso2.lua",LUA_MODIFIER_MOTION_NONE)

function item_deso2:GetIntrinsicModifierName(  )
	return "modifier_deso2_passive"
end

if modifier_deso2_passive == nil then modifier_deso2_passive = class({}) end

function modifier_deso2_passive:IsHidden(  )
	return true
end

function modifier_deso2_passive:IsPurgable(  )
	return false
end

function modifier_deso2_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_deso2_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_deso2_passive:GetModifierOrbPriority()
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_deso2_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target

	if target ~= caster and params.attacker == caster and not target:IsMagicImmune() and self:IsActiveOrb() then
		target:AddNewModifier(caster,ability,"deso2_modifier_corrupt",{duration = ability:GetSpecialValueFor("corrupt_duration")})
	end
end

if deso2_modifier_corrupt == nil then deso2_modifier_corrupt = class({}) end

function deso2_modifier_corrupt:GetTexture(  )
	return "item_deso2"
end

function deso2_modifier_corrupt:IsDebuff(  )
	return true
end

function deso2_modifier_corrupt:OnCreated(  )
 self.disarmor = -self:GetAbility():GetSpecialValueFor("corrupt_armor")
end

function deso2_modifier_corrupt:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function deso2_modifier_corrupt:GetModifierPhysicalArmorBonus(  )
	return self.disarmor
end