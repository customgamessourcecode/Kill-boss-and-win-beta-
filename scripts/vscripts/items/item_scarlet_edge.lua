if item_scarlet_edge == nil then item_scarlet_edge = class({}) end

LinkLuaModifier("modifier_scarlet_edge_passive","items/item_scarlet_edge.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blood_blade_cripple","items/item_blood_blade.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scarlet_edge_invisibility","items/item_scarlet_edge.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scarlet_edge_decrease","items/item_scarlet_edge.lua",LUA_MODIFIER_MOTION_NONE)

function item_scarlet_edge:GetIntrinsicModifierName(  )
	return "modifier_scarlet_edge_passive"
end

require('libraries/timers')

function item_scarlet_edge:OnSpellStart(  )
	local caster = self:GetCaster()
	local end_time = self:GetSpecialValueFor("delay")
	local duration = self:GetSpecialValueFor("inv_duration")
	local id0 = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start_ground.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
	caster:EmitSound("DOTA_Item.InvisibilitySword.Activate")

	Timers:CreateTimer({
		endTime = end_time, 
		callback = function()
			caster:AddNewModifier(caster,self,"modifier_scarlet_edge_invisibility",{duration = duration})
		end
	})
end

if modifier_scarlet_edge_passive == nil then modifier_scarlet_edge_passive = class({}) end

function modifier_scarlet_edge_passive:IsHidden(  )
	return true
end

function modifier_scarlet_edge_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_scarlet_edge_passive:IsPurgable(  )
	return false
end

function modifier_scarlet_edge_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_scarlet_edge_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.str = ability:GetSpecialValueFor("str")
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.atk = ability:GetSpecialValueFor("atk")
	self.all = ability:GetSpecialValueFor("all")
	self.chance = ability:GetSpecialValueFor("chance")
	self.health = ability:GetSpecialValueFor("health")
	self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_scarlet_edge_passive:GetModifierBonusStats_Strength(  )
	return self.str + self.all
end

function modifier_scarlet_edge_passive:GetModifierBonusStats_Agility(  )
	return self.all
end

function modifier_scarlet_edge_passive:GetModifierBonusStats_Intellect(  )
	return self.all
end

function modifier_scarlet_edge_passive:GetModifierHealthBonus(  )
	return self.health
end

function modifier_scarlet_edge_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_scarlet_edge_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

function modifier_scarlet_edge_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster and caster:IsRealHero() then 
		if RollPercentage(self.chance) then
			local target = params.target
			target:AddNewModifier(caster,self:GetAbility(),"modifier_blood_blade_cripple",{duration = self.duration})
		end
	end
end

if modifier_scarlet_edge_invisibility == nil then modifier_scarlet_edge_invisibility = class({}) end

function modifier_scarlet_edge_invisibility:OnCreated(  )
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("add_damage")
	self.speed = ability:GetSpecialValueFor("slow")
	self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_scarlet_edge_invisibility:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_TOOLTIP,MODIFIER_EVENT_ON_ABILITY_EXECUTED,MODIFIER_PROPERTY_INVISIBILITY_LEVEL,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_scarlet_edge_invisibility:GetModifierMoveSpeedBonus_Percentage(  )
	return self.speed
end

function modifier_scarlet_edge_invisibility:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then 
		local ability = self:GetAbility()
		local target = params.target
		target:AddNewModifier(caster,ability,"modifier_blood_blade_cripple",{duration = self.duration})
		target:AddNewModifier(caster,ability,"modifier_scarlet_edge_decrease",{duration = self.duration})
		EmitSoundOn("DOTA_Item.SilverEgde.Target",target)
		local damage = ability:GetSpecialValueFor("add_damage")
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = ability})
		caster:RemoveModifierByName(self:GetName())
	end
end

function modifier_scarlet_edge_invisibility:CheckState()
	local states = { [MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return states 
end

function modifier_scarlet_edge_invisibility:GetModifierInvisibilityLevel()
	return 100
end

function modifier_scarlet_edge_invisibility:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_scarlet_edge_invisibility:OnAbilityExecuted( params )
	local caster = self:GetParent()
	--DeepPrintTable(params)
	if params.ability:GetCooldown(params.ability:GetLevel()) > 0 and params.ability:GetManaCost(params.ability:GetLevel()) > 0 and params.unit == caster then
		caster:RemoveModifierByName(self:GetName())
	end
end

function modifier_scarlet_edge_invisibility:OnTooltip(  )
	return self:GetAbility():GetSpecialValueFor("add_damage")
end

if modifier_scarlet_edge_decrease == nil then modifier_scarlet_edge_decrease = class({}) end

function modifier_scarlet_edge_decrease:CheckState(  )
	return {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
end

function modifier_scarlet_edge_decrease:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_scarlet_edge_decrease:IsPurgable(  )
	return false
end

function modifier_scarlet_edge_decrease:IsDebuff(  )
	return true
end

function modifier_scarlet_edge_decrease:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_scarlet_edge_decrease:OnCreated(  )
	self.id0 = ParticleManager:CreateParticle("particles/scarlet_edge.vpcf",PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self.decrease = self:GetAbility():GetSpecialValueFor("decrease")
end

function modifier_scarlet_edge_decrease:OnDestroy(  )
	ParticleManager:DestroyParticle(self.id0,false)
end

function modifier_scarlet_edge_decrease:GetModifierBaseDamageOutgoing_Percentage(  )
	return -self.decrease
end