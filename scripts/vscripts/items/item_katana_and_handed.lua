if item_katana_and_handed == nil then
    item_katana_and_handed = class({})
end

LinkLuaModifier("modifier_katana_and_handed_passive","items/item_katana_and_handed.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_katana_and_handed_maim","items/item_katana_and_handed.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_katana_and_handed_movespeed","items/item_katana_and_handed.lua",LUA_MODIFIER_MOTION_NONE)

function item_katana_and_handed:GetIntrinsicModifierName(  )
    return "modifier_katana_and_handed_passive"
end

function item_katana_and_handed:OnSpellStart(  )
    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_katana_and_handed_movespeed",{duration = self:GetSpecialValueFor("duration")})
end

-----------------------

if modifier_katana_and_handed_passive == nil then
    modifier_katana_and_handed_passive = class({})
end

function modifier_katana_and_handed_passive:IsPurgable(  )
    return false
end

function modifier_katana_and_handed_passive:IsHidden(  )
    return true
end

function modifier_katana_and_handed_passive:OnCreated(  )
	self.evasion_a = self:GetAbility():GetSpecialValueFor("evade_chance")
    self.bonus_agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
    self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.dmg = self:GetAbility():GetSpecialValueFor("dmg")
    self.movement_speed_percent_bonus = self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus")
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    self.maim_duration = self:GetAbility():GetSpecialValueFor("maim_duration")
end

function modifier_katana_and_handed_passive:OnRefresh(  )
	self.evasion_a = self:GetAbility():GetSpecialValueFor("evade_chance")
    self.bonus_agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
    self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.dmg = self:GetAbility():GetSpecialValueFor("dmg")
    self.movement_speed_percent_bonus = self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus")
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    self.maim_duration = self:GetAbility():GetSpecialValueFor("maim_duration")
end

function modifier_katana_and_handed_passive:OnDestroy(  )
	self:GetParent():RemoveModifierByName("modifier_katana_and_handed_movespeed")
end

function modifier_katana_and_handed_passive:GetAttributes(  )
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_katana_and_handed_passive:DeclareFunctions(  )
    local funcs = { MODIFIER_PROPERTY_EVASION_CONSTANT,
    				MODIFIER_EVENT_ON_ATTACK_LANDED,
    				MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    				MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE}
    return funcs
end

function modifier_katana_and_handed_passive:GetModifierBonusStats_Agility(  )
    return self.bonus_agi
end

function modifier_katana_and_handed_passive:GetModifierBonusStats_Strength(  )
    return self.bonus_str
end

function modifier_katana_and_handed_passive:GetModifierAttackSpeedBonus_Constant(  )
    return self.bonus_attack_speed
end

function modifier_katana_and_handed_passive:GetModifierPreAttack_BonusDamage(  )
    return self.dmg
end

function modifier_katana_and_handed_passive:GetModifierMoveSpeedBonus_Percentage_Unique(  )
    return self.movement_speed_percent_bonus
end

function modifier_katana_and_handed_passive:GetModifierEvasion_Constant(  )
	if IsServer() then
		if self:GetParent():HasModifier("modifier_katana_and_handed_movespeed") then
			self.evasion = 0
		else
			self.evasion = self.evasion_a
		end
	    return self.evasion
	end
	return self.evasion
end

function modifier_katana_and_handed_passive:OnAttackLanded( params )
	local ability = self:GetAbility()
	local target = self:GetParent():GetAttackTarget()
	local caster = self:GetParent()
	if RollPercentage(self.chance) and IsServer() and params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) and target:IsAlive() then
		target:AddNewModifier(caster,ability,"modifier_katana_and_handed_maim",{duration = self.maim_duration})
	end
end

----------------------

if modifier_katana_and_handed_movespeed == nil then
    modifier_katana_and_handed_movespeed = class({})
end

function modifier_katana_and_handed_movespeed:IsHidden()
    return false
end

function modifier_katana_and_handed_movespeed:OnCreated(  )
	self.move_prc_active = self:GetAbility():GetSpecialValueFor("move_prc_active")
end

function modifier_katana_and_handed_movespeed:OnRefresh(  )
	self.move_prc_active = self:GetAbility():GetSpecialValueFor("move_prc_active")
end

function modifier_katana_and_handed_movespeed:GetTexture(  )
    return "item_katana_and_handed"
end

function modifier_katana_and_handed_movespeed:DeclareFunctions(  )
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
    return funcs
end

function modifier_katana_and_handed_movespeed:GetModifierMoveSpeedBonus_Percentage(  )
    return self.move_prc_active
end

------------------------------------------------

if modifier_katana_and_handed_maim == nil then
    modifier_katana_and_handed_maim = class({})
end

function modifier_katana_and_handed_maim:GetTexture(  )
    return "item_katana_and_handed"
end

function modifier_katana_and_handed_maim:IsDebuff(  )
    return true
end

function modifier_katana_and_handed_maim:DeclareFunctions(  )
	local funcs = { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
	return funcs
end

function modifier_katana_and_handed_maim:OnCreated(  )
	self.slow_maim = self:GetAbility():GetSpecialValueFor("maim_slow_movement")
	self.slow_atk_maim = self:GetAbility():GetSpecialValueFor("maim_slow_attack")
end

function modifier_katana_and_handed_maim:OnRefresh(  )
	self.slow_maim = self:GetAbility():GetSpecialValueFor("maim_slow_movement")
	self.slow_atk_maim = self:GetAbility():GetSpecialValueFor("maim_slow_attack")
end

function modifier_katana_and_handed_maim:GetModifierAttackSpeedBonus_Constant(  )
    return -self.slow_atk_maim
end

function modifier_katana_and_handed_maim:GetModifierMoveSpeedBonus_Percentage(  )
    return -self.slow_maim
end
