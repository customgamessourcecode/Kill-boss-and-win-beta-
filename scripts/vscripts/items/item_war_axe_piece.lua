require('libraries/timers')

if item_war_axe_piece == nil then	item_war_axe_piece = class({})end

function Base( keys )
	local caster = keys.caster
	local ability = keys.ability
	local charges = ability:GetCurrentCharges()
	local modifier = "modifier_war_axe_piece_damage"

	if not caster:HasModifier(modifier) then
		caster:AddNewModifier(caster,ability,modifier,{})
	else
		caster:SetModifierStackCount(modifier,caster,charges)
	end

	if charges >= 6 and ability then
		caster:RemoveItem(keys.ability)
		caster.flagpiece = 1
		Timers:CreateTimer(0.02,function() 
			if caster.flagpiece == 1 then
				caster.flagpiece = 0
				caster:AddItem(CreateItem("item_war_axe_dummy",caster,caster))
			end
		end)
	end
end

function Destroy( keys )
	local modifier = "modifier_war_axe_piece_damage"
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModifierStackCount(modifier,caster,0)
	caster:RemoveModifierByName(modifier)
end	