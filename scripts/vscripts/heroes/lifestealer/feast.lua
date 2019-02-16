function OnAttack(event)
	local ability	= event.ability
	local target 	= event.target
	local heal_pct 	= event.heal_pct	or 0
	local caster 	= event.caster

	if caster:IsIllusion() or target:IsIllusion() then return end
	if caster:PassivesDisabled() then return end

	heal_pct = heal_pct + caster:GetTalentSpecialValueFor("special_bonus_unique_lifestealer_3")
	
	local damage = target:GetHealth() * heal_pct / 100

	if IsUnitBossGlobal(target) then
		damage = damage / 3
	end

	local armor = (( (0.05 * target:GetPhysicalArmorValue() )/(1+ 0.05*target:GetPhysicalArmorValue() ) )) / 2
	if armor < 0 then armor = 0 end

	local heal = damage - damage*armor

	if (target:GetPhysicalArmorValue() < 0) then
		heal = damage;
	end

	if heal < 1 or damage < 1 then return end

	ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_PHYSICAL })

	if heal > caster:GetHealth() then return end

	if not IsUnitBossGlobal(target) then
		caster:Heal(heal, caster) 
	end

end