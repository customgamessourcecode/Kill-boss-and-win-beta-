item_rebels_sword2 = item_rebels_sword2 or class({}) 

LinkLuaModifier( "modifier_rebels_sword2_passive", 		'items/rebels_sword/modifiers/modifier_rebels_sword2_passive',   	LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rebels_sword2_disarmor", 		'items/rebels_sword/modifiers/modifier_rebels_sword2_disarmor', 		LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rebels_sword2_disarmor_cd", 	'items/rebels_sword/modifiers/modifier_rebels_sword2_disarmor_cd', 	LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_rebels_sword2:GetIntrinsicModifierName()
	return "modifier_rebels_sword2_passive"
end