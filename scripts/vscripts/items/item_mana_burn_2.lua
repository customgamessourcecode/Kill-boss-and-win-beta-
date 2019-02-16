if item_mana_burn_2 == nil then item_mana_burn_2 = class({}) end

LinkLuaModifier("modifier_mana_burn_two_passive","items/item_mana_burn_2.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_burn_two_slow","items/item_mana_burn_2.lua",LUA_MODIFIER_MOTION_NONE)

function item_mana_burn_2:OnSpellStart(  )
	local target = self:GetCursorTarget()
	local charges = self:GetCurrentCharges()
	if charges > 0 then
		self:SetCurrentCharges(charges - 1)
		if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
			target:Purge(false,true,false,true,false)
		else
			if target:TriggerSpellAbsorb(self) then return end
			target:TriggerSpellReflect(self) 
			target:AddNewModifier(self:GetCaster(),self,"modifier_mana_burn_two_slow",{duration = self:GetSpecialValueFor("duration")})
			target:Purge(true,false,false,false,false)
			local D01 = ParticleManager:CreateParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
          	ParticleManager:SetParticleControlEnt(D01, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
		end
	end
end

function item_mana_burn_2:CastFilterResultTarget( hTarget )
	local charges = self:GetCurrentCharges()
	if charges == 0 then return UF_FAIL_CUSTOM end
	if hTarget:IsMagicImmune() then return UF_FAIL_MAGIC_IMMUNE_ENEMY end
	return UF_SUCCESS
end

function item_mana_burn_2:GetCustomCastErrorTarget(hTarget)
	if self:CastFilterResultTarget() == UF_FAIL_CUSTOM then return "#dota_hud_error_custom_not_enought_charges" end
	
	return ""
end

function item_mana_burn_2:GetIntrinsicModifierName(  )
	return "modifier_mana_burn_two_passive"
end

if modifier_mana_burn_two_passive == nil then modifier_mana_burn_two_passive = class({}) end

function modifier_mana_burn_two_passive:IsHidden(  )
	return true
end

function modifier_mana_burn_two_passive:IsPurgable(  )
	return false
end	

function modifier_mana_burn_two_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_mana_burn_two_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_mana_burn_two_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("agi")
end

function modifier_mana_burn_two_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("int")
end

function modifier_mana_burn_two_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_CUSTOM
end

function modifier_mana_burn_two_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local target = params.target
	local ability = self:GetAbility()
	if params.attacker ~= caster then return end
	if target == caster or target:GetTeamNumber() == caster:GetTeamNumber() then return end
	if not self:IsActiveOrb() then return end
	target:ManaBurn(ability:GetSpecialValueFor("burn"),"particles/mana_burn_burn.vpcf",true,0,ability:GetSpecialValueFor("burn_damage"),ability,caster)
end

if modifier_mana_burn_two_slow == nil then modifier_mana_burn_two_slow = class({}) end

function modifier_mana_burn_two_slow:IsDebuff(  )
	return true
end

function modifier_mana_burn_two_slow:GetTexture(  )
	return "item_mana_burn_2"
end

function modifier_mana_burn_two_slow:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

require('libraries/timers')

function modifier_mana_burn_two_slow:OnCreated(  )
	self.slow = -100
	self.timer = Timers:CreateTimer(0, function() self.slow = self.slow + 2.5 return 0.1 end)
end

function modifier_mana_burn_two_slow:OnDestroy(  )
	Timers:RemoveTimer(self.timer)
end

function modifier_mana_burn_two_slow:GetModifierMoveSpeedBonus_Percentage(  )	
	return self.slow
end