-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  if GameMode._reentrantCheck then
    return
  end

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    --Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    GameMode:PostLoadPrecache()
    GameMode:OnAllPlayersLoaded()

    if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
      for i=0,9 do
        if PlayerResource:IsValidPlayer(i) then
          local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
          PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
      end
    end
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end

  GameMode._reentrantCheck = true
  GameMode:OnGameRulesStateChange(keys)
  GameMode._reentrantCheck = false
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and Duel.MAPS[ GetMapName() ] then
		Duel:Init()
	end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
  if GameMode._reentrantCheck then
    return
  end

  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    GameMode:OnHeroInGame(npc)
  end

  GameMode._reentrantCheck = true
  GameMode:OnNPCSpawned(keys)
  GameMode._reentrantCheck = false
end

-- An entity died
function GameMode:_OnEntityKilled( keys )
  if GameMode._reentrantCheck then
    return
  end

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local hero = nil

  if keys.entindex_attacker ~= nil then
    hero = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. hero:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(hero:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( hero:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
    end
  end

  GameMode._reentrantCheck = true
  GameMode:OnEntityKilled( keys )
  GameMode._reentrantCheck = false

  if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then
         OnHeroDeath(killedUnit, hero)
      end
      local UnitName = killedUnit:GetUnitName()
      if UnitName == "boss_warloc" or UnitName == "boss_druid" or UnitName == "boss_trent" or UnitName == "npc_dota_roshan" then
        print("BOSS KILLED, NAME: " .. UnitName)
        GameMode:BossRespawnAndEtc(killedUnit, hero)
      end
    --[[if killedUnit:GetUnitName() == "boss_trent" then
        for i = 0, PlayerResource:GetPlayerCount() - 1 do
            local gold = 800
            local player = PlayerResource:GetSelectedHeroEntity(i)
            if player:GetTeam() == hero:GetTeam() then
                player:ModifyGold( gold, true, 0 )
                SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player, gold, nil)
                player:AddExperience( 100, 0, false, false )
            end
        end
    end
    ]]
   if hero:HasItemInInventory("item_skull_of_midas")
   then if not killedUnit:IsRealHero() then
        local caster = hero
        local gold = 5
        local presymbol = POPUP_SYMBOL_PRE_PLUS
        local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf", PATTACH_ABSORIGIN, caster, caster:GetPlayerOwner())
        ParticleManager:SetParticleControl(particle, 1, Vector(presymbol, math.abs(gold), 0))
        ParticleManager:SetParticleControl(particle, 2, Vector(2, string.len(math.abs(gold)) + 1, 0))
        ParticleManager:SetParticleControl(particle, 3, Vector(255, 200, 33))
        hero:ModifyGold( 5 , true , 0 )
        hero:AddExperience( 15, 0, false, false )
     end
  end
  -- OLD ARENA CODE
  --[[
    if killedUnit:IsRealHero() then
        if killedUnit:IsReincarnating() == false then
            local ArenaKilledHero = killedUnit.OnDuel
            local ArenaKillerHero = hero.OnDuel
            if killedUnit ~= hero then
                if ArenaKilledHero == true then
                    if ArenaKillerHero == true then
                        killedUnit:SetTimeUntilRespawn( 99999 )
                        local GoldWin = _G.StartGoldAndXpPerDuel["Gold"] * _G.DuelNumber
                        local XpWin = _G.StartGoldAndXpPerDuel["Xp"] * _G.DuelNumber
                        local GoldLoose = math.floor(GoldWin / 2)
                        local XpLoose = math.floor(XpWin / 2)
                        if hero:GetTeamNumber() == 2 then
                            _G.WinsPerDuel2 = _G.WinsPerDuel2 + 1
                        elseif hero:GetTeamNumber() == 3 then
                            _G.WinsPerDuel3 = _G.WinsPerDuel3 + 1
                        end
                        _G.ArensNumber = _G.ArensNumber - 1
                        if _G.ArensNumber <= 0 then
                            Timers:CreateTimer(0.5, function()
                                local aHeroes = HeroList:GetAllHeroes()
                                if _G.WinsPerDuel2 > _G.WinsPerDuel3 then
                                    CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Победили Силы Света", Time = 5} )
                                    for count, h in ipairs(aHeroes) do
                                        local Check = h.OnDuel
                                        if h:IsIllusion() == false and h:IsRealHero() and Check == true then
                                            local TeamNumber = h:GetTeamNumber()
                                            if h:IsAlive() == false then
                                                h:RespawnHero(false, false)
                                             end
                                            h:RemoveModifierByName("modifier_truesight")
                                            h:SetAbsOrigin(h.BeforeArenaPosition)
                                            GameMode:RefreshHeroAll(h, false)
                                            if TeamNumber == 2 then
                                                h:AddExperience(XpWin, DOTA_ModifyXP_CreepKill, false, false)
                                                h:ModifyGold(GoldWin, false, DOTA_ModifyGold_CreepKill)
                                                SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldWin, nil )
                                            elseif TeamNumber == 3 then
                                                h:AddExperience(XpLoose, DOTA_ModifyXP_CreepKill, false, false)
                                                h:ModifyGold(GoldLoose, false, DOTA_ModifyGold_CreepKill)
                                                SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldLoose, nil )
                                            end
                                            h.OnDuel = false
                                        end
                                    end
                                elseif _G.WinsPerDuel2 < _G.WinsPerDuel3 then
                                    CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Победили Силы Тьмы", Time = 5} )
                                    for count, h in ipairs(aHeroes) do
                                        local Check = h.OnDuel
                                        if h:IsIllusion() == false and h:IsRealHero() and Check == true then
                                            local TeamNumber = h:GetTeamNumber()
                                            if h:IsAlive() == false then
                                                h:RespawnHero(false, false)
                                            end
                                            h:RemoveModifierByName("modifier_truesight")
                                            h:SetAbsOrigin(h.BeforeArenaPosition)
                                            GameMode:RefreshHeroAll(h, false)
                                            if TeamNumber == 3 then
                                                h:AddExperience(XpWin, DOTA_ModifyXP_CreepKill, false, false)
                                                h:ModifyGold(GoldWin, false, DOTA_ModifyGold_CreepKill)
                                                SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldWin, nil )
                                            elseif TeamNumber == 2 then
                                                h:AddExperience(XpLoose, DOTA_ModifyXP_CreepKill, false, false)
                                                h:ModifyGold(GoldLoose, false, DOTA_ModifyGold_CreepKill)
                                                SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldLoose, nil )
                                            end
                                            h.OnDuel = false
                                        end
                                    end
                                elseif _G.WinsPerDuel2 == _G.WinsPerDuel3 then
                                    CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Ничья!", Time = 5} )
                                    for count, h in ipairs(aHeroes) do
                                        local Check = h.OnDuel
                                        if h:IsIllusion() == false and h:IsRealHero() and Check == true then
                                            local TeamNumber = h:GetTeamNumber()
                                            if h:IsAlive() == false then
                                                h:RespawnHero(false, false)
                                            end
                                            h:RemoveModifierByName("modifier_truesight")
                                            h:SetAbsOrigin(h.BeforeArenaPosition)
                                            GameMode:RefreshHeroAll(h, false)
                                            h:AddExperience(XpLoose, DOTA_ModifyXP_CreepKill, false, false)
                                            h:ModifyGold(GoldLoose, false, DOTA_ModifyGold_CreepKill)
                                            SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldLoose, nil )
                                            h.OnDuel = false
                                        end
                                    end
                                end
                                _G.ArensTable["Arena" .. GameMode:GetSpecialCValue(killedUnit:GetTeamNumber(), killedUnit)] = {}
                                _G.SpecialPlayersTable = {}
                                _G.DuelNumber = _G.DuelNumber + 1
                                _G.DuelTimerTime = 301
                                _G.DuelStarts = false
                                _G.WinsPerDuel2 = 0
                                _G.WinsPerDuel3 = 0
                                CustomGameEventManager:Send_ServerToAllClients( "show_newstring", {StringNeed = "До дуэли:    "} )
                                CustomGameEventManager:Send_ServerToAllClients( "show_dueltimer", {Gold = _G.StartGoldAndXpPerDuel["Gold"] * _G.DuelNumber, Xp = _G.StartGoldAndXpPerDuel["Xp"] * _G.DuelNumber} )
                            end)
                        end
                    end
                end
            end
        end
    end]]
