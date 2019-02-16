
--Increases the stack count of Flesh Heap.
function StackCountIncrease( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapStackModifier = "modifier_damage_heap_collector"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

    caster:SetModifierStackCount(fleshHeapStackModifier, ability, (currentStacks + 1))
end

