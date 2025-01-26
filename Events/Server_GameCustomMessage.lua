require("Events");

---Server_GameCustomMessage
---@param game GameServerHook
---@param playerID PlayerID
---@param payload table
---@param setReturn fun(payload: table) # Sets the table that will be returned to the client when the custom message has been processed
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    if payload.Type == nil then
        print("payload.Type was nil");
        return;
    end
	local commandMap = {
        UpdateTrigger = updateTrigger,
        DeleteTrigger = deleteTrigger,
        UpdateEvent = updateEvent,
        DeleteEvent = deleteEvent,
        AddToTerritoryMap = addToTerritoryMap,
    };
    data = Mod.PublicGameData; 
    commandMap[payload.Type](game, playerID, payload, setReturn);
    Mod.PublicGameData = data;
end

function updateTrigger(game, playerID, payload, setReturn)
    data.Triggers[payload.Trigger.ID] = payload.Trigger;
end

function deleteTrigger(game, playerID, payload, setReturn)
    for _, assigned in pairs(data.TerritoryMap) do
        local list = {};
        for i, data in pairs(assigned[payload.Trigger.Type] or {}) do
            if data.TriggerID == payload.Trigger.ID then table.insert(list, i); end
        end
        for _, i in ipairs(list) do
            assigned[payload.Trigger.Type][i] = nil;
        end
    end

    removeEmptyTables(data.TerritoryMap);
    
    data.Triggers[payload.Trigger.ID] = nil;
end

function updateEvent(game, playerID, payload, setReturn)
    data.Events[payload.Event.ID] = payload.Event;
end

function deleteEvent(game, playerID, payload, setReturn)
    for _, assigned in pairs(data.TerritoryMap) do
        for _, triggersOfType in pairs(assigned) do
            local deleteCustomEvents = {};
            for k, customEventData in ipairs(triggersOfType) do
                local list = {};
                for i, eventID in pairs(customEventData.EventIDs) do
                    if eventID == payload.Event.ID then
                        table.insert(list, i);
                    end
                end
                for i = #list, 1, -1 do
                    table.remove(customEventData.EventIDs, list[i]);
                end
                if #customEventData.EventIDs == 0 then
                    table.insert(deleteCustomEvents, k);
                end 
            end
            for k = #deleteCustomEvents, 1, -1 do
                table.remove(triggersOfType, deleteCustomEvents[k]);
            end
        end
    end

    removeEmptyTables(data.TerritoryMap);

    data.Events[payload.Event.ID] = nil;
end

function addToTerritoryMap(game, playerID, payload, setReturn)
    data.TerritoryMap[payload.TerrID] = data.TerritoryMap[payload.TerrID] or {};
    data.TerritoryMap[payload.TerrID][payload.Trigger.Type] = data.TerritoryMap[payload.TerrID][payload.Trigger.Type] or {};
    table.insert(data.TerritoryMap[payload.TerrID][payload.Trigger.Type], {
        TriggerID = payload.Trigger.ID,
        EventIDs = payload.Events
    });
end

function printTable(t, s)
    s = s or "";
    for k, v in pairs(t) do
        print(s .. k .. " = " .. tostring(v));
        if type(v) == "table" then
            printTable(v, s .. "  ");
        end
    end
end

function removeEmptyTables(t)
    for i, v in pairs(t) do
        if type(v) == "table" then
            v = removeEmptyTables(v);
        end
        if tableIsNilOrEmpty(v) then
            t[i] = nil;
        end
    end
    return t;
end

function tableIsNilOrEmpty(t)
    if t == nil then return true; end
    if type(t) ~= "table" then return false; end
    for _, _ in pairs(t) do return false; end
    return true;
end