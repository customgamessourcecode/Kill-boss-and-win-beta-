if item_omnipresent_eye == nil then item_omnipresent_eye = class({}) end

LinkLuaModifier("modifier_omnipresent_eye_passive","items/item_omnipresent_eye.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_omnipresent_eye_debuff","items/item_omnipresent_eye.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_omnipresent_eye_true_sight","items/item_omnipresent_eye.lua",LUA_MODIFIER_MOTION_NONE)

function item_omnipresent_eye:GetIntrinsicModifierName(  )
    return "modifier_omnipresent_eye_passive"
end

function item_omnipresent_eye:OnSpellStart(  )
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local aoe = self:GetSpecialValueFor("aoe")
    self.id0 = ParticleManager:CreateParticle("particles/items_fx/dust_of_appearance.vpcf",PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.id0, 0, point)
    ParticleManager:SetParticleControl(self.id0,1,Vector(aoe,aoe,200))
    local units = FindUnitsInRadius(caster:GetTeamNumber(),
                              point,
                              nil,
                              aoe,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    local duration = self:GetSpecialValueFor("duration_v")
    for _, unit in pairs(units) do 
        unit:AddNewModifier(caster,self,"modifier_omnipresent_eye_true_sight",{duration = duration})
    end
end

function item_omnipresent_eye:GetBehavior(  )
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

function item_omnipresent_eye:GetAOERadius(  )
    return 450
end

if modifier_omnipresent_eye_passive == nil then modifier_omnipresent_eye_passive = class({}) end

function modifier_omnipresent_eye_passive:IsHidden(  )
    return true
end

function modifier_omnipresent_eye_passive:IsPurgable(  )
    return false
end

function modifier_omnipresent_eye_passive:GetAttributes(  )
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_omnipresent_eye_passive:DeclareFunctions(  )
    return {MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_omnipresent_eye_passive:GetModifierBonusStats_Strength(  )
    return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_omnipresent_eye_passive:GetModifierBonusStats_Agility(  )
    return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_omnipresent_eye_passive:GetModifierBonusStats_Intellect(  )
    return self:GetAbility():GetSpecialValueFor("all")
end

function modifier_omnipresent_eye_passive:GetModifierHealthBonus(  )
    return self:GetAbility():GetSpecialValueFor("hp_mp")
end
function modifier_omnipresent_eye_passive:GetModifierManaBonus(  )
    return self:GetAbility():GetSpecialValueFor("hp_mp")
end

function modifier_omnipresent_eye_passive:GetModifierOrbPriority()
    return DOTA_ORB_CUSTOM
end

function modifier_omnipresent_eye_passive:OnAttackLanded( params )
    local caster = self:GetCaster()
    local target = params.target

    if params.attacker == caster and not target:IsMagicImmune() then
        local ability = self:GetAbility()
        local cap = 0
        if IsBoss(target) then
            cap = ability:GetSpecialValueFor("b_cap")
        else
            cap = ability:GetSpecialValueFor("cap")
        end

        if self:IsActiveOrb() and caster:HasItemInInventory(ability:GetName()) and target:IsAlive() then 
            target:AddNewModifier(caster,ability,"modifier_omnipresent_eye_debuff",{duration = ability:GetSpecialValueFor("duration")})
            if target:HasModifier("modifier_omnipresent_eye_debuff") then
                local count = target:GetModifierStackCount("modifier_omnipresent_eye_debuff",caster)
                if count < cap then
                    target:SetModifierStackCount("modifier_omnipresent_eye_debuff",caster,count + 1)
                end
            end
        end
    end
end

if modifier_omnipresent_eye_debuff == nil then modifier_omnipresent_eye_debuff = class({}) end

function modifier_omnipresent_eye_debuff:GetTexture(  )
    return self:GetAbility():GetName()
end

function modifier_omnipresent_eye_debuff:IsDebuff(  )
    return true
end

function modifier_omnipresent_eye_debuff:DeclareFunctions(  )
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_omnipresent_eye_debuff:OnCreated(  )
    local ability = self:GetAbility()
    self.slow = -ability:GetSpecialValueFor("slow")
    self.atk_slow = -ability:GetSpecialValueFor("slow_atk")
    self.resist = -ability:GetSpecialValueFor("cold_magic_resist")
end

function modifier_omnipresent_eye_debuff:GetModifierMoveSpeedBonus_Percentage(  )
    return self.slow * self:GetStackCount()
end

function modifier_omnipresent_eye_debuff:GetModifierAttackSpeedBonus_Constant(  )
    return self.atk_slow * self:GetStackCount()
end

function modifier_omnipresent_eye_debuff:GetModifierMagicalResistanceBonus(  )
    return self.resist * self:GetStackCount()
end

if modifier_omnipresent_eye_true_sight == nil then modifier_omnipresent_eye_true_sight = class({}) end

function modifier_omnipresent_eye_true_sight:GetTexture(  )
    return self:GetAbility():GetName()
end

function modifier_omnipresent_eye_true_sight:IsPurgable(  )
    return false
end

LinkLuaModifier("modifier_true_vision","libraries/modifiers/modifier_true_vision.lua",LUA_MODIFIER_MOTION_NONE)
--require('libraries/timers')

function modifier_omnipresent_eye_true_sight:OnCreated(  )
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    parent:AddNewModifier(caster,ability,"modifier_true_vision",{duration = self:GetDuration()})
    self.id0 = ParticleManager:CreateParticle("particles/items_fx/dust_of_appearance_debuff.vpcf",PATTACH_ABSORIGIN_FOLLOW, parent)
    --ParticleManager:SetParticleControlEnt(id0, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false)
end

function modifier_omnipresent_eye_true_sight:OnDestroy(  )
    --Timers:RemoveTimer(self.timer)
    ParticleManager:DestroyParticle(self.id0,false)
end