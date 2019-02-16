modifier_life_catcher_passive = class({})
--------------------------------------------------------------------------------

function modifier_life_catcher_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:OnCreated( kv )
    self.bonus_str      = self:GetAbility():GetSpecialValueFor("bonus_str")
    self.bonus_int      = self:GetAbility():GetSpecialValueFor("bonus_int")
    self.hp_regen       = self:GetAbility():GetSpecialValueFor("bonus_hpregen")
    self.mana_regen     = self:GetAbility():GetSpecialValueFor("bonus_manaregen")
    self.bonus_dmg      = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.dmg_to_exp     = self:GetAbility():GetSpecialValueFor("damage_to_exp")  / 100
    self.min_exp        = self:GetAbility():GetSpecialValueFor("min_exp")
    self.max_exp        = self:GetAbility():GetSpecialValueFor("max_exp")
    self.exp_cooldown   = self:GetAbility():GetSpecialValueFor("exp_cooldown")

    self.cooldown_modifier = "modifier_life_catcher_passive_exp_cd"
end

function modifier_life_catcher_passive:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:GetModifierBonusStats_Strength( params )
	return self.bonus_str
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:GetModifierBonusStats_Intellect( params )
	return self.bonus_int
end 

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:GetModifierConstantHealthRegen( params )
    return self.hp_regen
end 

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:GetModifierConstantManaRegen( params )
    return self.mana_regen
end 

--------------------------------------------------------------------------------

function modifier_life_catcher_passive:GetModifierPreAttack_BonusDamage( params )
    return self.bonus_dmg
end 

--------------------------------------------------------------------------------

local forbidden_abilities = {
	["warlock_fatal_bonds"] = 1,
}

function modifier_life_catcher_passive:OnTakeDamage( params )
	if IsServer() then
        if params.attacker ~= self:GetParent() then
        	return
        end

        if not params.attacker:IsRealHero() or not params.unit:IsRealHero() or params.unit:GetTeamNumber() == params.attacker:GetTeamNumber() then return end

        if forbidden_abilities[self:GetAbility():GetName()] then return end 
        
        if params.damage < 10 then return end
        if ( self:GetCaster():GetAbsOrigin() - params.unit:GetAbsOrigin() ):Length2D() > 2000 then return end 
        
        for i = 0, 5 do
            if self:GetCaster():GetItemInSlot(i) and self:GetCaster():GetItemInSlot(i):GetName() == self:GetAbility():GetName() then
                if self:GetAbility() ~= self:GetCaster():GetItemInSlot(i) then
                    return
                else
                    break
                end
            end
        end

        if params.attacker:HasModifier(self.cooldown_modifier) then return end 

        local exp = 0

        if self.dmg_to_exp * params.damage < self.min_exp then
            exp = self.min_exp 
        else 
            if self.dmg_to_exp * params.damage > self.max_exp then
                exp = self.max_exp 
            else
                exp = self.dmg_to_exp * params.damage
            end
        end

        params.attacker:AddExperience(exp, 0, true, true)   
        params.attacker:AddNewModifier(params.attacker, self:GetAbility(), self.cooldown_modifier, 
            { duration = self.exp_cooldown }) 
	end
	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------