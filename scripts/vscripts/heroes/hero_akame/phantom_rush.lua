LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	if target ~= null and ability:IsCooldownReady() then
		if caster:GetTeam() ~= target:GetTeam() then
			local target_origin = target:GetAbsOrigin()
			local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
			ability.target = target
			if distance >= min_distance and distance <= max_distance then
				caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
				ability:StartCooldown(cooldown)
			elseif distance >= max_distance then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_check_distance", {})
			end
		end
	end
end

function DistanceCheck(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	if caster:GetAggroTarget() == ability.target then
		local target_origin = ability.target:GetAbsOrigin()
		local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
		if distance >= min_distance and distance <= max_distance then
			caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
			ability:StartCooldown(cooldown)
			caster:RemoveModifierByName("modifier_check_distance")
		end
	else
		caster:RemoveModifierByName("modifier_check_distance")
	end
end

function RemoveBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if target == null or target ~= ability.target then
		caster:RemoveModifierByName("modifier_speed_buff")
	end
end