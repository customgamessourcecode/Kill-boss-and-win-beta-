if item_demonic_axe == nil then	item_demonic_axe = class({})end

LinkLuaModifier("modifier_demonic_axe_passive","items/item_demonic_axe.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demonic_axe_spell","items/item_demonic_axe.lua",LUA_MODIFIER_MOTION_NONE)

function item_demonic_axe:GetIntrinsicModifierName(  ) return "modifier_demonic_axe_passive" end

function item_demonic_axe:OnSpellStart(  )
	self:GetCaster():EmitSound("DOTA_Item.MaskOfMadness.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_demonic_axe_spell",{duration = self:GetSpecialValueFor("duration")})
end

--------------------------------------

if modifier_demonic_axe_passive == nil then	modifier_demonic_axe_passive = class({})end

function modifier_demonic_axe_passive:GetAttributes(  )return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_demonic_axe_passive:IsHidden(  )return true end

function modifier_demonic_axe_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
	self.str = ability:GetSpecialValueFor("str")
	self.armor = ability:GetSpecialValueFor("armor")
	self.hp_mp = ability:GetSpecialValueFor("hp_mp")
	self.agi_int = ability:GetSpecialValueFor("agi_int")
	self.cleave_pct = ability:GetSpecialValueFor("cleave_damage_percent")
	self.cleave_radius = ability:GetSpecialValueFor("cleave_radius")
	self.lifesteal = ability:GetSpecialValueFor("lifesteal")
	self.hp_regen = ability:GetSpecialValueFor("hp_regen")
	self.mp_regen = ability:GetSpecialValueFor("mp_regen")
	self.quell = ability:GetSpecialValueFor("quell") 
	self.quell_ranged = ability:GetSpecialValueFor("quell_ranged") 
end

function modifier_demonic_axe_passive:IsPurgable(  )return false end

function modifier_demonic_axe_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
	return hFuncs
end

function modifier_demonic_axe_passive:GetModifierPreAttack_BonusDamage(  )return self.damage end

function modifier_demonic_axe_passive:GetModifierBonusStats_Strength(  )return self.str end

function modifier_demonic_axe_passive:GetModifierBonusStats_Intellect(  )return self.agi_int end

function modifier_demonic_axe_passive:GetModifierBonusStats_Agility(  )return self.agi_int end

function modifier_demonic_axe_passive:GetModifierHealthBonus(  )return self.hp_mp end

function modifier_demonic_axe_passive:GetModifierManaBonus(  )return self.hp_mp end

function modifier_demonic_axe_passive:GetModifierConstantHealthRegen(  )return self.hp_regen end

function modifier_demonic_axe_passive:GetModifierTotalPercentageManaRegen(  )return 1 + self.mp_regen/100 end

function modifier_demonic_axe_passive:GetModifierPhysicalArmorBonus(  )return self.armor end

function modifier_demonic_axe_passive:GetModifierOrbPriority()
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_demonic_axe_passive:OnAttackLanded( params )
	local caster = self:GetParent()
	local target = params.target

	if IsServer() and params.attacker == caster then
		damage = params.damage
		local ability = self:GetAbility()

		if caster:IsRealHero() then
				print('This unit is boss, Quell dont work on boss')
				return;
			else
				if target:IsCreep() then
					local quell = nil

					if self:GetCaster():IsRangedAttacker() then
						quell = self.quell_ranged
					else
						quell = self.quell
					end

					local damage_quell = (damage  * self.quell - damage) / 100

					ApplyDamage({victim = target, attacker = caster, damage = damage_quell, damage_type = DAMAGE_TYPE_PHYSICAL})
				end
			end

			if not caster:IsRangedAttacker() and not target:IsMagicImmune() then
				target:SplashDamage(damage, self.cleave_pct,DAMAGE_TYPE_PHYSICAL,false,caster,self.cleave_radius,ability)
			end

			if self:IsActiveOrb() then
				local heal = params.damage * self.lifesteal / 100
				caster:HealCustom(heal,caster,true)
			end
		end
	end
end

-------------------------------------

if modifier_demonic_axe_spell == nil then modifier_demonic_axe_spell = class({})end

function modifier_demonic_axe_spell:GetTexture(  )return "item_demonic_axe"end

function modifier_demonic_axe_spell:GetEffectName()return "particles/ui/ui_lina_goalburst_1.vpcf"end
 
function modifier_demonic_axe_spell:GetEffectAttachType()return PATTACH_OVERHEAD_FOLLOW end

function modifier_demonic_axe_spell:DeclareFunctions(  )local hFuncs = { MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_EVENT_ON_ATTACK_LANDED }return hFuncs end

function modifier_demonic_axe_spell:OnCreated(  )
	local ability = self:GetAbility()
	self.lifesteal_act = ability:GetSpecialValueFor("lifesteal_prc_act") 
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.atk = ability:GetSpecialValueFor("atk")
end

function modifier_demonic_axe_spell:GetModifierAttackSpeedBonus_Constant(  )return self.atk end

function modifier_demonic_axe_spell:GetModifierDamageOutgoing_Percentage(  )return self.dmg end

function modifier_demonic_axe_spell:OnAttackLanded( params )
	local caster = self:GetParent()
	local target = params.target
	if IsServer() and params.attacker == caster then
		local ability = self:GetAbility()
		local heal = target:GetHealth() * self.lifesteal_act / 100
		local name = target:GetUnitName()
		if IsBoss(target) then
			heal = heal / 4
		end
		caster:HealCustom(heal,caster,false)
		ApplyDamage({victim = target, attacker = caster, damage = heal, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end