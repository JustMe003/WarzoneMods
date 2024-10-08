require("Annotations");
require("Client_PresentMenuUI");

---Client_GameRefresh hook
---@param game GameClientHook
function Client_GameRefresh(game)
    if game.Us == nil or game.Game.TurnNumber < 1 then return; end
	if game.Us.State == WL.GamePlayerState.Playing and cardData ~= nil then
        cardData = Mod.PublicGameData.CardData[getPlayerOrTeamID(game.Us)];
        local c = 0;
        for _, order in pairs(game.Orders) do
            ---@diagnostic disable-next-line: undefined-field
            if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #"ForcedLD_") == "ForcedLD_" then
                c = c + 1;
            end
        end
        if c < Mod.PublicGameData.CardsPlayedThisTurn[game.Us.ID] then
            game.SendGameCustomMessage("Updating server...", {Action = "UpdateCardCount", Count = Mod.PublicGameData.CardsPlayedThisTurn[game.Us.ID] - c}, function(t) end);
        end
    
        if RefreshMainWindow and not UI.IsDestroyed(GlobalRoot) then
            showMain();
        end
    end
end

---Returns the playerID of teamID of the player
---@param player GamePlayer # The player in question
---@return PlayerID | TeamID | integer # The ID to use to index the data
function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end