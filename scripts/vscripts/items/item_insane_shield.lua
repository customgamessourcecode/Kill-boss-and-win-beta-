if item_insane_shield == nil then
	item_insane_shield = class({})
end

LinkLuaModifier("modifier_insane_shield_passive","items/item_insane_shield.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_insane_shield_reduce_spell","items/item_insane_shield.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_insane_shield_reduce","items/item_insane_shield.lua",LUA_MODIFIER_MOTION_NONE)

function item_insane_shield:GetIntrinsicModifierName(  )
	return "modifier_insane_shield_passive"
end

function item_insane_shield:OnSpellStart(  )
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_insane_shield_reduce_spell",{duration = self:GetSpecialValueFor("duration")})
	end
end

---------------------------------------------

if modifier_insane_shield_passive == nil then
	modifier_insane_shield_passive = class({})
end

function modifier_insane_shield_passive:IsPurgable(  )
	return false
end

function modifier_insane_shield_passive:IsHidden(  )
	return true
end

function modifier_insane_shield_passive:OnCreated(  )
	self.hp = self:GetAbility():GetSpecialValueFor("hp")
	self.mp = self:GetAbility():GetSpecialValueFor("mp")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.block = self:GetAbility():GetSpecialValueFor("block")
end

function modifier_insane_shield_passive:OnRefresh(  )
	self.hp = self:GetAbility():GetSpecialValueFor("hp")
	self.mp = self:GetAbility():GetSpecialValueFor("mp")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.block = self:GetAbility():GetSpecialValueFor("block")
end

function modifier_insane_shield_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_insane_shield_passive:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS  }
	return funcs
end

function modifier_insane_shield_passive:GetModifierPhysical_ConstantBlock()
	return self.block
end

function modifier_insane_shield_passive:GetModifierHealthBonus(  )
	return self.hp
end

function modifier_insane_shield_passive:GetModifierManaBonus(  )
	return self.mp
end

function modifier_insane_shield_passive:GetModifierConstantHealthRegen(  )
	return self.hp_regen
end

function modifier_insane_shield_passive:GetModifierPhysicalArmorBonus(  )
	return self.armor
end

function modifier_insane_shield_passive:OnTakeDamage(  )
	if IsServer() and not params.attacker == self:GetParent() then
		if RollPercentage(self.chance) then
			self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_insane_shield_reduce",{duration = 0.01})
		end
	end
end

------------------------------

if modifier_insane_shield_reduce == nil then
	modifier_insane_shield_reduce = class({})
end

function modifier_insane_shield_reduce:IsHidden(  )
	return true
end

function modifier_insane_shield_reduce:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE }
	return funcs
end

function modifier_insane_shield_reduce:OnCreated(  )
	self.reduce_c = -self:GetAbility():GetSpecialValueFor("reduce_c")
end

function modifier_insane_shield_reduce:OnRefresh(  )
	self.reduce_c = -self:GetAbility():GetSpecialValueFor("reduce_c")
end

function modifier_insane_shield_reduce:GetModifierIncomingPhysicalDamage_Percentage(  )
	return self.reduce_c
end

-----------------------------

if modifier_insane_shield_reduce_spell == nil then
	modifier_insane_shield_reduce_spell = class({})
end

function modifier_insane_shield_reduce_spell:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE }
	return funcs
end

function modifier_insane_shield_reduce_spell:OnCreated(  )
	self.reduce = -self:GetAbility():GetSpecialValueFor("reduce")
end

function modifier_insane_shield_reduce_spell:OnRefresh(  )
	self.reduce = -self:GetAbility():GetSpecialValueFor("reduce")
end

function modifier_insane_shield_reduce_spell:GetModifierIncomingPhysicalDamage_Percentage(  )
	return self.reduce
end

function modifier_insane_shield_reduce_spell:GetTexture(  )
	return "item_insane_shield"
end