end

function GetTotalPr(playerid)
    local streak = PlayerResource:GetStreak(playerid)
    local gold_per_streak = 1000;
    local gold_per_level  = 100;
    local minute = GameRules:GetGameTime() / 60
    if      minute < 10 then
        gold_per_streak = 210 + (RandomInt(-1, 1)) * RandomInt(0, 100)
    elseif  minute < 20 then
        gold_per_streak = 300 + (RandomInt(-1, 1)) * RandomInt(0, 100)
    elseif  minute < 30 then
        gold_per_streak = 1000 + (RandomInt(-1, 1)) * RandomInt(0, 110)
    elseif  minute < 50 then
        gold_per_streak = 3000 + (RandomInt(-1, 1)) * RandomInt(0, 220)
    elseif  minute > 50 then
        gold_per_streak = 5000 + (RandomInt(-1, 1)) * RandomInt(0, 250)
    end

    --print("GOLD PER STREAKS:", gold_per_streak*streak)
--    _G.tPlayers[playerid]                 = _G.tPlayers[playerid] or {}
--  _G.tPlayers[playerid].filter_gold   = _G.tPlayers[playerid].filter_gold or 0
--  _G.tPlayers[playerid].books         = _G.tPlayers[playerid].books or 0

    --print("FILTER GOLD:", _G.tPlayers[playerid].filter_gold)
    --print("BOOKS GOLD:", _G.tPlayers[playerid].books);
    local total_gold = gold_per_streak*streak--_G.tPlayers[playerid].filter_gold + gold_per_streak*streak + _G.tPlayers[playerid].books
    --print("TOTAL GOLD = ", total_gold)
    return total_gold
