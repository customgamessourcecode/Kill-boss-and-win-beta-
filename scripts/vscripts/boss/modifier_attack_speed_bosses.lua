modifier_attack_speed_bosses = class({
	IsHidden =      function() return true end,
	IsPurgable =    function() return false end,
	IsBuff =        function() return true end,
})

function modifier_attack_speed_bosses:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_attack_speed_bosses:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end