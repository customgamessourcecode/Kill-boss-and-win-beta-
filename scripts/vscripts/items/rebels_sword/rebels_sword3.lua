item_rebels_sword3 = item_rebels_sword3 or class({}) 

LinkLuaModifier( "modifier_rebels_sword3_passive", 		'items/rebels_sword/modifiers/modifier_rebels_sword3_passive',   	LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rebels_sword3_disarmor", 		'items/rebels_sword/modifiers/modifier_rebels_sword3_disarmor', 		LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rebels_sword3_disarmor_cd", 	'items/rebels_sword/modifiers/modifier_rebels_sword3_disarmor_cd', 	LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_rebels_sword3:GetIntrinsicModifierName()
	return "modifier_rebels_sword3_passive"
end