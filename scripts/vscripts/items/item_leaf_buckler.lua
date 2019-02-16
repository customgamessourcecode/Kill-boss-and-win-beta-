if item_leaf_buckler == nil then item_leaf_buckler = class({}) end

LinkLuaModifier("modifier_leaf_buckler_passive","items/item_leaf_buckler.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leaf_buckler_damage","items/item_leaf_buckler.lua",LUA_MODIFIER_MOTION_NONE)

function item_leaf_buckler:GetIntrinsicModifierName(  )
	return "modifier_leaf_buckler_passive"
end

if modifier_leaf_buckler_passive == nil then modifier_leaf_buckler_passive = class({}) end

function modifier_leaf_buckler_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_leaf_buckler_passive:IsHidden(  )
	return true
end

function modifier_leaf_buckler_passive:IsPurgable(  )
	return false
end

function modifier_leaf_buckler_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK_UNAVOIDABLE_PRE_ARMOR,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_leaf_buckler_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.target == caster then
		if ability:IsCooldownReady() then
			if caster:GetHealth() > params.damage then
				caster:AddNewModifier(caster,ability,"modifier_leaf_buckler_damage",{duration = 6})
			end
			
			ability:StartCooldown(ability:GetLevel())
		end
	end
end

function modifier_leaf_buckler_passive:GetModifierPhysical_ConstantBlockUnavoidablePreArmor(  )
	return self:GetAbility():GetSpecialValueFor("block")
end

function modifier_leaf_buckler_passive:GetModifierMoveSpeedBonus_Percentage(  )
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_leaf_buckler_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("agi")
end

if modifier_leaf_buckler_damage == nil then modifier_leaf_buckler_damage = class({}) end

function modifier_leaf_buckler_damage:GetTexture(  )
	return "item_leaf_buckler"
end

function modifier_leaf_buckler_damage:IsPurgable(  )
	return false
end

function modifier_leaf_buckler_damage:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_leaf_buckler_damage:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker == caster then
		caster:RemoveModifierByName("modifier_leaf_buckler_damage")
	end
end

function modifier_leaf_buckler_damage:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("block")
end