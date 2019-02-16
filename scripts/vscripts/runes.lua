--########################################################################
-- НАСТРОЙКИ
--########################################################################

USE_CUSTOM_RUNE_BEHAVIOR = true --использовать кастомные бонусы для всех рун, кроме баунти

--------------------------------------
-- BOUNTY RUNE
BOUNTY_CUSTOM = {}
BOUNTY_CUSTOM.player_number = 0 --не менять
BOUNTY_CUSTOM.player_count = 0 --не менять
BOUNTY_CUSTOM.USE_CUSTOM_BEHAVIOR = true -- использовать кастомные бонусы за баунти руны
BOUNTY_CUSTOM.GOLD_BASE = 50 -- Бонус на нулевой секунде и раньше
BOUNTY_CUSTOM.GOLD_INC = 28/60 -- Увеличение бонуса за каждую секунду
BOUNTY_CUSTOM.XP_BASE = 100
BOUNTY_CUSTOM.XP_INC = 100/60
---------------------------------------

---------------------------------------
-- DAMAGE RUNE
DAMAGE_CUSTOM = {}
DAMAGE_CUSTOM.DURATION = 30 -- Длительность эффекта
DAMAGE_CUSTOM.DAMAGE_BASE = 100 -- Бонусный урон в процентах
DAMAGE_CUSTOM.DAMAGE_INC = 5/75 -- (+600% в минуту)
---------------------------------------

---------------------------------------
-- HASTE RUNE
HASTE_CUSTOM = {}
HASTE_CUSTOM.DURATION = 30
HASTE_CUSTOM.SPEED_BASE = 425
HASTE_CUSTOM.SPEED_INC = 4/60
---------------------------------------

---------------------------------------
-- ILLUSION RUNE
ILLUSION_CUSTOM = {}
ILLUSION_CUSTOM.DURATION = 60
ILLUSION_CUSTOM.COUNT_BASE = 1 -- Начальное количество иллюзий
ILLUSION_CUSTOM.COUNT_INC_SEC = 600 -- Количество секунд, через которое будет добавляться иллюзия
ILLUSION_CUSTOM.COUNT_LIMIT = 4 -- Максимальное количество иллюзий
ILLUSION_CUSTOM.DAMGE_INCOMING = 200 -- Урон по иллюзии
ILLUSION_CUSTOM.DAMGE_OUTGOING = 50 -- Урон иллюзии
---------------------------------------

--#########################################################################
-- ТЕХНИЧЕСКИЙ КОД
--#########################################################################
if IsServer() then

_G.RuneColors = {
	[DOTA_RUNE_DOUBLEDAMAGE] = "3f7fff",
	[DOTA_RUNE_HASTE] = "ff0000",
	[DOTA_RUNE_ILLUSION] = "ffdf00",
	[DOTA_RUNE_INVISIBILITY] = "3f7f00",
	[DOTA_RUNE_REGENERATION] = "00ff00",
	[DOTA_RUNE_BOUNTY] = "ffbf00",
	[DOTA_RUNE_ARCANE] = "ff00bf",
}
_G.RuneNames = {
	[DOTA_RUNE_DOUBLEDAMAGE] = "Double Damage",
	[DOTA_RUNE_HASTE] = "Haste",
	[DOTA_RUNE_ILLUSION] = "Illusion",
	[DOTA_RUNE_INVISIBILITY] = "Invisibility",
	[DOTA_RUNE_REGENERATION] = "Regeneration",
	[DOTA_RUNE_BOUNTY] = "Bounty",
	[DOTA_RUNE_ARCANE] = "Arcane",
}

_G.RuneSimbols = {
	[DOTA_RUNE_DOUBLEDAMAGE] = "",
	[DOTA_RUNE_HASTE] = "",
	[DOTA_RUNE_ILLUSION] = "",
	[DOTA_RUNE_INVISIBILITY] = "",
	[DOTA_RUNE_REGENERATION] = "",
	[DOTA_RUNE_BOUNTY] = "",
	[DOTA_RUNE_ARCANE] = "",
}

