function Experience(kv)
	local caster = kv.caster
	print("Level "..caster:GetLevel().."\nExp "..XP_PER_LEVEL_TABLE[caster:GetLevel()])
	if caster:GetLevel() <= 1 then
		caster:AddExperience(220,false,false)
	else
		caster:AddLevels(1)
	end
end