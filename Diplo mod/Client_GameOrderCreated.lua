require("utilities")

---Client_GameOrderCreated hook
---@param game GameClientHook
---@param order GameOrder # The order that was just created by the player
---@param skipOrder fun() # function that when invoked, will cancel the order actually being added to the orderlist of the player. When invoking this function, you should make sure that the player knows why their order was not added to the orderlist
function Client_GameOrderCreated(game, order, skipOrder)
    if Mod.PlayerGameData and Mod.PlayerGameData.PersonalSettings and Mod.PlayerGameData.PersonalSettings.DisableWarningAlerts then
        return;
    end
    if order.proxyType == "GameOrderAttackTransfer" and order.AttackTransfer ~= WL.AttackTransferEnum.Transfer then
        ---@cast order GameOrderAttackTransfer
        local toOwner = game.LatestStanding.Territories[order.To].OwnerPlayerID;
        if toOwner ~= WL.PlayerID.Neutral and toOwner ~= game.Us.ID and toOwner ~= WL.PlayerID.Fogged and game.Game.Players[toOwner].State == WL.GamePlayerState.Playing then
            if Mod.PublicGameData.Relations[game.Us.ID][toOwner] ~= Relations.War then
                -- search for diplomacy card; if there is one between these players, warzone will show a pop up
                for _, activeCard in pairs(game.LatestStanding.ActiveCards) do
                    local card = activeCard.Card;
                    ---@cast card GameOrderPlayCardDiplomacy
                    if card.CardID == WL.CardID.Diplomacy and ((card.PlayerOne == game.Us.ID and card.PlayerTwo == toOwner) or (card.PlayerOne == toOwner and card.PlayerTwo == game.Us.ID)) then
                        return;
                    end
                end
                
                -- Now we know there is no diplo card between us and toOwner
                UI.Alert("You just created an order to attack " .. game.Game.Players[toOwner].DisplayName(nil, true) .. ", but you are not at war with them. Your order was still created, but it will be cancelled out by the mod if the territory is still controlled by this player.\n\nYou can disable this notification in the mod menu");
            end
        end
    end
end
