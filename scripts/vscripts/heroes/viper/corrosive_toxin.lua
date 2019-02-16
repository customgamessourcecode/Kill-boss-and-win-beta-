function OnAttackLanded(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local disarmor_pct = event.Disarmor_pct / 100
	local constant_damage_pct = event.Constant_damage_pct / 100
	local dmg_per_hp = event.Damage_per_hp / 100
	local duration = event.Duration 
	local modifier_name_stack = event.ModifierName
	local modifier_name = event.ModifierDisArmor
	local damage = 0
	local health = 0
	local multipler = 0
	
	if not caster or not target then return end
	if caster:IsIllusion() then return end

	health = target:GetHealth() / target:GetMaxHealth() 
	
	if health > 0.8 then
		multipler = 1
	elseif health > 0.6 then
		multipler = 2
	elseif health > 0.4 then
		multipler = 3
	elseif health > 0.2 then
		multipler = 4
	elseif health > 0 then
		multipler = 5
	end
	
	damage = (target:GetMaxHealth() - target:GetHealth())*(constant_damage_pct + dmg_per_hp*multipler)

	if not caster:IsRealHero() then
		disarmor_pct = disarmor_pct / 2 
		damage = damage / 2
	end
	if IsUnitBossGlobal(target) then
		damage = damage / 5
	end
	if caster:HasModifier(modifier_name_stack) then
		ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_PHYSICAL })
		ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration}) 
		target:SetModifierStackCount(modifier_name, caster, target:GetPhysicalArmorValue()*disarmor_pct*multipler)

		print("damage = ", damage)
		if target:IsHero() or IsUnitBossGlobal(target) then
			if caster:GetModifierStackCount(modifier_name_stack, ability) == 1 then 
				caster:RemoveModifierByName(modifier_name_stack)
			end
			caster:SetModifierStackCount(modifier_name_stack, caster, caster:GetModifierStackCount(modifier_name_stack, ability) - 1)
		end
	end
end

function RecoveryCharge(event)
	local caster = event.caster
	local ability = event.ability
	local modifier_name = event.ModifierName
	local max_stack = event.Max_stack
	
	if not caster or not ability or not modifier_name or not max_stack then return end
	if caster:IsIllusion() then return end

	if not caster:HasModifier(modifier_name) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_name, { duration = -1 }) 
	end

	if caster:GetModifierStackCount(modifier_name, ability) < max_stack then
		caster:SetModifierStackCount(modifier_name, caster, caster:GetModifierStackCount(modifier_name, ability) + 1) -- increase modifier_stack
	end
end