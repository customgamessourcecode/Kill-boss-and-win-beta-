if item_lesser_lightning == nil then item_lesser_lightning = class({}) end

LinkLuaModifier("modifier_lesser_lightning_passive","items/item_lesser_lightning.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lesser_lightning_override","items/item_lesser_lightning.lua",LUA_MODIFIER_MOTION_NONE)

function item_lesser_lightning:GetIntrinsicModifierName(  )
	return "modifier_lesser_lightning_passive"
end

function item_lesser_lightning:OnSpellStart(  )
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_lesser_lightning_override",{duration = self:GetSpecialValueFor("duration")})
end

if modifier_lesser_lightning_passive == nil then modifier_lesser_lightning_passive = class({}) end

function modifier_lesser_lightning_passive:IsHidden(  )
	return true
end

function modifier_lesser_lightning_passive:IsPurgable(  )
	return false
end

function modifier_lesser_lightning_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_lesser_lightning_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.atk = ability:GetSpecialValueFor("atk")
	self.lightning_damage = ability:GetSpecialValueFor("lightning_damage")
	self.lightning_range = ability:GetSpecialValueFor("lightning_range")
	self.chance = ability:GetSpecialValueFor("chance")
	self.jump_count = ability:GetSpecialValueFor("jump_count")
	self.mult = ability:GetSpecialValueFor("damage_multiplier")
end

function modifier_lesser_lightning_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_lesser_lightning_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

function modifier_lesser_lightning_passive:GetModifierOrbPriority(  )
	if self.succes == true then
		return DOTA_ORB_PRIORITY_ITEM_UNIQUE
	else
		return DOTA_ORB_PRIORITY_FALSE
	end
	return DOTA_ORB_PRIORITY_FALSE
end

function modifier_lesser_lightning_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then
		self.succes = false
		if not caster:IsRealHero() then self.chance = self.chance / 2 self.jump_count = self.jump_count / 2 end
		if RollPercentage(self.chance) then
			self.succes = true
			if self:IsActiveOrb() then
				local damage = self.lightning_damage
				print("Start Lightning")
				if caster:HasModifier("modifier_lesser_lightning_override") then damage = self.lightning_damage * self.mult * 0.01 else damage = self.lightning_damage end 
				caster:CreateLightning(ability, 
					damage, 
					self.lightning_range, 
					self.jump_count,
					DAMAGE_TYPE_MAGICAL,
					params.target)
				print("Damage = "..damage.." | Range = "..self.lightning_range.." | Jumps count = "..self.jump_count)
			end
		end
	end
end

if modifier_lesser_lightning_override == nil then modifier_lesser_lightning_override = class({}) end

function modifier_lesser_lightning_override:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_lesser_lightning_override:IsPurgable(  )
	return false
end

function modifier_lesser_lightning_override:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_lesser_lightning_override:OnCreated(  )
	self.mult = self:GetAbility():GetSpecialValueFor("damage_multiplier")
end

function modifier_lesser_lightning_override:OnTooltip(  )
	return self.mult
end