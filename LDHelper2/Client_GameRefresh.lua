require("Client_PresentMenuUI");
require("UI");
function Client_GameRefresh(game)
    print(lastTurn, game.Game.TurnNumber);
    if game.Us == nil or game.Us.IsAIOrHumanTurnedIntoAI then
        return;
    end
	if lastTurn == nil or lastTurn < game.Game.TurnNumber then
        if Mod.PlayerGameData.NewTurnAction == nil then
            game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "SetAction"); end);
        else
            print(tostring(tableIsEmpty(game.Orders)));
            printTable(game.Orders);
            if tableIsEmpty(game.Orders) then
                print(Mod.PlayerGameData.NewTurnAction);
                if Mod.PlayerGameData.NewTurnAction == "AutoDeploy" then
                    game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "AutoDeploy"); end);
                elseif Mod.PlayerGameData.NewTurnAction == "ShowWindow" then
                    game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "ShowWindow"); end);
                end
            end
        end
    end
    lastTurn = game.Game.TurnNumber;
end

function tableIsEmpty(t)
    for _, _ in pairs(t) do
        return false;
    end
    return true;
end

function printTable(t)
    for i, v in pairs(t) do
        print(i, v);
    end
end