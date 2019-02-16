if boss_ability_hardcore == nil then
	boss_ability_hardcore = class({})
end

LinkLuaModifier("boss_ability_hardcore_modifier_block","boss_abilities/boss_ability_hardcore.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("boss_ability_hardcore_modifier_damage","boss_abilities/boss_ability_hardcore.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("boss_ability_hardcore_modifier_evasion","boss_abilities/boss_ability_hardcore.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("boss_ability_hardcore_modifier_true","boss_abilities/boss_ability_hardcore.lua",LUA_MODIFIER_MOTION_NONE)

function boss_ability_hardcore:GetIntrinsicModifierName(  )
	return "boss_ability_hardcore_modifier_block"
end

---------------------------------------------

if boss_ability_hardcore_modifier_block == nil then
	boss_ability_hardcore_modifier_block = class({})
end

function boss_ability_hardcore_modifier_block:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_ATTACK_START,MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK }
	return hFuncs
end

function boss_ability_hardcore_modifier_block:IsHidden(  )
	return true
end

function boss_ability_hardcore_modifier_block:GetModifierPhysical_ConstantBlock(  )
	if IsServer() and not self:GetCaster():PassivesDisabled() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local hp  = caster:GetHealthPercent()
		local prc = ability:GetSpecialValueFor("block_prc")
		local block = (prc / hp) * 10

		if block >= prc then
			return prc
		end

		return block
	else
		return nil
	end
end

function boss_ability_hardcore_modifier_block:OnAttackStart( params )
	if IsServer() and self:GetAbility():IsCooldownReady() and not self:GetCaster():PassivesDisabled() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		

		if attacker == caster then

			if not target:IsMagicImmune() then
				if target:HasModifier("boss_ability_hardcore_modifier_evasion") then
					if target:GetModifierStackCount("boss_ability_hardcore_modifier_evasion", caster) * self:GetAbility():GetSpecialValueFor("eps") <= 100 then
						local stacks = target:GetModifierStackCount("boss_ability_hardcore_modifier_evasion", caster)
						target:SetModifierStackCount("boss_ability_hardcore_modifier_evasion", caster, stacks + 1)
					end
				end

				target:AddNewModifier(caster, ability, "boss_ability_hardcore_modifier_evasion", {duration = self:GetAbility():GetSpecialValueFor("eva_duration")})

				local stacks = target:GetModifierStackCount("boss_ability_hardcore_modifier_evasion", caster)
				local chance = target:GetModifierStackCount("boss_ability_hardcore_modifier_evasion", caster) * self:GetAbility():GetSpecialValueFor("eps")
				if RollPercentage(chance) then
					caster:AddNewModifier(caster,ability, "boss_ability_hardcore_modifier_true", {})
				end
			end
		end
	end
end

function boss_ability_hardcore_modifier_block:OnAttackLanded( params )
	if IsServer() and self:GetAbility():IsCooldownReady() and not self:GetCaster():PassivesDisabled() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker

		if attacker == caster then
			if not target:IsMagicImmune() then

				target:AddNewModifier(caster, ability, "boss_ability_hardcore_modifier_damage", {duration = self:GetAbility():GetSpecialValueFor("dmg_duration")})
				
				local stacks = target:GetModifierStackCount("boss_ability_hardcore_modifier_damage", caster)
				target:SetModifierStackCount("boss_ability_hardcore_modifier_damage", caster, stacks + 1)
			end
		end
	end
end

-------------------------

if boss_ability_hardcore_modifier_evasion == nil then
	boss_ability_hardcore_modifier_evasion = class({})
end

function boss_ability_hardcore_modifier_evasion:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_TOOLTIP }
	return hFuncs
end

function boss_ability_hardcore_modifier_evasion:IsDebuff(  )
	return true
end

function boss_ability_hardcore_modifier_evasion:IsPurgable(  )
	return false
end

function boss_ability_hardcore_modifier_evasion:IsHidden(  )
	return false
end

function boss_ability_hardcore_modifier_evasion:GetTexture(  )
	return "boss_ability_hardcore"
end

function boss_ability_hardcore_modifier_evasion:OnTooltip(  )
	local chance = self:GetAbility():GetSpecialValueFor("eps") * self:GetStackCount()

	if chance >= 100 then chance = 100 end

	return chance 
end

-----------------------

if boss_ability_hardcore_modifier_damage == nil then
	boss_ability_hardcore_modifier_damage = class({})
end

function boss_ability_hardcore_modifier_damage:IsHidden(  )
	return false
end

function boss_ability_hardcore_modifier_damage:IsDebuff(  )
	return true
end

function boss_ability_hardcore_modifier_damage:IsPurgable(  )
	return true
end

function boss_ability_hardcore_modifier_damage:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_TOOLTIP,MODIFIER_EVENT_ON_ATTACK_LANDED }
	return hFuncs
end

function boss_ability_hardcore_modifier_damage:GetTexture(  )
	return "boss_ability_hardcore"
end

function boss_ability_hardcore_modifier_damage:OnAttackLanded( params )
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		if attacker == caster and target == self:GetParent() then
			local damage = ability:GetSpecialValueFor("bdps") * self:GetStackCount()

			if attacker == caster then
				ApplyDamage({victim = target,attacker = attacker, damage = damage * params.damage * 0.01, damage_type = DAMAGE_TYPE_PHYSICAL})
			end
		end
	end
end

function boss_ability_hardcore_modifier_damage:OnTooltip(  )
	return self:GetAbility():GetSpecialValueFor("bdps") * self:GetStackCount()
end

--------------------

if boss_ability_hardcore_modifier_true == nil then
	boss_ability_hardcore_modifier_true = class({})
end

function boss_ability_hardcore_modifier_true:IsHidden(  )
	return true
end

function boss_ability_hardcore_modifier_true:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_ATTACK_LANDED }
	return hFuncs
end

function boss_ability_hardcore_modifier_true:CheckState()
	local states = { [MODIFIER_STATE_CANNOT_MISS] = true }
	return states
end

function boss_ability_hardcore_modifier_true:OnAttackLanded(  )
	if IsServer() then
		self:GetCaster():RemoveModifierByName("boss_ability_hardcore_modifier_true")
	end
end