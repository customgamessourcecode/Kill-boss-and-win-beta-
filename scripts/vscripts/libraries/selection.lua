SELECTION_VERSION = "1.00"

function CDOTA_PlayerResource:NewSelection(playerID, unit_args)
    local player = self:GetPlayer(playerID)
    if player then
        local entities = Selection:GetEntIndexListFromTable(unit_args)
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_new", {entities = entities})
    end
end 

function CDOTA_PlayerResource:AddToSelection(playerID, unit_args)
    local player = self:GetPlayer(playerID)
    if player then
        local entities = Selection:GetEntIndexListFromTable(unit_args)
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_add", {entities = entities})
    end
end

function CDOTA_PlayerResource:RemoveFromSelection(playerID, unit_args)
    local player = self:GetPlayer(playerID)
    if player then
        local entities = Selection:GetEntIndexListFromTable(unit_args)
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_remove", {entities = entities})
    end
end

function CDOTA_PlayerResource:ResetSelection(playerID)
    local player = self:GetPlayer(playerID)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_reset", {})
    end
end

function CDOTA_PlayerResource:GetSelectedEntities(playerID)
    return Selection.entities[playerID] or {}
end

function CDOTA_PlayerResource:GetMainSelectedEntity(playerID)
    local selectedEntities = self:GetSelectedEntities(playerID) 
    return selectedEntities and selectedEntities["0"]
end

function CDOTA_PlayerResource:IsUnitSelected(playerID, unit)
    if not unit then return false end
    local entIndex = type(unit)=="number" and unit or IsValidEntity(unit) and unit:GetEntityIndex()
    if not entIndex then return false end
    
    local selectedEntities = self:GetSelectedEntities(playerID)
    for _,v in pairs(selectedEntities) do
        if v==entIndex then
            return true
        end
    end
    return false
end

function CDOTA_PlayerResource:RefreshSelection()
    Timers:CreateTimer(0.03, function()
        FireGameEvent("dota_player_update_selected_unit", {})
    end)
end

function CDOTA_PlayerResource:SetDefaultSelectionEntity(playerID, unit)
    if not unit then unit = -1 end
    local entIndex = type(unit)=="number" and unit or unit:GetEntityIndex()
    local hero = self:GetSelectedHeroEntity(playerID)
    if hero then
        hero:SetSelectionOverride(unit)
    end
end

function CDOTA_BaseNPC:SetSelectionOverride(reselect_unit)
    local unit = self
    local reselectIndex = type(reselect_unit)=="number" and reselect_unit or reselect_unit:GetEntityIndex()

    CustomNetTables:SetTableValue("selection", tostring(unit:GetEntityIndex()), {entity = reselectIndex})
end

------------------------------------------------------------------------
-- Internal
------------------------------------------------------------------------

require('libraries/timers')

if not Selection then
    Selection = class({})
end

function Selection:Init()
    Selection.entities = {} --Stores the selected entities of each playerID
    CustomGameEventManager:RegisterListener("selection_update", Dynamic_Wrap(Selection, 'OnUpdate'))
end

function Selection:OnUpdate(event)
    local playerID = event.PlayerID
    Selection.entities[playerID] = event.entities
end

-- Internal function to build an entity index list out of various inputs
function Selection:GetEntIndexListFromTable(unit_args)
    local entities = {}
    if type(unit_args)=="number" then
        table.insert(entities, unit_args) -- Entity Index
    -- Check contents of the table
    elseif type(unit_args)=="table" then
        if unit_args.IsCreature then
            table.insert(entities, unit_args:GetEntityIndex()) -- NPC Handle
        else
            for _,arg in pairs(unit_args) do
                -- Table of entity index values
                if type(arg)=="number" then
                    table.insert(entities, arg)
                -- Table of npc handles
                elseif type(arg)=="table" then
                    if arg.IsCreature then
                        table.insert(entities, arg:GetEntityIndex())
                    end
                end
            end
        end
    end
    return entities
end

if not Selection.entities then Selection:Init() end