item_echo_sabre = class({})
item_echo_sabre_2 = class({})
item_echo_sabre_3 = class({})


LinkLuaModifier( "modifier_item_echo_sabre_custom1", "items/echo_sabre/sabre1/modifier_item_echo_sabre_custom1", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_echo_sabre_custom2", "items/echo_sabre/sabre2/modifier_item_echo_sabre_custom2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_echo_sabre_custom3", "items/echo_sabre/sabre3/modifier_item_echo_sabre_custom3", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "echo_sabre_double_attack1", "items/echo_sabre/sabre1/echo_sabre_double_attack1", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "echo_sabre_double_attack2", "items/echo_sabre/sabre2/echo_sabre_double_attack2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "echo_sabre_double_attack3", "items/echo_sabre/sabre3/echo_sabre_double_attack3", LUA_MODIFIER_MOTION_NONE )




LinkLuaModifier( "modifier_echo_sabre_slow_custom", "items/echo_sabre/modifier_echo_sabre_slow_custom", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

local getIntrinsicModifierName1 = function() return "modifier_item_echo_sabre_custom1" end
local getIntrinsicModifierName2 = function() return "modifier_item_echo_sabre_custom2" end
local getIntrinsicModifierName3 = function() return "modifier_item_echo_sabre_custom3" end

item_echo_sabre.GetIntrinsicModifierName = getIntrinsicModifierName1
item_echo_sabre_2.GetIntrinsicModifierName = getIntrinsicModifierName2
item_echo_sabre_3.GetIntrinsicModifierName = getIntrinsicModifierName3

--------------------------------------------------------------------------------