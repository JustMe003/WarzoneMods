require("Annotations");

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);

    if Mod.Settings.Data ~= nil then
        UI.CreateLabel(vert).SetText("Current loaded game:").SetColor("#DDDDDD");
        UI.CreateLabel(vert).SetText(Mod.Settings.Data.GameData.GameName).SetColor("#DDDDDD");
        UI.CreateLabel(vert).SetText("Turn " .. Mod.Settings.Data.GameData.TurnNumber).SetColor("#DDDDDD");

        UI.CreateEmpty(vert).SetPreferredHeight(5);

        for _, player in pairs(Mod.Settings.Data.GameData.PlayerMap) do
            UI.CreateLabel(vert).SetText(player.Name .. ": Slot " .. player.Slot).SetColor("#DDDDDD");
        end
    end
    UI.CreateLabel(vert).SetText("Input the serialized string below").SetColor("#DDDDDD");
    dataInput = UI.CreateTextInputField(vert).SetText("").SetPlaceholderText("Input serialized string here").SetPreferredWidth(2000);
    UI.CreateButton(vert).SetText("Load game").SetColor("#00FF05").SetOnClick(function() 
        Client_SaveConfigureUI(UI.Alert);
        UI.Destroy(vert);
        Client_PresentConfigureUI(rootParent);
    end);
end