if item_sacred_shield == nil then
	item_sacred_shield = class({})
end

LinkLuaModifier("modifier_item_sacred_shield", "items/item_sacred_shield.lua", LUA_MODIFIER_MOTION_NONE)

function item_sacred_shield:GetIntrinsicModifierName() 
	return "modifier_item_sacred_shield"
end

-----------

if modifier_item_sacred_shield == nil then
	modifier_item_sacred_shield = class({})
end

function modifier_item_sacred_shield:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_sacred_shield:IsPurgable(  )
	return false
end

function modifier_item_sacred_shield:IsHidden()
	return true 
end

function modifier_item_sacred_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
 
	return funcs
end

function modifier_item_sacred_shield:OnCreated()
	self.blockDamage = self:GetAbility():GetSpecialValueFor("damage_block")
	self.healthRegen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.healthBonus = self:GetAbility():GetSpecialValueFor("health")
end

function modifier_item_sacred_shield:GetModifierConstantHealthRegen()
	return self.healthRegen
end

function modifier_item_sacred_shield:GetModifierHealthBonus()
	return self.healthBonus
end

function modifier_item_sacred_shield:GetModifierPhysical_ConstantBlock()
	return self.blockDamage 
end