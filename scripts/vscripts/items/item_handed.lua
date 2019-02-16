function modifier_item_heavens_halberd_datadriven_on_attack_landed_random_on_success(keys)
    if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
        keys.target:EmitSound("DOTA_Item.Maim")
        keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_handed_maim", nil)
    end
end