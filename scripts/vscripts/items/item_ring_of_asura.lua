if item_ring_of_asura_inactive == nil then item_ring_of_asura_inactive = class({}) end

LinkLuaModifier("modifier_ring_of_asura_passive","items/item_ring_of_asura.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ring_of_asura_aura","items/item_ring_of_asura.lua",LUA_MODIFIER_MOTION_NONE)

function item_ring_of_asura_inactive:GetIntrinsicModifierName(  )
	return "modifier_ring_of_asura_passive"
end

function item_ring_of_asura_inactive:OnSpellStart(  )
	self:GetCaster():SwapItem(self:GetName(),"item_ring_of_asura",0)
end

if item_ring_of_asura == nil then item_ring_of_asura = class({}) end

function item_ring_of_asura:GetIntrinsicModifierName(  )
	return "modifier_ring_of_asura_passive"
end

function item_ring_of_asura:OnSpellStart(  )
	self:GetCaster():SwapItem(self:GetName(),"item_ring_of_asura_inactive",0)
end

if modifier_ring_of_asura_passive == nil then modifier_ring_of_asura_passive = class({}) end

function modifier_ring_of_asura_passive:IsHidden(  )
	return true
end

function modifier_ring_of_asura_passive:IsPurgable(  )
	return false
end

function modifier_ring_of_asura_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ring_of_asura_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_ring_of_asura_passive:OnCreated(  )
	self.dmg = self:GetAbility():GetSpecialValueFor("dmg")
	self.agi = self:GetAbility():GetSpecialValueFor("agi")
	self.str = self:GetAbility():GetSpecialValueFor("str")
	self.int = self:GetAbility():GetSpecialValueFor("int")
end

function modifier_ring_of_asura_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_ring_of_asura_passive:GetModifierBonusStats_Agility(  )
	return self.agi
end

function modifier_ring_of_asura_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_ring_of_asura_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_ring_of_asura_passive:IsAura()
	return true
end

function modifier_ring_of_asura_passive:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("range")
end

function modifier_ring_of_asura_passive:GetModifierAura()
    return "modifier_ring_of_asura_aura"
end
   
function modifier_ring_of_asura_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_ring_of_asura_passive:GetAuraSearchType()
	if self:GetAbility():GetName() == "item_ring_of_asura" then return DOTA_UNIT_TARGET_HERO else return DOTA_UNIT_TARGET_CREEP end  
	return nil
end

function modifier_ring_of_asura_passive:GetAuraDuration()
    return 0.1
end

if modifier_ring_of_asura_aura == nil then modifier_ring_of_asura_aura = class({}) end

function modifier_ring_of_asura_aura:GetTexture(  )
	return "item_ring_of_asura"
end

function modifier_ring_of_asura_aura:IsPurgable(  )
	return false
end

function modifier_ring_of_asura_aura:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_ring_of_asura_aura:OnCreated(  )
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_ring_of_asura_aura:GetModifierPhysicalArmorBonus(  )
	return self.armor
end

function modifier_ring_of_asura_aura:GetModifierConstantManaRegen(  )
	return self.mana_regen
end