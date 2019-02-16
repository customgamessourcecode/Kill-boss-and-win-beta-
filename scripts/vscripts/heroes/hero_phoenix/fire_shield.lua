--[[
	Author: Noya
	Date: 9.1.2015.
	Absorbs damage up to the max absorb, substracting from the shield until removed.
]]
function FireShieldCreated( event )
	-- Variables
	local caster = event.caster
	local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	local max_hp_percent = event.ability:GetLevelSpecialValueFor("max_hp_shield", event.ability:GetLevel() - 1 )
	local health_cost = event.ability:GetLevelSpecialValueFor("max_hp_shield", event.ability:GetLevel() - 1 )
	
	-- Reset the shield
	caster:SetHealth(caster:GetHealth()*(1-health_cost/100)+1)
	caster.AphoticShieldRemaining = max_damage_absorb + event.caster:GetMaxHealth()*max_hp_percent/100


end

function FireShieldAbsorb( event )
	-- Variables
	local damage = event.DamageTaken
	local unit = event.unit
	local ability = event.ability
	
	-- Track how much damage was already absorbed by the shield
	local shield_remaining = unit.AphoticShieldRemaining
--	print("Shield Remaining: "..shield_remaining)
--	print("Damage Taken pre Absorb: "..damage)

	-- Check if the unit has the borrowed time modifier
	if not unit:HasModifier("modifier_borrowed_time") then
		-- If the damage is bigger than what the shield can absorb, heal a portion
		if damage > shield_remaining then
			local newHealth = unit.OldHealth - damage + shield_remaining
--			print("Old Health: "..unit.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..shield_remaining)
			unit:SetHealth(newHealth)
		else
			local newHealth = unit.OldHealth			
			unit:SetHealth(newHealth)
--			print("Old Health: "..unit.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..damage)
		end

		-- Reduce the shield remaining and remove
		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining-damage
		if unit.AphoticShieldRemaining <= 0 then
			unit.AphoticShieldRemaining = nil
			unit:RemoveModifierByName("modifier_aphotic_shield")
			print("--Shield removed--")
		end

		if unit.AphoticShieldRemaining then
--			print("Shield Remaining after Absorb: "..unit.AphoticShieldRemaining)
--			print("---------------")
		end
	end

end




-- Keeps track of the targets health
function FireShieldHealth( event )
	local target = event.target

	target.OldHealth = target:GetHealth()
	
	

	
end