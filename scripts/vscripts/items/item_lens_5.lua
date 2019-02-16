if item_aether_lens_5 == nil then item_aether_lens_5 = class({}) end

LinkLuaModifier("modifier_lens_5_passive","items/item_lens_5.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lens_5_act","items/item_lens_5.lua",LUA_MODIFIER_MOTION_NONE)

function item_aether_lens_5:GetIntrinsicModifierName(  )
	return "modifier_lens_5_passive"
end

function item_aether_lens_5:OnSpellStart(  )
	caster = self:GetCaster()
	if not caster:IsMagicImmune() then
		caster:AddNewModifier(caster,self,"modifier_lens_5_act",{duration = self:GetSpecialValueFor("duration")})
		caster:EmitSound("Hero_FacelessVoid.TimeLockImpact")
	end
end

if modifier_lens_5_passive == nil then modifier_lens_5_passive = class({}) end

function modifier_lens_5_passive:IsPurgable(  )
	return false
end

function modifier_lens_5_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_lens_5_passive:IsHidden(  )
	return true
end

function modifier_lens_5_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_lens_5_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.mana = ability:GetSpecialValueFor("mana")
	self.int = ability:GetSpecialValueFor("int")
	self.hp_reg = ability:GetSpecialValueFor("hp_reg")
	self.ampl = ability:GetSpecialValueFor("spell_amp")
	self.range = ability:GetSpecialValueFor("cast_range_bonus")
end

function modifier_lens_5_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE ,MODIFIER_PROPERTY_CAST_RANGE_BONUS}
end

function modifier_lens_5_passive:GetModifierManaBonus(  )
	return self.mana
end

function modifier_lens_5_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_lens_5_passive:GetModifierConstantHealthRegen(  )
	return self.hp_reg
end

function modifier_lens_5_passive:GetModifierSpellAmplify_Percentage(  )
	return self.ampl
end

function modifier_lens_5_passive:GetModifierCastRangeBonus(  )
	return self.range
end

if modifier_lens_5_act == nil then modifier_lens_5_act = class({}) end

function modifier_lens_5_act:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_lens_5_act:IsPurgable(  )
	return false
end

function modifier_lens_5_act:OnCreated(  )
	self.int = self:GetAbility():GetSpecialValueFor("int_act")
	self.regen = self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_lens_5_act:OnRefresh(  )
	self.int = self:GetAbility():GetSpecialValueFor("int_act")
	self.regen = self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_lens_5_act:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_lens_5_act:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_lens_5_act:GetModifierConstantManaRegen(  )
	return self.regen
end