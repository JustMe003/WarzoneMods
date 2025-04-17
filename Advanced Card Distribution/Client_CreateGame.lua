require("Util")

---Client_CreateGame hook. Used to check the game settings before actually creating the game
---@param settings GameSettings # Read-only GameSettings object
---@param alert fun(message: string) # When invoked, it will show a pop-up for the client with the message. It will also abort the game creation
function Client_CreateGame(settings, alert)
    local cardList = {};
    for _, card in pairs(settings.Cards) do
        if card.proxyType == "CardGameCustom" then
            ---@cast card CardGameCustom
            table.insert(cardList, card.Name);
        end
    end

    local missingList = {};
    for name, _ in pairs(Mod.Settings.CustomCards) do
        local b = false;
        for _, cardName in ipairs(cardList) do
            if compareCardName(name, cardName) then
                b = true;
                break;
            end
        end
        if not b then table.insert(missingList, name); end
    end

    if #missingList > 0 and #cardList > 0 then
        alert("The mod was not able to link the following custom cards:\n\"" .. table.concat(missingList, "\"\n\"") .. "\"\nThese are the names of all the custom cards in the game:\n\"" .. table.concat(cardList, "\"\n\"") .. "\"");
    elseif #missingList > 0 then
        alert("The mod was not able to link the following custom cards:\n\"" .. table.concat(missingList, "\"\n\"") .. "\"\nNo custom cards were found");
    end
end
