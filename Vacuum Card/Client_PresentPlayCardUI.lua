function Client_PresentPlayCardUI(game, instance, playCard)
    game.CreateDialog(function(par, size, _, _, close)
        size(400, 200);
        root = UI.CreateVerticalLayoutGroup(par).SetFlexibleWidth(1);
        
        local line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
        UI.CreateEmpty(line).SetFlexibleWidth(0.5);
        UI.CreateLabel(line).SetText("Select a territory").SetColor("#DDDDDD");

        UI.CreateEmpty(line).SetPreferredWidth(10);
        label = UI.CreateLabel(line).SetText((selectedTerr or {Name = "None"}).Name).SetColor("#FFFF00");
        UI.CreateEmpty(line).SetFlexibleWidth(0.5);

        UI.CreateEmpty(root).SetPreferredHeight(5);

        line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
        UI.CreateEmpty(line).SetFlexibleWidth(0.5);
        button = UI.CreateButton(line).SetText("Select").SetColor("#0000FF").SetOnClick(function()
            playCard("Vacuum card on " .. selectedTerr.Name, "" .. selectedTerr.ID);
            close();
        end).SetInteractable(selectedTerr ~= nil);
        UI.CreateEmpty(line).SetFlexibleWidth(0.5);

        UI.InterceptNextTerritoryClick(terrClicked);
    end);
end

function terrClicked(terrDetails)
    if terrDetails == nil or UI == nil or UI.IsDestroyed(root) then
        return WL.CancelClickIntercept;
    else
        selectedTerr = terrDetails;
        label.SetText(selectedTerr.Name).SetColor("#00FF00");
        button.SetInteractable(true);
        UI.InterceptNextTerritoryClick(terrClicked);
    end
end