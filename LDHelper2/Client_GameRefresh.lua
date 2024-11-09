require("Client_PresentMenuUI");
require("UI");

-- This is sometimes called BEFORE Warzone has finished processing the whole turn
-- Resulting that when getting the last turn orders, the list is empty

function Client_GameRefresh(game)
    local hasAddedOrders = false;
    if game.Us == nil or game.Us.IsAIOrHumanTurnedIntoAI or game.Us.State ~= WL.GamePlayerState.Playing then
        return;
    end

    if Mod.PublicGameData.ModVersion == nil or Mod.PublicGameData.ModVersion < "3.0" then
        game.SendGameCustomMessage("Updating mod...", { Type = "UpdateVersion" }, function(t)  end);
        return;
    end

    if (lastTurn == nil or lastTurn < game.Game.TurnNumber) and game.Game.TurnNumber > 1 then
        if Mod.PlayerGameData.NewTurnAction == nil and (UI.IsDestroyed == nil or UI.IsDestroyed(vert)) then
            game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "SetAction"); end);
        else
            print("orderlist is empty: " .. tostring(tableIsEmpty(game.Orders)));
            if tableIsEmpty(game.Orders) then
                if Mod.PlayerGameData.NewTurnAction == "AutoDeploy" and Mod.PlayerGameData.SavedInputs == nil then
                    game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "SetDefaultOptions"); end);
                elseif Mod.PlayerGameData.NewTurnAction == "AutoDeploy" then
                    game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "AutoDeploy"); end);
                    hasAddedOrders = true;
                elseif Mod.PlayerGameData.NewTurnAction == "ShowWindow" then
                    game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, "ShowWindow"); end);
                    hasAddedOrders = true;
                end
            end
        end
    end
    if hasAddedOrders then
        lastTurn = game.Game.TurnNumber;
    end
end

function tableIsEmpty(t)
    for _, _ in pairs(t) do
        return false;
    end
    return true;
end