function GetRuneType( rune )
	local tModelToRuneType = {
		["models/props_gameplay/rune_doubledamage01.vmdl"] = DOTA_RUNE_DOUBLEDAMAGE,
		["models/props_gameplay/rune_haste01.vmdl"] = DOTA_RUNE_HASTE,
		["models/props_gameplay/rune_illusion01.vmdl"] = DOTA_RUNE_ILLUSION,
		["models/props_gameplay/rune_invisibility01.vmdl"] = DOTA_RUNE_INVISIBILITY,
		["models/props_gameplay/rune_regeneration01.vmdl"] = DOTA_RUNE_REGENERATION,
		["models/props_gameplay/rune_goldxp.vmdl"] = DOTA_RUNE_BOUNTY,
		["models/props_gameplay/rune_arcane.vmdl"] = DOTA_RUNE_ARCANE,
	}
	return tModelToRuneType[ rune:GetModelName() ] or DOTA_RUNE_INVALID
end

function IsRuneOverrded( rune )
	if USE_CUSTOM_RUNE_BEHAVIOR then
		if (	rune == DOTA_RUNE_DOUBLEDAMAGE or --Список переопределяемых рун
				rune == DOTA_RUNE_HASTE or
				rune == DOTA_RUNE_ILLUSION ) then
			return true
		end
	end
	return false
end

function CDOTA_BaseNPC:RunePickupThink()
	if self.rune_to_pickup == nil or self.rune_to_pickup:IsNull() then return end
	if #( self.rune_to_pickup:GetOrigin() - self:GetOrigin() ) <= 128 then
		OnPickupRuneC( self, GetRuneType( self.rune_to_pickup ) )
		self.rune_to_pickup:Kill()
		self.rune_to_pickup = nil
		self:Stop()
	end
	return 0.03
end

function OnPickupRuneC( hero, rune )
	if rune == DOTA_RUNE_DOUBLEDAMAGE then
		hero:AddNewModifier( hero, nil, "modifier_rune_damage_custom", { duration = DAMAGE_CUSTOM.DURATION } )

		EmitAnnouncerSoundForTeamOnLocation( "Rune.DD", hero:GetTeam(), hero:GetOrigin() )
	elseif rune == DOTA_RUNE_HASTE then
		hero:AddNewModifier( hero, nil, "modifier_rune_haste_custom", { duration = HASTE_CUSTOM.DURATION } )

		EmitAnnouncerSoundForTeamOnLocation( "Rune.Haste", hero:GetTeam(), hero:GetOrigin() )
	elseif rune == DOTA_RUNE_ILLUSION then
		local k = GameRules:GetDOTATime( false, false )
		local count = math.min( ILLUSION_CUSTOM.COUNT_BASE + math.floor( k / ILLUSION_CUSTOM.COUNT_INC_SEC ) , ILLUSION_CUSTOM.COUNT_LIMIT )

	 	for i = 1, count do
		    _G.IsCustomIllusionSpawned = IsCustomIllusionSpawned + 1

			local illusion = CreateUnitByName( hero:GetUnitName(), hero:GetOrigin(), true, hero, hero, hero:GetTeam() )
			illusion:SetControllableByPlayer( hero:GetPlayerOwnerID(), true )

			local angle = hero:GetAngles()
			illusion:SetAngles( angle.x, angle.y, angle.z )
			illusion:AddNewModifier( hero, nil, "modifier_illusion", { duration = ILLUSION_CUSTOM.DURATION, outgoing_damage = ILLUSION_CUSTOM.DAMGE_OUTGOING - 100, incoming_damage = ILLUSION_CUSTOM.DAMGE_INCOMING - 100 })
			illusion:MakeIllusion()
			for i2 = 2, hero:GetLevel() do
				illusion:HeroLevelUp(false)
			end

			illusion:SetAbilityPoints(0)
			for i2 = 0, illusion:GetAbilityCount() - 1 do
				local ability = hero:GetAbilityByIndex(i2)
				if ability then
					local ability2 = illusion:FindAbilityByName( ability:GetAbilityName() )
					if ability2 then
						ability2:SetLevel( ability:GetLevel() )
					end
				end
			end

			for _, mod in pairs( hero:FindAllModifiers() ) do
				if mod:GetName() == "modifier_undying_flesh_golem" then
					illusion:FindAbilityByName( mod:GetAbility():GetAbilityName() ):OnSpellStart()
				elseif mod:GetName() == "modifier_dragon_knight_dragon_form" then
					illusion:FindAbilityByName( mod:GetAbility():GetAbilityName() ):OnSpellStart()
				elseif mod:GetName() == "modifier_lycan_shapeshift" then
					illusion:AddNewModifier( illusion, illusion:FindAbilityByName( mod:GetAbility():GetAbilityName() ), "modifier_lycan_shapeshift", { duration = mod:GetDuration() } )
				elseif mod:GetName() == "modifier_terrorblade_metamorphosis" then
					illusion:AddNewModifier( illusion, illusion:FindAbilityByName( mod:GetAbility():GetAbilityName() ), "modifier_terrorblade_metamorphosis", { duration = mod:GetDuration() } )
				end
			end

			local void_items = {}
			local tp_scroll = illusion:GetItemInSlot(0)
			if tp_scroll then
				tp_scroll:EndCooldown()
				illusion:RemoveItem(tp_scroll)
			end
			for i2 = 0, 9 do
				local item = hero:GetItemInSlot(i2)
				if item ~= nil then
					illusion:AddItemByName( item:GetName() )
				else
					item = illusion:AddItemByName("item_branches")
					table.insert( void_items, item )
				end
			end
			for _, item in pairs(void_items) do
				illusion:RemoveItem(item)
			end

			illusion:SetHealth( hero:GetHealth() )
			illusion:SetMana( hero:GetMana() )
		end

		EmitAnnouncerSoundForTeamOnLocation( "Rune.Illusion", hero:GetTeam(), hero:GetOrigin() )
	end

	local playerID = hero:GetPlayerOwnerID()
	local player_color = hero:GetTeam() == DOTA_TEAM_BADGUYS and "ffff00" or "00ffff"
	local player_name = PlayerResource:GetPlayerName(playerID)
	local hero_name = HeroDisplayNames[ hero:GetUnitName() ] or "Someone"
	GameRules:SendCustomMessageToTeam( "<font color='#" .. player_color .. "'>" .. player_name .. " (" .. hero_name .. ")</font> activated " .. RuneSimbols[rune] .. "<font color='#" .. RuneColors[rune] .. "'>" .. RuneNames[rune] .. "</font>", 3, 3, 3 )
