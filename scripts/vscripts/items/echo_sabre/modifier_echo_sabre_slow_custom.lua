modifier_echo_sabre_slow_custom = class({})
--------------------------------------------------------------------------------
function modifier_echo_sabre_slow_custom:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_echo_sabre_slow_custom:IsDebuff()
	return true
end

--------------------------------------------------------------------------------
function modifier_echo_sabre_slow_custom:GetTexture()
	return "../items/custom/echo_sabre_2"
end

--------------------------------------------------------------------------------
function modifier_echo_sabre_slow_custom:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_echo_sabre_slow_custom:OnCreated( kv )
	self.movement_slow = self:GetAbility():GetSpecialValueFor( "movement_slow" )
	self.attack_speed_slow = self:GetAbility():GetSpecialValueFor( "attack_speed_slow" )
end

--------------------------------------------------------------------------------

function modifier_echo_sabre_slow_custom:OnRefresh( kv )
	self.movement_slow = self:GetAbility():GetSpecialValueFor( "movement_slow" )
	self.attack_speed_slow = self:GetAbility():GetSpecialValueFor( "attack_speed_slow" )
end

--------------------------------------------------------------------------------

function modifier_echo_sabre_slow_custom:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_echo_sabre_slow_custom:GetModifierMoveSpeedBonus_Percentage( params )
	return self.movement_slow
end

--------------------------------------------------------------------------------

function modifier_echo_sabre_slow_custom:GetModifierAttackSpeedBonus_Constant( params )
	return self.attack_speed_slow
end

--------------------------------------------------------------------------------