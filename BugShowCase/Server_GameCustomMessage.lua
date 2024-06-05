require("Annotations");

---Server_GameCustomMessage
---@param game GameServerHook
---@param playerID PlayerID
---@param payload table
---@param setReturn fun(payload: table) # Sets the table that will be returned to the client when the custom message has been processed
function Server_GameCustomMessage(game, playerID, payload, setReturn)
	if Mod.PublicGameData.HasUpdatedGold == nil then
        local data = Mod.PublicGameData;
        data.HasUpdatedGold = true;
        Mod.PublicGameData = data;
        for _, player in pairs(game.Game.PlayingPlayers) do
            if player.Slot ~= nil and Mod.Settings.Config[player.Slot] ~= nil then
                print("player: " .. player.DisplayName(nil, false));
                print("Slot: " .. player.Slot);
                print("Extra gold: " .. Mod.Settings.Config[player.Slot]);
                print();
                game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, math.max(0, game.ServerGame.LatestTurnStanding.NumResources(player.ID, WL.ResourceType.Gold) + Mod.Settings.Config[player.Slot]));
            end
        end
    end
end