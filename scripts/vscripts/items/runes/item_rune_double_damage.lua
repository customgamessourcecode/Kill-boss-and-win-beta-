function rune_of_dd( kv )
	local caster = kv.caster
	caster:AddNewModifier(caster,self,"modifier_rune_double_damage_damage",{duration = kv.ability:GetSpecialValueFor("duration")})
end

LinkLuaModifier("modifier_rune_double_damage_damage","items/runes/item_rune_double_damage.lua",LUA_MODIFIER_MOTION_NONE)

if modifier_rune_double_damage_damage == nil then modifier_rune_double_damage_damage = class({}) end

function modifier_rune_double_damage_damage:IsPurgable(  )
	return true
end

function modifier_rune_double_damage_damage:GetTexture(  )
	return "double_damage_rune"
end

function modifier_rune_double_damage_damage:OnCreated(  )
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
end

function modifier_rune_double_damage_damage:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_rune_double_damage_damage:GetModifierBaseDamageOutgoing_Percentage(  )
	return self.damage
end