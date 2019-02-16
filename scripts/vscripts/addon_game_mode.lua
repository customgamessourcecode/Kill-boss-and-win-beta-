LinkLuaModifier( "modifier_admin", "modifiers/modifier_admin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vip", "modifiers/modifier_vip", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sponsor", "modifiers/modifier_sponsor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_arcana", "modifiers/modifier_never_arcana", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rainbow", "modifiers/modifier_rainbow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_physical_damage_override", 0 )
LinkLuaModifier( "modifier_physical_damage_override_gamemode", "modifier_physical_damage_override", 0 )

require('internal/util')
require('gamemode')
require('lib/magic_lifesteal')
require('spawners')
require('console')
require('boss/bosses')
require('donation')
require('reklama')
require('filters')
require('runes')
require('duel')

_G.ReflectDamagePercentage = { 
boss_warloc = 40,
boss = 25,
boss_druid = 20,
boss_trent = 60,
npc_dota_roshan = 25,
} 

_G.ReflectorAbilities = { 
item_blade_mail = 0, 
bloodseeker_rupture = 0,
necrolyte_reapers_scythe = 2,
enigma_black_hole = 0,
undying_flesh_golem = 0,
doom_bringer_infernal_blade = 0,
}

_G.PlayerPersonalCouriers = {}
_G.PersonalCouriersMaps = {
	dota = true,
	map5v5 = true,
	map6v6 = true,
	map6v6noduel = true,
	map5v5noduel = true
}

_G.HeroDisplayNames = LoadKeyValues("scripts/npc/hero_names.txt")
_G.IsCustomIllusionSpawned = 0

_G.PlayerColors = {
[0] = "1f5fff",
"ff7fff",
"ffffff",
"ffffff",
"ffffff",
"ffffff",
"ffffff",
"ffffff",
"ffffff",
"ffffff"
}
if GetMapName() == "map5v5" then
_G.PlayerColors = {
[0] = "1f5fff",
"7fffbf",
"ff00ff",
"ffff00",
"ff7f00",
"ffffff",
"ff7fff",
"bfff7f",
"6fcfcf",
"007f00",
"7f3f00",
"ffffff"
}
elseif GetMapName() == "template_map" then
_G.PlayerColors = {
[0] = "1f5fff",
"7fffbf",
"ff00ff",
"ffff00",
"ff7f00",
"ff7fff",
"bfff7f",
"6fcfcf",
"007f00",
"7f3f00"
}
end

function Precache( context )

  PrecacheResource( "particle", "particles/kiteffects/god.vpcf", context)
  PrecacheResource( "particle", "particles/kiteffects/god_st_effect.vpcf", context)
  PrecacheResource( "particle", "particles/kiteffects/vip.vpcf", context)
  PrecacheResource( "particle", "particles/kiteffects/vvip.vpcf", context)
  PrecacheResource( "particle", "particles/kiteffects/svip_full.vpcf", context)
  PrecacheResource( "particle", "particles/newplayer_fx/npx_landslide_debris.vpcf", context )
  PrecacheResource( "particle", "particles/sponsor/sponsor_effect.vpcf", context )
  PrecacheResource( "particle", "particles/sponsor/templar_assassin_refraction.vpcf", context )
  PrecacheResource( "particle", "particles/vip/vip_effect.vpcf", context )
  PrecacheResource( "particle", "particles/vip_gold.vpcf", context )
  PrecacheResource( "particle", "particles/premium/premium_effect.vpcf", context )
  PrecacheResource( "particle", "particles/gob/gob_effect.vpcf", context )
  PrecacheResource( "soundfile", "soundevents/totem.vsndevts", context )
  PrecacheResource("particle", "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf" , context)
  PrecacheResource("particle", "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf" , context)

  DebugPrint("[BAREBONES] Performing pre-load precache")

  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)

  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)

  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
end

function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end
