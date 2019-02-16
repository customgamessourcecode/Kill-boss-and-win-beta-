if item_durandal == nil then item_durandal = class({}) end

LinkLuaModifier("modifier_durandal_passive","items/item_durandal.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_durandal_aura","items/item_durandal.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_durandal_spell","items/item_durandal.lua",LUA_MODIFIER_MOTION_NONE)

function item_durandal:OnSpellStart(  )
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local id0 = ParticleManager:CreateParticle("particles/durandal_spell.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
	--ParticleManager:SetParticleControlEnt(id0, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(id0, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(id0, 2, Vector(800))
	target:EmitSound("DOTA_Item.Dagon.Activate")
	target:EmitSound("DOTA_Item.Dagon5.Target")

	if target:TriggerSpellAbsorb(self) then return end
	target:TriggerSpellReflect(self) 
	
	target:AddNewModifier(caster,self,"modifier_durandal_spell",{duration = self:GetSpecialValueFor("duration")})
	ApplyDamage({victim = target, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
end

function item_durandal:GetIntrinsicModifierName(  )
	return "modifier_durandal_passive"
end

if modifier_durandal_passive == nil then modifier_durandal_passive = class({}) end

function modifier_durandal_passive:IsHidden(  )
	return true
end

function modifier_durandal_passive:IsPurgable(  )
	return false
end

function modifier_durandal_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_durandal_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.all = ability:GetSpecialValueFor("all")
	self.int = ability:GetSpecialValueFor("int")
	self.range = ability:GetSpecialValueFor("aura_range")
end

function modifier_durandal_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_durandal_passive:GetModifierBonusStats_Intellect(  )
	return self.int + self.all
end

function modifier_durandal_passive:GetModifierBonusStats_Strength(  )
	return self.all
end

function modifier_durandal_passive:GetModifierBonusStats_Agility(  )
	return self.all
end

function modifier_durandal_passive:IsAura()
	return true
end

function modifier_durandal_passive:GetModifierAura()
    return "modifier_durandal_aura"
end
   
function modifier_durandal_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_durandal_passive:GetAuraRadius()
    return self.range
end

function modifier_durandal_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_durandal_passive:GetAuraDuration()
    return 0.5
end

if modifier_durandal_aura == nil then modifier_durandal_aura = class({}) end

function modifier_durandal_aura:IsDebuff(  )
	return true
end

function modifier_durandal_aura:IsHidden(  )
	local bool = false
	if self:GetCaster():IsInvisible() then bool = true else bool = false end
	return bool
end

function modifier_durandal_aura:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_durandal_aura:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE,MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

require('libraries/timers')

function modifier_durandal_aura:OnCreated(  )
	local ability = self:GetAbility()
	self.miss = ability:GetSpecialValueFor("aura_miss")
	self.res = ability:GetSpecialValueFor("aura_resist")
	local dmg = ability:GetSpecialValueFor("period_dmg")
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local chance = ability:GetSpecialValueFor("chance")
	dmg = dmg * 0.5
	self.timer = Timers:CreateTimer(0, function()
		ApplyDamage({victim = parent, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
		return 0.5
	end)
	self.id0 = ParticleManager:CreateParticle("particles/durandal_aura.vpcf",PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(self.id0, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
end

function modifier_durandal_aura:GetModifierMiss_Percentage(  )
	return self.miss
end

function modifier_durandal_aura:GetModifierMagicalResistanceBonus(  )
	return -self.res
end

function modifier_durandal_aura:OnDestroy(  )
	ParticleManager:DestroyParticle(self.id0, false)
	Timers:RemoveTimer(self.timer)
end

if modifier_durandal_spell == nil then modifier_durandal_spell = class({}) end

function modifier_durandal_spell:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_durandal_spell:IsDebuff(  )
	return true
end

function modifier_durandal_spell:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_durandal_spell:OnCreated(  )
	self.id0 = ParticleManager:CreateParticle("particles/durandal_miss.vpcf",PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self.miss = self:GetAbility():GetSpecialValueFor("miss")
end

function modifier_durandal_spell:GetModifierMiss_Percentage(  )
	return self.miss
end

function modifier_durandal_spell:OnDestroy(  )
	ParticleManager:DestroyParticle(self.id0,false)
end

function modifier_durandal_spell:CheckState(  )
	return {[MODIFIER_STATE_BLIND] = true}
end