----------------
----------------

if not spawners then
	spawners = class({})
end
self = spawners
function spawners:Init()
	self.kv = LoadKeyValues("scripts/kv/spawners.txt")
	if not self.kv or not self.kv.spawnerssettings then return end
	self.cached = {}
	self.spawners = {}
	ListenToGameEvent("entity_killed",Dynamic_Wrap(self,'OnUnitKilled' ),self)
	ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(self,'OnGameRulesStateChange'),self)
end
function spawners:InitSpawners()
	if not self.kv.spawnerssettings then return end
	for spawnname,t in pairs(self.kv.spawnerssettings) do
		self.spawners[spawnname] = self.spawners[spawnname] or {}
		self.spawners[spawnname].upgrade = self.spawners[spawnname].upgrade or t.leveltimer or self.kv.leveltimer
		self.spawners[spawnname].level = self.spawners[spawnname].level or 0
		self.spawners[spawnname].respawntime = self.spawners[spawnname].respawntime or t.respawntime or self.kv.respawntime
		local s = Entities:FindAllByName(spawnname)
		for __,spawner in ipairs(s) do
			table.insert(self.spawners[spawnname],spawner)
			spawner.creeps = 0
		end
	end
end
function spawners:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:InitSpawners()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:Start()
	end
end
function spawners:Start()
	local time = 0
	Timers(function()
		for k,v in pairs(self.spawners) do
			if time % v.upgrade == 0 then
				v.level = v.level + 1
			end
			if time % v.respawntime == 0 then
				spawners:SpawnCreepsOnSpawner(k)
			end
		end
		time = time + 1
		return 1
	end)
end
function spawners:SpawnCreepsOnSpawner(spawnername)
	local table = self.spawners[spawnername]
	local t = self.kv.spawnerssettings[spawnername]
	if t then
		for _,spawner in ipairs(table) do
			local current = spawner.creeps
			local max = t.maxcreepsonstack or self.kv.maxcreepsonstack
			local creepsspawned = t.spawnspertick or self.kv.spawnspertick
			if creepsspawned > max - current then creepsspawned = max - current end
			if creepsspawned > 0 then
				for i=1,creepsspawned do
					self:SpawnCreep(spawner,t)
				end
			end
		end
	end
end
function spawners:SpawnCreep(spawner,t)
	local creeptable = t.creepstable
	local creeps = creeptable[tostring(self.spawners[spawner:GetName()].level)] or creeptable[tostring(length(creeptable))]
	local rand = RandomInt(1,length(creeps))
	local abs = spawner:GetOrigin()
	local creep = creeps[tostring(rand)]
	if not self.cached[creep] then
		PrecacheUnitByNameAsync(creep,function()
			self.cached[creep] = true
			self:SpawnCreep(spawner,t)
		end)
		return
	end
	CreateUnitByNameAsync(creep,abs+RandomVector(RandomInt(0,150)),true,nil,nil,DOTA_TEAM_NEUTRALS,
	function(unit)
		unit.spawner = spawner:entindex()
		spawner.creeps = spawner.creeps + 1
    	unit:SetAngles(0,RandomInt(0,360),0)
	end)
end
function spawners:OnUnitKilled(t)
    local unit = EntIndexToHScript( t.entindex_killed )
    if unit.spawner then
    	local spawn = EntIndexToHScript(unit.spawner)
		spawn.creeps = spawn.creeps - 1
	end
end
function length(t)
	local l = 0
	for k,v in pairs(t) do
		l = l+1
	end
	return l
end
self:Init()