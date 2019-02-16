if woodchopper_king_perfect_summon_choppers == nil then woodchopper_king_perfect_summon_choppers = class({}) end

LinkLuaModifier("woodchopper_king_perfect_summon_choppers_lifetime","boss_abilities/woodchopper_king_perfect_summon_choppers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("woodchopper_king_perfect_summon_choppers_passive","boss_abilities/woodchopper_king_perfect_summon_choppers.lua",LUA_MODIFIER_MOTION_NONE)

function woodchopper_king_perfect_summon_choppers:OnSpellStart(  )
	local easy = "npc_woodchopper_easy"
	local med = "npc_woodchopper_normal"
	local har = "npc_woodchopper_hard"
	local max = self:GetSpecialValueFor("countmax")
	local min = self:GetSpecialValueFor("countmin")
	local caster = self:GetCaster()
	count = RandomInt(min,max)
	if caster.rage_stage then
		return
	else
		units = {easy,med,har}

		for i = 1, count do
			local unit = CreateUnitByName(GetRandomMonsterFromTable(units),
				caster:GetAbsOrigin()+RandomVector(RandomInt(320, 460)),
				true,
				caster,
				caster,
				caster:GetTeamNumber())
			unit:AddNewModifier(caster,self,"woodchopper_king_perfect_summon_choppers_lifetime",{duration = 32})
		end
	end
end

function woodchopper_king_perfect_summon_choppers:GetIntrinsicModifierName(  )
	if self:GetCaster().rage_stage then return "woodchopper_king_perfect_summon_choppers_passive" else return end
	return nil
end

function GetRandomMonsterFromTable(TABLE)
local d = #TABLE
return TABLE[math.random(d)]
end

-----------------------

if woodchopper_king_perfect_summon_choppers_lifetime == nil then woodchopper_king_perfect_summon_choppers_lifetime = class({}) end

function woodchopper_king_perfect_summon_choppers_lifetime:GetTexture(  )
	return "woodchopper_king_perfect_summon_choppers"
end

function woodchopper_king_perfect_summon_choppers_lifetime:OnDestroy(  )
	self:GetParent():ForceKill(false)
end