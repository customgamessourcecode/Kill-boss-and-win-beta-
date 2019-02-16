function MiranaOverskillStart( event )
	local caster 		= event.caster
	local ability 		= event.ability
	local multipler 	= event.Multipler or 0
	local modifier_name = event.ModifierName
	local duration 		= event.Duration
	local charges 		= caster:GetAgility()*multipler 

	if caster:HasModifier(modifier_name) then return end
	
	ability:ApplyDataDrivenModifier(caster, caster, modifier_name, { duration = duration })	
	caster:SetModifierStackCount(modifier_name, ability, charges)


end
