if item_empowered_treads == nil then item_empowered_treads = class({}) end

LinkLuaModifier("modifier_empowered_greaves_passive","items/item_empowered_treads.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_empowered_greaves_aura","items/item_empowered_treads.lua",LUA_MODIFIER_MOTION_NONE)

function item_empowered_treads:GetIntrinsicModifierName(  )
	return "modifier_empowered_greaves_passive"
end

function item_empowered_treads:OnSpellStart(  )
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

if modifier_empowered_greaves_passive == nil then
	modifier_empowered_greaves_passive = class({})
end

function modifier_empowered_greaves_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_empowered_greaves_passive:IsHidden(  )
	return true
end

function modifier_empowered_greaves_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return hFuncs
end

function modifier_empowered_greaves_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.speed = ability:GetSpecialValueFor("speed")
	self.mana = ability:GetSpecialValueFor("mana")
	self.all = ability:GetSpecialValueFor("all")
	self.armor = ability:GetSpecialValueFor("armor")
	self.radius = ability:GetSpecialValueFor("range")
	self.int = ability:GetSpecialValueFor("int")
	self.atr_prc = ability:GetSpecialValueFor("atr_prc") * 0.01
	self.spd_prc = ability:GetSpecialValueFor("speed_prc")
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.atk = ability:GetSpecialValueFor("atk")
end

function modifier_empowered_greaves_passive:GetModifierMoveSpeedBonus_Special_Boots(  )
	return self.speed
end

function modifier_empowered_greaves_passive:GetModifierManaBonus(  )
	return self.mana
end

function modifier_empowered_greaves_passive:GetModifierBonusStats_Strength(  )
	return self.all + self:GetCaster():GetBaseStrength() * self.atr_prc
end

function modifier_empowered_greaves_passive:GetModifierBonusStats_Agility(  )
	return self.all + self:GetCaster():GetBaseAgility() * self.atr_prc
end

function modifier_empowered_greaves_passive:GetModifierBonusStats_Intellect(  )
	return self.all + self.int + self:GetCaster():GetBaseIntellect() * self.atr_prc
end

function modifier_empowered_greaves_passive:GetModifierMoveSpeedBonus_Percentage_Unique(  )
	return self.spd_prc
end

function modifier_empowered_greaves_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_empowered_greaves_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

function modifier_empowered_greaves_passive:GetModifierPhysicalArmorBonus(  )
	return self.armor
end

function modifier_empowered_greaves_passive:IsAura()
	return true
end

function modifier_empowered_greaves_passive:IsPurgable()
    return false
end

function modifier_empowered_greaves_passive:GetAuraRadius()
    return self.radius
end

function modifier_empowered_greaves_passive:GetModifierAura()
    return "modifier_empowered_greaves_aura"
end
   
function modifier_empowered_greaves_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_empowered_greaves_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_empowered_greaves_passive:GetAuraDuration()
    return 0.1
end

-----------------

if modifier_empowered_greaves_aura == nil then
	modifier_empowered_greaves_aura = class({})
end

function modifier_empowered_greaves_aura:IsPurgable(  )
	return false
end

function modifier_empowered_greaves_aura:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_empowered_greaves_aura:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
	return hFuncs
end

function modifier_empowered_greaves_aura:OnCreated(  )
	local abilty = self:GetAbility()
	self.rage_regen = abilty:GetSpecialValueFor("rage_reg")
	self.rage_armor = abilty:GetSpecialValueFor("rage_arm")
	self.regen = abilty:GetSpecialValueFor("aura_hp_r")
	self.armor = abilty:GetSpecialValueFor("aura_armor")
	self.rage = abilty:GetSpecialValueFor("rage_prc")
	self.int = abilty:GetSpecialValueFor("int_aura")
	self.mn_reg = abilty:GetSpecialValueFor("mn_reg_aura")
end

function modifier_empowered_greaves_aura:GetModifierConstantHealthRegen(  )
	if IsServer() then 
		if self:GetParent():GetHealthPercent() < self.rage then
			return self.rage_regen
		else
			return self.regen
		end
	end
	return self.regen
end

function modifier_empowered_greaves_aura:GetModifierPhysicalArmorBonus(  )
	if IsServer() then 
		if self:GetParent():GetHealthPercent() < self.rage then
			return self.rage_armor
		else
			return self.armor
		end
	end
	return self.armor
end

function modifier_empowered_greaves_aura:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_empowered_greaves_aura:GetModifierConstantManaRegen(  )
	return self.mn_reg
end