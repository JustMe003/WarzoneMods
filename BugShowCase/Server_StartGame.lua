---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local structs = standing.Territories[1].Structures or {};
    structs[1.0] = 5;
    standing.Territories[1].Structures = structs
    -- local terrs = {};
    -- --First, loop through and extract all possible territories we could put cities on
	-- for _, territory in pairs(standing.Territories) do
    --     if (territory.OwnerPlayerID == WL.PlayerID.Neutral) then
    --         table.insert(terrs, territory);
    --     end
    -- end

    -- --Randomize order of table
    -- -- shuffle(terrs);

    -- local numTerrs = 100;
    -- if (numTerrs > #terrs) then numTerrs = #terrs; end; --if we request more territories than we have, cap it.

    -- --Then loop up to the number of territories we need to distribute on
    -- for i=1,numTerrs do
    --     local s = terrs[i].Structures;
    --     if (s == nil) then s = {}; end;
    --     s[WL.StructureType.City] = 1;
    --     terrs[i].Structures = s;
    -- end
end