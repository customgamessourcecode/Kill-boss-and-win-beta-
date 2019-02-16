item_life_catcher = item_life_catcher or class({})

LinkLuaModifier("modifier_life_catcher_passive", 'items/life_catcher/modifiers/modifier_life_catcher_passive', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_life_catcher_passive_exp_cd", 'items/life_catcher/modifiers/modifier_life_catcher_passive_exp_cd', LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function item_life_catcher:GetIntrinsicModifierName() return "modifier_life_catcher_passive"; end

function item_life_catcher:CreateParticle(sParticleName, hSource, hTarget, bDodgeable)
	local info =
    {
        Target = hTarget,
        Source = hSource,
        Ability = self,
        EffectName = sParticleName,
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        vSourceLoc = hSource:GetAbsOrigin(),
        bDrawsOnMinimap = false,
        bDodgeable = bDodgeable,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = GameRules:GetGameTime() + 10,
        bProvidesVision = false,
    }
    ProjectileManager:CreateTrackingProjectile(info)
end 

function item_life_catcher:OnSpellStart()
    local target = self:GetCursorTarget()

    if not IsServer() then return end

    if target:TriggerSpellAbsorb(self) then return end

    self:CreateParticle("particles/life_catcher/life_catcher_out.vpcf", self:GetCaster(), target, true)
end

function item_life_catcher:OnProjectileHitEnemy(hTarget, value)
    local caster = self:GetCaster() 

     ApplyDamage({
        victim = hTarget,
        attacker = caster,
        damage = value,
        damage_type = self:GetAbilityDamageType(),
        ability = self
    })

    self:CreateParticle("particles/life_catcher/life_catcher_in.vpcf", hTarget, caster, false)
end 

function item_life_catcher:OnProjectileHitFriend(hTarget, value)
    hTarget:Heal(value, self)  
end 


function item_life_catcher:OnProjectileHit(hTarget, vLocation)
    if not self then return end

    local caster = self:GetCaster()
    local att_damage = Util:DisableSpellAmp(caster, caster:GetPrimaryStatValue() * (self:GetSpecialValueFor("mainstat_to_dmg") / 100))

    if hTarget == caster then
        self:OnProjectileHitFriend(hTarget, att_damage)
    else 
        self:OnProjectileHitEnemy(hTarget, att_damage + self:GetSpecialValueFor("damage"))
    end
end 
