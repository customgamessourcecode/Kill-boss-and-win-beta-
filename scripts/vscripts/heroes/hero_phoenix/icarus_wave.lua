function IcarusWaveStart( keys ) 
	local caster = keys.caster
	local ability = keys.ability
	local current_hp_cost = ability:GetSpecialValueFor("current_hp_cost")/ 100 
	
	caster:SetHealth(caster:GetHealth()*(1-current_hp_cost)+1)
end

function IcarusWaveImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local target = keys.target
	local dmg_max_hp = ability:GetSpecialValueFor("hp_dmg") * caster:GetMaxHealth() / 100 
	local base_damage = ability:GetSpecialValueFor("base_dmg")


	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	damage_table.ability = ability
	damage_table.damage = base_damage + dmg_max_hp

	ApplyDamage(damage_table)
end