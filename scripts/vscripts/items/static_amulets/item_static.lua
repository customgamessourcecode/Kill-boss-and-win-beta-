item_slice_amulet = class({})
item_static_amulet = class({})


LinkLuaModifier("modifier_static_amulets_stats", "items/static_amulets/modifier_static_amulets_stats", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_static_amulets_damage", "items/static_amulets/modifier_static_amulets_damage", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

local getIntrinsicModifierName = function() return "modifier_static_amulets_stats" end

item_slice_amulet.GetIntrinsicModifierName = getIntrinsicModifierName
item_static_amulet.GetIntrinsicModifierName = getIntrinsicModifierName

--------------------------------------------------------------------------------
function item_slice_amulet:OnToggle()
    local net_table = CustomNetTables:GetTableValue("heroes", "anti_valve_perks") or {}
    local unicalUnitString = tostring("static"..self:GetCaster():entindex())
    net_table[unicalUnitString .. "_statAct"] = not self:GetToggleState()
    CustomNetTables:SetTableValue("heroes", "anti_valve_perks", net_table)
end

function item_static_amulet:OnToggle()
    local net_table = CustomNetTables:GetTableValue("heroes", "anti_valve_perks") or {}
    local unicalUnitString = tostring("static"..self:GetCaster():entindex())
    net_table[unicalUnitString .. "_statAct"] = not self:GetToggleState()
    CustomNetTables:SetTableValue("heroes", "anti_valve_perks", net_table)
end

function item_slice_amulet:GetAbilityTextureName()
    local net_table = CustomNetTables:GetTableValue("heroes", "anti_valve_perks") or {}
    local unicalUnitString = tostring("static"..self:GetCaster():entindex())
    local act = net_table[unicalUnitString .. "_statAct"]
    if not act or act == 1 then
        return "custom/slice_amulet"
    else
        return "custom/slice_amulet_off"
    end
end
function item_static_amulet:GetAbilityTextureName()
    local net_table = CustomNetTables:GetTableValue("heroes", "anti_valve_perks") or {}
    local unicalUnitString = tostring("static"..self:GetCaster():entindex())
    local act = net_table[unicalUnitString .. "_statAct"]
    if not act or act == 1 then
        return "custom/static_amulet"
    else
        return "custom/static_amulet_off"
    end
end


function item_static_amulet:OnSpellStart()
end
function item_slice_amulet:OnSpellStart()
end



