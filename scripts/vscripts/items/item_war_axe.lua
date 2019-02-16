if item_war_axe == nil then	item_war_axe = class({})end

LinkLuaModifier("modifier_war_axe_passive","items/item_war_axe.lua",LUA_MODIFIER_MOTION_NONE)
function item_war_axe:GetIntrinsicModifierName(  ) return "modifier_war_axe_passive" end


--------------------------------------

if modifier_war_axe_passive == nil then	modifier_war_axe_passive = class({})end

function modifier_war_axe_passive:GetAttributes(  )return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_war_axe_passive:IsHidden(  )return true end

function modifier_war_axe_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
	self.cleave_pct = ability:GetSpecialValueFor("cleave_pct")
	self.cleave_radius = ability:GetSpecialValueFor("cleave_radius")
	self.hp_regen = ability:GetSpecialValueFor("hp_regen")
	self.mp_regen = ability:GetSpecialValueFor("mp_regen_pct")
end

function modifier_war_axe_passive:IsPurgable(  )return false end

function modifier_war_axe_passive:DeclareFunctions(  )
	local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return funcs
end

function modifier_war_axe_passive:GetModifierPreAttack_BonusDamage(  )return self.damage end

function modifier_war_axe_passive:GetModifierConstantHealthRegen(  )return self.hp_regen end

function modifier_war_axe_passive:GetModifierTotalPercentageManaRegen (  )return 1 + self.mp_regen/100 end

function modifier_war_axe_passive:OnAttackLanded( params )
	local caster = self:GetParent()
	local target = params.target

	if IsServer() and params.attacker == caster and not caster:IsRangedAttacker() and not target:IsMagicImmune() then
		damage = params.damage
		local ability = self:GetAbility()
		target:SplashDamage(damage,self.cleave_pct,DAMAGE_TYPE_PHYSICAL,false,caster,self.cleave_radius,ability)
	end
end