--[[Handling the stacking of Linas Fiery Soul ability
	Author: Pizzalol
	Date: 30.12.2014.]]
function Cooldown( keys )
local ability = keys.event_ability
	if (ability and not ability:IsItem() and ability:GetManaCost() > 90) then
		local caster = keys.caster
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local maxStack = ability:GetLevelSpecialValueFor("fiery_soul_max_stacks", level)
		local modifierBuffName = "modifier_fiery_soul_buff_datadriven"
		local modifierName
		local count = 1
		local chance = ability:GetLevelSpecialValueFor("chance", level)
	end
end