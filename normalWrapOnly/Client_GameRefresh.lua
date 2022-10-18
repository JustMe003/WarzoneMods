require("Dialog");
require("Client_PresentMenuUI")
function Client_GameRefresh(game)
    print(playerWantsNotifications());
    if not hasSeenIntroductionMessage() then
        showIntroductionDialog(game, ""); return;
    end
    if playerWantsNotifications() then
        game.CreateDialog(Client_PresentMenuUI);
    end
end