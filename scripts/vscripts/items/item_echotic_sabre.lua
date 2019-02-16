if item_echotic_sabre == nil then
	item_echotic_sabre = class({})
end

LinkLuaModifier("modifier_echotic_sabre_passive","items/item_echotic_sabre.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_echotic_sabre_slow","items/item_echotic_sabre.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_echotic_sabre_atk","items/item_echotic_sabre.lua",LUA_MODIFIER_MOTION_NONE)

function item_echotic_sabre:GetIntrinsicModifierName(  )
	return "modifier_echotic_sabre_passive"
end

------------------------

if modifier_echotic_sabre_passive == nil then
	modifier_echotic_sabre_passive = class({})
end

function modifier_echotic_sabre_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_echotic_sabre_passive:IsHidden(  )
	return true
end

function modifier_echotic_sabre_passive:IsPurgable(  )
	return false
end

function modifier_echotic_sabre_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return hFuncs
end

function modifier_echotic_sabre_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_echotic_sabre_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor("atk")
end

function modifier_echotic_sabre_passive:GetModifierDamageOutgoing_Percentage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_echotic_sabre_passive:GetModifierBonusStats_Strength(  )
	return self:GetAbility():GetSpecialValueFor("is")
end

function modifier_echotic_sabre_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("is")
end

function modifier_echotic_sabre_passive:OnCreated(  )
	self.mod = self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_echotic_sabre_atk",{})
end

function modifier_echotic_sabre_passive:OnDestroy(  )
	self.mod:Destroy()
end

---------------------

if modifier_echotic_sabre_atk == nil then
	modifier_echotic_sabre_atk = class({})
end

function modifier_echotic_sabre_atk:IsHidden(  )
	return true
end

function modifier_echotic_sabre_atk:IsPurgable(  )
	return false
end

function modifier_echotic_sabre_atk:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_ATTACK_LANDED }
	return hFuncs
end

function modifier_echotic_sabre_atk:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target
	local projectile = "particles/echotic_sabre_perform.vpcf"

	if params.attacker == caster then
		local chance = ability:GetSpecialValueFor("chance")

		if ability:IsCooldownReady() and caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then

			if not caster.performFlag then
				caster.performFlag = true
				caster:PerformAttack(target, true, true, true, false, true,false,false)
				target:AddNewModifier(caster,ability,"modifier_echotic_sabre_slow",{duration = ability:GetSpecialValueFor("duration")})
				ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			end
			caster.performFlag = nil
			
			caster.Cooldown_use = true
		end

		if RollPercentage(chance) then
			if target:IsAlive() and not caster.performFlag and not caster.Cooldown_use and (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() < caster:GetAttackRange() + caster:GetAttackRange() * 0.5 then
				caster.performFlag = true
				caster:PerformAttack(target, true, true, true, false, true,false,false)
			end
			caster.performFlag = nil
		end
		caster.Cooldown_use = nil
	end
end

---------------------------

if modifier_echotic_sabre_slow == nil then
	modifier_echotic_sabre_slow = class({})
end

function modifier_echotic_sabre_slow:IsHidden(  )
	return false
end

function modifier_echotic_sabre_slow:GetTexture(  )
	return "item_echotic_sabre"
end

function modifier_echotic_sabre_slow:IsDebuff(  )
	return true
end

function modifier_echotic_sabre_slow:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
	return hFuncs
end

function modifier_echotic_sabre_slow:GetModifierAttackSpeedBonus_Constant(  )
	return -self:GetAbility():GetSpecialValueFor("atk_slow")
end

function modifier_echotic_sabre_slow:GetModifierMoveSpeedBonus_Percentage(  )
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_echotic_sabre_slow:GetEffectName()
	return "particles/holy_shiet_particle.vpcf"
end

function modifier_echotic_sabre_slow:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end