end

function OnHeroDeath(dead_hero, killer)
    if dead_hero and killer and IsValidEntity(killer) and dead_hero ~= killer and dead_hero:GetTeamNumber() ~= killer:GetTeamNumber() then
        local playerid = killer:GetPlayerOwnerID()

        if (not playerid or playerid == -1) then return end

        if not killer:IsRealHero() then
            killer = killer:GetPlayerOwner():GetAssignedHero();
        end

        local dead_hero_cost = GetTotalPr(dead_hero:GetPlayerOwnerID() )
        local killer_cost = GetTotalPr(killer:GetPlayerOwnerID())
        local total_gold_get = 0

        if dead_hero_cost > killer_cost then
            total_gold_get = dead_hero_cost - killer_cost
            if total_gold_get > 40000 then
                total_gold_get = 40000 + RandomInt(52, 600)
            end

            if GameRules:GetGameTime() / 60 < 35 then
                if total_gold_get > 25000 then
                    total_gold_get = 25000 + RandomInt(5, 400)
                end
            end

            total_gold_get = total_gold_get / 2 + RandomInt(1, 100)

            GameRules:SendCustomMessage( "#ANGEL_ARENA_ON_KILL", killer:GetPlayerID(), total_gold_get)
            PlayerResource:ModifyGold( playerid, total_gold_get*0.7, false, 0)

            local anti_bug_system = {}
            anti_bug_system[playerid] = true
            local heroes = HeroList:GetAllHeroes()

            for _, hero in pairs(heroes) do
                if(hero and (hero:GetAbsOrigin() - dead_hero:GetAbsOrigin()):Length2D() < 1300 and hero:GetTeamNumber() ~= dead_hero:GetTeamNumber() ) then

                    if not anti_bug_system[hero:GetPlayerOwnerID()] then
                        PlayerResource:ModifyGold( hero:GetPlayerOwnerID(), total_gold_get*0.3, false, 0)
                        print("2givegold to hero " , hero:GetUnitName() , "gold=", total_gold_get*0.3)
                        anti_bug_system[hero:GetPlayerOwnerID()] = true
                    end
                end
            end

            anti_bug_system = nil
        else
            --total_gold_get = RandomInt(50, 150)
            --GameRules:SendCustomMessage( "#ANGEL_ARENA_ON_KILL", killer:GetPlayerID(), total_gold_get)
            --PlayerResource:ModifyGold( playerid, total_gold_get, false, 0)
        end
    end

