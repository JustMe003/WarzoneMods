require("UI");
require("Docs");
require("Util");
require("PresentConfiguration");

data = data;
---@diagnostic disable-next-line:unknown-cast-variable
---@cast data MoreCardLimitsSettings

---Creates the configuration UI
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    GlobalRoot = UI2.CreateVert(rootParent);
    data = data or Mod.Settings or {};
    
    MainMenu();
end

function MainMenu()
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    PresentConfiguration(root, data);

    UI2.CreateEmpty(root).SetMinHeight(10);

    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Modify limits").SetColor(UI2.Colors.SubmitButton).SetOnClick(ModifyMenu);
end

function ModifyMenu()
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    inputs = {};
    ---@diagnostic disable-next-line:unknown-cast-variable
    ---@cast inputs MoreCardLimitsInputs

    for card, cardData in pairs(data) do
        local line = UI2.CreateHorz(root).SetFlexibleWidth(1);
        UI2.CreateButton(line).SetText(GetCardName(card)).SetColor(GetCardColor(card));
        UI2.CreateEmpty(line).SetFlexibleWidth(1);
        UI2.CreateButton(line).SetText("X").SetColor(UI2.Colors.DeleteButton).SetOnClick(function()
            SaveInputs();
            data[card] = nil;
            ModifyMenu();
        end);

        inputs[card] = {} ---@diagnostic disable-line;
        ModifyCardLimits(root, cardData);

        UI2.CreateEmpty(root).SetMinHeight(10);
    end
    
    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Add limit").SetColor(UI2.Colors.SubmitButton).SetOnClick(function()
        SaveInputs();
        SelectCard();
    end);
end

---Menu part for modifying the limits on a card
---@param cardData CardSettings
function ModifyCardLimits(root, cardData)
    UI2.CreateLabel(root).SetText("Maximum " .. GetCardName(cardData.ID) .. " cards a player can hold in their hand");
    inputs[cardData.ID].MaxCardHold = UI2.CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(cardData.MaxCardHold or 0);

    UI2.CreateLabel(root).SetText("Maximum " .. GetCardName(cardData.ID) .. " cards a player gets in the whole game");
    inputs[cardData.ID].MaxGameCardLimit = UI2.CreateNumberInputField(root).SetSliderMaxValue(0).SetSliderMaxValue(10).SetValue(cardData.MaxGameCardLimit or 0);
end

---Menu for selecting a card
function SelectCard()
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetColor(UI2.Colors.CancelButton).SetText("Cancel").SetOnClick(ModifyMenu);

    UI2.CreateEmpty(root).SetMinHeight(10);

    UI2.CreateLabel(root).SetText("Select a card below");
    for _, id in pairs(WL.CardID) do
        if data[id] == nil then
            UI2.CreateButton(root).SetText(GetCardName(id)).SetColor(GetCardColor(id)).SetOnClick(function()
                data[id] = CreateCardSettings(id, CardTypeEnum.Base);
                ModifyMenu();
            end)
        end
    end
end
