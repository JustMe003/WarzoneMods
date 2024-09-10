require("Annotations");
require("UI");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    if game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing then 
        close();
        UI.Alert("You can't use the mod since you are not in the game");
        return;
    end
    setMaxSize(300, 300);
    Init();
    colors = GetColors();
    Game = game;
    GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1);
    Close = close;
    showMain();
end

---Shows the main menu of the mod
function showMain()
    RefreshMainWindow = false;

    DestroyWindow();
    cardData = Mod.PublicGameData.CardData[getPlayerOrTeamID(Game.Us)];

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    local line = CreateHorz(root).SetFlexibleWidth(1);
    ---@diagnostic disable-next-line: param-type-mismatch
    CreateButton(line).SetText("Play card").SetColor(colors.Green).SetOnClick(playForcedLDCard).SetInteractable(cardData.WholeCards - getAllPlayedCardsCount(Game, getPlayerOrTeamID(Game.Us)) >= 1);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("Reload").SetColor(colors.Orange).SetOnClick(function() 
        local c = 0;
        for _, order in pairs(Game.Orders) do
            ---@diagnostic disable-next-line: undefined-field
            if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #"ForcedLD_") == "ForcedLD_" then
                c = c + 1;
            end
        end
        if c < Mod.PublicGameData.CardsPlayedThisTurn[Game.Us.ID] then
            Game.SendGameCustomMessage("Updating server...", {Action = "UpdateCardCount", Count = Mod.PublicGameData.CardsPlayedThisTurn[Game.Us.ID] - c}, function(t) end);
        end
        RefreshMainWindow = true;
     end)

    if Mod.PublicGameData.IsTeamGame then
        CreateLabel(root).SetText("Your team cards").SetColor(colors.TextColor);
    else
        CreateLabel(root).SetText("Your cards").SetColor(colors.TextColor);
    end
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Whole cards: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(cardData.WholeCards).SetColor(colors.Aqua);
    ---@diagnostic disable-next-line: param-type-mismatch
    if getAllPlayedCardsCount(Game, getPlayerOrTeamID(Game.Us)) > 0 then
        ---@diagnostic disable-next-line: param-type-mismatch
        CreateLabel(root).SetText("(" .. Mod.PublicGameData.CardsPlayedThisTurn[Game.Us.PlayerID] .. " cards played by you" .. aOrB(getAllPlayedCardsCount(Game, getPlayerOrTeamID(Game.Us)) - Mod.PublicGameData.CardsPlayedThisTurn[Game.Us.PlayerID] > 0, " and " .. getAllPlayedCardsCount(Game, getPlayerOrTeamID(Game.Us)) - Mod.PublicGameData.CardsPlayedThisTurn[Game.Us.PlayerID] .. " by your team)", ")")).SetColor(colors.TextColor);
    end
    CreateEmpty(line).SetFlexibleWidth(1);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Card pieces: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(cardData.Pieces).SetColor(colors.Aqua);

    CreateEmpty(root).SetPreferredHeight(5);
    CreateButton(root).SetText("Show active cards").SetColor(colors["Royal Blue"]).SetOnClick(showActiveCards);
end

---Shows the menu to play a Forced LD card
---@param target GamePlayer? # When first called, `target` will be nill. 
function playForcedLDCard(target)
    target = target or {DisplayName = function(_, _) return "Select"; end, Color = {HtmlColor = "#DDDDDD"}};
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Target:").SetColor(colors.TextColor);
    CreateButton(line).SetText(getStringForButton(target.DisplayName(nil, true))).SetColor(target.Color.HtmlColor).SetOnClick(selectTarget);

    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateButton(line).SetText("Play card").SetColor(colors.Green).SetOnClick(function()
        sendUpdateToServer(target);
    end).SetInteractable(target.ID ~= nil);
    CreateButton(line).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(showMain);
end

