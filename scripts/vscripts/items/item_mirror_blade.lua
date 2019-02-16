if item_mirror_blade == nil then item_mirror_blade = class({}) end

LinkLuaModifier("modifier_mirror_blade_passive","items/item_mirror_blade.lua",LUA_MODIFIER_MOTION_NONE)

function item_mirror_blade:OnSpellStart(  )
	local caster = self:GetCaster()
	ProjectileManager:ProjectileDodge(caster)
	caster:EmitSound("DOTA_Item.Manta.Activate")

	local id0 = ParticleManager:CreateParticle("particles/items2_fx/manta_phase.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
    
    caster:Purge(false, true, false, false, false)
	caster:AddNoDraw()
	local illusion_duration = self:GetSpecialValueFor("duration")
	local illusion_outgoing_damage = self:GetSpecialValueFor("out_damage") - 100
	local illusion_incoming_damage = self:GetSpecialValueFor("take_damage") - 100
	local count = self:GetSpecialValueFor("illusions")
	local player_id = caster:GetPlayerID()
	local ability_chance = self:GetSpecialValueFor("ability_chance")
	local cpl = self:GetSpecialValueFor("ability_chance_per_level") * caster:GetLevel()
	local chance = ability_chance + cpl
	if IsServer() then 
		caster_health = caster:GetHealthPercent()
		caster_mana = caster:GetManaPercent()
		caster_agi = caster:GetBaseAgility()
		caster_str = caster:GetBaseStrength()
		caster_int = caster:GetBaseIntellect()
	end

		for i=1, count do 
			local unit = CreateUnitByName(caster:GetName(), caster:GetAbsOrigin()+Vector(RandomInt(-120,120),RandomInt(-120,120),0), true, caster, nil, caster:GetTeam())
			local caster_level = caster:GetLevel()
		    for i = 1, caster_level - 1 do
		        unit:HeroLevelUp(false)
		    end
		    unit:SetPlayerID(player_id)
    		unit:SetControllableByPlayer(player_id, true)
    		unit:SetAbilityPoints(0)

			unit:SetBaseAgility(caster_agi)
			unit:SetBaseIntellect(caster_int)
			unit:SetBaseStrength(caster_str)
			unit:SetHealth(unit:GetMaxHealth() * caster_health * 0.01)
			unit:SetMana(unit:GetMaxMana() * caster_mana * 0.01)
    		
		    for ability_slot = 0, 5 do
		        local individual_ability = caster:GetAbilityByIndex(ability_slot)
		        if individual_ability and RollPercentage(chance) then 
		        	local ability = unit:AddAbility(individual_ability:GetName())
		        	local level = individual_ability:GetLevel()
		            --unit:SetAbilityByIndex(ability,ability_slot)
		            ability:SetLevel(level)
		        end
		    end

		    for item_slot = 0, 5 do
		        local individual_item = caster:GetItemInSlot(item_slot)
		        if individual_item then
		            local illusion_duplicate_item = CreateItem(individual_item:GetName(), unit, unit)
		            unit:AddItem(illusion_duplicate_item)
		        end
		    end

		    unit:AddNewModifier(caster, self, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
    
    		unit:MakeIllusion()
		end

		caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(RandomInt(-120,120),RandomInt(-120,120),0))
		FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),false)
		caster:RemoveNoDraw()

		ParticleManager:DestroyParticle(id0,false)
end

function item_mirror_blade:GetIntrinsicModifierName(  )
	return "modifier_mirror_blade_passive"
end

if modifier_mirror_blade_passive == nil then modifier_mirror_blade_passive = class({}) end

function modifier_mirror_blade_passive:IsHidden(  )
	return true
end

function modifier_mirror_blade_passive:IsPurgable(  )
	return false
end

function modifier_mirror_blade_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.agi = ability:GetSpecialValueFor("agi")
	self.str = ability:GetSpecialValueFor("str")
	self.int = ability:GetSpecialValueFor("int")
	self.speed = ability:GetSpecialValueFor("speed")
	self.evasion = ability:GetSpecialValueFor("evasion")
	self.atk = ability:GetSpecialValueFor("atk")
end

function modifier_mirror_blade_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE}
end

function modifier_mirror_blade_passive:GetModifierBonusStats_Agility(  )
	return self.agi
end

function modifier_mirror_blade_passive:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_mirror_blade_passive:GetModifierBonusStats_Intellect(  )
	return self.int
end

function modifier_mirror_blade_passive:GetModifierMoveSpeedBonus_Percentage_Unique(  )
	return self.speed
end

function modifier_mirror_blade_passive:GetModifierEvasion_Constant(  )
	return self.evasion
end

function modifier_mirror_blade_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end