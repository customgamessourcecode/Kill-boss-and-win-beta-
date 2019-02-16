if item_blade_mail_c == nil then
	item_blade_mail_c = class({})
end

LinkLuaModifier("modifier_blade_mail_c_passive","items/item_blade_mail_c.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blade_mail_c_blade","items/item_blade_mail_c.lua",LUA_MODIFIER_MOTION_NONE)

function item_blade_mail_c:GetIntrinsicModifierName(  )
	return "modifier_blade_mail_c_passive"
end

function item_blade_mail_c:OnSpellStart(  )
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_blade_mail_c_blade",{duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
end

-------------------------

if modifier_blade_mail_c_passive == nil then
	modifier_blade_mail_c_passive = class({})
end

function modifier_blade_mail_c_passive:IsHidden(  )
	return true
end

function modifier_blade_mail_c_passive:IsPurgable(  )
	return false
end

function modifier_blade_mail_c_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return hFuncs
end

function modifier_blade_mail_c_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_blade_mail_c_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("int")
end

function modifier_blade_mail_c_passive:OnDestroy(  )
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_blade_mail_c_blade") then caster:RemoveModifierByName("modifier_blade_mail_c_blade") else return end
end

--------------------------

if modifier_blade_mail_c_blade == nil then
	modifier_blade_mail_c_blade = class({})
end

function modifier_blade_mail_c_blade:IsPurgable(  )
	return false
end

function modifier_blade_mail_c_blade:GetTexture(  )
	return "item_blade_mail_c"
end

function modifier_blade_mail_c_blade:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_TAKEDAMAGE }
	return hFuncs
end

function modifier_blade_mail_c_blade:GetEffectName()
	return "particles/test_particle/creature_spiked_carapace.vpcf"
end

require('libraries/IsBoss')

function modifier_blade_mail_c_blade:OnTakeDamage( params )
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