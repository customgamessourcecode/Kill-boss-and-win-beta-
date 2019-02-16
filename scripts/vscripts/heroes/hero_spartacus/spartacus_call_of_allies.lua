LinkLuaModifier( "modifier_spartacus_call_of_allies", "heroes/hero_spartacus/spartacus_call_of_allies.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff

spartacus_call_of_allies = class({})

function spartacus_call_of_allies:GetIntrinsicModifierName()
	return "modifier_spartacus_call_of_allies"
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

modifier_spartacus_call_of_allies = class({})

--------------------------------------------------------------------------------

function modifier_spartacus_call_of_allies:IsPurgable()
	return false;
end

--------------------------------------------------------------------------------

function modifier_spartacus_call_of_allies:IsHidden()
	return true;
end

--------------------------------------------------------------------------------

function modifier_spartacus_call_of_allies:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end



--------------------------------------------------------------------------------

function modifier_spartacus_call_of_allies:OnTakeDamage( params )
	if IsServer() then
		local hUnit = params.unit
		local hAttacker = params.attacker
		local ability = self:GetAbility()
		
		
		if (hUnit == self:GetParent())  then		
			local flDamage = params.damage
			if flDamage <= 0 then
				return
			end
			if self.flAccumDamage == nil then self.flAccumDamage = 0 end
			self.flAccumDamage = self.flAccumDamage + flDamage
			local flTriggerDamage = hUnit:GetMaxHealth() * ability:GetSpecialValueFor("health_trigger")/100
			
			if self.flAccumDamage >= flTriggerDamage then
			
				self.flAccumDamage = self.flAccumDamage - flTriggerDamage
				local strength = hUnit:GetStrength()
				local player = self:GetParent():GetPlayerID()
				local point = hUnit:GetAbsOrigin()
				local team = hUnit:GetTeam()
				local unit_name = "npc_dota_spartacus_summon"
				local base_dmg = ability:GetSpecialValueFor("base_dmg")
				local str_dmg = strength * ability:GetSpecialValueFor("str_dmg")/100
				local base_armor = ability:GetSpecialValueFor("base_armor")
				local base_hp = ability:GetSpecialValueFor("base_hp")
				local summon_duration = ability:GetSpecialValueFor("summon_duration")
				
				local unit = CreateUnitByName( unit_name, point, true, hUnit, hUnit, team )
				unit:AddNewModifier( hUnit, self, "modifier_kill", { duration = summon_duration } )
				unit:SetControllableByPlayer(player, false)
				unit:SetOwner(hUnit)
				unit:SetBaseDamageMin(base_dmg + strength )
				unit:SetBaseDamageMax(base_dmg + strength )				
				unit:SetPhysicalArmorBaseValue( base_armor )
				unit:SetBaseMaxHealth(base_hp + flTriggerDamage )
				unit:SetMaxHealth(base_hp + flTriggerDamage )
				unit:SetHealth(base_hp + flTriggerDamage )

			end

		end
	end

	return 0
end

--------------------------------------------------------------------------------

