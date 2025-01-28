require("Util");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local data = Mod.PublicGameData;
    local s = standing;
    for terr, arr in pairs(data.ArtilleryPlacements) do
        if type(terr) == "number" and game.Map.Territories[terr] ~= nil and standing.Territories[terr].OwnerPlayerID ~= WL.PlayerID.Neutral then
            if type(arr) == "table" then
                local t = {};
                for _, v in pairs(arr) do
                    if Mod.Settings.Artillery[v] ~= nil then
                        table.insert(t, createArtillery(Mod.Settings.Artillery[v], standing.Territories[terr].OwnerPlayerID))
                    end
                end
                s.Territories[terr].NumArmies = s.Territories[terr].NumArmies.Add(WL.Armies.Create(0, t));
            else
                table.insert(data.Errors, "The inputted data didn't have the right format. DO NOT CHANGE ANYTHING MANUALLY TO THE INPUT DATA. If you didn't, please let me know so I can fix it.");
            end
        else
            table.insert(data.Errors, "There does not exist a territory with ID [" .. terr .. "]");
        end
    end
    standing = s;
    Mod.PublicGameData = data;
end