end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  if GameMode._reentrantCheck then
    return
  end

  GameMode:_CaptureGameMode()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply

  GameMode._reentrantCheck = true
  GameMode:OnConnectFull( keys )
  GameMode._reentrantCheck = false
end

--[[ OLD ARENA CODE
_G.SpecialPlayersTable = {}
_G.Team2SortedValues = {}
_G.Team3SortedValues = {}
_G.ArensTable = {
    Arena1 = {},
    Arena2 = {},
    Arena3 = {},
    Arena4 = {},
    Arena5 = {},
    Arena6 = {}
}
_G.DuelNumber = 1
_G.ArensNumber = 0
_G.DuelTimerTime = 301
_G.DuelStarts = true
_G.WinsPerDuel2 = 0
_G.WinsPerDuel3 = 0
_G.StartGoldAndXpPerDuel = {
    Gold = 150,
    Xp = 135
}

function GameMode:DuelTimer()
    _G.DuelTimerTime = _G.DuelTimerTime - 1
    if _G.DuelTimerTime <= 0 then
        _G.DuelTimerTime = 0
        if _G.DuelStarts == false then
            GameMode:GetPlayersInformation()
        else
            GameMode:ResetAllDuel()
        end
    end
    local t = _G.DuelTimerTime
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer =
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdownDuel", broadcast_gametimer )
end

function GameMode:ResetAllDuel()
                        local GoldWin = _G.StartGoldAndXpPerDuel["Gold"] * _G.DuelNumber
                        local XpWin = _G.StartGoldAndXpPerDuel["Xp"] * _G.DuelNumber
                        local GoldLoose = math.floor(GoldWin / 2)
                        local XpLoose = math.floor(XpWin / 2)
                        _G.ArensNumber = 0
                        if _G.ArensNumber <= 0 then
                            local aHeroes = HeroList:GetAllHeroes()
                            if _G.WinsPerDuel2 > _G.WinsPerDuel3 then
                                CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Победили Силы Света", Time = 5} )
                                for count, h in ipairs(aHeroes) do
                                    if h:IsIllusion() == false and h:IsRealHero() and GameMode:GetArena(h:GetTeamNumber(), h) ~= nil then
                                        local TeamNumber = h:GetTeamNumber()
                                        if h:IsAlive() == false then
                                            h:RespawnHero(false, false)
                                        end
                                        h:RemoveModifierByName("modifier_truesight")
                                        h:SetAbsOrigin(h.BeforeArenaPosition)
                                        GameMode:RefreshHeroAll(h, false)
                                        if TeamNumber == 2 then
                                            h:AddExperience(XpWin, DOTA_ModifyXP_CreepKill, false, false)
                                            h:ModifyGold(GoldWin, false, DOTA_ModifyGold_CreepKill)
                                            SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldWin, nil )
                                        elseif TeamNumber == 3 then
                                            h:AddExperience(XpLoose, DOTA_ModifyXP_CreepKill, false, false)
                                            h:ModifyGold(GoldLoose, false, DOTA_ModifyGold_CreepKill)
                                            SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldLoose, nil )
                                        end
                                        h.OnDuel = false
                                    end
                                end
                            elseif _G.WinsPerDuel2 < _G.WinsPerDuel3 then
                                CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Победили Силы Тьмы", Time = 5} )
                                for count, h in ipairs(aHeroes) do
                                    if h:IsIllusion() == false and h:IsRealHero() and GameMode:GetArena(h:GetTeamNumber(), h) ~= nil then
                                        local TeamNumber = h:GetTeamNumber()
                                        if h:IsAlive() == false then
                                            h:RespawnHero(false, false)
                                        end
                                        h:RemoveModifierByName("modifier_truesight")
                                        h:SetAbsOrigin(h.BeforeArenaPosition)
                                        GameMode:RefreshHeroAll(h, false)
                                        if TeamNumber == 3 then
                                            h:AddExperience(XpWin, DOTA_ModifyXP_CreepKill, false, false)
                                            h:ModifyGold(GoldWin, false, DOTA_ModifyGold_CreepKill)
                                            SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldWin, nil )
                                        elseif TeamNumber == 2 then
                                            h:AddExperience(XpLoose, DOTA_ModifyXP_CreepKill, false, false)
                                            h:ModifyGold(GoldLoose, false, DOTA_ModifyGold_CreepKill)
                                            SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldLoose, nil )
                                        end
                                        h.OnDuel = false
                                    end
                                end
                            elseif _G.WinsPerDuel2 == _G.WinsPerDuel3 then
                                CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Ничья!", Time = 5} )
                                for count, h in ipairs(aHeroes) do
                                    if h:IsIllusion() == false and h:IsRealHero() and GameMode:GetArena(h:GetTeamNumber(), h) ~= nil then
                                        local TeamNumber = h:GetTeamNumber()
                                        if h:IsAlive() == false then
                                            h:RespawnHero(false, false)
                                        end
                                        h:RemoveModifierByName("modifier_truesight")
                                        h:SetAbsOrigin(h.BeforeArenaPosition)
                                        GameMode:RefreshHeroAll(h, false)
                                        h:AddExperience(XpLoose, DOTA_ModifyXP_CreepKill, false, false)
                                        h:ModifyGold(GoldLoose, false, DOTA_ModifyGold_CreepKill)
                                        SendOverheadEventMessage( h, OVERHEAD_ALERT_GOLD, h, GoldLoose, nil )
                                        h.OnDuel = false
                                    end
                                end
                            end
                        end

	_G.SpecialPlayersTable = {}
    _G.Team2SortedValues = {}
    _G.Team3SortedValues = {}
    _G.ArensTable = {
        Arena1 = {},
        Arena2 = {},
        Arena3 = {},
        Arena4 = {},
        Arena5 = {},
        Arena6 = {}
    }

    _G.DuelNumber = _G.DuelNumber + 1
    _G.DuelTimerTime = 301
    _G.DuelStarts = false
    _G.WinsPerDuel2 = 0
    _G.WinsPerDuel3 = 0
    CustomGameEventManager:Send_ServerToAllClients( "show_newstring", {StringNeed = "До дуэли:    "} )
    CustomGameEventManager:Send_ServerToAllClients( "show_dueltimer", {Gold = _G.StartGoldAndXpPerDuel["Gold"] * _G.DuelNumber, Xp = _G.StartGoldAndXpPerDuel["Xp"] * _G.DuelNumber} )
