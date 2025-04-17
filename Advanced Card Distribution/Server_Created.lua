require("Util");

---Server_Created hook
---@param game GameServerHook
---@param settings GameSettings
function Server_Created(game, settings)
    if Mod.Settings.CustomCards then
        local t = {};
        local t2 = {};
        for card, cardGame in pairs(settings.Cards) do
            if cardGame.proxyType == "CardGameCustom" then
                ---@cast cardGame CardGameCustom
                for name, id in pairs(Mod.Settings.CustomCards) do
                    if compareCardName(name, cardGame.Name) then
                        t[id] = card;
                        t2[card] = id;
                        print(id, card, name);
                        break;
                    end
                end
            end
        end
        local data = Mod.PublicGameData;
        data.ModToGame = t;
        data.GameToMod = t2;
        Mod.PublicGameData = data;
    end
end

