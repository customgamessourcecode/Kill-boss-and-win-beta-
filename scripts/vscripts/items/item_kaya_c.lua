if item_kaya_c == nil then item_kaya_c = class({}) end

LinkLuaModifier("modifier_kaya_c_passive","items/item_kaya_c.lua",LUA_MODIFIER_MOTION_NONE)

function item_kaya_c:GetIntrinsicModifierName(  )
	return "modifier_kaya_c_passive"
end

if modifier_kaya_c_passive == nil then modifier_kaya_c_passive = class({}) end

function modifier_kaya_c_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_kaya_c_passive:IsHidden() return true end

function modifier_kaya_c_passive:IsPurgable() return false end

function modifier_kaya_c_passive:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MANACOST_PERCENTAGE,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
	return funcs
end

function modifier_kaya_c_passive:OnCreated() 
	local ability = self:GetAbility()
	self.manacost = ability:GetSpecialValueFor("manacost")
	self.amp = ability:GetSpecialValueFor("amp")
	self.int = ability:GetSpecialValueFor("int")
end

function modifier_kaya_c_passive:GetModifierPercentageManacost() return self.manacost end

function modifier_kaya_c_passive:GetModifierBonusStats_Intellect() return self.int end

function modifier_kaya_c_passive:GetModifierSpellAmplify_Percentage() return self.amp end