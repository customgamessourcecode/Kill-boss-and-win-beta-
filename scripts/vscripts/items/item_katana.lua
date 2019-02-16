if item_katana == nil then
    item_katana = class({})
end

LinkLuaModifier("modifier_katana_passive","items/item_katana.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_katana_movespeed","items/item_katana.lua",LUA_MODIFIER_MOTION_NONE)

function item_katana:GetIntrinsicModifierName(  )
    return "modifier_katana_passive"
end

function item_katana:OnSpellStart(  )
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_item_katana_movespeed",{duration = self:GetSpecialValueFor("duration")})
end

-----------------------

if modifier_katana_passive == nil then
    modifier_katana_passive = class({})
end

function modifier_katana_passive:IsPurgable(  )
    return false
end

function modifier_katana_passive:IsHidden(  )
    return true
end

function modifier_katana_passive:OnCreated(  )
    self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
    self.agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
    self.atk = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.damage = self:GetAbility():GetSpecialValueFor("dmg")
    self.movespeed_prc = self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus")
end

function modifier_katana_passive:OnRefresh(  )
    self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
    self.agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
    self.atk = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.damage = self:GetAbility():GetSpecialValueFor("dmg")
    self.movespeed_prc = self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus")
end

function modifier_katana_passive:GetAttributes(  )
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_katana_passive:DeclareFunctions(  )
    local funcs = { MODIFIER_PROPERTY_EVASION_CONSTANT,
                    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE}
    return funcs
end

function modifier_katana_passive:GetModifierBonusStats_Agility(  )
    return self.agi
end

function modifier_katana_passive:GetModifierAttackSpeedBonus_Constant(  )
    return self.atk
end

function modifier_katana_passive:GetModifierPreAttack_BonusDamage(  )
    return self.damage
end

function modifier_katana_passive:GetModifierMoveSpeedBonus_Percentage_Unique(  )
    return self.movespeed_prc
end

function modifier_katana_passive:GetModifierEvasion_Constant(  )
    if IsServer() then
        if self:GetCaster():HasModifier("modifier_item_katana_movespeed") then
            return nil
        end
        return self.evasion
    end
    return self.evasion
end

function modifier_katana_passive:OnDestroy(  )
    self:GetParent():RemoveModifierByName("modifier_item_katana_movespeed")
end

-----------------------

if modifier_item_katana_movespeed == nil then
    modifier_item_katana_movespeed = class({})
end

function modifier_item_katana_movespeed:IsHidden()
    return false
end

function modifier_item_katana_movespeed:GetTexture(  )
    return "item_katana"
end

function modifier_item_katana_movespeed:OnCreated(  )
    self.movespeed = self:GetAbility():GetSpecialValueFor("move_prc_active")
end

function modifier_item_katana_movespeed:OnRefresh(  )
    self.movespeed = self:GetAbility():GetSpecialValueFor("move_prc_active")
end

function modifier_item_katana_movespeed:DeclareFunctions(  )
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
    return funcs
end

function modifier_item_katana_movespeed:GetModifierMoveSpeedBonus_Percentage(  )
    return self.movespeed
end
