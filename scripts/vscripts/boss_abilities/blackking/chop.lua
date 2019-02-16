if woodchopper_king_chop == nil then woodchopper_king_chop = class({}) end

LinkLuaModifier("modifier_woodchopper_king_chop_passive","boss_abilities/BlackKing/Chop.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_woodchopper_king_chop_maim","boss_abilities/BlackKing/Chop.lua",LUA_MODIFIER_MOTION_NONE)

function woodchopper_king_chop:GetIntrinsicModifierName(  )
	return "modifier_woodchopper_king_chop_passive"
end

if modifier_woodchopper_king_chop_passive == nil then modifier_woodchopper_king_chop_passive = class({}) end

function modifier_woodchopper_king_chop_passive:IsHidden(  )
	return true
end

function modifier_woodchopper_king_chop_passive:IsPurgable(  )
	return false
end

function modifier_woodchopper_king_chop_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_woodchopper_king_chop_passive:OnCreated(  )
	local id0 = ParticleManager:CreateParticle("woodchopper_king_black_mantle.vpcf",PATTACH_ROOTBONE_FOLLOW, self:GetParent())	
	local ability = self:GetAbility()
	self.chance = ability:GetSpecialValueFor("chance")
	self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_woodchopper_king_chop_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster and IsServer() then 
		local ability = self:GetAbility()
		local target = params.target
		if RollPercentage(self.chance) and ability:IsCooldownReady() and target:IsAlive() then
			target:EmitSound("Hero_Brewmaster.Brawler.Crit") 
			target:AddNewModifier(caster,ability,"modifier_woodchopper_king_chop_maim",{duration = self.duration})
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

if modifier_woodchopper_king_chop_maim == nil then modifier_woodchopper_king_chop_maim = class({}) end

function modifier_woodchopper_king_chop_maim:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_woodchopper_king_chop_maim:IsDebuff(  )
	return true
end

require('libraries/timers')

function modifier_woodchopper_king_chop_maim:OnCreated(  )
	local target = self:GetParent()
	local caster = self:GetCaster()
	self.id0 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_armor_of_the_favorite_crit.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
	self.id1 = ParticleManager:CreateParticle("particles/woodchopper_king_chop_blood.vpcf",PATTACH_ABSORIGIN_FOLLOW, target) 	
	local ability = self:GetAbility()
	local delay = 0.25
	local damage_type = DAMAGE_TYPE_PHYSICAL
	local damage_health = ability:GetSpecialValueFor("damage") * delay * 0.01
	self.timer = Timers:CreateTimer(0, function()
		if IsServer() then 
			local parent_health = target:GetHealth()
			local damage = parent_health * damage_health
			ApplyDamage({damage = damage, victim = target, attacker = caster, ability = ability, damage_type = damage_type})
		end
	return delay
	end)
end

function modifier_woodchopper_king_chop_maim:OnDestroy(  )
	Timers:RemoveTimer(self.timer)
	ParticleManager:DestroyParticle(self.id0, false)
	ParticleManager:DestroyParticle(self.id1, false)
end