end

end

--####################################################################
-- КАСТОМНЫЕ МОДИФИКАТОРЫ РУН
--####################################################################

LinkLuaModifier( "modifier_rune_damage_custom", "runes", 0 )
LinkLuaModifier( "modifier_rune_haste_custom", "runes", 0 )
-- DAMAGE
modifier_rune_damage_custom = class{}
function modifier_rune_damage_custom:GetTexture()
	return "rune_doubledamage"
end
function modifier_rune_damage_custom:GetEffectName()
	return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end
function modifier_rune_damage_custom:OnCreated(kv)
	local k = GameRules:GetDOTATime( false, false )
	self.damage = DAMAGE_CUSTOM.DAMAGE_BASE  +  DAMAGE_CUSTOM.DAMAGE_INC * k
end
function modifier_rune_damage_custom:OnRefresh(kv)
	local k = GameRules:GetDOTATime( false, false )
	self.damage = DAMAGE_CUSTOM.DAMAGE_BASE  +  DAMAGE_CUSTOM.DAMAGE_INC * k
end
function modifier_rune_damage_custom:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_rune_damage_custom:GetModifierBaseDamageOutgoing_Percentage(kv)
	return self.damage
end
-- HASTE
modifier_rune_haste_custom = class{}
function modifier_rune_haste_custom:GetTexture()
	return "rune_haste"
end
function modifier_rune_haste_custom:GetEffectName()
	return "particles/generic_gameplay/rune_haste_owner.vpcf"
end
function modifier_rune_haste_custom:OnCreated(kv)
	local k = GameRules:GetDOTATime( false, false )
	self.speed = HASTE_CUSTOM.SPEED_BASE  +  HASTE_CUSTOM.SPEED_INC * k
end
function modifier_rune_haste_custom:OnRefresh(kv)
	local k = GameRules:GetDOTATime( false, false )
	self.speed = HASTE_CUSTOM.SPEED_BASE  +  HASTE_CUSTOM.SPEED_INC * k
end
function modifier_rune_haste_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_rune_haste_custom:GetModifierMoveSpeed_Absolute(kv)
	return self.speed
end
function modifier_rune_haste_custom:GetModifierMoveSpeed_Max(kv)
	return self.speed
end
function modifier_rune_haste_custom:GetActivityTranslationModifiers(kv)
	return "haste"
end
