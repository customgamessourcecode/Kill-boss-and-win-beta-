require('libraries/timers')
function CDOTA_BaseNPC:CreateLightning( ability, damage, range, jump_count, damage_type, old_target, particle )
  local particle_name
  if particle == nil then particle_name = "particles/lightning_custom.vpcf" else particle_name = particle end
  local caster = self
  local counts = 0
  
  local units = FindUnitsInRadius(
    caster:GetTeamNumber(),
    old_target:GetAbsOrigin(),
    nil,
    range,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_ALL,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false)

  if old_target and old_target:TotalEnemyHeroesInRange(range,caster) <= 1 then 
    if old_target:IsMagicImmune() then
      print("Target is magic immune")
    else
      old_target:EmitSound("Hero_Leshrac.Lightning_Storm")
      local id1 = ParticleManager:CreateParticle(particle_name,PATTACH_ABSORIGIN_FOLLOW, old_target)
      local id2 = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_talon_explosion_flash.vpcf",PATTACH_ABSORIGIN_FOLLOW, old_target)
      ParticleManager:SetParticleControl(id1, 1, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+caster:GetBoundingMaxs().z))
      ParticleManager:SetParticleControl(id1, 0, Vector(old_target:GetAbsOrigin().x,old_target:GetAbsOrigin().y,old_target:GetAbsOrigin().z+old_target:GetBoundingMaxs().z))
      ParticleManager:SetParticleControl(id2, 5, old_target:GetAbsOrigin())
      ApplyDamage({victim = old_target, attacker = caster, damage = damage, damage_type = damage_type})
    end
    return nil;
  else
    local delay = 0
    for _, target in pairs(units) do
      delay = delay + 0.15
      Timers:CreateTimer(delay, function()
        if counts < jump_count and old_target ~= nil then
          counts = counts + 1
          local new_target = old_target:RandomEnemyHeroInRange(range, true,caster)
          if new_target ~= nil then
            if target:IsMagicImmune() then
              print("Target is magic immune")
            else
              old_target:EmitSound("Hero_Leshrac.Lightning_Storm")
              local id1 = ParticleManager:CreateParticle(particle_name,PATTACH_ABSORIGIN_FOLLOW, new_target)
              local id2 = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_talon_explosion_flash.vpcf",PATTACH_ABSORIGIN_FOLLOW, new_target)
              ParticleManager:SetParticleControl(id1, 1, Vector(old_target:GetAbsOrigin().x,old_target:GetAbsOrigin().y,old_target:GetAbsOrigin().z+old_target:GetBoundingMaxs().z))
              ParticleManager:SetParticleControl(id1, 0, Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z+new_target:GetBoundingMaxs().z))
              ParticleManager:SetParticleControl(id2, 5, new_target:GetAbsOrigin())
              ApplyDamage({victim = new_target, attacker = caster, damage = damage, damage_type = damage_type})
            end
            old_target = new_target
          end
        else
          return nil;
        end
      end)
    end
  end
end

function CDOTA_BaseNPC:CreateBashingLightning( ability, damage, range, jump_count, damage_type, old_target, particle, bash_damage, bash_chance )
  local particle_name
  if particle == nil then particle_name = "particles/lightning_custom.vpcf" else particle_name = particle end
  local caster = self
  local counts = 0
  
  local units = FindUnitsInRadius(
    caster:GetTeamNumber(),
    old_target:GetAbsOrigin(),
    nil,
    range,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_ALL,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false)

  if old_target and old_target:TotalEnemyHeroesInRange(range,caster) <= 1 then 
    if old_target:IsMagicImmune() then
      print("Target is magic immune")
    else
      if RollPercentage(bash_chance) then 
        old_target:AddNewModifier(caster, ability, "modifier_stun",{duration = 0.1}) 
        ApplyDamage({victim = old_target, attacker = caster, damage = bash_damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = ability}) 
      end
      old_target:EmitSound("Hero_Leshrac.Lightning_Storm")
      local id1 = ParticleManager:CreateParticle(particle_name,PATTACH_ABSORIGIN_FOLLOW, old_target)
      local id2 = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_talon_explosion_flash.vpcf",PATTACH_ABSORIGIN_FOLLOW, old_target)
      ParticleManager:SetParticleControl(id1, 1, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+caster:GetBoundingMaxs().z))
      ParticleManager:SetParticleControl(id1, 0, Vector(old_target:GetAbsOrigin().x,old_target:GetAbsOrigin().y,old_target:GetAbsOrigin().z+old_target:GetBoundingMaxs().z))
      ParticleManager:SetParticleControl(id2, 5, old_target:GetAbsOrigin())
      ApplyDamage({victim = old_target, attacker = caster, damage = damage, damage_type = damage_type})
    end
    return nil;
  else
    local delay = 0
    for _, target in pairs(units) do
      delay = delay + 0.15
      Timers:CreateTimer(delay, function()
        if counts < jump_count and old_target ~= nil then
          counts = counts + 1
          local new_target = old_target:RandomEnemyHeroInRange(range, true,caster)
          if new_target ~= nil then
            if target:IsMagicImmune() then
              print("Target is magic immune")
            else
              if RollPercentage(bash_chance) then 
            old_target:AddNewModifier(caster, ability, "modifier_stun",{duration = 0.1}) 
            ApplyDamage({victim = new_target, attacker = caster, damage = bash_damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = ability}) 
          end
              old_target:EmitSound("Hero_Leshrac.Lightning_Storm")
              local id1 = ParticleManager:CreateParticle(particle_name,PATTACH_ABSORIGIN_FOLLOW, new_target)
              local id2 = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_talon_explosion_flash.vpcf",PATTACH_ABSORIGIN_FOLLOW, new_target)
              ParticleManager:SetParticleControl(id1, 1, Vector(old_target:GetAbsOrigin().x,old_target:GetAbsOrigin().y,old_target:GetAbsOrigin().z+old_target:GetBoundingMaxs().z))
              ParticleManager:SetParticleControl(id1, 0, Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z+new_target:GetBoundingMaxs().z))
              ParticleManager:SetParticleControl(id2, 5, new_target:GetAbsOrigin())
              ApplyDamage({victim = new_target, attacker = caster, damage = damage, damage_type = damage_type})
            end
            old_target = new_target
          end
        else
          return nil;
        end
      end)
    end
  end
end

function CDOTA_BaseNPC:TotalEnemyHeroesInRange(range, caster)
  local target = self
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  local enemies = FindUnitsInRadius( caster:GetTeam(), target:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
  
  local count = 0
  
  for _,enemy in pairs(enemies) do
    local distanceToEnemy = (target:GetAbsOrigin() - enemy:GetAbsOrigin()):Length()
    if enemy:IsAlive() and distanceToEnemy < range then
      count = count + 1
    end
  end
  return count
end

function CDOTA_BaseNPC:RandomEnemyHeroInRange( range , magic_immune, caster)
  local entity = self
  local flags = 0
  if magic_immune then
    flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  end
  local enemies = FindUnitsInRadius( caster:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
  if #enemies > 0 then
    local index = RandomInt( 1, #enemies )
    return enemies[index]
  else
    return nil
  end
end