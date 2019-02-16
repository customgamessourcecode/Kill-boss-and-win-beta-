local factorySYK = require("items/factory_sange_yasha_kaya")

item_battlefury_baseclass = {}
LinkLuaModifier("modifier_item_battlefury_arena", "items/item_battlefury.lua", LUA_MODIFIER_MOTION_NONE)

function item_battlefury_baseclass:GetIntrinsicModifierName()
	return "modifier_item_battlefury_arena"
end

function item_battlefury_baseclass:CastFilterResultTarget(hTarget)
	return (hTarget:GetClassname() == "ent_dota_tree" or hTarget:IsCustomWard()) and UF_SUCCESS or UF_FAIL_CUSTOM
end

function item_battlefury_baseclass:GetCustomCastErrorTarget(hTarget)
	return (hTarget:GetClassname() == "ent_dota_tree" or hTarget:IsCustomWard()) and "" or "dota_hud_error_cant_cast_on_non_tree_ward"
end

if IsServer() then
	function item_battlefury_baseclass:OnSpellStart()
		self:GetCursorTarget():CutTreeOrWard(self:GetCaster(), self)
	end
end

item_quelling_fury = class(item_battlefury_baseclass)
item_quelling_fury.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"
item_battlefury_arena = class(item_battlefury_baseclass)
item_battlefury_arena.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"
item_elemental_fury = class(item_battlefury_baseclass)
item_elemental_fury.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"
function item_elemental_fury:GetIntrinsicModifierName()
	return "modifier_item_elemental_fury"
end


modifier_item_battlefury_arena = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_battlefury_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_battlefury_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_battlefury_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_battlefury_arena:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

if IsServer() then
	function modifier_item_battlefury_arena:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker == self:GetParent() --[[and not attacker:IsMuted()]] then
			local ability = self:GetAbility()
			local target = keys.target
		end
	end
end


LinkLuaModifier("modifier_item_elemental_fury", "items/item_battlefury.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_elemental_fury_maim", "items/item_battlefury.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_elemental_fury, modifier_item_elemental_fury_maim = factorySYK(
	{ sange = "modifier_item_elemental_fury_maim", yasha = true, kaya = true },
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
)
modifier_item_elemental_fury.GetModifierConstantHealthRegen = modifier_item_battlefury_arena.GetModifierConstantHealthRegen
modifier_item_elemental_fury.GetModifierConstantManaRegen = modifier_item_battlefury_arena.GetModifierConstantManaRegen
local baseOnAttackLanded = modifier_item_elemental_fury.OnAttackLanded
modifier_item_elemental_fury.OnAttackLanded = function(self, keys)
	baseOnAttackLanded(self, keys)
	modifier_item_battlefury_arena.OnAttackLanded(self, keys)
end
