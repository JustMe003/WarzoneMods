require("Annotations");

---Server_GameCustomMessage
---@param game GameServerHook
---@param playerID PlayerID
---@param payload table
---@param setReturn fun(payload: table) # Sets the table that will be returned to the client when the custom message has been processed
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    if payload == nil or payload.TerrID == nil or payload.ArtilleryID == nil or payload.Action == nil then
        return;
    end

    local data = Mod.PublicGameData;
    data.ArtilleryPlacements = data.ArtilleryPlacements or {};
    if payload.Action == "Add" then
        data.ArtilleryPlacements[payload.TerrID] = data.ArtilleryPlacements[payload.TerrID] or {};
        table.insert(data.ArtilleryPlacements[payload.TerrID], payload.ArtilleryID);
    elseif payload.Action == "Remove" then
        if data.ArtilleryPlacements[payload.TerrID] ~= nil then
            for i, v in pairs(data.ArtilleryPlacements[payload.TerrID]) do
                if v == payload.ArtilleryID then
                    table.remove(data.ArtilleryPlacements[payload.TerrID], i);
                    break;
                end
            end
            if #data.ArtilleryPlacements[payload.TerrID] == 0 then 
                data.ArtilleryPlacements[payload.TerrID] = nil;
            end
        end
    end
    Mod.PublicGameData = data;
end