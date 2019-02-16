function healing(event)
local caster = event.caster
local health = caster:GetHealth()
local heal = health / 10
caster:Heal(heal,caster)
print("healed")
end

function damage(event)
local caster = event.caster
local target = event.attacker
local damage = event.damage
ApplyDamage({ victim = target, attacker = caster, damage = 20, damage_type = DAMAGE_TYPE_MAGICAL })
end