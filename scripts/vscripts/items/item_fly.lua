function item_fly_on_spell_start(keys)
    --Remove all evasion granted by flies in the caster's inventory.
    while keys.caster:HasModifier("modifier_item_fly_evasion") do
        keys.caster:RemoveModifierByName("modifier_item_fly_evasion")
    end

    keys.caster:EmitSound("DOTA_Item.Butterfly")
    keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_fly_movespeed", nil)
end


--[[ ============================================================================================================
    Author: Rook
    Date: February 1, 2015
    Called when the movespeed active modifier expires.  Gives the caster has a stack of evasion for every 
    fly in their inventory.
================================================================================================================= ]]
function modifier_item_fly_movespeed_on_destroy(keys)
    if not keys.caster:HasModifier("modifier_item_fly_movespeed") then
        --Reset all evasion granted by flies in the caster's inventory before adding it back, just to be sure we end up with the right amount.
        while keys.caster:HasModifier("modifier_item_fly_evasion") do
            keys.caster:RemoveModifierByName("modifier_item_fly_evasion")
        end

        for i=0, 5, 1 do
            local current_item = keys.caster:GetItemInSlot(i)
            if current_item ~= nil then
                if current_item:GetName() == "item_fly" then
                    keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_fly_evasion", {duration = -1})
                end
            end
        end
    end
end


--[[ ============================================================================================================
    Author: Rook
    Date: February 1, 2015
    Called when a fly is acquired.  Adds an additional evasion modifier if fly hasn't been cast recently.
================================================================================================================= ]]
function modifier_item_fly_on_created(keys)
    if not keys.caster:HasModifier("modifier_item_fly_movespeed") then
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_fly_evasion", {duration = -1})
    end
end


--[[ ============================================================================================================
    Author: Rook
    Date: February 1, 2015
    Called when a fly is dropped, sold, etc..  Remove an evasion modifier if fly hasn't been cast recently.
================================================================================================================= ]]
function modifier_item_fly_on_destroy(keys)
    if not keys.caster:HasModifier("modifier_item_fly_movespeed") then
        keys.caster:RemoveModifierByName("modifier_item_fly_evasion")
    end
end