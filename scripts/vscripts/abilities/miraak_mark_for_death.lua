miraak_mark_for_death = class({})
LinkLuaModifier( "modifier_miraak_mark_for_death", "abilities/miraak_mark_for_death.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function miraak_mark_for_death:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end


function miraak_mark_for_death:OnAbilityPhaseStart()
    if IsServer() then 
        EmitSoundOn("Miraak.MarkForDeath.Cast", self:GetCaster())
    end 
	return true
end

function miraak_mark_for_death:OnSpellStart()
    if IsServer() then 
        local hTarget = self:GetCursorTarget()
        if hTarget ~= nil then
            hTarget:AddNewModifier(self:GetCaster(), self, "modifier_miraak_mark_for_death", {duration = self:GetSpecialValueFor("duration")})
            
            EmitSoundOn( "Hero_Terrorblade.Reflection", self:GetCaster() )
        end
    end
end

if not modifier_miraak_mark_for_death then modifier_miraak_mark_for_death = class({}) end 

function modifier_miraak_mark_for_death:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_leyconduit_debuff_energy.vpcf"
end

function modifier_miraak_mark_for_death:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_miraak_mark_for_death:IsPurgable()
	return false
end

function modifier_miraak_mark_for_death:OnCreated(params)
    if IsServer() then 
        
        self:StartIntervalThink(self:GetAbility():GetSpecialValueFor( "tick_interval" )) 
    end 
end

function modifier_miraak_mark_for_death:OnIntervalThink()
    if IsServer() then 
        local radius = self:GetAbility():GetSpecialValueFor( "radius" ) 
		print(radius)

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #units > 0 then
            for _, target in pairs(units) do
                local damage = {
                    victim = target,
                    attacker = self:GetCaster(),
                    damage = self:GetAbility():GetSpecialValueFor("damage"),
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                }
                ApplyDamage( damage )
            end
        end
	return self:GetAbility():GetSpecialValueFor( "tick_interval" )	
    end 
end

