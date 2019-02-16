if item_treatment_greaves == nil then
	item_treatment_greaves = class({})
end

LinkLuaModifier("modifier_treatment_greaves_passive","items/item_treatment_greaves.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_treatment_greaves_aura","items/item_treatment_greaves.lua",LUA_MODIFIER_MOTION_NONE)

function item_treatment_greaves:GetIntrinsicModifierName(  )
	return "modifier_treatment_greaves_passive"
end

function item_treatment_greaves:OnSpellStart(  )
	local abilty = self
	local caster = self:GetCaster()
	local int = caster:GetIntellect()

	local Units = FindUnitsInRadius(caster:GetTeamNumber(),
                              caster:GetAbsOrigin(),
                              nil,
                              abilty:GetSpecialValueFor("range"),
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	for _,target in pairs(Units) do
	    if target:GetTeamNumber() == caster:GetTeamNumber() and not target:IsMagicImmune() then
	    	if timer then Timers:RemoveTimer(timer) end

	    	local heal = abilty:GetSpecialValueFor("heal")
	    	heal = heal + heal * int / 12 * 0.01
	    	local restore = abilty:GetSpecialValueFor("restore")
	    	restore = restore + restore * int / 12 * 0.01
			target:HealCustom(heal,caster,true)
			target:GiveMana(restore)
			local id0 = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_pu_ti6_heal_hammers.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(id0, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
			EmitSoundOn("Hero_Warlock.ShadowWord",target)
			local timer = Timers:CreateTimer({endTime = 2, callback = function() StopSoundOn("Hero_Warlock.ShadowWord",target) end})
		elseif target:GetTeamNumber() == caster:GetTeamNumber() and target:IsMagicImmune() then

	    	local heal = abilty:GetSpecialValueFor("heal")
	    	heal = heal + heal * (int / 12 * 0.01) * abilty:GetSpecialValueFor("mih") * 0.01

	    	local restore = abilty:GetSpecialValueFor("restore")
	    	restore = restore + restore * (int / 12 * 0.01) * abilty:GetSpecialValueFor("mih") * 0.01
			target:HealCustom(heal,caster,true)
			target:GiveMana(restore)
			local id0 = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_pu_ti6_heal_hammers.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(id0, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
			EmitSoundOn("Hero_Warlock.ShadowWord",target)
			local timer = Timers:CreateTimer({endTime = 2, callback = function() StopSoundOn("Hero_Warlock.ShadowWord",target) end})
		end
	end

	caster:Purge(false, true, false, false, false)
end

---------------

if modifier_treatment_greaves_passive == nil then
	modifier_treatment_greaves_passive = class({})
end

function modifier_treatment_greaves_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_treatment_greaves_passive:IsHidden(  )
	return true
end

function modifier_treatment_greaves_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE }
	return hFuncs
end

function modifier_treatment_greaves_passive:GetModifierMoveSpeedBonus_Special_Boots(  )
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_treatment_greaves_passive:GetModifierManaBonus(  )
	return self:GetAbility():GetSpecialValueFor("mana")
end

function modifier_treatment_greaves_passive:GetModifierBonusStats_Strength(  )
	return self:GetAbility():GetSpecialValueFor("all")
end

function modifier_treatment_greaves_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("all")
end

function modifier_treatment_greaves_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("all")
end

function modifier_treatment_greaves_passive:GetModifierPhysicalArmorBonus(  )
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_treatment_greaves_passive:IsAura()
	return true
end

function modifier_treatment_greaves_passive:IsPurgable()
    return false
end

function modifier_treatment_greaves_passive:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("range")
end

function modifier_treatment_greaves_passive:GetModifierAura()
    return "modifier_treatment_greaves_aura"
end
   
function modifier_treatment_greaves_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_treatment_greaves_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_treatment_greaves_passive:GetAuraDuration()
    return 0.5
end

-----------------

if modifier_treatment_greaves_aura == nil then
	modifier_treatment_greaves_aura = class({})
end

function modifier_treatment_greaves_aura:IsPurgable(  )
	return false
end

function modifier_treatment_greaves_aura:GetTexture(  )
	return "item_treatment_greaves"
end

function modifier_treatment_greaves_aura:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
	return hFuncs
end

function modifier_treatment_greaves_aura:OnCreated(  )
	local abilty = self:GetAbility()
	self.rage_regen = abilty:GetSpecialValueFor("rage_reg")
	self.rage_armor = abilty:GetSpecialValueFor("rage_arm")
	self.regen = abilty:GetSpecialValueFor("aura_hp_r")
	self.armor = abilty:GetSpecialValueFor("aura_armor")
	self.rage = abilty:GetSpecialValueFor("rage_prc")
end

function modifier_treatment_greaves_aura:GetModifierConstantHealthRegen(  )
	if IsServer() then
		if self:GetParent():GetHealth() < self:GetParent():GetMaxHealth() * (self.rage * 0.01) then
			return self.rage_regen
		else
			return self.regen
		end
		return self.regen
	end
end

function modifier_treatment_greaves_aura:GetModifierPhysicalArmorBonus(  )
	if IsServer() then
		if self:GetParent():GetHealth() < self:GetParent():GetMaxHealth() * (self.rage * 0.01) then
			return self.rage_armor
		else
			return self.armor
		end
		return self.armor
	end
end