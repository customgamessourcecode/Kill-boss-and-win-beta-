--[[
	Name: 		Boss Settings Library
	Creator: 	HappyFeedFriends
	Date: 		19.09.2018
	Version: 	0.01
]]
LinkLuaModifier( "modifier_attack_speed_boss", "boss/bosses", LUA_MODIFIER_MOTION_NONE )
if not Boss then
	Boss = ({})
	BOSSES_LOW = 0
	BOSSES_MEDIUM = 0
	BOSSES_HARD = 0
	Boss.unit = "boss"
	Boss.entity = "spawner_boss"
	Boss.Text = 
	{
		["default"] = 	"Стандартный",
		["low"]     = 	"Лёгкий",
		["medium"]  = 	"Средний",
		["hard"]    = 	"Сложный",
	}
end
function Boss:KilledBoss(keys)
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local killerEntity
	if keys.entindex_attacker then killerEntity = EntIndexToHScript( keys.entindex_attacker ) end
	if killerEntity and killedUnit:IsBosses() then
		GameRules:SetGameWinner( killerEntity:GetTeam() )
	end 
end 
function Boss:GameRulesChangeBoss(keys)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then 
		self:Init()
	end
end
function math.maxThree(one,two,three)
	if not (one or two or three)  then
		return false
	end
	return math.max(math.max(one,two),three)
end 
require("boss/data")
function Boss:Init()
	local dif = math.maxThree(BOSSES_LOW,BOSSES_MEDIUM,BOSSES_HARD)
	local table = dif == 0 and "default" or  
	dif == BOSSES_LOW and "low" or 
	dif == BOSSES_MEDIUM and "medium" or 
	dif == BOSSES_HARD and "hard" or false
	if table and BOSS_DATA_NEW[table] then
		local data = BOSS_DATA_NEW[table]
        local coords = Entities:FindByName(nil,self.entity) and Entities:FindByName(nil,self.entity):GetAbsOrigin()
		if not coords then
			print("No coords entity of bossName:", Boss.unit)
			return false
		end 
		local unit = CreateUnitByName(self.unit, coords, true, nil, nil, DOTA_TEAM_NEUTRALS)
		FindClearSpaceForUnit(unit, coords, true)
		unit:SetDeathXP(data.xp  or 0)
		unit:SetMinimumGoldBounty(data.gold_drop  or 0)
		unit:SetMaximumGoldBounty(data.gold_drop  or 0)
		unit:SetMaxHealth(data.hp or 1000)
		unit:SetBaseMaxHealth(data.hp  or 1000)
		unit:SetHealth(data.hp  or 1000)
		unit:SetBaseDamageMin(data.damage  or 0)
		unit:SetBaseDamageMax(data.damage  or 0)
		unit:SetBaseMoveSpeed(data.movespeed  or 250) 
		unit:SetPhysicalArmorBaseValue(data.armor  or 0)
		unit:SetBaseMagicalResistanceValue(data.magic_armor or 0)
		unit:AddNewModifier(nil,nil,"modifier_attack_speed_boss",{duration = -1}):SetStackCount(data.attack_speed or 0)
		unit.boss = true
		unit:RemoveAbilityBoss()
		for _,ability in pairs(data.Ability) do
			unit:AddAbility(ability):SetLevel(1)
		end 		
		for k,item in pairs(data.items) do
			if k <= 6 then
				unit:AddItem(CreateItem(item, unit, unit))
			end
		end 
		GameRules:SendCustomMessage("Bыбранный уровень сложности для босса: " .. self.Text[table] or self.Text["default"],1,1)
	end
end
print(math.maxThree(1,1,1))
function CDOTA_BaseNPC:RemoveAbilityBoss()
    for i=0,self:GetAbilityCount() - 1 do
        local ability = self:GetAbilityByIndex(i)
		if ability then
			self:RemoveAbility(ability:GetAbilityName())
		end
    end
end
function CDOTA_BaseNPC:IsBosses()
	return self.boss
end  

function Boss:SetDifficuilt(keys)
	local dif = keys.diff
	BOSSES_LOW = dif == "low" and BOSSES_LOW + 1 or BOSSES_LOW
	BOSSES_MEDIUM = dif == "medium" and BOSSES_MEDIUM + 1 or BOSSES_MEDIUM
	BOSSES_HARD = dif == "hard" and BOSSES_HARD + 1 or BOSSES_HARD
end 

modifier_attack_speed_boss = class({
	IsHidden =      function() return true end,
	IsPurgable =    function() return false end,
	IsBuff =        function() return true end,
	RemoveOnDeath = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_attack_speed_boss:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_attack_speed_boss:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end