function shinobu_attack(keys)
	if keys.ability ~= nil then
		local caster = keys.caster
		local ability = keys.ability
		local target = keys.target
		local modifier = "modifier_shinobu_agi"
		local lua_modifier = "modifier_shinobu_Agi_bonus"
		local stack = ability:GetSpecialValueFor("stack")
		local limit = ability:GetSpecialValueFor("limit")
		local dur = inf
		local lua_stack = caster:GetModifierStackCount( lua_modifier, ability )
		local current_stack = caster:GetModifierStackCount( modifier, ability )
		if target:IsHero() then	
			if caster:HasModifier( modifier ) then
				ability:ApplyDataDrivenModifier( caster, caster, modifier, { Duration = dur })
				caster:SetModifierStackCount( modifier, ability, current_stack + stack )
			else
				ability:ApplyDataDrivenModifier( caster, caster, modifier, { Duration = dur })
				caster:SetModifierStackCount( modifier, ability, stack )
			end
		
			if current_stack >= limit then
				if caster:HasModifier( lua_modifier ) then	
					caster:RemoveModifierByName(modifier)
					caster:SetModifierStackCount( lua_modifier, ability, lua_stack + 1  )
				else
					caster:AddNewModifier( caster, ability, lua_modifier, {duration = -1})
				end
			end
		end
	end
end

function Shinobu_death(keys)
	if keys.ability ~= nil then
		local caster = keys.caster
		local ability = keys.ability
		local modifier = "modifier_shinobu_agi"
		local stack_bonus = ability:GetSpecialValueFor("stack_bonus") 
		local lua_modifier = "modifier_shinobu_Agi_bonus"
		local stack = ability:GetSpecialValueFor("stack") * (stack_bonus - 1)
		local limit = ability:GetSpecialValueFor("limit")
		local dur = inf
		local lua_stack = caster:GetModifierStackCount( lua_modifier, ability )
		local current_stack = caster:GetModifierStackCount( modifier, ability )
		local talent = caster:FindAbilityByName("special_bonus_shinobu_5")	
		if caster:HasTalent("special_bonus_shinobu_5") then
			if caster:HasModifier( lua_modifier ) then	
				caster:SetModifierStackCount( lua_modifier, ability, lua_stack + 1  )
			else
				caster:AddNewModifier( caster, ability, lua_modifier, {duration = -1})
				caster:SetModifierStackCount( lua_modifier, ability, 1  )
			end
		else
			if caster:HasModifier( modifier ) then
				ability:ApplyDataDrivenModifier( caster, caster, modifier, { Duration = dur })
				caster:SetModifierStackCount( modifier, ability, current_stack + stack )
			else
				ability:ApplyDataDrivenModifier( caster, caster, modifier, { Duration = dur })
				caster:SetModifierStackCount( modifier, ability, stack )
			end
			if current_stack >= limit then
				if caster:HasModifier( lua_modifier ) then	
					caster:RemoveModifierByName(modifier)
					caster:SetModifierStackCount( lua_modifier, ability, lua_stack + 1  )
				else
					caster:AddNewModifier( caster, ability, lua_modifier, {duration = -1})
				end
			end
		end
	end
end