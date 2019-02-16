if item_black_king_hood == nil then
	item_black_king_hood = class({})
end

LinkLuaModifier("modifier_black_king_hood_spell","items/item_black_king_hood.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_black_king_hood_passive","items/item_black_king_hood.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_black_king_hood_aura","items/item_black_king_hood.lua",LUA_MODIFIER_MOTION_NONE)

function item_black_king_hood:GetIntrinsicModifierName(  )
	return "modifier_black_king_hood_passive"
end

function item_black_king_hood:OnChannelFinish( bInterrupted )
	if not bInterrupted then
	    local ability = self
		local caster = self:GetCaster()
		caster:AddNewModifier(caster,ability,"modifier_black_king_hood_spell",{duration = ability:GetSpecialValueFor("duration")})
	else
		return nil
	end
end

-------------------------------

if modifier_black_king_hood_spell == nil then
	modifier_black_king_hood_spell = class({})
end

function modifier_black_king_hood_spell:OnCreated(  )
	self.resistance_spell = self:GetAbility():GetSpecialValueFor("resistance")
end

function modifier_black_king_hood_spell:OnRefresh(  )
	self.resistance_spell = self:GetAbility():GetSpecialValueFor("resistance")
end

function modifier_black_king_hood_spell:DeclareFunctions()
	local hFuncs ={ MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
	return hFuncs
end

function modifier_black_king_hood_spell:GetTexture(  )
	return "item_black_king_hood"
end

function modifier_black_king_hood_spell:GetModifierMagicalResistanceBonus()
    return self.resistance_spell
end

function modifier_black_king_hood_spell:GetEffectName()
    return "particles/econ/events/pw_compendium_2014/teleport_end_pw2014.vpcf"
end

--------------------------------

if modifier_black_king_hood_passive == nil then
	modifier_black_king_hood_passive = class({})
end

function modifier_black_king_hood_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_black_king_hood_passive:IsHidden()
	return true
end

function modifier_black_king_hood_passive:OnCreated(  )
	self.all = self:GetAbility():GetSpecialValueFor("all")
	self.int = self:GetAbility():GetSpecialValueFor("int")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.resistance_passive = self:GetAbility():GetSpecialValueFor("resistance_passive")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.range = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_black_king_hood_passive:OnRefresh(  )
	self.all = self:GetAbility():GetSpecialValueFor("all")
	self.int = self:GetAbility():GetSpecialValueFor("int")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.resistance_passive = self:GetAbility():GetSpecialValueFor("resistance_passive")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.range = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_black_king_hood_passive:DeclareFunctions()
	local hFuncs ={ MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
	return hFuncs
end

function modifier_black_king_hood_passive:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_black_king_hood_passive:GetModifierBonusStats_Agility()
	return self.all
end

function modifier_black_king_hood_passive:GetModifierBonusStats_Strength()
	return self.all
end

function modifier_black_king_hood_passive:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_black_king_hood_passive:GetModifierMagicalResistanceBonus()
	return self.resistance_passive
end

function modifier_black_king_hood_passive:IsAura()
	return true
end

function modifier_black_king_hood_passive:IsPurgable()
    return false
end

function modifier_black_king_hood_passive:GetAuraRadius()
    return self.range
end

function modifier_black_king_hood_passive:GetModifierAura()
    return "modifier_black_king_hood_aura"
end
   
function modifier_black_king_hood_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_black_king_hood_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_black_king_hood_passive:GetAuraDuration()
    return 0.5
end

-------------------------------------------

if modifier_black_king_hood_aura == nil then
	modifier_black_king_hood_aura = class({})
end

function modifier_black_king_hood_aura:OnCreated(  )
	self.armor_aura = self:GetAbility():GetSpecialValueFor("armor")
	self.mana_regen_aura = self:GetAbility():GetSpecialValueFor("mana_regen")
	self.resistance_aura = self:GetAbility():GetSpecialValueFor("resistance_aura")
end

function modifier_black_king_hood_aura:OnRefresh(  )
	self.armor_aura = self:GetAbility():GetSpecialValueFor("armor")
	self.mana_regen_aura = self:GetAbility():GetSpecialValueFor("mana_regen")
	self.resistance_aura = self:GetAbility():GetSpecialValueFor("resistance_aura")
end

function modifier_black_king_hood_aura:DeclareFunctions()
	local hFuncs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE }
	return hFuncs
end

function modifier_black_king_hood_aura:GetModifierMagicalResistanceBonus()
    return self.resistance_aura
end

function modifier_black_king_hood_aura:GetModifierPercentageManaRegen()
    return self.mana_regen_aura / 10
end

function modifier_black_king_hood_aura:GetModifierPhysicalArmorBonus()
    return self.armor_aura
end

function modifier_black_king_hood_aura:GetTexture()
    return "item_black_king_hood"
end