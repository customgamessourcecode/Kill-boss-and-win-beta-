_G.LifestealModifiers = {
	-- items
	modifier_item_mask_of_death = 15,
    modifier_banner_of_victory_aura_effect = 5,	
	modifier_item_mask_of_madness = 15,
	modifier_item_vladmir_aura = function( unit )
		if unit:IsRangedAttacker() then
			return 10
		end
		return 15
	end,
	modifier_item_satanic = 25,
	modifier_item_satanic_unholy = 175,
	
	--abilities
	modifier_shinobu_lifesteal_passive = { 1, 2, 3, 4, 5, 6, 7 },
	modifier_broodmother_insatiable_hunger = function( _, mod )
		local talent = mod:GetCaster():FindAbilityByName("special_bonus_unique_broodmother_1")
		local value = mod:GetAbility():GetSpecialValueFor("lifesteal_pct")
		if talent and talent:IsTrained() then
			value = value + talent:GetSpecialValueFor("value")
		end
		return value
	end,
	modifier_lone_druid_spirit_link = { 40, 50, 60, 70 },
	modifier_chaos_knight_chaos_strike = function( unit, modifier )
		local ability = modifier:GetAbility()
		if ability:GetCooldown( ability:GetLevel() ) - ability:GetCooldownTimeRemaining() < 0.01 then
			return modifier:GetAbility():GetSpecialValueFor("lifesteal")
		end
		return 0
	end,
	modifier_troll_warlord_battle_trance = { 20, 30, 40, 50, 60, 70, 80 },
	modifier_monkey_king_quadruple_tap_bonuses = { 30 },
	modifier_skeleton_king_vampiric_aura_buff = function( _, mod )
		local ability = mod:GetAbility()
		local talent = mod:GetCaster():FindAbilityByName("special_bonus_unique_wraith_king_2")
		local value = ability:GetSpecialValueFor("vampiric_aura")
		if talent and talent:IsTrained() then
			value = value + talent:GetSpecialValueFor("value")
		end
		return value
	end,
	modifier_legion_commander_moment_of_courage = function( _, mod )
		if RollPercentage(25) then
			return mod:GetAbility():GetSpecialValueFor("hp_leech_percent")
		end
		return 0
	end
}

LifestealModifiers.Inflictors = {
	monkey_king_boundless_strike = true,
	phantom_assassin_stifling_dagger = true,
	tidehunter_anchor_smash = true,
	sven_great_cleave = true
}

local function ArmorResistFormula( armor )
	return 0.05 * armor / ( 1 + 0.05 * math.abs(armor) )
end

-----------------------------------------------------------------------------------------

modifier_physical_damage_override = class{}

function modifier_physical_damage_override:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_physical_damage_override:IsHidden()
	return true
end

function modifier_physical_damage_override:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
	}
end

function modifier_physical_damage_override:GetAbsoluteNoDamagePhysical()
	return 1
end

--------------------------------------------------------------------------------------------------

modifier_physical_damage_override_gamemode = class{}

function modifier_physical_damage_override_gamemode:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_physical_damage_override_gamemode:OnTakeDamage( kv )
	if kv.damage_type == DAMAGE_TYPE_PHYSICAL and not kv.unit:IsAttackImmune() then
		local modifiers = kv.unit:FindAllModifiers()
		local armor = kv.unit:GetPhysicalArmorValue()
		local damage = kv.original_damage * ( 1 - ArmorResistFormula(armor) )
		
		for _, mod in pairs(modifiers) do
			if mod.ModifyPhisicalDamagePost0 then
				damage = mod:ModifyPhisicalDamagePost0( damage )
			end
		end
		
		local damage_flags = kv.damage_flags
		if math.floor( damage_flags / DOTA_DAMAGE_FLAG_REFLECTION ) % 2 == 0 then
			damage_flags = damage_flags + DOTA_DAMAGE_FLAG_REFLECTION
		end
		
		ApplyDamage{
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			victim = kv.unit,
			attacker = kv.attacker,
			ability = kv.inflictor,
			damage_flags = damage_flags
		}
		
		if kv.inflictor == nil or ( not kv.inflictor:IsNull() and LifestealModifiers.Inflictors[ kv.inflictor:GetName() ] ) then
			local lifesteal = kv.attacker:GetLifesteal()
			if lifesteal > 0 then
				kv.attacker:Heal( lifesteal * damage / 100, kv.attacker )
			end
		else
			print( kv.inflictor:GetName() )
		end
	end
end


function modifier_physical_damage_override_gamemode:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

---------------------------------------------------------------------------------------------------

if IsServer() then

function CDOTA_BaseNPC:GetLifesteal()
	local lifesteal = 0
	for _, mod in pairs( self:FindAllModifiers() ) do
		print(mod:GetName())
		if mod:GetName() == "modifier_special_bonus_lifesteal" then
			lifesteal = lifesteal + mod:GetAbility():GetSpecialValueFor("value")
		else
			lifesteal = lifesteal + self:TranslateLifestealModifier( mod )
		end
	end
	return lifesteal
end

function CDOTA_BaseNPC:TranslateLifestealModifier( modifier )
	local value = LifestealModifiers[ modifier:GetName() ]
	if value == nil then return 0 end
	if type(value) == "number" then
		return value
	elseif type(value) == "function" then
		return value( self, modifier )
	elseif type(value) == "table" then
		local ability = modifier:GetAbility()
		if ability then
			return value[ math.max( 1, math.min( #value, ability:GetLevel() ) ) ]
		end
		return value[1]
	end
	return 0
end

end