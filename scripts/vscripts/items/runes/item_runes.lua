LinkLuaModifier("modifier_rune_double_damage_damage","items/runes/item_rune_double_damage.lua",LUA_MODIFIER_MOTION_NONE)
function rune_of_dd( kv )
	local caster = kv.caster
	caster:AddNewModifier(caster,kv.ability,"modifier_rune_double_damage_damage",{duration = kv.ability:GetSpecialValueFor("duration")})
end

if modifier_rune_double_damage_damage == nil then modifier_rune_double_damage_damage = class({}) end

function modifier_rune_double_damage_damage:IsPurgable(  )
	return true
end

function modifier_rune_double_damage_damage:GetTexture(  )
	return "double_damage_rune"
end

function modifier_rune_double_damage_damage:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_rune_double_damage_damage:GetModifierBaseDamageOutgoing_Percentage(  )
	return 100
end