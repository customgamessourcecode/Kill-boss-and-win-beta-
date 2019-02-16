if item_spell_rune == nil then item_spell_rune = class({}) end

LinkLuaModifier("modifier_spell_rune_passive","items/item_spell_rune.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spell_rune_act","items/item_spell_rune.lua",LUA_MODIFIER_MOTION_NONE)

function item_spell_rune:GetIntrinsicModifierName(  )
	return "modifier_spell_rune_passive"
end

function item_spell_rune:OnSpellStart(  )
	caster = self:GetCaster()
	if not caster:IsMagicImmune() then
		caster:AddNewModifier(caster,self,"modifier_spell_rune_act",{duration = self:GetSpecialValueFor("duration")})
		caster:EmitSound("Hero_FacelessVoid.TimeLockImpact")
	end
end

if modifier_spell_rune_passive == nil then modifier_spell_rune_passive = class({}) end

function modifier_spell_rune_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_spell_rune_passive:IsHidden()
	return true
end

function modifier_spell_rune_passive:IsPurgable(  )
	return false
end

function modifier_spell_rune_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_spell_rune_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("int")
end

if modifier_spell_rune_act == nil then modifier_spell_rune_act = class({}) end

function modifier_spell_rune_act:GetTexture(  )
	return "item_spell_rune"
end

function modifier_spell_rune_act:IsPurgable(  )
	return false
end

function modifier_spell_rune_act:OnCreated(  )
	local ability = self:GetAbility()
	self.int = ability:GetSpecialValueFor("int_act")
	self.mana = ability:GetSpecialValueFor("mana_regen")
end

function modifier_spell_rune_act:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_spell_rune_act:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_spell_rune_act:GetModifierConstantManaRegen(  )
	return self.mana
end