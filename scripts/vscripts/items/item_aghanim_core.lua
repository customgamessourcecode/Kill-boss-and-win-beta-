if not item_aghanim_core then item_aghanim_core = class({}) end

LinkLuaModifier("modifier_aghanim_core_passive","items/item_aghanim_core.lua",LUA_MODIFIER_MOTION_NONE)

function item_aghanim_core:GetIntrinsicModifierName(  )
	return "modifier_aghanim_core_passive"
end

if not modifier_aghanim_core_passive then modifier_aghanim_core_passive = class({}) end

function modifier_aghanim_core_passive:IsHidden(  )
	return true
end

function modifier_aghanim_core_passive:IsPurgable(  )
	return false
end

function modifier_aghanim_core_passive:DeclareFunctions( )
	return {MODIFIER_PROPERTY_IS_SCEPTER,MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_aghanim_core_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.agi = ability:GetSpecialValueFor("agi")
	self.str = ability:GetSpecialValueFor("str")
	self.int = ability:GetSpecialValueFor("int")
	self.hp = ability:GetSpecialValueFor("hp")
	self.mana = ability:GetSpecialValueFor("mana")
	self.mana_regen = ability:GetSpecialValueFor("mana_regen")
	self.reduce = ability:GetSpecialValueFor("reduce_cooldown")
end

function modifier_aghanim_core_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end
function modifier_aghanim_core_passive:GetModifierBonusStats_Agility(  )
	return self.agi
end
function modifier_aghanim_core_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_aghanim_core_passive:GetModifierHealthBonus(  )
	return self.hp
end
function modifier_aghanim_core_passive:GetModifierManaBonus(  )
	return self.hp
end

function modifier_aghanim_core_passive:GetModifierPercentageCooldown(  )
	return self.reduce
end

function modifier_aghanim_core_passive:GetModifierPercentageCooldown(  )
	return self.reduce
end

function modifier_aghanim_core_passive:GetModifierPercentageManaRegen(  )
	return self.mana_regen
end

function modifier_aghanim_core_passive:GetModifierScepter(  )
	return true
end