end



function GameMode:GetPlayersInformation()
    CustomGameEventManager:Send_ServerToAllClients( "show_newstring", {StringNeed = "Конец дуэли: "} )
    _G.DuelTimerTime = 90
    _G.DuelStarts = true
    local AllHeroes = HeroList:GetAllHeroes()
    for count, hero in ipairs(AllHeroes) do
        if hero:IsIllusion() == false and hero:IsRealHero() then
            hero.InTriggerEntity = nil
            if IsInToolsMode() == true then
                if PlayerResource:GetConnectionState(hero:GetPlayerID()) == 2 or PlayerResource:GetConnectionState(hero:GetPlayerID()) == 1 then

                    local TeamNumber = hero:GetTeamNumber()
                    GameMode:SetToTableSpecialBalanceValue(hero, TeamNumber)
                end
            elseif IsInToolsMode() == false then
                if PlayerResource:GetConnectionState(hero:GetPlayerID()) == 2 then

                    local TeamNumber = hero:GetTeamNumber()
                    GameMode:SetToTableSpecialBalanceValue(hero, TeamNumber)
                end
            end
        end
    end
    _G.Team2SortedValues = {}
    _G.Team3SortedValues = {}
    _G.ArensTable = {
        Arena1 = {},
        Arena2 = {},
        Arena3 = {},
        Arena4 = {},
        Arena5 = {},
        Arena6 = {}
    }
    if _G.SpecialPlayersTable["Team2"] ~= nil then
        for k, v in pairs(_G.SpecialPlayersTable["Team2"]) do
            _G.Team2SortedValues[#_G.Team2SortedValues + 1] = v
        end
        table.sort(_G.Team2SortedValues, function (a, b) return (a > b) end)
    end
    if _G.SpecialPlayersTable["Team3"] ~= nil then
        for k, v in pairs(_G.SpecialPlayersTable["Team3"]) do
            _G.Team3SortedValues[#_G.Team3SortedValues + 1] = v
        end
        table.sort(_G.Team3SortedValues, function (a, b) return (a > b) end)
    end
    GameMode:SetDuelsStart()
end

function GameMode:SetDuelsStart()
    repeat
        if #_G.Team3SortedValues > #_G.Team2SortedValues then
            table.remove(_G.Team3SortedValues)
        elseif #_G.Team3SortedValues < #_G.Team2SortedValues then
            table.remove(_G.Team2SortedValues)
        end
    until #_G.Team3SortedValues == #_G.Team2SortedValues
    _G.ArensNumber = #_G.Team3SortedValues
	if _G.ArensNumber == 0 then
        CustomGameEventManager:Send_ServerToAllClients( "show_whowin", {Who = "Не хватает игроков для дуэли", Time = 5} )
		_G.SpecialPlayersTable = {}
        _G.Team2SortedValues = {}
        _G.Team3SortedValues = {}
        _G.ArensTable = {
            Arena1 = {},
            Arena2 = {},
            Arena3 = {},
            Arena4 = {},
            Arena5 = {},
            Arena6 = {}
        }

        _G.DuelNumber = _G.DuelNumber + 1
        _G.DuelTimerTime = 301
        _G.DuelStarts = false
        _G.WinsPerDuel2 = 0
        _G.WinsPerDuel3 = 0
        CustomGameEventManager:Send_ServerToAllClients( "show_newstring", {StringNeed = "До дуэли:    "} )
        CustomGameEventManager:Send_ServerToAllClients( "show_dueltimer", {Gold = _G.StartGoldAndXpPerDuel["Gold"] * _G.DuelNumber, Xp = _G.StartGoldAndXpPerDuel["Xp"] * _G.DuelNumber} )
    end

    local AllHeroes = HeroList:GetAllHeroes()
    for count, hero in ipairs(AllHeroes) do
        if hero:IsIllusion() == false and hero:IsRealHero() then
            local TeamNumber = hero:GetTeamNumber()
            if TeamNumber == 2 then
                for c, h in pairs(_G.Team2SortedValues) do
                    if _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == h and _G.ArensTable["Arena" .. c][TeamNumber] ~= false then
                        if hero:IsAlive() == false then
                            hero:RespawnHero(false, false)
                        end
                        GameMode:RefreshHeroAll(hero, true)
                        for n, need in ipairs(AllHeroes) do
                            if need:GetTeamNumber() == 3 then
                                hero:AddNewModifier(need, nil, "modifier_truesight", {Duration = inf})
                                break
                            end
                        end
                        hero.BeforeArenaPosition = hero:GetAbsOrigin()
                        hero.OnDuel = true
						_G.ArensTable["Arena" .. c][TeamNumber] = false
                        local Tp = Entities:FindByName( nil, "Arena" .. c .. "_1" ):GetAbsOrigin()
                        if hero:IsInvulnerable() == true then
                            Timers:CreateTimer(hero:GetUnitName() .. "Timer", {
                                useGameTime = true,
                                endTime = 0,
                                callback = function()
                                    if hero:IsInvulnerable() == false then
                                        Timers:RemoveTimer(hero:GetUnitName() .. "Timer")
                                        hero:SetAbsOrigin(Tp)
                                    end
                                  return 0.1
                                end
                              })
                        end
                        hero:InterruptMotionControllers(true)
                        hero:SetAbsOrigin(Tp)
                        break
                    end
                end
            elseif TeamNumber == 3 then
                for c, h in pairs(_G.Team3SortedValues) do
                    if _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == h and _G.ArensTable["Arena" .. c][TeamNumber] ~= false then
                        if hero:IsAlive() == false then
                            hero:RespawnHero(false, false)
                        end
                        GameMode:RefreshHeroAll(hero, true)
                        for n, need in ipairs(AllHeroes) do
                            if need:GetTeamNumber() == 2 then
                                hero:AddNewModifier(need, nil, "modifier_truesight", {Duration = inf})
                                break
                            end
                        end
                        hero.BeforeArenaPosition = hero:GetAbsOrigin()
                        hero.OnDuel = true
						_G.ArensTable["Arena" .. c][TeamNumber] = false
                        local Tp = Entities:FindByName( nil, "Arena" .. c .. "_2" ):GetAbsOrigin()
                        if hero:IsInvulnerable() == true then
                            Timers:CreateTimer(hero:GetUnitName() .. "Timer", {
                                useGameTime = true,
                                endTime = 0,
                                callback = function()
                                    if hero:IsInvulnerable() == false then
                                        Timers:RemoveTimer(hero:GetUnitName() .. "Timer")
                                        hero:SetAbsOrigin(Tp)
                                    end
                                  return 0.1
                                end
                              })
                        end
                        hero:InterruptMotionControllers(true)
                        hero:SetAbsOrigin(Tp)
                        break
                    end
                end
            end
        end
    end
end

function GameMode:RefreshHeroAll(hero, itemscd)
    if itemscd == true then
        for i = 0, 14 do
            local current_item = hero:GetItemInSlot(i)
            if current_item ~= nil then
                current_item:EndCooldown()
            end
        end
    end
    for j = 0, 23 do
        local ability = hero:GetAbilityByIndex(j)
        if ability ~= nil then
            ability:EndCooldown()
        end
    end
    hero:SetHealth(hero:GetMaxHealth())
    hero:SetMana(hero:GetMaxMana())
end

function GameMode:GetSpecialCValue(TeamNumber, hero)
    if TeamNumber == 2 then
        for c, h in pairs(_G.Team2SortedValues) do
            if _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == h then
                if _G.ArensTable["Arena" .. c][TeamNumber] ~= nil then
                    return c
                else
                    return nil
                end
            elseif _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == nil then
                return nil
            end
        end
    elseif TeamNumber == 3 then
        for c, h in pairs(_G.Team3SortedValues) do
            if _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == h then
                if _G.ArensTable["Arena" .. c][TeamNumber] ~= nil then
                    return c
                else
                    return nil
                end
            elseif _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == nil then
                return nil
            end
        end
    end
    return nil
end

function GameMode:GetArena(TeamNumber, hero)
    if TeamNumber == 2 then
        for c, h in pairs(_G.Team2SortedValues) do
            if _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == h then
                if _G.ArensTable["Arena" .. c][TeamNumber] ~= nil then
                    return _G.ArensTable["Arena" .. c]
                else
                    return nil
                end
            elseif _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == nil then
                return nil
            end
        end
    elseif TeamNumber == 3 then
        for c, h in pairs(_G.Team3SortedValues) do
            if _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == h then
                if _G.ArensTable["Arena" .. c][TeamNumber] ~= nil then
                    return _G.ArensTable["Arena" .. c]
                else
                    return nil
                end
            elseif _G.SpecialPlayersTable["Team" .. TeamNumber][hero:GetUnitName()] == nil then
                return nil
            end
        end
    end
    return nil
end

function GameMode:SetToTableSpecialBalanceValue(hero, TeamNumber)
    if _G.SpecialPlayersTable["Team" .. TeamNumber] == nil then
        _G.SpecialPlayersTable["Team" .. TeamNumber] = {}
    end
    local thisTable = _G.SpecialPlayersTable["Team" .. TeamNumber]
    local GoldfromItems = 0
    for i = 0, 14 do
        local current_item = hero:GetItemInSlot(i)
        if current_item ~= nil then
            GoldfromItems = GoldfromItems + GetItemCost(current_item:GetAbilityName())
        end
    end
    local gold = math.floor((PlayerResource:GetGold(hero:GetPlayerID()) + GoldfromItems) / 100)
    local lvl = PlayerResource:GetLevel(hero:GetPlayerID())
    local SpecialValue = gold + lvl
    thisTable[hero:GetUnitName()] = SpecialValue
end
]]