if item_cursed_eye == nil then item_cursed_eye = class({}) end

LinkLuaModifier("modifier_cursed_eye_passive","items/item_cursed_eye.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cursed_eye_debuff","items/item_cursed_eye.lua",LUA_MODIFIER_MOTION_NONE)

function item_cursed_eye:GetIntrinsicModifierName(  )
    return "modifier_cursed_eye_passive"
end

if modifier_cursed_eye_passive == nil then modifier_cursed_eye_passive = class({}) end

function modifier_cursed_eye_passive:IsHidden(  )
    return true
end

function modifier_cursed_eye_passive:IsPurgable(  )
    return false
end

function modifier_cursed_eye_passive:DeclareFunctions(  )
    return {MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_cursed_eye_passive:GetModifierBonusStats_Strength(  )
    return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_cursed_eye_passive:GetModifierBonusStats_Agility(  )
    return self:GetAbility():GetSpecialValueFor("all")
end
function modifier_cursed_eye_passive:GetModifierBonusStats_Intellect(  )
    return self:GetAbility():GetSpecialValueFor("all")
end

function modifier_cursed_eye_passive:GetModifierHealthBonus(  )
    return self:GetAbility():GetSpecialValueFor("hp_mp")
end
function modifier_cursed_eye_passive:GetModifierManaBonus(  )
    return self:GetAbility():GetSpecialValueFor("hp_mp")
end

function modifier_cursed_eye_passive:GetModifierOrbPriority()
    return DOTA_ORB_CUSTOM
end

function modifier_cursed_eye_passive:OnAttackLanded( params )
    local ability = self:GetAbility()
    local cap = 0
    local caster = self:GetCaster()
    local target = params.target

    if params.attacker == caster and target ~= caster and target:GetTeamNumber() ~= caster:GetTeamNumber() and not target:IsMagicImmune() then
        if IsBoss(target) then
            cap = ability:GetSpecialValueFor("b_cap")
        else
            cap = ability:GetSpecialValueFor("cap")
        end
        
        if self:IsActiveOrb() then
            target:AddNewModifier(caster,ability,"modifier_cursed_eye_debuff",{duration = ability:GetSpecialValueFor("duration")})
            if target:HasModifier("modifier_cursed_eye_debuff") then
                local count = target:GetModifierStackCount("modifier_cursed_eye_debuff",caster)
                if count < cap then
                    target:SetModifierStackCount("modifier_cursed_eye_debuff",caster,count + 1)
                end
            end
        end
    end
end

if modifier_cursed_eye_debuff == nil then modifier_cursed_eye_debuff = class({}) end

function modifier_cursed_eye_debuff:GetTexture(  )
    return "item_cursed_eye"
end

function modifier_cursed_eye_debuff:IsDebuff(  )
    return true
end

function modifier_cursed_eye_debuff:DeclareFunctions(  )
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_cursed_eye_debuff:OnCreated(  )
    local ability = self:GetAbility()
    self.slow = -ability:GetSpecialValueFor("slow")
    self.atk_slow = -ability:GetSpecialValueFor("slow_atk")
    self.resist = -ability:GetSpecialValueFor("cold_magic_resist")
end

function modifier_cursed_eye_debuff:GetModifierMoveSpeedBonus_Percentage(  )
    return self.slow * self:GetStackCount()
end

function modifier_cursed_eye_debuff:GetModifierAttackSpeedBonus_Constant(  )
    return self.atk_slow * self:GetStackCount()
end

function modifier_cursed_eye_debuff:GetModifierMagicalResistanceBonus(  )
    return self.resist * self:GetStackCount()
end