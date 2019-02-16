function CursedBlade( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local modifier2 = keys.modifier2
	local max_stacks = ability:GetLevelSpecialValueFor("number_stacks", ability_level)
	local max_stacks2 = ability:GetLevelSpecialValueFor("number_stacks2", ability_level)
	local level = ability:GetLevel() - 1
	local cooldown = ability:GetCooldown(level)
	local modifierName = "modifier_akame_cursed_blade"
	
if caster:IsIllusion() == false then
		if caster.fervor_target then
			if caster.fervor_target == target then
				if target:HasModifier(modifier) then
					local stack_count = target:GetModifierStackCount(modifier, ability)
					
					if stack_count < max_stacks then
						target:SetModifierStackCount(modifier, ability, stack_count + 1)
					end
					
					if stack_count == max_stacks2 then
						ability:ApplyDataDrivenModifier(caster, caster, modifier2, {})
						target:RemoveModifierByName(modifier)
						
						ability:StartCooldown(cooldown)

						caster:RemoveModifierByName(modifierName) 

						Timers:CreateTimer(cooldown, function()
							ability:ApplyDataDrivenModifier(caster, caster, modifierName, {})
						end)
					end
				else
					ability:ApplyDataDrivenModifier(target, target, modifier, {})
					target:SetModifierStackCount(modifier, ability, 1)
				end	
			else
				target:RemoveModifierByName(modifier)
				caster.fervor_target = target
			end
		else
			caster.fervor_target = target
		end
		end
end

function CursedBladeStacks( event )

	local target = event.target
	local caster = event.caster
	local ability = event.ability
	local modifier = "modifier_cursed_blade_stack_count"
	local stack_count = target:GetModifierStackCount(modifier, ability)

	local integer = math.floor(math.abs(stack_count))
	
	if caster:IsIllusion() == false then	
		local particle = ParticleManager:CreateParticle( "particles/akame/skill_stacks.vpcf", PATTACH_OVERHEAD_FOLLOW, target )			
		ParticleManager:SetParticleControl( particle, 1, Vector( 0, integer, 0) )
	end
end

function CursedBladeDamage( keys )

	local caster = keys.caster
	local target = keys.target
	local damage = target:GetMaxHealth() / 100 * 25
	local ability = keys.ability
	
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end