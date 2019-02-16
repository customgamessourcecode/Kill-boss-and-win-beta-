local Pets = {
	"unit_premium_pet",
	"unit_premium_pet2",
	"unit_premium_pet3",
	"unit_premium_pet4",
	"unit_premium_pet5"
}
local SuperPets = {
	"unit_premium_pet6",
	"unit_premium_pet7",
	"unit_premium_pet8",
	"unit_premium_pet9",
	"unit_premium_pet10"
}
local RodorPet = {
    "petrodor"
}
local DoomPet = {
    "doompet"
}
local PlayersWithPets = {
	[201292507] = true,
	[324462062] = true,
	[408491440] = true,
	[97545412] = true,
	[241369394] = true,
	[413326993] = true,
	[886431389] = true,
	[355338135] = true,
	[26966141] = true,
	[70244638] = true,
	[247243065] = true,
	[439453370] = true,
	[869091555] = true,
	[867959699] = true,
	[347624347] = true,
	[837843988] = true,
	[355504658] = true
}
local PlayersWithSuperPets = {
    [376414229] = true
}
local RodorWithPet = {
    [259596687] = true,
	[148706827] = true,
	[247243065] = true,
	[217577393] = true
}
local DoomWithPet = {
    [327070922] = true,
	[259133332] = true,
	[180067831] = true
}
local PlayersWithCustomEffect = {
	[259596687] = 'admin',	
	[355504658] = 'vip',
	[148706827] = 'vip',
	[837843988] = 'admin',
	[837843988] = 'sponcor',
	[148706827] = 'admin',
	[327070922] = 'sponcor',
	[327070922] = 'vip',
	[361243100] = 'admin',
	[448936694] = 'pro',
	[53671783] = 'pro',
	[369284252] = 'pro',
	[372886755] = 'pro',
	[148706827] = 'sponcor',
	[887087100] = 'sponcor',
	[201292507] = 'sponcor',
	[875896422] = 'sponcor',
    [201292507] = 'halo',
	[97545412] = 'mega',
	[355578211] = 'halo',
	[97545412] = 'admin',
	[42706663] = 'vip',
	[179214531] = 'sponcor',
	[293220875] = 'pro',
	[259133332] = 'vip',
	[259133332] = 'admin',
	[324462062] = 'pro',
	[867959699] = 'pro',
	[324462062] = 'mega',
	[910251838] = 'sponcor',
	[910251838] = 'mega',
	[875925994] = 'halo',
	[347624347] = 'mega',
	[376414229] = 'mega',
	[875925994] = 'sponcor',
	[132237176] = 'vip',
	[241369394] = 'pro',
	[259133332] = 'halo',
	[90136697] = 'pro',
	[869091555] = 'pro',
	[265131980] = 'vip',
	[901767542] = 'vip',
	[341908728] = 'pro',
	[265131980] = 'sponcor',
	[398181367] = 'halo',
	[308803921] = 'pro',
	[313189048] = 'halo',
	[26966141] = 'mega',
	[292225202] = 'halo',
	[313189048] = 'pro',
	[269411444] = 'vip',
	[379271640] = 'pro',
	[178716609] = 'mega',
	[396174509] = 'vip',
	[168787681] = 'pro',
	[70244638] = 'mega',
	[70244638] = 'halo',
	[439453370] = 'mega',
	[336061840] = 'mega',
	[439453370] = 'sponcor',
	[362803015] = 'pro',
	[321904551] = 'admin',
	[199757798] = 'pro',
	[844552970] = 'sponcor',
	[180067831] = 'admin',
	[247243065] = 'mega',
	[118097576] = 'sponcor',
	[130487297] = 'pro',
	[244642824] = 'halo'
}
local PayersWithModifiers = {
	[97545412] = true,
	[201292507] = 'centaur'
}
_G.PersonalWithFreeCourier = {
	[259596687] = true,
	[247243065] = true
}
_G.PersonalWithCourier = {
    [247243065] = "NIAN",
	[259596687] = "NIAN",
	[376414229] = "DARK_MOON_BABY_ROSHAN",
	[201292507] = "GOLDEN_BABY_ROSHAN",
	[213416921] = "DESERT_BABY_ROSHAN",
	[148706827] = "DARK_MOON_BABY_ROSHAN",
	[118097576] = "LAVA_BABY_ROSHAN",
	[228322778] = {
		model = "models/courier/donkey_unicorn/donkey_unicorn.vmdl",
		fly = {
			model = "models/courier/donkey_ti7/donkey_ti7_flying.vmdl",
			scale = 1.6,
			particle = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
		}
	}
}
PersonalWithCourier.Models = {
	BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan.vmdl",
		fly = "models/courier/baby_rosh/babyroshan_flying.vmdl"
	},
	GOLDEN_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan.vmdl",
		material = "1",
		particle = "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf",
		fly = "GOLDEN_BABY_ROSHAN_FLY"
	},
	GOLDEN_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_flying.vmdl",
		material = "1",
		particle = "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf"
	},
	PLATINUM_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan.vmdl",
		material = "2",
		particle = "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf",
		fly = "PLATINUM_BABY_ROSHAN_FLY"
	},
	PLATINUM_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_flying.vmdl",
		material = "2",
		particle = "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf"
	},
	DARK_MOON_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan.vmdl",
		material = "3",
		particle = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf",
		fly = "DARK_MOON_BABY_ROSHAN_FLY"
	},
	DARK_MOON_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_flying.vmdl",
		particle = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_flying.vpcf",
		material = "3"
	},
	DESERT_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan.vmdl",
		material = "4",
		particle = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf",
		fly = "DESERT_BABY_ROSHAN_FLY"
	},
	DESERT_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_flying.vmdl",
		material = "4",
		particle = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying.vpcf"
	},
	JADE_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan.vmdl",
		material = "5",
		particle = "particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8.vpcf",
		fly = "JADE_BABY_ROSHAN_FLY"
	},
	JADE_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_flying.vmdl",
		material = "5",
		particle = "particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8_flying.vpcf"
	},
	LAVA_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan_elemental.vmdl",
		material = "1",
		particle = "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf",
		fly = "LAVA_BABY_ROSHAN_FLY"
	},
	LAVA_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_elemental_flying.vmdl",
		material = "1",
		particle = "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf"
	},
	ICE_BABY_ROSHAN = {
		model = "models/courier/baby_rosh/babyroshan_elemental.vmdl",
		material = "2",
		particle = "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf",
		fly = "ICE_BABY_ROSHAN_FLY"
	},
	ICE_BABY_ROSHAN_FLY = {
		model = "models/courier/baby_rosh/babyroshan_elemental_flying.vmdl",
		material = "2",
		particle = "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf"
	},
	GOLDEN_ROOSHAN_TEST = {
		model = "models/creeps/roshan/roshan.vmdl",
		material = "1",
		scale = 0.36,
		fly = "GOLDEN_ROOSHAN_TEST"
	},
	GINGER_BREAD_BABY_ROSHAN = {
	    model = "models/courier/baby_rosh/babyroshan_winter18.vmdl",
	    particle = "particles/econ/courier/courier_babyroshan_winter18/courier_babyroshan_winter18_ambient.vpcf",
		fly = "GINGER_BREAD_BABY_ROSHAN_FLY",
	},
	GINGER_BREAD_BABY_ROSHAN_FLY = {
	    model = "models/courier/baby_rosh/babyroshan_winter18_flying.vmdl",
	    particle = "particles/econ/courier/courier_babyroshan_winter18/courier_babyroshan_winter18_ambient.vpcf",
	},	
	NIAN = {
	    model = "models/items/courier/nian_courier/nian_courier.vmdl",
	    particle = "particles/econ/courier/courier_nian/courier_nian_ambient.vpcf",
		fly = "NIAN_FLY",
	},	
	NIAN_FLY = {
	    model = "models/items/courier/nian_courier/nian_courier_flying.vmdl",
	    particle = "particles/econ/courier/courier_nian/courier_nian_ambient.vpcf",
	}		
}
local EffectPresets = {
	default = 'particles/rainbow.vpcf',
	sponcor = {
	{effect='particles/sponsor/sponsor_effect.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW},
	{effect='particles/sponsor/templar_assassin_refraction.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW}
	},
	vip = {
	{effect='particles/vip/vip_effect.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW},
	{effect='particles/vip_gold.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW}
	},
	mega = {
	{effect='particles/gob/gob_effect.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW},
	{effect='particles/sponsor/sponsor_effect.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW},
	{effect='particles/vip/vip_effect.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW}
	},
	rodor = {
	{effect='particles/gob/overhead_runes.vpcf_c',attachtype = PATTACH_ABSORIGIN_FOLLOW}
	},
	admin = {
	{effect='particles/premium/premium_effect.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW},
	{effect='particles/vip_gold.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW}
	},
	pro = {
		{effect='particles/rainbow.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW},
		{effect='particles/econ/events/ti7/ti7_hero_effect.vpcf'}
	},
	halo = {
		{effect='particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings.vpcf',attachtype = PATTACH_ABSORIGIN_FOLLOW,
			oncreated = function(hero,partid)
		        ParticleManager:SetParticleControlEnt(partid, 5, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), true)
			end
		},
		{effect='particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light.vpcf',attachtype = PATTACH_POINT_FOLLOW,
			oncreated = function(hero,partid)
				ParticleManager:SetParticleControlEnt(partid,1,hero,PATTACH_POINT_FOLLOW,"attach_attack1",hero:GetAbsOrigin(),true)
				ParticleManager:SetParticleControlEnt(partid,2,hero,PATTACH_POINT_FOLLOW,"attach_attack1",hero:GetAbsOrigin(),true)
			end
		},
		{effect='particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light.vpcf',attachtype = PATTACH_POINT_FOLLOW,
			oncreated = function(hero,partid)
				ParticleManager:SetParticleControlEnt(partid,1,hero,PATTACH_POINT_FOLLOW,"attach_attack2",hero:GetAbsOrigin(),true)
				ParticleManager:SetParticleControlEnt(partid,2,hero,PATTACH_POINT_FOLLOW,"attach_attack2",hero:GetAbsOrigin(),true)
			end
		}
	}
}
local ModifiersPresets = {
	default = 'modifier_rainbow',
	onlysven = {{triggerhero='npc_dota_hero_sven',mod='modifier_rainbow'}},
	centaur = {{triggerhero='npc_dota_hero_ursa',mod='modifier_rainbow'}},
	test = 'modifier_god_donate'
}
if not donation then
	donation = class({})
end
function donation:Init()
	ListenToGameEvent("dota_player_pick_hero",Dynamic_Wrap(self,'OnHeroPicked'),self)
	ListenToGameEvent("npc_spawned",Dynamic_Wrap(self,'OnNPCSpawned'),self)
    ListenToGameEvent("entity_killed",Dynamic_Wrap(self,'OnNPCKilled'),self)
end
function donation:OnHeroPicked(t)
    local hero = EntIndexToHScript(t.heroindex)
    local playerowner = hero:GetPlayerOwner()
    local playerownerid = hero:GetPlayerOwnerID()
    local steam_id = PlayerResource:GetSteamAccountID(playerownerid)
	if IsCustomIllusionSpawned > 0 then
      _G.IsCustomIllusionSpawned = IsCustomIllusionSpawned - 1
      return
    end
	if hero.pet_registred then return end
    if not steam_id then return end
	hero.pet_registred = true
    if PlayersWithPets[steam_id] then
    	local rand = RandomInt(1,#Pets)
    	local abs = hero:GetOrigin()
    	CreateUnitByNameAsync(Pets[rand],abs+RandomVector(RandomFloat(0,100)),true,hero,hero,hero:GetTeam(),function(pet)
    		pet:SetOwner(hero)
    	end)
	end
    if PlayersWithSuperPets[steam_id] then
    	local rand = RandomInt(1,#SuperPets)
    	local abs = hero:GetOrigin()
    	CreateUnitByNameAsync(SuperPets[rand],abs+RandomVector(RandomFloat(0,100)),true,hero,hero,hero:GetTeam(),function(pet)
    		pet:SetOwner(hero)
    	end)
	end	
    if RodorWithPet[steam_id] then
    	local rand = RandomInt(1,#RodorPet)
    	local abs = hero:GetOrigin()
    	CreateUnitByNameAsync(RodorPet[rand],abs+RandomVector(RandomFloat(0,100)),true,hero,hero,hero:GetTeam(),function(pet)
    		pet:SetOwner(hero)
        pet:SetMaterialGroup "4"
        ParticleManager:CreateParticle( "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, pet )		
    	end)
	end	
    if DoomWithPet[steam_id] then
    	local rand = RandomInt(1,#DoomPet)
    	local abs = hero:GetOrigin()
    	CreateUnitByNameAsync(DoomPet[rand],abs+RandomVector(RandomFloat(0,100)),true,hero,hero,hero:GetTeam(),function(pet)
    		pet:SetOwner(hero)
        pet:SetMaterialGroup "1"
        ParticleManager:CreateParticle( "particles/econ/courier/courier_golden_doomling/courier_golden_doomling_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, pet )				
    	end)
	end		
	if PayersWithModifiers[steam_id] then
    	local var = PayersWithModifiers[steam_id]
    	if PayersWithModifiers[steam_id] == true then
    		var = ModifiersPresets.default
    	end
    	if type(var) == "string" then
    		if ModifiersPresets[var] then
    			var = ModifiersPresets[var]
    			if type(var) == "string" then
    				hero:AddNewModifier(hero,nil,var,{})
    			end
    		else
				hero:AddNewModifier(hero,nil,var,{})
    		end
    	end
		if type(var) == "table" then
    		for i,v in ipairs(var) do
    			if type(v) == "table" then
    				if v.triggerhero and hero:GetClassname() == v.triggerhero then
    					hero:AddNewModifier(hero,nil,v.mod,{})
    				elseif not v.triggerhero then
    					hero:AddNewModifier(hero,nil,v.mod,{})
    				end
				elseif type(v) == 'string' then
    				hero:AddNewModifier(hero,nil,var,{})
				end
    		end
    	end
	end
end
function donation:OnNPCSpawned(t)
	local hero = EntIndexToHScript(t.entindex)
	if hero:IsRealHero() and IsCustomIllusionSpawned == 0 then
	    local playerownerid = hero:GetPlayerOwnerID()
	    local steam_id = PlayerResource:GetSteamAccountID(playerownerid)
	    if not steam_id then return end
		if not hero.firstspawn then
			hero.firstspawn = true
		end
		if PlayersWithCustomEffect[steam_id] then
	    	hero.effects = hero.effects or {}
	    	local var = PlayersWithCustomEffect[steam_id]
	    	if PlayersWithCustomEffect[steam_id] == true then
	    		var = EffectPresets.default
	    	end
	    	if type(var) == "string" then
	    		if EffectPresets[var] then
	    			var = EffectPresets[var]
	    			if type(var) == "string" then
	    				table.insert(hero.effects,ParticleManager:CreateParticle(var,PATTACH_ABSORIGIN_FOLLOW,hero))
	    			end
	    		else
	    			table.insert(hero.effects,ParticleManager:CreateParticle(var,PATTACH_ABSORIGIN_FOLLOW,hero))
	    		end
	    	end
    		if type(var) == "table" then
	    		for i,v in ipairs(var) do
	    			if type(v) == "table" then
	    				local part = ParticleManager:CreateParticle(v.effect,v.attachtype or PATTACH_ABSORIGIN_FOLLOW,hero)
	    				if v.oncreated then
	    					v.oncreated(hero,part)
	    				end
	    				table.insert(hero.effects,part)
    				elseif type(v) == 'string' then
    					table.insert(hero.effects,ParticleManager:CreateParticle(v,PATTACH_ABSORIGIN_FOLLOW,hero))
    				end
	    		end
	    	end
	    end
	end
	if hero:IsRealHero() then
		local steamID = PlayerResource:GetSteamAccountID( hero:GetPlayerID() )
		if PersonalWithFreeCourier[ steamID ] then
			PersonalWithFreeCourier[ steamID ] = false
			PlayerPersonalCouriers[ hero:GetPlayerID() ] = false
			hero:SetThink( function() hero:AddItemByName("item_personal_courier") end, "initial_timed_courier_activator", 1 + math.random() * 3 )
		end
	end	
end
function donation:OnNPCKilled(t)
    local hero = EntIndexToHScript( t.entindex_killed )
    if hero.effects then
		for i,v in ipairs(hero.effects) do
			ParticleManager:DestroyParticle(v,false)
			table.remove(hero.effects,i)
		end
	end
end
donation:Init()
