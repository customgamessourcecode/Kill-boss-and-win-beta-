function swap_to_item(keys, ItemName)
    for i=0, 5, 1 do
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item == nil then
            local item = keys.caster:AddItem(CreateItem("item_dummy", keys.caster, keys.caster))
            item:SetPurchaseTime(0)
        end
    end
    
    keys.caster:RemoveItem(keys.ability)
    local newitem = keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster))
    newitem:SetPurchaseTime(0)
    
    for i=0, 5, 1 do
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() == "item_dummy" then
                keys.caster:RemoveItem(current_item)
            end
        end
    end
end

function Swap_str(keys)
    local newItem = "item_power_treads_intellegence_2"
    swap_to_item(keys, newItem)
end

function Swap_agi(keys)
    local newItem = "item_power_treads_strength_2"
    swap_to_item(keys, newItem)
end

function Swap_int(keys)
    local newItem = "item_power_treads_agility_2"
    swap_to_item(keys, newItem)
end

function Swap_str2(keys)
    local newItem = "item_power_treads_intellegence_3"
    swap_to_item(keys, newItem)
end

function Swap_agi2(keys)
    local newItem = "item_power_treads_strength_3"
    swap_to_item(keys, newItem)
end

function Swap_int2(keys)
    local newItem = "item_power_treads_agility_3"
    swap_to_item(keys, newItem)
end