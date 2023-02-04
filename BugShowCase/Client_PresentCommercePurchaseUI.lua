require("Client_PresentMenuUI");
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateButton(vert).SetText("Click me").SetOnClick(function() close(); game.CreateDialog(Client_PresentMenuUI) end);
end
