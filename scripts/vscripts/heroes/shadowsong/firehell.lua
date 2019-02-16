function DealDamage( keys )
    local caster        = keys.caster
    local target        = keys.target
    local damage_pct    = keys.DamagePct
    local damage        = keys.Damage 
    local ability       = keys.ability 

    local talent_1 = caster:FindAbilityByName("shadowsong_special_bonus_firedamage")
    local talent_2 = caster:FindAbilityByName("shadowsong_special_bonus_firedamagepct")

    print("pre", damage, damage_pct)
    damage = damage + talent_1:GetSpecialValueFor("value")
    damage_pct = damage_pct + talent_2:GetSpecialValueFor("value")
    print("post", damage, damage_pct)
    Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage, damage_pct)
end

function firehell_start( keys )
    local caster = keys.caster
    local ability = keys.ability

    local mana_per_sec = ability:GetLevelSpecialValueFor("mana_per_sec", ability:GetLevel() - 1)
    local nova_tick = 1.0
    print("MANA PER SEK = ".. mana_per_sec)
    firehell_take_mana({caster=caster,
                        ability=ability,
                        mana_per_sec=mana_per_sec,
                        nova_tick=nova_tick})
end

function firehell_take_mana( params )
    if not params.ability then return end
    if params.ability:GetToggleState() == false then
        return
    end
    params.caster:ReduceMana(params.mana_per_sec)
    if params.caster:GetMana() < params.mana_per_sec then
        params.ability:ToggleAbility()
    end
    Timers:CreateTimer("firehell_".. params.caster:GetPlayerID(),{ --таймер следующей дуэльки
                endTime =params.nova_tick,
                callback = function()
                    firehell_take_mana({caster=params.caster,
                        ability=params.ability,
                        mana_per_sec=params.mana_per_sec,
                        nova_tick=params.nova_tick})
                    return nil
                end})
end

function firehell_stop( keys )
    local caster = keys.caster
    local sound = "Hero_DoomBringer.ScorchedEarthAura"
    StopSoundEvent(sound, caster)  
    Timers:RemoveTimer("firehell_".. caster:GetPlayerID())
end

function firehell_check_mana( keys )
    local mana_per_sec = keys.ability:GetLevelSpecialValueFor("mana_per_sec", keys.ability:GetLevel() - 1)
    print("trying check mana")

    if keys.caster:GetMana() < mana_per_sec then
        keys.ability:ToggleAbility()
        print("trying check mana off ability")
        keys.caster:RemoveModifierByName("modifier_firehell")
    end
end