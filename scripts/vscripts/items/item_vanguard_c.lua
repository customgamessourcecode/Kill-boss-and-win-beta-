if item_vanguard_c == nil then
	item_vanguard_c = class({})
end

LinkLuaModifier("modifier_item_vanguard_c", "items/item_vanguard_c.lua", LUA_MODIFIER_MOTION_NONE)

function item_vanguard_c:GetIntrinsicModifierName() 
	return "modifier_item_vanguard_c"
end

-----------------------

if modifier_item_vanguard_c == nil then
	modifier_item_vanguard_c = class({})
end

function modifier_item_vanguard_c:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_item_vanguard_c:IsHidden()
	return true 
end

function modifier_item_vanguard_c:IsPurgable(  )
	return false
end

function modifier_item_vanguard_c:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS
	} 
	return funcs
end

function modifier_item_vanguard_c:OnCreated()
	self.blockDamage = self:GetAbility():GetSpecialValueFor("damage_block")
	self.healthRegen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.healthBonus = self:GetAbility():GetSpecialValueFor("health")
end

function modifier_item_vanguard_c:GetModifierConstantHealthRegen()
	return self.healthRegen
end

function modifier_item_vanguard_c:GetModifierHealthBonus()
	return self.healthBonus
end

function modifier_item_vanguard_c:GetModifierPhysical_ConstantBlock()
	return self.blockDamage 
end