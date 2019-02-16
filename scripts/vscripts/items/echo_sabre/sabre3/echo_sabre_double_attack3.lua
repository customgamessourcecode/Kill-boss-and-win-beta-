echo_sabre_double_attack3 = class({})

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:IsDebuff()
    return false
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:DestroyOnExpire()
    return false
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:OnCreated(kv)
    self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

--------------------------------------------------------------------------------
function echo_sabre_double_attack3:OnAttackLanded(params)
    if not IsServer() then return end
    if self:GetAbility():GetCooldownTimeRemaining() > 0 then return end
    local caster = params.attacker
    if caster == self:GetParent() then
        if caster:IsRangedAttacker() then return end
        if caster:IsIllusion() then return end
        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel() - 1))

        Timers:CreateTimer("echo_sabre_double_attack3" .. tostring(caster:entindex()), {
            useGameTime = false,
            endTime = 0.1,
            callback = function()
                caster:PerformAttack(params.target, true, true, true, true, true, false, false)
                params.target:AddNewModifier(caster, self:GetAbility(), "modifier_echo_sabre_slow_custom", { duration = self.slow_duration })
            end
        })
    end
end

--------------------------------------------------------------------------------

function echo_sabre_double_attack3:OnDestroy(params)
    if not IsServer() then return end
    Timers:RemoveTimer("echo_sabre_double_attack3" .. tostring(self:GetParent():entindex()))
end
-------------------------------------------------------------------------------
