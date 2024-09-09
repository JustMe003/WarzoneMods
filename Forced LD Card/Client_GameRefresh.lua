require("Annotations");
require("Client_PresentMenuUI");

---Client_GameRefresh hook
---@param game GameClientHook
function Client_GameRefresh(game)
    numForcedLDCardsPlayed = numForcedLDCardsPlayed or 0;
	if game.Us ~= nil and game.Us.State == WL.GamePlayerState.Playing and cardData ~= nil then
        cardData = Mod.PublicGameData.CardData[getPlayerOrTeamID(game.Us)];
    end

    local c = 0;
    for _, order in pairs(game.Orders) do
        ---@diagnostic disable-next-line: undefined-field
        if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #"ForcedLD_") == "ForcedLD_" then
            c = c + 1;
        end
    end
    if c < numForcedLDCardsPlayed then
        game.SendGameCustomMessage("Updating server...", {Action = "UpdateCardCount", Count = numForcedLDCardsPlayed - c}, function(t) end);
    end
    numForcedLDCardsPlayed = c;
end

function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end