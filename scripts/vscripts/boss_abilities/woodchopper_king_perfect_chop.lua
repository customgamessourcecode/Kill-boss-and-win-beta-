if woodchopper_king_perfect_chop == nil then woodchopper_king_perfect_chop = class({}) end

LinkLuaModifier("modifier_woodchopper_king_perfect_chop_passive","boss_abilities/woodchopper_king_perfect_chop.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_woodchopper_king_perfect_chop_chop","boss_abilities/woodchopper_king_perfect_chop.lua",LUA_MODIFIER_MOTION_NONE)

function woodchopper_king_perfect_chop:GetIntrinsicModifierName(  )
	return "modifier_woodchopper_king_perfect_chop_passive"
end

-----------

if modifier_woodchopper_king_perfect_chop_passive == nil then modifier_woodchopper_king_perfect_chop_passive = class({}) end

function modifier_woodchopper_king_perfect_chop_passive:IsHidden(  ) return true end

function modifier_woodchopper_king_perfect_chop_passive:IsPurgable(  ) return false end

function modifier_woodchopper_king_perfect_chop_passive:DeclareFunctions(  ) return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_woodchopper_king_perfect_chop_passive:OnAttackLanded( params )
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = params.target
	if params.attacker == caster and target:GetTeamNumber() ~= caster:GetTeamNumber() and ability:IsCooldownReady() then
		if RollPercentage(ability:GetSpecialValueFor("chance")) then
			target:AddNewModifier(caster,ability,"modifier_woodchopper_king_perfect_chop_chop",{duration = ability:GetSpecialValueFor("duration")})
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

--------------

if modifier_woodchopper_king_perfect_chop_chop == nil then modifier_woodchopper_king_perfect_chop_chop = class({}) end

function modifier_woodchopper_king_perfect_chop_chop:IsPurgable(  )	return false end

function modifier_woodchopper_king_perfect_chop_chop:GetTexture(  ) return "woodchopper_king_perfect_chop" end

function modifier_woodchopper_king_perfect_chop_chop:DeclareFunctions(  ) return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end

function modifier_woodchopper_king_perfect_chop_chop:CheckState()
	local sate = {[MODIFIER_STATE_STUNNED] = true}
	local states = { [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true }
	local target = self:GetParent()
	if target.Has_Chopped_by_king then return states else return sate end return sate
end

require('libraries/timers')

function modifier_woodchopper_king_perfect_chop_chop:OnCreated(  )
	local ability = self:GetAbility()
	local target = self:GetParent()
	self.id01 = ParticleManager:CreateParticle("particles/woodchopper_king_blood_meer.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
	ParticleManager:SetParticleControlEnt(self.id01, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	EmitSoundOn("sounds/weapons/hero/axe/culling_blade_fail.vsnd",target)
	target.Has_Chopped_by_king = false
	self.damager = Timers:CreateTimer(0,function()
		local damage = ability:GetSpecialValueFor("dps") / 100
		damage = damage * target:GetMaxHealth()
		damage = damage / 2
		ApplyDamage({victim = target,attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE})
	return ability:GetSpecialValueFor("rate") / 2 end)

	self.freezer = Timers:CreateTimer({endTime = 0.6, callback = function() target.Has_Chopped_by_king = true end})
end

function modifier_woodchopper_king_perfect_chop_chop:GetOverrideAnimation(  ) return ACT_DOTA_DIE end

function modifier_woodchopper_king_perfect_chop_chop:OnDestroy(  )
	ParticleManager:DestroyParticle(self.id01,false)
	Timers:RemoveTimer(self.damager)
	Timers:RemoveTimer(self.freezer)
	self:GetParent().Has_Chopped_by_king = false
end