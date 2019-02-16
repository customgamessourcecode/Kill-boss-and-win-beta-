if IsServer() and Duel == nil then

_G.Duel = {}

Duel.MAPS = {
	map5v5 = 5,
    map6v6 = 6,
}

Duel.INTERVAL = { 2, 300 }
Duel.DURATION = 90

Duel.DISTRIBUTION_XP_MULTIPLIER = 2

Duel.WINNER_REWARD = 1
Duel.LOOSER_REWARD = 0.5
Duel.DRAW_REWARD = 1

Duel.GOLD_REWARD = {}
Duel.GOLD_REWARD.TOTAL_GOLD_MULTIPLIER = 0.01
Duel.GOLD_REWARD.TOTAL_LEVEL_MULTIPLIER = 0
Duel.GOLD_REWARD.MINUTE_MULTIPLIER = 50

Duel.XP_REWARD = {}
Duel.XP_REWARD.TOTAL_GOLD_MULTIPLIER = 0
Duel.XP_REWARD.TOTAL_LEVEL_MULTIPLIER = 5
Duel.XP_REWARD.MINUTE_MULTIPLIER = 25

Duel.WIN_MSG = {
	[DOTA_TEAM_GOODGUYS] = "СИЛЫ СВЕТА ПОБЕДИЛИ",
	[DOTA_TEAM_BADGUYS] = "СИЛЫ ТЬМЫ ПОБЕДИЛИ",
	DRAW = "НИЧЬЯ"
}
Duel.FAIL_MSG = "НЕДОСТАТОЧНО ИГРОКОВ ДЛЯ ДУЭЛИ!!!"
Duel.WIN_MSG_TIME = 5

Duel.EXPLUSION_DIRECTION = {
	map5v5 = Vector( 0, -1, 0 ),
	map6v6 = Vector( 0, 1, 0 ),
}

Duel.PERMANENT_UNITS = {
	npc_dota_lone_druid_bear1 = true,
	npc_dota_lone_druid_bear2 = true,
	npc_dota_lone_druid_bear3 = true,
	npc_dota_lone_druid_bear4 = true,
	npc_dota_hero_meepo = true,
	npc_dota_brewmaster_earth_1 = true, 
    npc_dota_brewmaster_earth_2 = true, 
    npc_dota_brewmaster_earth_3 = true, 
	npc_dota_brewmaster_earth_4 = true,
	npc_dota_brewmaster_earth_5 = true,
	npc_dota_brewmaster_earth_6 = true,
	npc_dota_brewmaster_earth_7 = true,
    npc_dota_brewmaster_storm_1 = true, 
    npc_dota_brewmaster_storm_2 = true, 
    npc_dota_brewmaster_storm_3 = true, 
	npc_dota_brewmaster_storm_4 = true,
	npc_dota_brewmaster_storm_5 = true,
	npc_dota_brewmaster_storm_6 = true,
	npc_dota_brewmaster_storm_7 = true,
    npc_dota_brewmaster_fire_1 = true, 
    npc_dota_brewmaster_fire_2 = true, 
    npc_dota_brewmaster_fire_3 = true,
	npc_dota_brewmaster_fire_4 = true,
	npc_dota_brewmaster_fire_5 = true,
    npc_dota_brewmaster_fire_6 = true,
    npc_dota_brewmaster_fire_7 = true, 	
}

Duel.CHARGE_COUNTER_MODIFIERS = {
	modifier_ember_spirit_fire_remnant_charge_counter = 3,
	modifier_ember_spirit_sleight_of_fist_charge_counter = 2,
	modifier_earth_spirit_stone_caller_charge_counter = 5,
	modifier_shadow_demon_demonic_purge_charge_counter = 3,
	modifier_obsidian_destroyer_astral_imprisonment_charge_counter = 2,
	modifier_gyrocopter_homing_missile_charge_counter = 3,
	modifier_broodmother_spin_web_charge_counter = 1,
	modifier_sniper_shrapnel_charge_counter = 3,
	modifier_death_prophet_spirit_siphon_charge_counter = 3,
	modifier_bloodseeker_rupture_charge_counter = 2,
	modifier_vengefulspirit_nether_swap_charge_counter = 2,
	modifier_mirana_leap_charge_counter = 2,
	modifier_tiny_toss_charge_counter = 3,
}

