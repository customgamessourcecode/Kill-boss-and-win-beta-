if woodchopper_king_rage_summon_choppers == nil then woodchopper_king_rage_summon_choppers = class({}) end

LinkLuaModifier("woodchopper_king_perfect_summon_choppers_lifetime","boss_abilities/woodchopper_king_perfect_summon_choppers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("woodchopper_king_rage_summon_choppers_passive","boss_abilities/woodchopper_king_rage_summon_choppers.lua",LUA_MODIFIER_MOTION_NONE)

function woodchopper_king_rage_summon_choppers:GetIntrinsicModifierName(  )
	return "woodchopper_king_rage_summon_choppers_passive"
end

-----------------------

if woodchopper_king_rage_summon_choppers_passive == nil then woodchopper_king_rage_summon_choppers_passive = class({}) end

function woodchopper_king_rage_summon_choppers_passive:OnCreated(  )
	local har = "npc_woodchopper_hard"
	local max = self:GetAbility():GetSpecialValueFor("countmax")
	local min = self:GetAbility():GetSpecialValueFor("countmin")
	local caster = self:GetCaster()
	
	local ability = self:GetAbility()
	count = RandomInt(min,max)
	self.summoner = Timers:CreateTimer(0,function()
		if not caster.rage_stage then return end
		if ability:IsCooldownReady() and caster:GetMana() >= ability:GetManaCost() then
			for i = 1, count do
				local unit = CreateUnitByName(har,
					caster:GetAbsOrigin()+RandomVector(RandomInt(320, 460)),
					true,
					caster,
					caster,
					caster:GetTeamNumber())
				unit:AddNewModifier(caster,ability,"woodchopper_king_perfect_summon_choppers_lifetime",{duration = 32})
				ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
				caster:SpendMana(ability:GetManaCost())
			end
		end
	return 1
	end)
end

function woodchopper_king_rage_summon_choppers:OnDestroy(  )
	Timers:RemoveTimer(self.summoner)
end