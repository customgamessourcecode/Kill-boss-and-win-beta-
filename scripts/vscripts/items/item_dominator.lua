if item_dominator == nil then item_dominator = class({}) end
require('libraries/IsBoss')

LinkLuaModifier("modifier_dominator_passive","items/item_dominator.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dominator_health","items/item_dominator.lua",LUA_MODIFIER_MOTION_NONE)

function item_dominator:GetIntrinsicModifierName(  )
	return "modifier_dominator_passive"
end

function item_dominator:OnSpellStart(  )
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	local target = self.target
	local health = self:GetSpecialValueFor("health")
	local speed = self:GetSpecialValueFor("speed")

	if target:IsAncient() then return end 
	if target:IsMagicImmune() then return end
	if IsBoss(target) then return end
	if target.dominated then return end

		if not self.dominated_units then
			self.dominated_units = {}
		end

		for k,v in pairs(self.dominated_units) do
			if v and IsValidEntity(v) then 
				v.disable_drop = true
				v:ForceKill(false)
			end
		end

		self.dominated_units = {}

		local t_health = target:GetHealth()
		local t_max_health = target:GetMaxHealth()
		local t_speed = target:GetBaseMoveSpeed()
		target.disable_drop = true
		target:ForceKill(false)
		local unit = CreateUnitByName(target:GetUnitName(), target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
		unit:SetHealth(t_health)
		unit:AddNewModifier(caster, self, "modifier_dominator_health", {})
		unit:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(),true)
		unit:SetOwner(caster)

		if t_max_health < health then
			print("Set Health to "..health)
		end

		if t_speed < speed then
			print("Set Movespeed to "..speed)
		end

		table.insert(self.dominated_units, unit)
	unit.dominated = true
end

function item_dominator:CastFilterResultTarget( hTarget )
	if hTarget:IsHero() then return UF_FAIL_HERO end
	if IsBoss(hTarget) then return UF_FAIL_CUSTOM end
	if hTarget:IsAncient() then	return UF_FAIL_ANCIENT end
	if hTarget:IsMagicImmune() then return UF_FAIL_MAGIC_IMMUNE_ENEMY  end
	if hTarget.dominated then return UF_FAIL_DOMINATED end

	return UF_SUCCESS
end

function item_dominator:GetCustomCastErrorTarget(hTarget)
	if IsBoss(hTarget) then return "#dota_hud_error_custom_is_boss" end
	
	return ""
end

if modifier_dominator_passive == nil then modifier_dominator_passive = class({}) end

function modifier_dominator_passive:IsHidden(  )
	return true
end

function modifier_dominator_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dominator_passive:IsPurgable(  )
	return false
end

function modifier_dominator_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_dominator_passive:GetModifierOrbPriority()
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_dominator_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker == caster and params.target ~= caster and not params.target:IsMagicImmune() and self:IsActiveOrb() then
		local heal = params.damage * self.lifesteal
		caster:HealCustom(heal,caster,true)
	end
end

function modifier_dominator_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.armor = ability:GetSpecialValueFor("armor")
	self.hp_reg = ability:GetSpecialValueFor("hp_regen")
	self.lifesteal = ability:GetSpecialValueFor("lifesteal") * 0.01
end

function modifier_dominator_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_dominator_passive:GetModifierPhysicalArmorBonus(  )
	return self.armor
end

function modifier_dominator_passive:GetModifierConstantHealthRegen(  )
	return self.hp_reg
end

if modifier_dominator_health == nil then modifier_dominator_health = class({}) end

function modifier_dominator_health:IsHidden(  )
	return true
end

function modifier_dominator_health:IsPurgable(  )
	return false
end

function modifier_dominator_health:OnCreated(  )
	self.health = self:GetAbility():GetSpecialValueFor("hp")
	self.ms = self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_dominator_health:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_dominator_health:GetModifierExtraHealthBonus(  )
	return self.health
end

function modifier_dominator_health:GetModifierMoveSpeedBonus_Constant(  )
	local ms = self:GetParent():GetBaseMoveSpeed()
	if ms < self.ms then return self.ms - ms end
	return 0
end