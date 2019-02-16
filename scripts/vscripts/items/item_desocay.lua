if item_desocay == nil then
	item_desocay = class({})
end

LinkLuaModifier("modifier_desocay_passive","items/item_desocay.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_desocay_disarmor","items/item_desocay.lua",LUA_MODIFIER_MOTION_NONE)

function item_desocay:GetIntrinsicModifierName(  )
	return "modifier_desocay_passive"
end

------------

if modifier_desocay_passive == nil then
	modifier_desocay_passive = class({})
end

function modifier_desocay_passive:IsPurgable(  )
	return false
end

function modifier_desocay_passive:IsHidden(  )
	return true
end

function modifier_desocay_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_desocay_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED }
	return hFuncs
end

function modifier_desocay_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_desocay_passive:OnAttackLanded( params )
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target

		if caster == params.attacker and not target:IsMagicImmune() and not caster:IsIllusion() then
			local ability = self:GetAbility()
			local max_cap = ability:GetSpecialValueFor("max_cap")

			target:EmitSound("DOTA_Item.Desolator")
			local desolate_particle = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_desolation/sf_base_attack_desolation_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
			ParticleManager:SetParticleControlEnt(desolate_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

			if target:HasModifier("modifier_desocay_disarmor") then
				self.stacks = target:GetModifierStackCount("modifier_desocay_disarmor",caster)
				if self.stacks < max_cap then
					target:SetModifierStackCount("modifier_desocay_disarmor", caster, self.stacks + 1)
				end

				if self.stacks >= max_cap then target:SetModifierStackCount("modifier_desocay_disarmor", caster, max_cap) end
			end

			target:AddNewModifier(caster,ability,"modifier_desocay_disarmor",{duration = ability:GetSpecialValueFor("duration")})
		end
	end
end

------------

if modifier_desocay_disarmor == nil then
	modifier_desocay_disarmor = class({})
end

function modifier_desocay_disarmor:GetTexture(  )
	return "item_desocay"
end

function modifier_desocay_disarmor:IsDebuff(  )
	return true
end

function modifier_desocay_disarmor:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_TOOLTIP }
	return hFuncs
end

function modifier_desocay_disarmor:OnCreated(  )
	local ability = self:GetAbility()
	self.aps = ability:GetSpecialValueFor("aps")
	self.armor = ability:GetSpecialValueFor("base_armor")
end

function modifier_desocay_disarmor:GetModifierPhysicalArmorBonus(  )
	return -self.aps * self:GetStackCount() - self.armor
end

function modifier_desocay_disarmor:GetEffectName(  )
	return "particles/items2_fx/heavens_halberd_debuff.vpcf"
end