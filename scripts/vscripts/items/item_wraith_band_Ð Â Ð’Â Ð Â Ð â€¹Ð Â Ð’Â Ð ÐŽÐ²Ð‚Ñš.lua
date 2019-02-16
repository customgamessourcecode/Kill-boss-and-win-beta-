if item_wraith_band_c == nil then
	item_wraith_band_c = class({})
end

LinkLuaModifier("modifer_wraith_band_c_passive","items/item_wraith_band_c.lua",LUA_MODIFIER_MOTION_NONE)

function item_wraith_band_c:GetIntrinsicModiferName(  )
	return "modifer_wraith_band_c_passive"
end

function item_wraith_band_c:OnSpellStart( event )
	local target = event.target

	target:ModifyAgility(self:GetSpecialValueFor("act"))
end

---------------

if modifer_wraith_band_c_passive == nil then
	modifer_wraith_band_c_passive = class({})
end

function modifer_wraith_band_c_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
	return hFuncs
end

function modifer_wraith_band_c_passive:IsHidden(  )
	return true
end

function modifer_wraith_band_c_passive:IsPurgable(  )
	return false
end

function modifer_wraith_band_c_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("str")
end

function modifer_wraith_band_c_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("aid")
end

function modifer_wraith_band_c_passive:GetModifierBonusStats_Strength(  )
	return self:GetAbility():GetSpecialValueFor("aid")
end

function modifer_wraith_band_c_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("aid")
end