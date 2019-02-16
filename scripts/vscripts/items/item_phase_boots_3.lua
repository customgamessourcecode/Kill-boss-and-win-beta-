if item_phase_boots_3 == nil then
	item_phase_boots_3 = class({})
end

LinkLuaModifier("modifier_phase_boots_3","items/item_phase_boots_3.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phase_boots_three_active","items/item_phase_boots_3.lua",LUA_MODIFIER_MOTION_NONE)

function item_phase_boots_3:GetIntrinsicModifierName(  )
	return "modifier_phase_boots_3"
end

function item_phase_boots_3:OnSpellStart(  )
	self:GetCaster():EmitSound("DOTA_Item.PhaseBoots.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_phase_boots_three_active",{duration = self:GetSpecialValueFor("duration")})
end

--------------------------------

if modifier_phase_boots_3 == nil then
	modifier_phase_boots_3 = class({})
end

function modifier_phase_boots_3:IsPurgable(  )
	return false
end

function modifier_phase_boots_3:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_phase_boots_3:OnCreated(  )
	self.cap = self:GetAbility():GetSpecialValueFor("cap")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.movespeed_pas = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_phase_boots_3:OnRefresh(  )
	self.cap = self:GetAbility():GetSpecialValueFor("cap")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.movespeed_pas = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_phase_boots_3:IsHidden(  )
	return true
end

function modifier_phase_boots_3:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return funcs
end

function modifier_phase_boots_3:GetModifierMoveSpeed_Max(  )
	return self.cap
end

function modifier_phase_boots_3:GetModifierPreAttack_BonusDamage(  )
	return self.damage
end

function modifier_phase_boots_3:GetModifierMoveSpeedBonus_Special_Boots(  )
	return self.movespeed_pas
end

-------------------------------

if modifier_phase_boots_three_active == nil then
	modifier_phase_boots_three_active = class({})
end

function modifier_phase_boots_three_active:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE }
	return funcs 
end

function modifier_phase_boots_three_active:OnCreated(  )
	local caster = self:GetParent()

	local movespeed_active = self:GetAbility():GetSpecialValueFor("movespeed_active")
	local movespeed_active_range = self:GetAbility():GetSpecialValueFor("movespeed_active_range")
	if IsServer() then
		caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
	end
	if IsServer() then
		if self:GetParent():GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			self.speed = movespeed_active
		elseif self:GetParent():GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
			self.speed = movespeed_active_range
		end
	end
end

function modifier_phase_boots_three_active:CheckState()
	local states = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
	return states
end

function modifier_phase_boots_three_active:OnDestroy(  )
	local caster = self:GetParent()
	if IsServer() then
		caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	end

	if IsClient() then ClientLoadGridNav() end
	GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 192, true)
	if IsServer() then FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true) end
end

function modifier_phase_boots_three_active:GetTexture(  )
	return "item_phase_boots_3"
end

function modifier_phase_boots_three_active:GetEffectName(  )
	return "particles/econ/events/ti6/phase_boots_ti6.vpcf"
end

function modifier_phase_boots_three_active:GetModifierMoveSpeedBonus_Percentage_Unique(  )
	return self.speed
end