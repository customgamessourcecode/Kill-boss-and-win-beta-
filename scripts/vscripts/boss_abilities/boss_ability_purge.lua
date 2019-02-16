function Purge(event)
	if not event.caster:PassivesDisabled() then
		local target_table = event.target_entities
		local caster = event.caster

		for k,v in pairs(target_table) do
		v:Purge(true,false,false,false,false)
		end

		caster:Purge(false,true,false,true,true)
		caster:RemoveModifierByName("modifier_ursa_fury_swipes_damage_increase")
		caster:RemoveModifierByName("modifier_ursa_fury_swipes")
	end
end