if item_mask_of_madness_custom == nil then item_mask_of_madness_custom = class({}) end

LinkLuaModifier("modifier_mask_of_madness_custom_passive","items/item_mask_of_madness_custom",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mask_of_madness_custom_act","items/item_mask_of_madness_custom",LUA_MODIFIER_MOTION_NONE)

function item_mask_of_madness_custom:OnSpellStart(  )
	self:GetCaster():EmitSound("DOTA_Item.MaskOfMadness.Activate|soundevents/game_sounds_items.vsndevts")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_mask_of_madness_custom_act",{duration = self:GetSpecialValueFor("duration")})
end

function item_mask_of_madness_custom:GetIntrinsicModifierName(  )
	return "modifier_mask_of_madness_custom_passive"
end

if modifier_mask_of_madness_custom_passive == nil then modifier_mask_of_madness_custom_passive = class({}) end

function modifier_mask_of_madness_custom_passive:IsHidden(  )
	return true
end

function modifier_mask_of_madness_custom_passive:IsPurgable(  )
	return false
end

function modifier_mask_of_madness_custom_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_mask_of_madness_custom_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker == caster and params.target ~= caster and not params.target:IsMagicImmune() and self:IsActiveOrb() then
		local lifesteal = ability:GetSpecialValueFor("lifesteal")
		local heal = params.damage * lifesteal * 0.01
		caster:HealCustom(heal,caster,true)
	end
end

function modifier_mask_of_madness_custom_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

if modifier_mask_of_madness_custom_act == nil then modifier_mask_of_madness_custom_act = class({}) end

function modifier_mask_of_madness_custom_act:GetTexture(  )
	return "item_mask_of_madness_custom"
end

function modifier_mask_of_madness_custom_act:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.speed = ability:GetSpecialValueFor("speed")
	self.atk = ability:GetSpecialValueFor("atk")
end

function modifier_mask_of_madness_custom_act:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_mask_of_madness_custom_act:GetModifierIncomingDamage_Percentage(  )
	return self.dmg
end

function modifier_mask_of_madness_custom_act:GetModifierMoveSpeedBonus_Percentage(  )
	return self.speed
end

function modifier_mask_of_madness_custom_act:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end