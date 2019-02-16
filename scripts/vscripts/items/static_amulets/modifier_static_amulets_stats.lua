modifier_static_amulets_stats = class({})
--------------------------------------------------------------------------------
function modifier_static_amulets_stats:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function modifier_static_amulets_stats:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_static_amulets_stats:DestroyOnExpire()
    return false
end

--------------------------------------------------------------------------------
function modifier_static_amulets_stats:OnCreated(kv)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
    self.bonus_int = self:GetAbility():GetSpecialValueFor("bonus_int")
    self.bonus_stats = self:GetAbility():GetSpecialValueFor("bonus_stats")
    if IsServer() then
        if self and self:GetParent() and self:GetAbility() and (not self:GetParent():IsIllusion()) then
            self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_static_amulets_damage", { duration = -1 })
        end
    end
end

--------------------------------------------------------------------------------
function modifier_static_amulets_stats:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
function modifier_static_amulets_stats:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

--------------------------------------------------------------------------------
function modifier_static_amulets_stats:GetModifierPhysicalArmorBonus(kv) return self.bonus_armor; end

function modifier_static_amulets_stats:GetModifierBonusStats_Strength(kv) return self.bonus_stats; end

function modifier_static_amulets_stats:GetModifierBonusStats_Agility(kv) return self.bonus_stats; end

function modifier_static_amulets_stats:GetModifierBonusStats_Intellect(kv) return self.bonus_stats + self.bonus_int; end

--------------------------------------------------------------------------------