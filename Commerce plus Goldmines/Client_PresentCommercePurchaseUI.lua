function Client_PresentCommercePurchaseUI(rootParent, game, close)
    if game.Settings.CommerceCityBaseCost == nil then return; end
    local vert = UI.CreateVerticalLayoutGroup(rootParent);

    UI.CreateLabel(vert).SetText("NOTE\nWhen you build a city, you actually start to build a Goldmine. Building a Goldmine takes " .. Mod.Settings.NTurns .. " turns and the build process is indicated by cities (3 cities indicate it will take 3 more turns before the Goldmien is built). Goldmines give " .. Mod.Settings.Income .. " income and cities give 0")
end