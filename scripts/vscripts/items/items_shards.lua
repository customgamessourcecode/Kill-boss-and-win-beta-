function AddStat(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then
		return
	end
	local ability = keys.ability
	local str = keys.str
	local agi = keys.agi
	local int = keys.int
	if str then
		caster:ModifyStrength(str)
		caster.Additional_str = (caster.Additional_str or 0) + str
	end
	if agi then
		caster:ModifyAgility(agi)
		caster.Additional_agi = (caster.Additional_agi or 0) + agi
	end
	if int then
		caster:ModifyIntellect(int)
		caster.Additional_int = (caster.Additional_int or 0) + int
	end
end

function AddAttackspeedModifier(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then
		return
	end
	local ability = keys.ability
	if not caster:HasModifier("modifier_item_shard_attackspeed_stack") then
		caster:AddNewModifier(caster, ability, "modifier_item_shard_attackspeed_stack", {})
	end
	local mod = caster:FindModifierByName("modifier_item_shard_attackspeed_stack")
	if mod then
		mod:IncrementStackCount()
	end
	caster.Additional_attackspeed = mod:GetStackCount()
end

function AddLevels(keys)
	local ability = keys.ability
	local caster = keys.caster
	if not caster:IsRealHero() then return end

	local level = caster:GetLevel()
	local newLevel = math.min(level + keys.amount, #XP_PER_LEVEL_TABLE)

	caster:AddExperience(XP_PER_LEVEL_TABLE[newLevel] - XP_PER_LEVEL_TABLE[level], 0, false, false)
end
