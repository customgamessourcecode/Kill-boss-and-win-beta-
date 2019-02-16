if item_blood_blade == nil then item_blood_blade = class({}) end

LinkLuaModifier("modifier_blood_blade_passive","items/item_blood_blade.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blood_blade_cripple","items/item_blood_blade.lua",LUA_MODIFIER_MOTION_NONE)

function item_blood_blade:GetIntrinsicModifierName(  )
	return "modifier_blood_blade_passive"
end

if modifier_blood_blade_passive == nil then modifier_blood_blade_passive = class({}) end

function modifier_blood_blade_passive:IsHidden(  )
	return true
end

function modifier_blood_blade_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_blood_blade_passive:IsPurgable(  )
	return false
end

function modifier_blood_blade_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_blood_blade_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.str = ability:GetSpecialValueFor("str")
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.chance = ability:GetSpecialValueFor("chance")
	self.health = ability:GetSpecialValueFor("health")
	self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_blood_blade_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_blood_blade_passive:GetModifierHealthBonus(  )
	return self.health
end

function modifier_blood_blade_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_blood_blade_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster and caster:IsRealHero() then 
		if RollPercentage(self.chance) then
			local target = params.target
			target:AddNewModifier(caster,self:GetAbility(),"modifier_blood_blade_cripple",{duration = self.duration})
			EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast",target)
		end
	end
end

if modifier_blood_blade_cripple == nil then modifier_blood_blade_cripple = class({}) end

function modifier_blood_blade_cripple:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_blood_blade_cripple:IsDebuff(  )
	return true
end

function modifier_blood_blade_cripple:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

require('libraries/timers')
require('libraries/IsBoss')

function modifier_blood_blade_cripple:OnCreated(  )
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local prc = ability:GetSpecialValueFor("damage")
	local caster = self:GetCaster()
	local health = parent:GetHealth()
	local delay = 0.2
	if IsBoss(parent) then prc = prc / 8 end
	self.slow = ability:GetSpecialValueFor("slow")
	self.timer = Timers:CreateTimer(delay, function()
		local id0 = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf",PATTACH_ABSORIGIN_FOLLOW, parent)
		health = parent:GetHealth()
		local damage = health * prc * 0.01 * delay
		ApplyDamage({victim = parent, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = caster, ability = ability})
	return delay
	end)
end

function modifier_blood_blade_cripple:OnDestroy(  )
	Timers:RemoveTimer(self.timer)
end

function modifier_blood_blade_cripple:GetModifierMoveSpeedBonus_Percentage(  )
	return -self:GetAbility():GetSpecialValueFor("slow")
end