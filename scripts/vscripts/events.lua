_G.BossesTable = {
    boss_warloc = {
        SGVFUB = 1,
        gold = 2500,
        xp = 1000,
        health = 60,
        armor = 15,
        damage = 60,
        magicresist = 1,
        attackspeed = 20,
        modelscale = 0.1,
        name = "Варлок голема",
        respoint = nil
    },
    boss_druid = {
        SGVFUB = 1,
        gold = 3000,
        xp = 750,
        health = 20,
        armor = 45,
        damage = 20,
        magicresist = 1,
        attackspeed = 4,
        modelscale = 0.1,
        name = "Друида",
        respoint = nil
    },
    npc_dota_roshan = {
        SGVFUB = 1,
        gold = 2000,
        xp = 500,
        health = 35,
        armor = 50,
        damage = 35,
        magicresist = 1,
        attackspeed = 20,
        modelscale = 0.1,
        name = "Рошана",
        respoint = nil
    },
    boss_trent = {
        SGVFUB = 1,
        gold = 800,
        xp = 350,
        health = 60,
        armor = 35,
        damage = 35,
        magicresist = 1,
        attackspeed = 20,
        modelscale = 0.1,
        name = "Трента",
        respoint = nil
    }
}
_G.TeamNames = {
    ["#DOTA_GoodGuys"] = "сил Света",
    ["#DOTA_BadGuys"] = "сил Тьмы"
}

function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  local newState = GameRules:State_Get()

  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	GameRules:GetGameModeEntity():SetContextThink( "GiveBooksThink", GiveBooksThink, GIVE_BOOKS_INTERVAL )
  local units = FindUnitsInRadius( 0, Vector(0,0,0), nil, 50000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, 0, false ) 
  for _, unit in pairs(units) do 
    local tBoss = BossesTable[unit:GetUnitName()] 
    if tBoss then 
      unit.respoint = unit:GetOrigin() 
    end 
  end	
 end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)

  local npc = EntIndexToHScript(keys.entindex)
	   	if npc:IsRealHero() and npc.bFirstSpawned == nil then
	   		npc.bFirstSpawned = true
			GameMode:OnHeroInGame(npc)
			local playerID = npc:GetPlayerID()
	    	local steamID = PlayerResource:GetSteamAccountID(playerID)
	    	local current_hero = npc:GetUnitName()
	    	print( "Steam Community ID: " .. tostring( steamID ) )
	    	print( "Current Hero: " .. tostring( current_hero ) )

			local premium =
			{
				2012877,
				3553352,
				26966141
			}

			for _,premium_modifier in pairs(premium) do
				if steamID == premium_modifier then
					npc:AddNewModifier( npc, nil, "modifier_admin", {duration = -1})

					local chancePet = RandomInt(1,5)
					if chancePet == 1 then
							local Pet = CreateUnitByName("unit_premium_pet", npc:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, npc, nil, npc:GetTeamNumber())
							Pet:SetOwner(npc)
						elseif chancePet == 2 then
							local Pet = CreateUnitByName("unit_premium_pet2", npc:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, npc, nil, npc:GetTeamNumber())
							Pet:SetOwner(npc)
						elseif chancePet == 3 then
							local Pet = CreateUnitByName("unit_premium_pet3", npc:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, npc, nil, npc:GetTeamNumber())
							Pet:SetOwner(npc)
						elseif chancePet == 4 then
							local Pet = CreateUnitByName("unit_premium_pet4", npc:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, npc, nil, npc:GetTeamNumber())
							Pet:SetOwner(npc)
						elseif chancePet == 5 then
							local Pet = CreateUnitByName("unit_premium_pet5", npc:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, npc, nil, npc:GetTeamNumber())
							Pet:SetOwner(npc)
					end
				end
			end

			if steamID == 259596687 or steamID == 26966141 then
				local Pet = CreateUnitByName("unit_premium_pet5", npc:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, npc, nil, npc:GetTeamNumber())
				Pet:SetOwner(npc)
			end
		end
	if npc then
		npc:AddNewModifier( npc, nil, "modifier_physical_damage_override", {} )
	end
end

