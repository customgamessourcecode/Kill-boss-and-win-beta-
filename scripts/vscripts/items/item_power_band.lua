if item_power_band == nil then item_power_band = class({}) end

LinkLuaModifier("modifier_power_band_passive","items/item_power_band.lua",LUA_MODIFIER_MOTION_NONE)

function item_power_band:OnSpellStart(  )
	local caster = self:GetCaster()
	if not caster.flag_power_band then
		local hendl = ""
		local all_c = self:GetSpecialValueFor("all_act")
		EmitSoundOn("ui.crafting_gem_create",caster)
		local ID0 = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave_halo.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(ID0, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

		for i=0,5 do
			hendl = caster:GetItemInSlot(i)
			if hendl and hendl == self then
				caster:RemoveItem(hendl)
				caster.flag_power_band = true
				caster:ModifyAgility(all_c)
				caster:ModifyIntellect(all_c)
				caster:ModifyStrength(all_c)
				break
			end
		end
	end
end

function item_power_band:CastFilterResult(  )
	local caster = self:GetCaster()
	if caster.flag_power_band then return UF_FAIL_CUSTOM end

	return UF_SUCCESS
end

function item_power_band:GetCustomCastError()
	local caster = self:GetCaster()
	if caster.flag_power_band then return "#dota_hud_error_this_target_is_affected" end
	
	return ""
end

function item_power_band:IsRefreshable()
	return false
end

function item_power_band:GetIntrinsicModifierName(  )
	return "modifier_power_band_passive"
end

if modifier_power_band_passive == nil then modifier_power_band_passive = class({}) end

function modifier_power_band_passive:IsHidden(  )
	return true
end

function modifier_power_band_passive:IsPurgable(  )
	return false
end

function modifier_power_band_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_power_band_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.all = ability:GetSpecialValueFor("all")
	self.not_all = self.all * 0.75
end

function modifier_power_band_passive:GetModifierBonusStats_Strength(  )
	local caster = self:GetCaster()
	if self:GetAbility():IsCooldownReady() then
		if caster.flag_power_band then return self.not_all end
		return self.all
	end
	return 0
end

function modifier_power_band_passive:GetModifierBonusStats_Agility(  )
	local caster = self:GetCaster()
	if self:GetAbility():IsCooldownReady() then
		if caster.flag_power_band then return self.not_all end
		return self.all
	end
	return 0
end

function modifier_power_band_passive:GetModifierBonusStats_Intellect(  )
	local caster = self:GetCaster()
	if self:GetAbility():IsCooldownReady() then
		if caster.flag_power_band then return self.not_all end
		return self.all
	end
	return 0
end