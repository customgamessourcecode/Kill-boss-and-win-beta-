--[[ Thanks Pizzalol for jump prioritets! ]]

local talent_value = 60

function ShadowWave( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local ability 			= keys.ability
	local max_targets		= ability:GetSpecialValueFor("max_targets")
	local bounce_radius 	= ability:GetSpecialValueFor("bounce_radius")
	local damage_radius 	= ability:GetSpecialValueFor("damage_radius")
	local max_targets 		= ability:GetSpecialValueFor("max_targets")
	local damage_pct		= ability:GetSpecialValueFor("damage_pct") / 100
	local damage 			= ability:GetSpecialValueFor("damage") + caster:GetIntellect() * damage_pct
	local heal_pct 			= ability:GetSpecialValueFor("heal_pct") / 100
	local heal 				= damage + caster:GetIntellect() * heal_pct

	local heal_table 		= {}
	local current_targets 	= 0;
	local this_unit			= target;
	local next_unit			;

	table.insert(heal_table, caster)
	table.insert(heal_table, target)

	if caster:HasTalent("special_bonus_unique_dazzle_2") then
		heal = heal + caster:GetTalentSpecialValueFor("special_bonus_unique_dazzle_2") 
	end

	while(current_targets ~= max_targets) do

		next_unit = _FindNextHero(caster, ability, this_unit, bounce_radius, heal_table)

		if(not next_unit) then -- if hero not found, find creep

			next_unit = _FindNextUnit(caster, ability, this_unit, bounce_radius, heal_table)

		else

			if(next_unit:GetHealth() / next_unit:GetMaxHealth() == 1) then -- if hero found, but hero has max health. may be creeps have less health?
				local temp_unit = _FindNextUnit(caster, ability, this_unit, bounce_radius, heal_table) -- find less health creep!
				if(temp_unit and temp_unit:GetHealth() / temp_unit:GetMaxHealth() < 1) then
					next_unit = temp_unit;
				end
			end

		end

		if(not next_unit) then -- no any units here :c need to leave this loop
			break;
		end

		this_unit = next_unit;
		table.insert(heal_table, next_unit)
		current_targets = current_targets + 1;
	end


	for i = 1, #heal_table do -- TIME TO HEAL
		if(i > 1) then
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle, 0, heal_table[i - 1], PATTACH_POINT_FOLLOW, "attach_hitloc", heal_table[i - 1]:GetAbsOrigin() , true)
			ParticleManager:SetParticleControlEnt(particle, 1, heal_table[i], PATTACH_POINT_FOLLOW, "attach_hitloc", heal_table[i - 1]:GetAbsOrigin() , true)
		end

		Util:_HealUnit(heal_table[i], caster, heal, 0, true)
		DealDamageArround(caster, ability, heal_table[i], damage_radius, damage, 0)
	end

end

function DealDamageArround(caster, ability, unit, radius, damage, damage_pct)
	local units_to_damage = FindUnitsInRadius(caster:GetTeam(), unit:GetAbsOrigin() , nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false)

	print("units to damage", units_to_damage, #units_to_damage)

	if(not units_to_damage) then return end

	for i = 1, #units_to_damage do

		local dmg = damage;
		local dmg_pct = damage_pct;

		if IsUnitBossGlobal( units_to_damage[i] ) then
			dmg = dmg / 2
			dmg_pct = dmg_pct / 4
		end

		ApplyDamage({
			victim 		= units_to_damage[i],
			attacker 	= caster,
			damage 		= dmg,
			damage_type = ability:GetAbilityDamageType(),
		})
		print("deal damage", dmg)
		Util:DealPercentDamageOfMaxHealth(units_to_damage[i], caster, ability:GetAbilityDamageType() , 0, dmg_pct)

		local damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_damage.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(damage_particle, 0, units_to_damage[i], PATTACH_POINT_FOLLOW, "attach_hitloc", units_to_damage[i]:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(damage_particle)
	end
end

function _IsUnitInTable(_table, unit)
	if not _table then return false; end;

	for i = 0, #_table do
		if _table[i] == unit then return true end
	end
	return false;
end

function _FindNextHero(caster, ability, this_hero, bounce_radius, heal_table)
	local heroes = FindUnitsInRadius(caster:GetTeam(), this_hero:GetAbsOrigin(), nil, bounce_radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	
	local min = 101;
	local min_unit;
	if heroes then
		for i = 1, #heroes do
			if(heroes[i]:GetHealth() / heroes[i]:GetMaxHealth() < min and not _IsUnitInTable(heal_table, heroes[i]) ) then
				min = heroes[i]:GetHealth() /heroes[i]:GetMaxHealth() 
				min_unit = heroes[i]
			end
		end
	end	

	return min_unit;
end

function _FindNextUnit(caster, ability, this_unit, bounce_radius, heal_table)
	local units = FindUnitsInRadius(caster:GetTeam(), this_unit:GetAbsOrigin() , nil, bounce_radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		
	local min = 101;
	local min_unit;

	if units then
		for i = 1, #units do
			if(units[i]:GetHealth() /units[i]:GetMaxHealth() < min and not _IsUnitInTable(heal_table, units[i]) ) then
				min = units[i]:GetHealth() /units[i]:GetMaxHealth() 
				min_unit = units[i]
			end
		end
	end	

	return min_unit;
end