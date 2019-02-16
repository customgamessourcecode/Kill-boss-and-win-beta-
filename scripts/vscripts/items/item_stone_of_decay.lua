if item_stone_of_decay == nil then item_stone_of_decay = class({}) end

LinkLuaModifier("modifier_stone_of_decay_passive","items/item_stone_of_decay.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("decay_modifier_corrupt","items/item_stone_of_decay.lua",LUA_MODIFIER_MOTION_NONE)

function item_stone_of_decay:GetIntrinsicModifierName(  )
	return "modifier_stone_of_decay_passive"
end

if modifier_stone_of_decay_passive == nil then modifier_stone_of_decay_passive = class({}) end

function modifier_stone_of_decay_passive:IsHidden(  )
	return true
end

function modifier_stone_of_decay_passive:IsPurgable(  )
	return false
end

function modifier_stone_of_decay_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_stone_of_decay_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target

	if target ~= caster and params.attacker == caster and not target:IsMagicImmune() and self:IsActiveOrb() then
		target:AddNewModifier(caster,ability,"decay_modifier_corrupt",{duration = ability:GetSpecialValueFor("corrupt_duration")})
	end
end

function modifier_stone_of_decay_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

if decay_modifier_corrupt == nil then decay_modifier_corrupt = class({}) end

function decay_modifier_corrupt:GetTexture(  )
	return "item_stone_of_decay"
end

function decay_modifier_corrupt:IsDebuff(  )
	return true
end

function decay_modifier_corrupt:OnCreated(  )
 self.disarmor = -self:GetAbility():GetSpecialValueFor("corrupt_armor")
end

function decay_modifier_corrupt:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function decay_modifier_corrupt:GetModifierPhysicalArmorBonus(  )
	return self.disarmor
end