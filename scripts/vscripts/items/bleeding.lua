function bleed(event)
local target = event.target
local caster = event.caster
local damage = target:GetMaxHealth() * 0.03
ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })

if event.ability:IsCooldownReady() then
	event.ability:StartCooldown(event.ability:GetCooldown(event.ability:GetLevel()))			
	end
end