---Shows all the player we can play a card on
function selectTarget()
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local teamID = getPlayerOrTeamID(Game.Us);

    CreateLabel(root).SetText("Select your target").SetColor(colors.TextColor);

    local list = {};
    local blacklist = getAllTargettedPlayers()
    for _, p in pairs(Game.Game.PlayingPlayers) do
        local pID = getPlayerOrTeamID(p);
        if (Mod.Settings.CanPlayOnTeammates or pID ~= teamID) and not blacklist[p.ID] then
            table.insert(list, p);
        end
    end
    table.sort(list, function(a, b) return string.lower(b.DisplayName(nil, false)) > string.lower(a.DisplayName(nil, false)); end);

    for _, player in pairs(list) do
        CreateButton(root).SetText(player.DisplayName(nil, true)).SetColor(player.Color.HtmlColor).SetOnClick(function()
            playForcedLDCard(player);
        end)
    end
end

---Shows all the active Forced LD cards currently in play
function showActiveCards()
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local teamID = getPlayerOrTeamID(Game.Us);

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);

    CreateEmpty(root).SetPreferredHeight(3);
    
    CreateLabel(root).SetText("The color corresponds to the player who was targetted by the Forced LD card").SetColor(colors.TextColor);
    
    CreateEmpty(root).SetPreferredHeight(3);
    
    CreateLabel(root).SetText("Active cards").SetColor(colors.TextColor);
    for _, playedCard in pairs(Mod.PublicGameData.ActiveCards) do
        if Game.Settings.CardPlayingsFogged then
            if getPlayerOrTeamID(Game.Game.Players[playedCard.Target]) == teamID or getPlayerOrTeamID(Game.Game.Players[playedCard.PlayerID]) == teamID then
                CreateButton(root).SetText("Forced LD card played by " .. Game.Game.Players[playedCard.PlayerID].DisplayName(nil, true) .. " on " .. Game.Game.Players[playedCard.Target].DisplayName(nil, false) .. ", lasts till turn " .. playedCard.LastTillTurn).SetColor(Game.Game.Players[playedCard.Target].Color.HtmlColor);
            end
        else
            CreateButton(root).SetText("Forced LD card played by " .. Game.Game.Players[playedCard.PlayerID].DisplayName(nil, true) .. " on " .. Game.Game.Players[playedCard.Target].DisplayName(nil, false) .. ", lasts till turn " .. playedCard.LastTillTurn).SetColor(Game.Game.Players[playedCard.Target].Color.HtmlColor);
        end
    end
end

---Sends an message to the server to notify the team and update `Mod.PublicGameData.CardsPlayedThisTurn`
---@param target GamePlayer # The target player of the Forced LD card
function sendUpdateToServer(target)
    if target.ID == nil then
        UI.Alert("You have not selected a player");
        return;
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    if getAllPlayedCardsCount(Game, getPlayerOrTeamID(Game.Us)) >= cardData.WholeCards then
        UI.Alert("Your team has already played all the cards available");
        return;
    end

    Game.SendGameCustomMessage("Sending move...", {Action = "PlayCard"}, function(t) end);

    local turnPhase = WL.TurnPhase.BlockadeCards + 1;
    local orders = Game.Orders;
    local order = WL.GameOrderCustom.Create(Game.Us.ID, "Playing Forced LD card on " .. target.DisplayName(nil, false), "ForcedLD_" .. target.ID, {}, turnPhase);
    local index = 0;
    for i, o in ipairs(orders) do
        if o.OccursInPhase ~= nil and o.OccursInPhase < turnPhase then
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders; end
    table.insert(orders, order);
    Game.Orders = orders;
    Close();
end

function getAllTargettedPlayers()
    local t = {};
    for _, order in pairs(Game.Orders) do
        ---@diagnostic disable-next-line: undefined-field
        if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #"ForcedLD_") ~= nil then
            ---@diagnostic disable-next-line: undefined-field
            t[tonumber(string.sub(order.Payload, #"ForcedLD_" + 1, -1))] = true
        end
    end
    return t;
end

---Counts all the Forced LD cards played by the team
---@param game GameClientHook # The game object
---@param teamID TeamID # The teamID of the team we want to count the cards from
---@return integer # The number of cards played
function getAllPlayedCardsCount(game, teamID)
    local c = 0;
    for _, p in pairs(game.Game.PlayingPlayers) do
        if getPlayerOrTeamID(p) == teamID then
            c = c + Mod.PublicGameData.CardsPlayedThisTurn[p.ID];
        end
    end
    return c;
end

---Returns the playerID of teamID of the player
---@param player GamePlayer # The player in question
---@return PlayerID | TeamID | integer # The ID to use to index the data
function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
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
