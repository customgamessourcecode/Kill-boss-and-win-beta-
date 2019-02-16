function heal(keys)
	if IsServer() then
		--local ability = keys.ability
		local percentage = 25 * 0.01 --ability:GetSpecialValueFor("total_health_x") * 0.01
		local hp_regen_base = 40 --ability:GetSpecialValueFor("health_per_second")

		local hpreg = percentage * keys.target:GetMaxHealth() * 0.01 + hp_regen_base / 10
		keys.target:Heal(hpreg,keys.target)
	end
end