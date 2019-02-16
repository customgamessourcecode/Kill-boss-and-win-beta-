function spear(event)
local caster = event.caster
local target = event.target
local hits = 1 + math.random(4)
local dur = (hits * 0.4) + 0.1
if caster:GetPrimaryAttribute() == 0 then 
	dmg = caster:GetStrength()
	end

if caster:GetPrimaryAttribute() == 1 then 
	dmg = caster:GetAgility()
	end
	
if caster:GetPrimaryAttribute() == 2 then 
	dmg = caster:GetIntellect()
end
event.ability:ApplyDataDrivenModifier(caster, target,"modifier_item_renegra_cast", {duration = dur})
ApplyDamage({ victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL })
target:EmitSound("Hero_TemplarAssassin.Trap.Explode")
local particle = ParticleManager:CreateParticle("particles/items/reniga/nevermore_shadowraze.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(0, 0, 0))
end

function hit(event)
local caster = event.caster
local target = event.target
local ability = event.ability
local dmg = 0
if caster:GetPrimaryAttribute() == 0 then 
	dmg = caster:GetStrength()
	end

if caster:GetPrimaryAttribute() == 1 then 
	dmg = caster:GetAgility()
	end
	
if caster:GetPrimaryAttribute() == 2 then 
	dmg = caster:GetIntellect()
end

ApplyDamage({ victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL })
target:EmitSound("Hero_TemplarAssassin.Trap.Explode")
local particle = ParticleManager:CreateParticle("particles/items/reniga/nevermore_shadowraze.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(0, 0, 0))
end

function start(keys)
  local caster = keys.caster
  local i = 1
  local ability = keys.ability
  Timers:CreateTimer(0, function()
    if ability:IsChanneling() then
      caster:EmitSound("DOTA_Item.Orchid.Activate")
      local particle = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explosion_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
      ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0, 0, 0))
      ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() + Vector(0, 0, 0))
      ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin() + Vector(0, 0, 0))
      i = i + 1
    end
  if i < 4 then return 0.3 else return nil end
  end)
end