function CDOTA_BaseNPC:SwapItem( item_name, upgraded_item_name, full_sell_time )
  local caster = self
  if not caster:HasItemInInventory(item_name) then return false; end
  for i=0,5 do
    local item = caster:GetItemInSlot(i)
    if item:GetName() == item_name then
      caster:RemoveItem(item)
      local item = caster:AddItem(CreateItem(upgraded_item_name,caster,caster))
      if full_sell_time then
        item:SetPurchaseTime(full_sell_time)
      end
      break
    end
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

  local unitEntity = nil
  if keys.UnitEntitIndex then
    unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
  elseif keys.HeroEntityIndex then
    unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
  end

  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys)
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname

  -- The cost of the item purchased
  local itemcost = keys.itemcost

end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil


  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- The ability/item used to kill, or nil if not killed by an item/ability
  local killerAbility = nil

  if keys.entindex_inflictor ~= nil then
    killerAbility = EntIndexToHScript( keys.entindex_inflictor )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless

end



-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname

  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
  local teamonly = keys.teamonly
  local userID = keys.userid
  local playerID = self.vUserIds[userID]:GetPlayerID()

  local text = keys.text
end

function CDOTA_BaseNPC:SwapToItem(ItemName)
    for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item == nil then
            keys.caster:AddItem(CreateItem("item_dummy", keys.caster, keys.caster))
        end
    end

    keys.caster:RemoveItem(keys.ability)
    keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster))  --This should be put into the same slot that the removed item was in.

    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() == "item_dummy_datadriven" then
                keys.caster:RemoveItem(current_item)
            end
        end
    end
end

function CDOTA_BaseNPC:RemoveCurrentModifier( modifier )
  local caster = self
  local mod_list = caster:FindAllModifiersByName(modifier:GetName())
  for _,mod in pairs(mod_list) do
    if mod == modifier then
      mod:Destroy()
    end
  end
end

function GameMode:BossRespawnAndEtc(unit, killer)
    GameMode:GiveAllGoldAndXP(unit, killer)
    local bossName = unit:GetUnitName()
    local point = unit.respoint 
    local team = unit:GetTeamNumber()
    Timers:CreateTimer(360,function()
        local unit = CreateUnitByName(bossName, point + RandomVector( RandomFloat( 0, 50)), true, nil, nil, team)
        GameMode:SetAllStatsBoss(unit)
		unit.respoint = point
    end)
 end

LinkLuaModifier( "modifier_attack_speed_bosses", "boss/modifier_attack_speed_bosses.lua", LUA_MODIFIER_MOTION_NONE )

function GameMode:SetAllStatsBoss(unit)
    local bossName = unit:GetUnitName()
    local SGVFUB = _G.BossesTable[bossName]["SGVFUB"] + 1
    _G.BossesTable[bossName]["SGVFUB"] = SGVFUB
    local Health = unit:GetMaxHealth() + (unit:GetMaxHealth() / 100 * (_G.BossesTable[bossName]["health"] * SGVFUB))
    local Armor = unit:GetPhysicalArmorBaseValue() + (unit:GetPhysicalArmorBaseValue() / 100 * (_G.BossesTable[bossName]["armor"] * SGVFUB))
    local Damage = unit:GetAverageTrueAttackDamage(unit) + (unit:GetAverageTrueAttackDamage(unit) / 100 * (BossesTable[bossName]["damage"] * SGVFUB))
    local MagicResist = unit:GetBaseMagicalResistanceValue() + (unit:GetBaseMagicalResistanceValue() / 100 * (_G.BossesTable[bossName]["magicresist"] * SGVFUB))
    local AttackSpeed = unit:GetAttackSpeed() * (_G.BossesTable[bossName]["attackspeed"] * SGVFUB)
    local ModelScale = unit:GetModelScale() + _G.BossesTable[bossName]["modelscale"] * SGVFUB
    unit:SetMaxHealth(Health)
    unit:SetBaseMaxHealth(Health)
    unit:SetHealth(Health)
    unit:SetPhysicalArmorBaseValue(Armor)
    unit:SetBaseDamageMin(Damage)
    unit:SetBaseDamageMax(Damage)
    unit:SetBaseMagicalResistanceValue(MagicResist)
    unit:AddNewModifier(nil,nil,"modifier_attack_speed_bosses",{duration = -1}):SetStackCount(AttackSpeed)
    unit:SetModelScale(ModelScale)
end

