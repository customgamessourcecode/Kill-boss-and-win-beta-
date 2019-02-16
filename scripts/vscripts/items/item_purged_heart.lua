if item_purged_heart == nil then item_purged_heart = class({}) end

LinkLuaModifier("modifier_purged_heart_passive","items/item_purged_heart.lua",LUA_MODIFIER_MOTION_NONE)

function item_purged_heart:GetIntrinsicModifierName(  )
	return "modifier_purged_heart_passive"
end

if modifier_purged_heart_passive == nil then modifier_purged_heart_passive = class({}) end

function modifier_purged_heart_passive:IsHidden(  )
	return true
end

function modifier_purged_heart_passive:IsPurgable(  )
	return false
end

function modifier_purged_heart_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_purged_heart_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_SPENT_MANA,MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_purged_heart_passive:GetModifierManaBonus(  )
	return self.mana
end

function modifier_purged_heart_passive:GetModifierHealthBonus(  )
	return self.hp
end

function modifier_purged_heart_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_purged_heart_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_purged_heart_passive:GetModifierConstantHealthRegen(  )
	return self.hp_regen
end

function modifier_purged_heart_passive:GetModifierConstantManaRegen(  )
	return self.mana_regen
end

function modifier_purged_heart_passive:OnCreated(  )
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local rate = ability:GetSpecialValueFor("regen_interval")
	local health_regen_prc = ability:GetSpecialValueFor("health_regen_prc")
	local mana_regen_prc = ability:GetSpecialValueFor("mana_regen_prc")
	self.heal_timer = Timers:CreateTimer(function() 
		if ability:IsCooldownReady() then
			local caster_health = caster:GetMaxHealth() * health_regen_prc * 0.01 * rate
			local caster_mana = caster:GetMaxMana() * mana_regen_prc * 0.01 * rate
			caster:Heal(caster_health, ability)
			caster:SetMana(caster:GetMana() + caster_mana)
		end
		return rate 
	end)

	self.mana = ability:GetSpecialValueFor("bonus_mana")
	self.hp = ability:GetSpecialValueFor("bonus_health")
	self.int = ability:GetSpecialValueFor("int_bonus")
	self.str = ability:GetSpecialValueFor("str_bonus")
	self.hp_regen = ability:GetSpecialValueFor("hp_regen")
	self.mana_regen = ability:GetSpecialValueFor("mp_regen")
end

function modifier_purged_heart_passive:OnDestroy(  )
	Timers:RemoveTimer(self.heal_timer)
end

function modifier_purged_heart_passive:OnTakeDamage( params )
	local caster = self:GetCaster()
	if params.unit == caster then 
		if params.damage > caster:GetMaxHealth() * 0.01 * 5 then 
			local ability = self:GetAbility()
			if ability:IsCooldownReady() then
				ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			end
		end
	end
end

function modifier_purged_heart_passive:OnSpentMana( params )
	local caster = self:GetCaster()
	if params.unit == caster then 
		if params.cost > caster:GetMaxMana() * 0.01 * 2.5 then
			local ability = self:GetAbility()
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end