if item_lightning_rod == nil then item_lightning_rod = class({}) end
LinkLuaModifier("modifier_lightning_rod_passive","items/item_lightning_rod.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stun","libraries/modifiers/modifier_stun.lua",LUA_MODIFIER_MOTION_NONE)

function item_lightning_rod:GetIntrinsicModifierName(  )
	return "modifier_lightning_rod_passive"
end

if modifier_lightning_rod_passive == nil then modifier_lightning_rod_passive = class({}) end

function modifier_lightning_rod_passive:IsHidden(  )
	return true
end

function modifier_lightning_rod_passive:IsPurgable(  )
	return false
end

function modifier_lightning_rod_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_lightning_rod_passive:CheckState(  )
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end

function modifier_lightning_rod_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.chance = ability:GetSpecialValueFor("chance")
	self.damage = ability:GetSpecialValueFor("damage")
	self.range = ability:GetSpecialValueFor("radius")
	self.jump_count = ability:GetSpecialValueFor("lightning_count")
	self.damage_b = ability:GetSpecialValueFor("damage_b")
	self.chance_b = ability:GetSpecialValueFor("chance_b")
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.atk = ability:GetSpecialValueFor("atk")
end

function modifier_lightning_rod_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if caster:IsIllusion() then return end
	if params.attacker == caster then 
		self.proc = false
		local ability = self:GetAbility()
		if IsSummoned(caster) then 
			self.chance = self.chance / 2 
			self.jump_count = self.jump_count / 2 
		end
		
		if RollPercentage(self.chance) then
			self.proc = true
			if self:IsActiveOrb() then
				caster:CreateBashingLightning(ability, self.damage, self.range, self.jump_count, DAMAGE_TYPE_MAGICAL, params.target, nil, self.damage_b, self.chance_b)
			end
		else
			self.proc = false
		end
	end
end

function modifier_lightning_rod_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_lightning_rod_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

function modifier_lightning_rod_passive:GetModifierOrbPriority(  )
	if self.proc == true then
		return DOTA_ORB_PRIORITY_ITEM_UNIQUE
	else
		return DOTA_ORB_PRIORITY_FALSE
	end
end