function GameMode:GiveAllGoldAndXP(unit, killer)
    local bossName = unit:GetUnitName()
    local SGVFUB = _G.BossesTable[bossName]["SGVFUB"]
    local TeamNumber = killer:GetTeamNumber()
    local TeamName = GetTeamName(TeamNumber)
    local Gold = _G.BossesTable[bossName]["gold"] + 600 * SGVFUB
    if Gold > 8000 then
      Gold = 8000
    end
    GameRules:SendCustomMessage("Команда " .. _G.TeamNames[TeamName] .. " убила босса (<font color='red'>" .._G.BossesTable[bossName]["name"] .. "</font>)",1,1)
    for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			if hero and not hero:IsNull() then
				if TeamNumber == hero:GetTeamNumber() and hero:IsRealHero() and hero:IsClone() == false then
					hero:AddExperience(_G.BossesTable[bossName]["xp"] * SGVFUB, DOTA_ModifyXP_CreepKill, false, false)
					hero:ModifyGold(Gold, false, DOTA_ModifyGold_CreepKill)
					SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, Gold, nil )
				end
			end
		end
    end
end

GIVE_BOOKS_INTERVAL = 120 
GIVE_BOOKS_START = 14
GIVE_BOOKS_ITEMS = {}
GIVE_BOOKS_ITEMS[1] = "item_shard_level_custom" 
GIVE_BOOKS_ITEMS[2] = "item_shard_str_small_custom"
GIVE_BOOKS_ITEMS[3] = "item_shard_int_small_custom"
GIVE_BOOKS_ITEMS[4] = "item_shard_agi_small_custom"

GIVE_BOOKS_DIFFERENCE = 0
GIVE_BOOKS_DIFFERENCE_FOR_ITEM = 0.5
GIVE_BOOKS_COUNT = 1
GIVE_BOOKS_MAX = 4

function GiveBooksThink()
	if GameRules:IsGamePaused() then
		return 0.1
	end

	if GameRules:GetDOTATime( false, false ) >= GIVE_BOOKS_START * 60 then
		local gold = {}
		local level = {}

		for p = 0, 63 do
			local player = PlayerResource:GetPlayer( p )
			if player and player:GetAssignedHero() then
				local hero = player:GetAssignedHero()
				local player_gold = PlayerResource:GetGoldPerMin( p ) * GameRules:GetDOTATime( false, false )
				local player_level = PlayerResource:GetLevel( p )
				local player_team = PlayerResource:GetTeam( p )

				if not gold[player_team] then gold[player_team] = 0 end
				gold[player_team] = gold[player_team] + player_gold

				if not level[player_team] then level[player_team] = 0 end
				level[player_team] = level[player_team] + player_level
			end
		end

		local advantage = {}

		for i = 2, 13 do
			if gold[i] and level[i] then
				advantage[i] = ( gold[i] / 5000 ) * ( level[i] / 50 )
			end
		end

		local losing_team
		local almost_losing_team

		for i = 2, 13 do
			if advantage[i] then
				if not losing_team then
					losing_team = i
				elseif advantage[losing_team] > advantage[i] then
					losing_team = i
				end
			end
		end
		for i = 2, 13 do
			if advantage[i] and i ~= losing_team then
				if not almost_losing_team then
					almost_losing_team = i
				elseif advantage[almost_losing_team] > advantage[i] then
					almost_losing_team = i
				end
			end
		end

		local difference = ( advantage[almost_losing_team] / advantage[losing_team] ) - 1

		if difference >= GIVE_BOOKS_DIFFERENCE then
			for p = 0, 63 do
				local player = PlayerResource:GetPlayer( p )
				if player and player:GetAssignedHero() and player:GetTeam() == losing_team then
					local hero = player:GetAssignedHero()

					local anime = math.floor( difference / GIVE_BOOKS_DIFFERENCE_FOR_ITEM )
					if anime > GIVE_BOOKS_MAX then anime = GIVE_BOOKS_MAX end
					for i = 1, anime do
						for c = 1, GIVE_BOOKS_COUNT do
							hero:AddItem( CreateItem( GIVE_BOOKS_ITEMS[RandomInt( 1, #GIVE_BOOKS_ITEMS )], hero, hero ) )
						end
					end
				end
			end
		end
	end

	return GIVE_BOOKS_INTERVAL
end
