require("UI");
require("Docs");
require("Util");

---Menu presenting the configuration
---@param root UIObject
---@param data MoreCardLimitsSettings
function PresentConfiguration(root, data)
    if TableIsEmpty(data) then
        UI2.CreateLabel(root).SetText("There are no limits configured");
    else
        UI2.CreateLabel(root).SetText("The following limits have been configured:");

        UI2.CreateEmpty(root).SetMinHeight(10);
        
        for card, cardData in pairs(data) do
            if cardData.MaxCardHold > 0 or cardData.MaxGameCardLimit > 0 then
                UI2.CreateButton(root).SetText(GetCardName(card)).SetColor(GetCardColor(card));
                if cardData.MaxCardHold > 0 then
                    UI2.CreateLabel(CreateIndentedLine(root, 10)).SetText("Maximum " .. GetCardName(card) .. " cards a player can hold: " .. cardData.MaxCardHold);
                end
                if cardData.MaxGameCardLimit > 0 then
                    UI2.CreateLabel(CreateIndentedLine(root, 10)).SetText("Maximum " .. GetCardName(card) .. " cards a player gets in the whole game: " .. cardData.MaxGameCardLimit);
                end
            end
        end
    end
end