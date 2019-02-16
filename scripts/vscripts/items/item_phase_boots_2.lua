if item_phase_boots_2 == nil then
	item_phase_boots_2 = class({})
end

LinkLuaModifier("modifier_phase_boots_2","items/item_phase_boots_2.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phase_boots_2_active","items/item_phase_boots_2.lua",LUA_MODIFIER_MOTION_NONE)

function item_phase_boots_2:GetIntrinsicModifierName(  )
	return "modifier_phase_boots_2"
end

function item_phase_boots_2:OnSpellStart(  )
	self:GetCaster():EmitSound("DOTA_Item.PhaseBoots.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_phase_boots_2_active",{duration = self:GetSpecialValueFor("duration")})
end

--------------------------------

if modifier_phase_boots_2 == nil then
	modifier_phase_boots_2 = class({})
end

function modifier_phase_boots_2:IsPurgable(  )
	return false
end

function modifier_phase_boots_2:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_phase_boots_2:OnCreated(  )
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.movespeed_pas = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_phase_boots_2:OnRefresh(  )
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.movespeed_pas = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_phase_boots_2:IsHidden(  )
	return true
end

function modifier_phase_boots_2:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return funcs
end

function modifier_phase_boots_2:GetModifierPreAttack_BonusDamage(  )
	return self.damage
end

function modifier_phase_boots_2:GetModifierMoveSpeedBonus_Special_Boots(  )
	return self.movespeed_pas
end

-------------------------------

if modifier_phase_boots_2_active == nil then
	modifier_phase_boots_2_active = class({})
end

function modifier_phase_boots_2_active:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
	return funcs 
end

function modifier_phase_boots_2_active:OnCreated(  )
	local movespeed_active = self:GetAbility():GetSpecialValueFor("movespeed_active")
	local movespeed_active_range = self:GetAbility():GetSpecialValueFor("movespeed_active_range")
	self.range = movespeed_active_range
	self.melee = movespeed_active
	CustomNetTables:SetTableValue( "phase_boots_active", "melee_phase_boots_2", {speed = movespeed_active} )
	CustomNetTables:SetTableValue( "phase_boots_active", "range_phase_boots_2", {speed = movespeed_active_range} )
end

function modifier_phase_boots_2_active:CheckState()
	local states = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
	return states
end

function modifier_phase_boots_2_active:GetTexture(  )
	return "item_phase_boots_2"
end

function modifier_phase_boots_2_active:GetEffectName(  )
	return "particles/items2_fx/phase_boots.vpcf"
end

function modifier_phase_boots_2_active:GetModifierMoveSpeedBonus_Percentage(  )
	local caster = self:GetParent()
	--[[if IsServer() then 
		if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			return self.melee
		elseif caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
			return self.range
		end
	else ]]
		local nettable
		if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			nettable = CustomNetTables:GetTableValue( "phase_boots_active", "melee_phase_boots_2" )
		elseif caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
			nettable = CustomNetTables:GetTableValue( "phase_boots_active", "range_phase_boots_2" )
		end
		return nettable.speed
	--end
	--return 0
end