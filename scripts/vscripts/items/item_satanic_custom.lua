if item_satanic_custom == nil then item_satanic_custom = class({}) end

LinkLuaModifier("modifier_satanic_passive","items/item_satanic_custom.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_satanic_act","items/item_satanic_custom.lua",LUA_MODIFIER_MOTION_NONE)

function item_satanic_custom:GetIntrinsicModifierName(  )
	return "modifier_satanic_passive"
end

function item_satanic_custom:OnSpellStart(  )
	self:GetCaster():EmitSound("DOTA_Item.Satanic.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_satanic_act",{duration = self:GetSpecialValueFor("duration")})
end

if modifier_satanic_passive == nil then modifier_satanic_passive = class({}) end

function modifier_satanic_passive:IsHidden(  )
	return true
end

function modifier_satanic_passive:IsPurgable(  )
	return false
end

function modifier_satanic_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_satanic_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_satanic_passive:GetModifierBonusStats_Strength(  )
	return self:GetAbility():GetSpecialValueFor("str")
end

function modifier_satanic_passive:GetModifierPhysicalArmorBonus(  )
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_satanic_passive:GetModifierOrbPriority()
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_satanic_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker == caster and params.target ~= caster and not params.target:IsMagicImmune() and self:IsActiveOrb() then
		local lifesteal = 0
		if caster:HasModifier("modifier_satanic_act") then lifesteal = ability:GetSpecialValueFor("act_lifesteal") else lifesteal = ability:GetSpecialValueFor("lifesteal") end
		local heal = params.damage * lifesteal * 0.01
		caster:HealCustom(heal,caster,true)
	end
end

if modifier_satanic_act == nil then modifier_satanic_act = class({}) end

function modifier_satanic_act:GetTexture(  )
	return "item_satanic"
end

function modifier_satanic_act:IsPurgable(  )
	return false
end

function modifier_satanic_act:OnCreated(  )
	self.lifesteal = self:GetAbility():GetSpecialValueFor("act_lifesteal") - self:GetAbility():GetSpecialValueFor("lifesteal")
	self.id0 = ParticleManager:CreateParticle("particles/satanic_buff_custom.vpcf",PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.id0, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
end

function modifier_satanic_act:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_satanic_act:OnDestroy(  )
	ParticleManager:DestroyParticle(self.id0,false)
end

function modifier_satanic_act:OnTooltip(  )
	return self.lifesteal
end