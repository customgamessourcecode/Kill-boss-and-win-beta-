if item_blight_stone_custom == nil then item_blight_stone_custom = class({}) end

LinkLuaModifier("modifier_blight_stone_custom_passive","items/item_blight_stone_custom.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blight_stone_custom_disarmor","items/item_blight_stone_custom.lua",LUA_MODIFIER_MOTION_NONE)

function item_blight_stone_custom:GetIntrinsicModifierName(  )
	return "modifier_blight_stone_custom_passive"
end

if modifier_blight_stone_custom_passive == nil then modifier_blight_stone_custom_passive = class({}) end

function modifier_blight_stone_custom_passive:IsHidden(  )
	return true
end

function modifier_blight_stone_custom_passive:IsPurgable(  )
	return false
end

function modifier_blight_stone_custom_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_blight_stone_custom_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_blight_stone_custom_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target

	if target ~= caster and params.attacker == caster and not target:IsMagicImmune() and self:IsActiveOrb() then
		target:AddNewModifier(caster,ability,"modifier_blight_stone_custom_disarmor",{duration = ability:GetSpecialValueFor("duration")})
	end
end

if modifier_blight_stone_custom_disarmor == nil then modifier_blight_stone_custom_disarmor = class({}) end

function modifier_blight_stone_custom_disarmor:GetTexture(  )
	return "item_blight_stone_custom"
end

function modifier_blight_stone_custom_disarmor:IsDebuff(  )
	return true
end

function modifier_blight_stone_custom_disarmor:OnCreated(  )
 	self.disarmor = self:GetAbility():GetSpecialValueFor("disarmor")
end

function modifier_blight_stone_custom_disarmor:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_blight_stone_custom_disarmor:GetModifierPhysicalArmorBonus(  )
	return -self.disarmor
end