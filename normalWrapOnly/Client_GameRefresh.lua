require("Dialog");
require("Client_PresentMenuUI")
function Client_GameRefresh(game)
    if not hasSeenIntroductionMessage() then
        showIntroductionDialog(game, ""); return;
    end
    print(playerWantsNotifications());
    if playerWantsNotifications() then
        game.CreateDialog(Client_PresentMenuUI);
    end
end