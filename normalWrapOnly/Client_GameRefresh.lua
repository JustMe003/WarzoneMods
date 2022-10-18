require("Dialog");
require("Client_PresentMenuUI")
function Client_GameRefresh(game)
    if not hasSeenIntroductionMessage() then
        showIntroductionDialog(game, "Welcome to the [unnamed] mod! You cannot move armies from one side to the other side of the map, the mod will send you a notification if you have an 'illegal' order."); return;
    end
    if playerWantsNotifications() then
        for _, order in pairs(game.Orders) do
            if order.proxyType == "GameOrderAttackTransfer" and game.Map.Territories[order.From].ConnectedTo[order.To].Wrap ~= WL.TerritoryConnectionWrap.Normal then
                game.CreateDialog(Client_PresentMenuUI);
                return;
            end
        end
    end
end