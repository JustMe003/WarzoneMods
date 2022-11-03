require("Dialog");
require("Client_PresentMenuUI")
function Client_GameRefresh(game)
    if game.Us == nil then return; end
    if not hasSeenIntroductionMessage() then
        showIntroductionDialog(game, "Welcome to the [unnamed] mod! You cannot move armies from one side to the other side of the map, the mod will send you a notification if you have an 'illegal' order."); return;
    end
    if playerWantsNotifications() and timeSinceLastUpdate(game, "Seconds", 30) then
        for _, order in pairs(game.Orders) do
            if (order.proxyType == "GameOrderAttackTransfer" and game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal) or (order.proxyType == "GameOrderPlayCardBomb" and isIllegalBomb(game, order)) then
                CalledFromRefresh = true;
                sendUpdate(game, function() game.CreateDialog(Client_PresentMenuUI); end);
                return;
            end
        end
    end
end

function isIllegalBomb(game, order)
    for connID, conn in pairs(game.Map.Territories[order.TargetTerritoryID].ConnectedTo) do
        if conn.Wrap == WL.TerritoryConnectionWrap.Normal and game.LatestStanding.Territories[connID].OwnerPlayerID == game.Us.ID then return false; end
    end
    return true;
end