if item_demon_lifesteal == nil then item_demon_lifesteal = class({}) end

LinkLuaModifier("modifier_demon_lifesteal_passive","items/item_demon_lifesteal.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demon_lifesteal_act","items/item_demon_lifesteal.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demon_lifesteal_aura","items/item_demon_lifesteal.lua",LUA_MODIFIER_MOTION_NONE)

function item_demon_lifesteal:OnSpellStart(  )
	self:GetCaster():EmitSound("DOTA_Item.MaskOfMadness.Activate|soundevents/game_sounds_items.vsndevts")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_demon_lifesteal_act",{duration = self:GetSpecialValueFor("duration")})
end

function item_demon_lifesteal:GetIntrinsicModifierName(  )
	return "modifier_demon_lifesteal_passive"
end

if modifier_demon_lifesteal_passive == nil then modifier_demon_lifesteal_passive = class({}) end

function modifier_demon_lifesteal_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_demon_lifesteal_passive:IsHidden(  )
	return true
end

function modifier_demon_lifesteal_passive:IsPurgable(  )
	return false
end

function modifier_demon_lifesteal_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_demon_lifesteal_passive:GetModifierPhysicalArmorBonus(  )
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_demon_lifesteal_passive:GetModifierConstantHealthRegen(  )
	return self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_demon_lifesteal_passive:GetModifierBonusStats_Strength(  )
	return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_demon_lifesteal_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_demon_lifesteal_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("all")
end

function modifier_demon_lifesteal_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_demon_lifesteal_passive:IsAura()
	return true
end

function modifier_demon_lifesteal_passive:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("range")
end

function modifier_demon_lifesteal_passive:GetModifierAura()
    return "modifier_demon_lifesteal_aura"
end
   
function modifier_demon_lifesteal_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_demon_lifesteal_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_demon_lifesteal_passive:GetAuraDuration()
    return 0.1
end

if modifier_demon_lifesteal_aura == nil then modifier_demon_lifesteal_aura = class({}) end

function modifier_demon_lifesteal_aura:IsPurgable(  )
	return false
end

function modifier_demon_lifesteal_aura:GetTexture(  )
	return "item_demon_lifesteal"
end

function modifier_demon_lifesteal_aura:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_demon_lifesteal_aura:OnCreated(  )
	local ability = self:GetAbility()
	self.armor = self:GetAbility():GetSpecialValueFor("aura_armor")
	self.dmg = self:GetAbility():GetSpecialValueFor("aura_dmg")
	self.mana = self:GetAbility():GetSpecialValueFor("aura_mana")
	self.reg = self:GetAbility():GetSpecialValueFor("aura_reg")
end

function modifier_demon_lifesteal_aura:GetModifierPhysicalArmorBonus(  )
	return self.armor
end

function modifier_demon_lifesteal_aura:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_demon_lifesteal_aura:GetModifierConstantManaRegen(  )
	return self.mana
end

function modifier_demon_lifesteal_aura:GetModifierConstantHealthRegen(  )
	return self.reg
end

function modifier_demon_lifesteal_aura:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_demon_lifesteal_aura:OnAttackLanded( params )
	local damage = params.damage
	local target = params.target
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local percentage = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
	if params.attacker == parent and target ~= parent and self:IsActiveOrb() then
		local heal = damage * percentage
		parent:HealCustom(heal,parent,true,false)
	end
end

if modifier_demon_lifesteal_act == nil then modifier_demon_lifesteal_act = class({}) end

function modifier_demon_lifesteal_act:GetTexture(  )
	return "item_demon_lifesteal"
end

function modifier_demon_lifesteal_act:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE}
end

function modifier_demon_lifesteal_act:OnCreated(  )
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("act_damage")
	self.speed = ability:GetSpecialValueFor("act_speed")
	self.atk = ability:GetSpecialValueFor("act_atk")
end

function modifier_demon_lifesteal_act:GetModifierIncomingPhysicalDamage_Percentage(  )
	return self.damage
end

function modifier_demon_lifesteal_act:GetModifierMoveSpeedBonus_Percentage(  )
	return self.speed
end

function modifier_demon_lifesteal_act:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end