Duel.PERMANENT_MODIFIERS = {
	modifier_ember_spirit_fire_remnant_timer = true,
	modifier_fountain_magical_resist = true,
	modifier_brewmaster_primal_split_duration = true, 
    modifier_brewmaster_primal_split_delay = true, 
    modifier_brewmaster_primal_split = true,
	modifier_bristleback_warpath = true, 
    modifier_bristleback_warpath_stack = true,
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Duel.number = 1
Duel.timer = 0
Duel.reward = { 0, 0 }
Duel.state = false
Duel.unrestricted = {}
Duel.loosers = {}
Duel.size = 0


function Duel:Init()
	local current_time = GameRules:GetDOTATime( false, false )
	local offset = 0
	Duel.timer = math.floor( Duel.INTERVAL[1] - current_time ) 
	GameRules:GetGameModeEntity():SetThink( function()
		local newtime = GameRules:GetDOTATime( false, false )
		if newtime - current_time + offset > 0.99 then
			offset = 1 - newtime + current_time
			current_time = newtime
			Duel:Think()
		end
		return 1/30
	end, "DuelThink" )
end

function Duel:Think()
	Duel.timer = Duel.timer - 1
	
	if Duel.state then
		local bEnd = true
		for i = 1, Duel.size do
			if Duel.loosers[i] == nil then
				bEnd = false
			end
		end
		if bEnd then
			Duel:_End()
		end
	end
	
	if Duel.timer == 0 then
		if Duel.state then
			Duel:_End()
		else
			Duel.state = true		
			Duel.timer = Duel.DURATION
			CustomGameEventManager:Send_ServerToAllClients( "show_newstring", { StringNeed = "Дуэль:    " } )
			Duel:Start()
		end
	end
	
	local minute = math.floor( Duel.timer / 60 )
	local second = Duel.timer - minute*60
	CustomGameEventManager:Send_ServerToAllClients( "countdownDuel", {
		timer_minute_10 = math.floor( minute / 10 ),
		timer_minute_01 = minute % 10,
		timer_second_10 = math.floor( second / 10 ),
		timer_second_01 = second % 10,
	} )
	if not Duel.state then
		Duel.reward = { Duel:GetGoldReward(), Duel:GetExpReward() }
		CustomGameEventManager:Send_ServerToAllClients( "show_dueltimer", {
			Gold = Duel.reward[1],
			Xp = Duel.reward[2]
		} )
	end
	return 1
end


function Duel:Start()

	local function resort_i_table( t )
		local t2 = {}
		local indexes = {}
		for i in pairs(t) do
			table.insert( indexes, i )
		end
		table.sort( indexes )
		for i, v in ipairs( indexes ) do
			t2[i] = t[v]
		end
		return t2
	end
	
	local cost_indexes = {}
	local function get_free_cost_index( cost )
		while cost_indexes[cost] do
			cost = cost + 1
		end
		cost_indexes[cost] = true
		return cost
	end
	
	local RadiantHeroes = {}
	local DireHeroes = {}
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			if hero and not hero:HasOwnerAbandoned() then
				local hero_cost = PlayerResource:GetTotalEarnedGold(i) + PlayerResource:GetTotalEarnedXP(i) * Duel.DISTRIBUTION_XP_MULTIPLIER
				hero_cost = get_free_cost_index( hero_cost )
				hero.hero_cost = hero_cost
				if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
					RadiantHeroes[ hero_cost ] = hero
				else
					DireHeroes[ hero_cost ] = hero
				end
			end
		end
	end
	
	RadiantHeroes = resort_i_table( RadiantHeroes )
	DireHeroes = resort_i_table( DireHeroes )
	local size = math.min( #RadiantHeroes, #DireHeroes )
	
	if size == 0 then
		Duel.state = false
		Duel.number = Duel.number + 1
		Duel.timer = Duel:GetInterval()
		CustomGameEventManager:Send_ServerToAllClients( "show_newstring", { StringNeed = "До дуэли:    " } )
		CustomGameEventManager:Send_ServerToAllClients( "show_whowin", { Who = Duel.FAIL_MSG, Time = Duel.WIN_MSG_TIME } )
		return
	end
	
	Duel.size = size
	
	
	local tPairs = {}
	if #DireHeroes == #RadiantHeroes then
		for i = 1, size do
			if i <= Duel.MAPS[ GetMapName() ] then
				tPairs[ RadiantHeroes[i] ] = DireHeroes[i]
			end
		end
	else
		if #DireHeroes > #RadiantHeroes then
			for i = 1, size do
				if i > Duel.MAPS[ GetMapName() ] then break end
				local hero1 = RadiantHeroes[i]
				local hero2
				local hero228
				local delta
				for j = 1, #DireHeroes do
					hero2 = DireHeroes[j]
					if hero2.duel_restricted == nil and ( delta == nil or math.abs( hero1.hero_cost - hero2.hero_cost ) < delta ) then
						delta = math.abs( hero1.hero_cost - hero2.hero_cost )
						tPairs[ hero1 ] = hero2
						if hero228 then hero228.duel_restricted = nil end
						hero2.duel_restricted = true
						hero228 = hero2
					end
				end
			end
		else
			for i = 1, size do
				if i > Duel.MAPS[ GetMapName() ] then break end
				local hero1 = DireHeroes[i]
				local hero2
				local hero228
				local delta
				for j = 1, #RadiantHeroes do
					hero2 = RadiantHeroes[j]
					if hero2.duel_restricted == nil and ( delta == nil or math.abs( hero1.hero_cost - hero2.hero_cost ) < delta) then
						delta = math.abs( hero1.hero_cost - hero2.hero_cost )
						tPairs[ hero1 ] = hero2
						if hero228 then hero228.duel_restricted = nil end
						hero2.duel_restricted = true
						hero228 = hero2
					end
				end
			end
		end
	end
	local i = 1
	for hero1, hero2 in pairs( tPairs ) do
		Duel:HeroStart( hero1, i, Entities:FindByName( nil, "arena" .. i .. "_1" ):GetOrigin(), hero2 )
		Duel:HeroStart( hero2, i, Entities:FindByName( nil, "arena" .. i .. "_2" ):GetOrigin(), hero1 )
		hero1.hero_cost = nil
		hero1.duel_restricted = nil
		hero2.hero_cost = nil
		hero2.duel_restricted = nil
		i = i + 1
	end
	
end

function Duel:HeroStart( hero, arena, position, enemy )
	local trigger = Entities:FindByName( nil, "Tarena" .. arena )
	
	local bDead = false
	if not hero:IsAlive() then
		hero:RespawnHero( false, false )
		bDead = true
	end
	hero:SetRespawnsDisabled( true )
	
	local modifiers = {}
	local unrefreshable = {}
	for _, mod in pairs( hero:FindAllModifiers() ) do
		if Duel.CHARGE_COUNTER_MODIFIERS[ mod:GetName() ] then
			unrefreshable[ mod:GetAbility() ] = true
		elseif not Duel.PERMANENT_MODIFIERS[ mod:GetName() ] and not ( mod.IsPermanent and mod:IsPermanent() ) and mod:GetRemainingTime() > 0 then
			table.insert( modifiers, { name = mod:GetName(), n = mod:GetStackCount(), dur = mod:GetRemainingTime(), caster = mod:GetCaster(), ability = mod:GetAbility() } )
			mod:Destroy()
		end
	end
	
	local cooldowns = {}
	for i = 0, hero:GetAbilityCount() - 1 do
		local ability = hero:GetAbilityByIndex(i)
		if ability and not ability:IsNull() and not unrefreshable[ ability ] then
			cooldowns[ ability ] = ability:GetCooldownTimeRemaining() or 0
			ability:EndCooldown()
		end
	end
	for i = 0, 8 do
		local item = hero:GetItemInSlot(i)
		if item and not item:IsNull() and not unrefreshable[ item ] then
			cooldowns[ item ] = item:GetCooldownTimeRemaining() or 0
			item:EndCooldown()
		end
	end
	
	local mod = hero:AddNewModifier( hero, nil, "modifier_duel", {} )
	mod.arena = arena
	mod.enemy = enemy
	mod.trigger = trigger
	mod.oldstate = {
		cooldowns = cooldowns,
		modifiers = modifiers,
		position = hero:GetOrigin(),
		hp = hero:GetHealthPercent() / 100,
		mp = hero:GetManaPercent() / 100,
		dead = bDead
	}
	mod:StartIntervalThink(1/30)
	
	FindClearSpaceForUnit( hero, position, true )
	
	Duel:Relocate( hero, false )
	hero:SetHealth( hero:GetMaxHealth() )
	hero:SetMana( hero:GetMaxMana() )
end


function Duel:_End()
	Duel.state = false
	Duel.number = Duel.number + 1
	Duel.timer = Duel:GetInterval()
	CustomGameEventManager:Send_ServerToAllClients( "show_newstring", { StringNeed = "До дуэли:    " } )
	Duel:End()
end

function Duel:End()
	
	local RadiantLoosers = 0
	local DireLoosers = 0
	for i = 1, Duel.MAPS[ GetMapName() ] do
		if Duel.loosers[i] == DOTA_TEAM_BADGUYS then
			DireLoosers = DireLoosers + 1
		elseif Duel.loosers[i] == DOTA_TEAM_GOODGUYS then
			RadiantLoosers = RadiantLoosers + 1
		end
	end
	
	if RadiantLoosers == DireLoosers then
		CustomGameEventManager:Send_ServerToAllClients( "show_whowin", { Who = Duel.WIN_MSG["DRAW"], Time = Duel.WIN_MSG_TIME } )
		for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if hero then
					Duel:HeroEnd( hero )
					hero:ModifyGold( Duel.reward[1] * Duel.DRAW_REWARD, true, DOTA_ModifyGold_HeroKill )
					hero:AddExperience( Duel.reward[2] * Duel.DRAW_REWARD, DOTA_ModifyXP_HeroKill, false, false )
				end
			end
		end
	else
		local winner = DOTA_TEAM_GOODGUYS
		if RadiantLoosers > DireLoosers then
			winner = DOTA_TEAM_BADGUYS
			CustomGameEventManager:Send_ServerToAllClients( "show_whowin", { Who = Duel.WIN_MSG[ winner ], Time = Duel.WIN_MSG_TIME } )
		else
			CustomGameEventManager:Send_ServerToAllClients( "show_whowin", { Who = Duel.WIN_MSG[ winner ], Time = Duel.WIN_MSG_TIME } )
		end
		for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if hero then
					Duel:HeroEnd( hero )
					if hero:GetTeam() == winner then
						hero:ModifyGold( Duel.reward[1] * Duel.WINNER_REWARD, true, DOTA_ModifyGold_HeroKill )
						hero:AddExperience( Duel.reward[2] * Duel.WINNER_REWARD, DOTA_ModifyXP_HeroKill, false, false )
					else
						hero:ModifyGold( Duel.reward[1] * Duel.LOOSER_REWARD, true, DOTA_ModifyGold_HeroKill )
						hero:AddExperience( Duel.reward[2] * Duel.LOOSER_REWARD, DOTA_ModifyXP_HeroKill, false, false )
					end
				end
			end
		end
	end
	
	Duel.unrestricted = {}
	Duel.loosers = {}
	Duel.size = 0
	
end

function Duel:HeroEnd( hero )

	local mod = hero:FindModifierByName("modifier_duel")
	if mod == nil then return end
	
	hero:SetRespawnsDisabled( false )
	if not hero:IsAlive() or mod.oldstate.dead then
		hero:RespawnHero( false, false )
	end
	
	if not mod.oldstate.dead then
		hero:SetHealth( math.max( 1, hero:GetMaxHealth() * mod.oldstate.hp ) )
		hero:SetMana( hero:GetMaxMana() * mod.oldstate.mp )
		FindClearSpaceForUnit( hero, mod.oldstate.position, true )
	end
	
	Duel:Relocate( hero, true )
	
	for ability, cooldown in pairs( mod.oldstate.cooldowns ) do
		if not ability:IsNull() then
			ability:EndCooldown()
			ability:StartCooldown( cooldown )
		end
	end
	
	for _, mod in pairs( hero:FindAllModifiers() ) do
		if not Duel.CHARGE_COUNTER_MODIFIERS[ mod:GetName() ] and not Duel.PERMANENT_MODIFIERS[ mod:GetName() ] and not ( mod.IsPermanent and mod:IsPermanent() ) and mod:GetRemainingTime() > 0 then
			mod:Destroy()
		end
	end
	for _, info in pairs( mod.oldstate.modifiers ) do
    local mod = hero:AddNewModifier( info.caster, info.ability, info.name, { duration = info.dur } ) 
    if mod then 
      mod:SetStackCount( info.n ) 
    end
	end
	
	mod:Destroy()
	
end


function Duel:GetInterval()
	return Duel.INTERVAL[ math.min( Duel.number, #Duel.INTERVAL ) ]
end

function Duel:GetGoldReward()
	local gold, level, minute = Duel:GetRewardParams()
	return math.floor( gold * Duel.GOLD_REWARD.TOTAL_GOLD_MULTIPLIER + level * Duel.GOLD_REWARD.TOTAL_LEVEL_MULTIPLIER + minute * Duel.GOLD_REWARD.MINUTE_MULTIPLIER )
end

function Duel:GetExpReward()
	local gold, level, minute = Duel:GetRewardParams()
	return math.floor( gold * Duel.XP_REWARD.TOTAL_GOLD_MULTIPLIER + level * Duel.XP_REWARD.TOTAL_LEVEL_MULTIPLIER + minute * Duel.XP_REWARD.MINUTE_MULTIPLIER )
end

function Duel:GetRewardParams()
	local gold = 600
	local level = 0
	local minute = GameRules:GetDOTATime( false, false )
	local p_count = 0
	for i = 0, 9 do
		if PlayerResource:IsValidPlayerID(i) then
			gold = gold + PlayerResource:GetTotalEarnedGold(i)
			level = level + PlayerResource:GetLevel(i)
			p_count = p_count + 1
		end
	end
	return gold / p_count, level / p_count, math.floor( minute / 60 )
end

function Duel:Relocate( hero, bKillSummons )
	ProjectileManager:ProjectileDodge( hero )
	hero:Interrupt()
	PlayerResource:SetCameraTarget( hero:GetPlayerOwnerID(), hero )
	hero:SetThink( function() PlayerResource:SetCameraTarget( hero:GetPlayerOwnerID(), nil ) end, "cam_distarget", 0.5 )
	
	local units =  FindUnitsInRadius( hero:GetTeam(), Vector(0,0,0), nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 0, false )
	for _, unit in pairs(units) do
		if unit:GetPlayerOwnerID() == hero:GetPlayerOwnerID() and unit ~= hero then
			if Duel.PERMANENT_UNITS[ unit:GetUnitName() ] then
				ProjectileManager:ProjectileDodge( unit )
				unit:Interrupt()
				for _, mod in pairs( unit:FindAllModifiers() ) do
					if not ( mod.IsPermanent and mod:IsPermanent() ) and mod:GetRemainingTime() > 0 then
						mod:Destroy()
					end
				end
				if unit.oldstate_arena and bKillSummons then
					unit:SetMana( unit.oldstate_arena.mp * unit:GetMaxMana() )
					unit:SetHealth( math.max( 1, unit.oldstate_arena.hp * unit:GetMaxHealth() ) )
					FindClearSpaceForUnit( unit, unit.oldstate_arena.pos, true )
					unit.oldstate_arena = nil
				else
					if not bKillSummons then
						unit.oldstate_arena = {
							mp = unit:GetManaPercent() / 100,
							hp = unit:GetHealthPercent() / 100,
							pos = unit:GetOrigin()
						}
					end
					FindClearSpaceForUnit( unit, hero:GetOrigin(), true )
					unit:SetMana( unit:GetMaxMana() )
					unit:SetHealth( unit:GetMaxHealth() )
				end
			else
				if bKillSummons then
					if unit.bNotArenaSummon == nil then
						unit:ForceKill(false)
					end
				else
					unit.bNotArenaSummon = true
				end
			end
		end
	end
end


function DropUnitFromArena( kv )
	local owner = kv.activator:GetPlayerOwner()
	owner = owner and owner:GetAssignedHero()
	if owner == nil or owner:IsNull() or owner:HasModifier("modifier_duel") then return end
	if not kv.caller:IsTouching( kv.activator ) then return end
	
	local vDir = Duel.EXPLUSION_DIRECTION[ GetMapName() ]
	if vDir == nil then return end
	local bounds = kv.caller:GetBoundingMaxs()
	local vPos = kv.activator:GetOrigin()
	
	if vDir.x == 0 then
		vPos.y = kv.caller:GetOrigin().y + vDir.y * ( bounds.y + 128 )
	else
		vPos.x = kv.caller:GetOrigin().x + vDir.x * ( bounds.x + 128 )
	end
	
	FindClearSpaceForUnit( kv.activator, vPos, true )
end

end



LinkLuaModifier( "modifier_duel", "duel", 0 )
modifier_duel = class{}

function modifier_duel:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_duel:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_duel:OnIntervalThink()
	local Maxs = self.trigger:GetBoundingMaxs() + self.trigger:GetOrigin()
	local Mins = self.trigger:GetBoundingMins() + self.trigger:GetOrigin()
	local origin = self:GetParent():GetOrigin()
	local bUpdate = false
	if origin.x > Maxs.x then
		origin.x = Maxs.x - 64
		bUpdate = true
	end
	if origin.x < Mins.x then
		origin.x = Mins.x + 64
		bUpdate = true
	end
	if origin.y > Maxs.y then
		origin.y = Maxs.y - 64
		bUpdate = true
	end
	if origin.y < Mins.y then
		origin.y = Mins.y + 64
		bUpdate = true
	end
	if bUpdate then
		FindClearSpaceForUnit( self:GetParent(), origin, true )
	end
	local fountain_aura = self:GetParent():FindModifierByName("modifier_fountain_aura_buff")
	if fountain_aura and not fountain_aura:IsNull() then
		fountain_aura:Destroy()
	end
end

function modifier_duel:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end

function modifier_duel:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_duel:GetModifierIncomingDamage_Percentage(kv)
	if kv.attacker == nil or kv.attacker:IsNull() then return end
	if kv.attacker:GetPlayerOwner() == self.enemy:GetPlayerOwner() or kv.attacker:GetPlayerOwner() == self:GetParent():GetPlayerOwner() then
		return 0
	end
	return -100
end

function modifier_duel:OnDeath(kv)
	if kv.unit == self:GetParent() or ( kv.unit:GetUnitName() == "npc_dota_hero_meepo" and kv.unit:GetPlayerOwnerID() == self:GetParent():GetPlayerOwnerID() ) then
		if self:GetParent():IsReincarnating() then 
			self:GetParent():SetRespawnsDisabled( false )
			return
		end
		self:GetParent():SetRespawnsDisabled( true )
		if Duel.loosers[ self.arena ] == nil then
			Duel.loosers[ self.arena ] = self:GetParent():GetTeam()
		else
			Duel.loosers[ self.arena ] = false
		end
	end
end