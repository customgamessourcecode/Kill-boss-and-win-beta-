LinkLuaModifier( "modifier_spartacus_sword_of_vengance", "heroes/hero_spartacus/spartacus_sword_of_vengance.lua", LUA_MODIFIER_MOTION_NONE )			-- Owner's bonus attributes, stackable
LinkLuaModifier( "modifier_spartacus_sword_of_vengance_debuff", "heroes/hero_spartacus/spartacus_sword_of_vengance.lua", LUA_MODIFIER_MOTION_NONE )			-- Owner's bonus attributes, stackable

if spartacus_sword_of_vengance == nil then spartacus_sword_of_vengance = class({}) end


function spartacus_sword_of_vengance:GetIntrinsicModifierName()
	return "modifier_spartacus_sword_of_vengance" end

-----------------------------------------------------------------------------------------------------------
--	Sange passive modifier (stackable)
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
--	Sange and Yasha passive modifier (stackable)
-----------------------------------------------------------------------------------------------------------

if modifier_spartacus_sword_of_vengance == nil then modifier_spartacus_sword_of_vengance = class({}) end
function modifier_spartacus_sword_of_vengance:IsHidden() return true end
function modifier_spartacus_sword_of_vengance:IsDebuff() return false end
function modifier_spartacus_sword_of_vengance:IsPurgable() return false end
function modifier_spartacus_sword_of_vengance:IsPermanent() return true end
function modifier_spartacus_sword_of_vengance:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- Declare modifier events/properties
function modifier_spartacus_sword_of_vengance:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end


-- On attack landed, roll for proc and apply stacks
function modifier_spartacus_sword_of_vengance:OnAttackLanded( keys )
	if IsServer() then
		local caster = self:GetParent()
		local target = keys.target
		local ability = self:GetAbility()
		local debuff_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
		local trigger_chance = self:GetAbility():GetSpecialValueFor("trigger_chance")
		local ability_damage = self:GetAbility():GetSpecialValueFor("ability_damage")
		
		-- If this attack was not performed by the modifier's owner, do nothing
		if caster ~= keys.attacker then
			return end

--		if math.random(1,100) <= trigger_chance then
--			target:AddNewModifier( caster, self, "modifier_spartacus_sword_of_vengance_debuff", { duration = duration } )

			if ability:IsCooldownReady() and RollPercentage(ability:GetSpecialValueFor("trigger_chance")) then

				-- Proc! Apply the disarm/silence modifier
				target:AddNewModifier(caster, ability, "modifier_spartacus_sword_of_vengance_debuff", {duration = debuff_duration})
				--target:AddNewModifier( caster, self, "modifier_spartacus_sword_of_vengance_debuff", { duration = duration } )
				ApplyDamage({
					attacker = caster,
					victim = target,
					damage_type = self:GetAbility():GetAbilityDamageType(),
					ability = self:GetAbility(),
					damage = ability_damage
				})				
				target:EmitSound("Imba.SangeProc")
				ability:UseResources(false, false, true)
			end
--		end
	end
end

-----------------------------------------------------------------------------------------------------------
--	Sange and Yasha disarm debuff
-----------------------------------------------------------------------------------------------------------

if modifier_spartacus_sword_of_vengance_debuff == nil then modifier_spartacus_sword_of_vengance_debuff = class({}) end
function modifier_spartacus_sword_of_vengance_debuff:IsHidden() return true end
function modifier_spartacus_sword_of_vengance_debuff:IsDebuff() return true end
function modifier_spartacus_sword_of_vengance_debuff:IsPurgable() return true end

-- Modifier particle


function modifier_spartacus_sword_of_vengance_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- Declare modifier states
function modifier_spartacus_sword_of_vengance_debuff:CheckState()
	local states = {
		[MODIFIER_STATE_DISARMED] = true,
	}
	return states
end

