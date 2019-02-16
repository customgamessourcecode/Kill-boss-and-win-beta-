if item_doom_upgrade_scroll == nil then item_doom_upgrade_scroll = class({}) end

function item_doom_upgrade_scroll:OnSpellStart(  )
	local caster = self:GetCaster()
	if caster:HasItemInInventory("item_blink") then 
		EmitSoundOn("CustomHeroArena.AllahuAkbar",caster)
		return UF_SUCCESS;
	elseif caster:HasItemInInventory("item_mana_burn_2") then
		EmitSoundOn("CustomHeroArena.AllahuAkbar",caster)
		return UF_SUCCESS;
	end
end

function item_doom_upgrade_scroll:CastFilterResult()
	local caster = self:GetCaster()		
	if caster:HasItemInInventory("item_mana_burn_2") then
		return UF_SUCCESS
	elseif caster:HasItemInInventory("item_blink")then
		return UF_SUCCESS
	end

	return UF_FAIL_CUSTOM
end

function item_doom_upgrade_scroll:GetCustomCastError()
	local caster = self:GetCaster()
	if caster:HasItemInInventory("item_mana_burn_2") then
		return ""
	elseif caster:HasItemInInventory("item_blink")then
		return ""
	end
	return "#dota_hud_error_custom_not_have_required_item"
end

function item_doom_upgrade_scroll:OnChannelFinish( bInterrupted )
	local caster = self:GetCaster()

	if bInterrupted then return nil; end
	if RollPercentage(self:GetSpecialValueFor("chance")) then
		PrecacheResource("soundfile", "soundevents/CustomSounds.vsndevts", context )
		PrecacheResource("particle_folder", "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_flash_c.vpcf", context )
		local id0 = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_flash_c.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(id0, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
		EmitSoundOn("CustomHeroArena.Boom",caster)
		caster:RemoveItem(self)
		caster:ForceKill(false)
		
		return nil;
	end
	if caster:HasItemInInventory("item_blink") then
		caster:SwapItem("item_blink","item_blink_dagger_two",10)
		local id0 = ParticleManager:CreateParticle("particles/econ/items/shredder/timber_controlled_burn/timber_controlled_burn_timber_dmg_flame.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		caster:EmitSound("Hero_Axe.Culling_Blade_Success")
		caster:RemoveItem(self)
	elseif caster:HasItemInInventory("item_mana_burn_2") then
		caster:SwapItem("item_mana_burn_2","item_suzzwke",10)
		local id0 = ParticleManager:CreateParticle("particles/econ/items/shredder/timber_controlled_burn/timber_controlled_burn_timber_dmg_flame.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		caster:EmitSound("Hero_Axe.Culling_Blade_Success")
		caster:RemoveItem(self)
	end
end