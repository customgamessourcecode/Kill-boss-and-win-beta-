item_rebels1 = item_rebels1 or class({}) 

LinkLuaModifier( "modifier_rebels1_passive", 		'items/rebels_sword/modifiers/modifier_rebels1_passive',   	LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rebels1_disarmor", 		'items/rebels_sword/modifiers/modifier_rebels1_disarmor', 		LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rebels1_disarmor_cd", 	'items/rebels_sword/modifiers/modifier_rebels1_disarmor_cd', 	LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_rebels1:GetIntrinsicModifierName()
	return "modifier_rebels1_passive"
end