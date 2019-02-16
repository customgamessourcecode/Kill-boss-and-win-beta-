miraak_dragon_aspect = class({})
LinkLuaModifier( "modifier_miraak_dragon_aspect", "abilities/miraak_dragon_aspect.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function miraak_dragon_aspect:OnAbilityPhaseStart()
    if IsServer() then 
        EmitSoundOn("Miraak.DragonAspect.Cast", self:GetCaster())
    end 
	return true
end

function miraak_dragon_aspect:OnSpellStart()
    if IsServer() then 
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_miraak_dragon_aspect", {duration = self:GetSpecialValueFor("duration")})      
        
        EmitSoundOn( "Hero_Terrorblade.ConjureImage", self:GetCaster() )
    end
end

if not modifier_miraak_dragon_aspect then modifier_miraak_dragon_aspect = class({}) end 

function modifier_miraak_dragon_aspect:GetEffectName()
	return "particles/miraak/dragon_aspect.vpcf"
end

function modifier_miraak_dragon_aspect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_miraak_dragon_aspect:IsPurgable()
	return false
end

function modifier_miraak_dragon_aspect:OnCreated(params)
    if IsServer() then 
        
    end 
end

function modifier_miraak_dragon_aspect:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_miraak_dragon_aspect:OnTakeDamage( params )
    if IsServer() then
        if params.unit == self:GetParent() then
            local target = params.attacker
            local damage = params.damage

            
            local units = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for i, unit in pairs(units) do
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/shadow_shaman/shadow_shaman_ti8/shadow_shaman_ti8_ether_shock.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
                ParticleManager:SetParticleControlEnt( nFXIndex, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true );
                ParticleManager:ReleaseParticleIndex( nFXIndex );

                EmitSoundOn("Hero_Pugna.NetherWard.Target", unit)

                local damage_table = {
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage = damage * (self:GetAbility():GetSpecialValueFor("damage_return") / 100),
                    damage_type = DAMAGE_TYPE_PURE,
                    ability = self:GetAbility()
                }
                ApplyDamage( damage_table )
            end
        end
    end
end