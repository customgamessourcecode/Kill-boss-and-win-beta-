if item_blade_guard == nil then
	item_blade_guard = class({})
end

LinkLuaModifier("modifier_blade_guard_passive","items/item_blade_guard.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blade_guard_blade","items/item_blade_guard.lua",LUA_MODIFIER_MOTION_NONE)

function item_blade_guard:GetIntrinsicModifierName(  )
	return "modifier_blade_guard_passive"
end

function item_blade_guard:OnSpellStart(  )
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_blade_guard_blade",{duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
end

-------------------------

if modifier_blade_guard_passive == nil then
	modifier_blade_guard_passive = class({})
end

function modifier_blade_guard_passive:IsHidden(  )
	return true
end

function modifier_blade_guard_passive:IsPurgable(  )
	return false
end

function modifier_blade_guard_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK_UNAVOIDABLE_PRE_ARMOR,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return hFuncs
end

function modifier_blade_guard_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_blade_guard_passive:GetModifierPhysicalArmorBonus(  )
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_blade_guard_passive:GetModifierConstantHealthRegen(  )
	return self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_blade_guard_passive:GetModifierHealthBonus(  )
	return self:GetAbility():GetSpecialValueFor("hp")
end

function modifier_blade_guard_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("int")
end

function modifier_blade_guard_passive:GetModifierPhysical_ConstantBlockUnavoidablePreArmor(  )
	return self:GetAbility():GetSpecialValueFor("block")
end

function modifier_blade_guard_passive:OnDestroy(  )
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_blade_guard_blade") then caster:RemoveModifierByName("modifier_blade_guard_blade") else return end
end

--------------------------

if modifier_blade_guard_blade == nil then
	modifier_blade_guard_blade = class({})
end

function modifier_blade_guard_blade:IsPurgable(  )
	return false
end

function modifier_blade_guard_blade:GetTexture(  )
	return "item_blade_guard"
end

function modifier_blade_guard_blade:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_TAKEDAMAGE }
	return hFuncs
end

function modifier_blade_guard_blade:GetEffectName()
	return "particles/test_particle/creature_spiked_carapace.vpcf"
end

require('libraries/IsBoss')

function modifier_blade_guard_blade:OnTakeDamage( params )
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local damage = params.damage
	local attacker = params.attacker
	local target = params.unit
	if IsServer() then
		print("Damage Taked:")
		if not attacker:IsMagicImmune() and attacker ~= caster and attacker:GetTeamNumber() ~= caster:GetTeamNumber() and target == caster and not attacker:HasModifier("modifier_blade_mail_c_blade") and not attacker:HasModifier("modifier_blade_guard_blade") then
			local prc = ability:GetSpecialValueFor("prc")
			local dmg = damage * prc

			ApplyDamage({victim = attacker, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_PHYSICAL})

			print("Taked Damage:" ..damage)
			print("Damage Returned:" ..dmg)
		else return end
	end
end