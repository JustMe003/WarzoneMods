require("UI");
require("Util");

---UI for playing a custom card
---@param game GameClientHook
---@param cardInstance CardInstance
---@param playCard fun(orderText: string, modData: string, phase: EnumTurnPhase?, annotations: table<TerritoryID, TerritoryAnnotation>?, rectangleVM: RectangleVM?)
---@param closeCardsUI fun()
function Client_PresentPlayCardUI(game, cardInstance, playCard, closeCardsUI)
    closeCardsUI();

    game.CreateDialog(function(rootParent, setMaxSize, setScrollable, _, close)
        if Close ~= nil then Close(); end
        Init();
        colors = GetColors();
        local root = CreateVert(rootParent).SetFlexibleWidth(1);
        Close = close;

        CreateLabel(root).SetText("Select the player you want to play the card on");

        target = nil;
        targetButton = CreateButton(root).SetText("Select").SetOnClick(function()
            UI.PromptFromList("Select a player", createPlayerList(game));
        end);

        CreateEmpty(root).SetMinHeight(5);

        playCardButton = CreateButton(root).SetText("Play").SetColor(colors.Green).SetInteractable(false).SetOnClick(function()
            if not valueInTable(getTargetedPlayers(game.Orders), target.ID) then
                playCard("Force local deployment for " .. Mod.Settings.Duration .. " turn" .. aOrB(Mod.Settings.Duration == 1, "", "s") .. " on " .. target.DisplayName(nil, true), createCardPayload(target.ID), WL.TurnPhase.SanctionCards);
                close();
            else
                UI.Alert("You already have played a card on this player");
            end
        end);

    end);
end

---Creates and returns a selectable list of players
---@param game GameClientHook
function createPlayerList(game)
    local list = {};
    local us = getPlayerOrTeamID(game.Us);
    local targetedPlayers = getTargetedPlayers(game.Orders);
    for _, p in pairs(game.Game.PlayingPlayers) do
        if (Mod.Settings.CanPlayOnTeammates or getPlayerOrTeamID(p) ~= us) and not valueInTable(targetedPlayers, p.ID) then
            table.insert(list, {
                player = p.ID;
                selected = function()
                    target = p;
                    targetButton.SetText(getStringForButton(p.DisplayName(nil, true), 30)).SetColor(p.Color.HtmlColor);
                    playCardButton.SetInteractable(true);
                end
            });
        end
    end
    return list;
end

---Returns all the targeted players
---@param orders GameOrder[]
---@return PlayerID[]
function getTargetedPlayers(orders)
    local targetedPlayers = {};
    for _, order in ipairs(orders) do
        if order.proxyType == "GameOrderPlayCardCustom" then
            ---@cast order GameOrderPlayCardCustom
            if order.CustomCardID == Mod.Settings.CardID then
                table.insert(targetedPlayers, getTargetPlayerID(order.ModData));
            end
        end
    end
    return targetedPlayers;
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end

---Returns the playerID of teamID of the player
---@param player GamePlayer # The player in question
---@return PlayerID | TeamID | integer # The ID to use to index the data
function getPlayerOrTeamID(player)
    if player.Team == -1 then return player.ID; else return player.Team; end
end

---Returns a shorterend string if the string is longer than the limit
---@param s string # The string in question
---@param limit integer? # The limit of the string, default is 20
---@return string # The (modified) string 
function getStringForButton(s, limit)
    limit = limit or 20;
    if #s > limit then
        return string.sub(s, 1, limit) .. "...";
    else
        return s;
    end
end

---Helper function to return either `r1` or `r2`
---@param b boolean # Boolean to determine to return `r1` or `r2`
---@param r1 any # If `b` is true, return this
---@param r2 any # If `b` is false, return this
---@return any # Either `r1` or `r2`, depending on `b` is true
function aOrB(b, r1, r2)
	if b then return r1; else return r2; end
end