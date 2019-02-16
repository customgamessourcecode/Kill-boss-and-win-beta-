function AghanimsSynthCast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_synth = keys.modifier_synth
	local modifier_stats = keys.modifier_stats
	local sound_cast = keys.sound_cast

	if caster:HasModifier(modifier_synth) or caster:HasModifier("modifier_arc_warden_tempest_double") then
		return nil
	end

	caster:AddNewModifier(caster, nil, modifier_synth, {})
	ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})

	caster:EmitSound(sound_cast)

	ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
	caster:RemoveItem(ability)

	local dummy_scepter = CreateItem("item_ultimate_scepter", caster, caster)
	caster:AddItem(dummy_scepter)
	Timers:CreateTimer(0.01, function()
		caster:RemoveItem(dummy_scepter)
	end)
end
