if item_time_scale_shard == nil then item_time_scale_shard = class({}) end

LinkLuaModifier("modifier_time_scale_shard_passive","items/item_time_scale_shard.lua",LUA_MODIFIER_MOTION_NONE)

function item_time_scale_shard:GetIntrinsicModifierName(  )
	return "modifier_time_scale_shard_passive"
end

if modifier_time_scale_shard_passive == nil then modifier_time_scale_shard_passive = class({}) end

function modifier_time_scale_shard_passive:IsHidden(  )
	return true
end

function modifier_time_scale_shard_passive:IsPurgable(  )
	return false
end

function modifier_time_scale_shard_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT}
end

function modifier_time_scale_shard_passive:GetModifierCooldownReduction_Constant(  )
	return self:GetAbility():GetSpecialValueFor("time") * self:GetAbility():GetCurrentCharges()
end
