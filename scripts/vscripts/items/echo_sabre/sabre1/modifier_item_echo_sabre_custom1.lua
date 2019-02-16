modifier_item_echo_sabre_custom1 = class({})
--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:DestroyOnExpire()
    return false
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:OnCreated(kv)
    if IsServer() then
        self:GetAbility():GetCaster():AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "echo_sabre_double_attack1", { duration = -1 })
    end
    self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
    self.bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:GetAttributes()
    return (MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE);
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return funcs
end

--------------------------------------------------------------------------------
function modifier_item_echo_sabre_custom1:GetModifierBonusStats_Intellect(kv) return self.bonus_intellect; end

function modifier_item_echo_sabre_custom1:GetModifierBonusStats_Strength(kv) return self.bonus_strength; end

function modifier_item_echo_sabre_custom1:GetModifierAttackSpeedBonus_Constant(kv) return self.bonus_attack_speed; end

function modifier_item_echo_sabre_custom1:GetModifierPreAttack_BonusDamage(kv) return self.bonus_damage; end

function modifier_item_echo_sabre_custom1:GetModifierConstantManaRegen(kv) return self.bonus_mana_regen; end

function modifier_item_echo_sabre_custom1:OnDestroy(kv)
    if not IsServer() then return end
    self:GetParent():RemoveModifierByName("echo_sabre_double_attack1")
end

--------------------------------------------------------------------------------