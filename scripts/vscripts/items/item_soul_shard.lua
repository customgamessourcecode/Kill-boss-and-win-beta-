if item_soul_shard == nil then item_soul_shard = class({}) end

LinkLuaModifier("modifier_soul_shard_passive","items/item_soul_shard.lua",LUA_MODIFIER_MOTION_NONE)

function item_soul_shard:GetIntrinsicModifierName(  )
	return "modifier_soul_shard_passive"
end

if modifier_soul_shard_passive == nil then modifier_soul_shard_passive = class({}) end

function modifier_soul_shard_passive:IsHidden(  )
	return true
end

function modifier_soul_shard_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_soul_shard_passive:IsPurgable(  )
	return false
end

function modifier_soul_shard_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_soul_shard_passive:OnCreated(  )
	self.int_prc = self:GetAbility():GetSpecialValueFor("int") * 0.01
	self.str_prc = self:GetAbility():GetSpecialValueFor("str") * 0.01
	self.agi_prc = self:GetAbility():GetSpecialValueFor("agi") * 0.01
end

function modifier_soul_shard_passive:GetModifierBonusStats_Intellect(  )
	local int = self:GetCaster():GetBaseIntellect() * self.int_prc
	return int
end

function modifier_soul_shard_passive:GetModifierBonusStats_Agility(  )
	local int = self:GetCaster():GetBaseAgility() * self.agi_prc
	return int
end

function modifier_soul_shard_passive:GetModifierBonusStats_Strength(  )
	local int = self:GetCaster():GetBaseStrength() * self.str_prc
	return int
end