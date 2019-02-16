function kill(event)

if event.ability:IsCooldownReady() then
	local caster = event.caster
	local killed = event.unit
	local lvl = killed:GetLevel()
	local mana = caster:GetMana() + 5 * lvl
	caster:SetMana(mana)
	local particle = ParticleManager:CreateParticle("particles/items3_fx/mango_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, -20))
	caster:EmitSound("DOTA_Item.Mango.Activate")
	event.ability:StartCooldown(event.ability:GetCooldown(event.ability:GetLevel()))			
	end
end