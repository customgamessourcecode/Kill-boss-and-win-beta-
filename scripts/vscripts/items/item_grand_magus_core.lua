if not item_grand_magus_core then item_grand_magus_core = class({}) end

LinkLuaModifier("modifier_grand_magus_core_passive","items/item_grand_magus_core.lua",LUA_MODIFIER_MOTION_NONE)

function item_grand_magus_core:GetIntrinsicModifierName(  )
	return "modifier_grand_magus_core_passive"
end

function item_grand_magus_core:OnSpellStart(  )
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.Refresher.Activate")
	local id0 = ParticleManager:CreateParticle("particles/grand_magus_core.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
	for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability then
            ability:EndCooldown()
        end
    end
end

if not modifier_grand_magus_core_passive then modifier_grand_magus_core_passive = class({}) end

function modifier_grand_magus_core_passive:IsHidden(  )
	return true
end

function modifier_grand_magus_core_passive:IsPurgable(  )
	return false
end

function modifier_grand_magus_core_passive:DeclareFunctions( )
	return {MODIFIER_PROPERTY_IS_SCEPTER,MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_grand_magus_core_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.agi = ability:GetSpecialValueFor("agi")
	self.str = ability:GetSpecialValueFor("str")
	self.int = ability:GetSpecialValueFor("int")
	self.hp = ability:GetSpecialValueFor("hp")
	self.mana = ability:GetSpecialValueFor("mana")
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.hp_regen = ability:GetSpecialValueFor("hp_regen")
	self.mana_regen = ability:GetSpecialValueFor("mana_regen")
	self.reduce = ability:GetSpecialValueFor("reduce_cooldown")
end

function modifier_grand_magus_core_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_grand_magus_core_passive:GetModifierBonusStats_Agility(  )
	return self.agi
end

function modifier_grand_magus_core_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_grand_magus_core_passive:GetModifierHealthBonus(  )
	return self.hp
end

function modifier_grand_magus_core_passive:GetModifierManaBonus(  )
	return self.mana
end

function modifier_grand_magus_core_passive:GetModifierPercentageCooldown(  )
	return self.reduce
end

function modifier_grand_magus_core_passive:GetModifierPercentageCooldown(  )
	return self.reduce
end

function modifier_grand_magus_core_passive:GetModifierPercentageManaRegen(  )
	return self.mana_regen
end

function modifier_grand_magus_core_passive:GetModifierConstantHealthRegen(  )
	return self.hp_regen
end

function modifier_grand_magus_core_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_grand_magus_core_passive:GetModifierScepter(  )
	return true
end