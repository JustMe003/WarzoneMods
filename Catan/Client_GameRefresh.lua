require("Catan");

TEXTCOLOR = "#DDDDDD";
ORANGE = "#FF7D00";
YELLOW = "#FFFF00";

---Client_GameRefresh hook
---@param game GameClientHook # The client game
function Client_GameRefresh(game);
    if game.Us and game.Us.State == WL.GamePlayerState.Playing then
        if updateGlobalVariables then
            updateGlobalVariables(game);
        end

        if LastRecordedTurn ~= nil and game.Game.TurnNumber < LastRecordedTurn then
            LastRecordedTurn = game.Game.TurnNumber;
            if not resourceWindowIsOpen() and Mod.PlayerGameData.Settings and Mod.PlayerGameData.Settings.AutoOpenResourceWindow then
                -- Create window automatically if closed
                game.CreateDialog(CreateResourcesWindow);
            elseif resourceWindowIsOpen() then
                -- Only update window if open
                updateLabels();
                updateExpectedGainsLabels(game);
                -- UI.Destroy(vertClientRefresh);
                -- vertClientRefresh = UI.CreateVerticalLayoutGroup(rootClientRefresh);
                -- initResourceDataWindow(game);
            end
        elseif game.Game.TurnNumber > 0 then
            LastRecordedTurn = game.Game.TurnNumber;
            if not resourceWindowIsOpen() and Mod.PlayerGameData.Settings and Mod.PlayerGameData.Settings.AutoOpenResourceWindow then
                game.CreateDialog(CreateResourcesWindow);
            elseif resourceWindowIsOpen() then
                updateLabels();
                updateExpectedGainsLabels(game);
            end
        end

        if not Mod.PlayerGameData.HasOpenedGame then
            game.SendGameCustomMessage("Updating server...", {Command = "OpenedGame"}, function(t) end);
            game.CreateDialog(createPlayerSettingsDialog)
            game.CreateDialog(createWelcomeDialog)
        end
    
        if menuWindowIsOpen ~= nil and menuWindowIsOpen() and clientIsWaiting() then
            print("Waiting! Showing main menu again");
            showMain();
            toggleWaiting();
        end
    
        LastTerrIDClick = LastTerrIDClick or -1;
        TerrClickCount = TerrClickCount or 0;
        UI.InterceptNextTerritoryClick(function(d) 
            TripleTerrClickInterceptor(game, d); 
            return WL.CancelClickIntercept;
        end);
    end
end

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function CreateResourcesWindow(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(300, 440);
    rootClientRefresh = rootParent;
    vertClientRefresh = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1);
    resourcesCloseFunc = close;
    initResourceDataWindow(game);
end

function initResourceDataWindow(game)
    showResourcesWindow();
    UI.CreateEmpty(vertClientRefresh).SetPreferredHeight(10);
    showExpectedGains(game);
end

---Initialises the resources labels and data
function showResourcesWindow()
    UI.CreateLabel(vertClientRefresh).SetText("Available resources").SetColor(TEXTCOLOR);
    ResourceLabels = {};
    for i, n in ipairs(Mod.PlayerGameData.Resources) do
        local labels = {};
        local line = UI.CreateHorizontalLayoutGroup(vertClientRefresh).SetFlexibleWidth(1);
        labels.ResourceName = UI.CreateLabel(line).SetText(getResourceName(i)).SetColor(getResourceColor(i));
        UI.CreateLabel(line).SetText(": ").SetColor(TEXTCOLOR);
        labels.NumberOfResourceLabel = UI.CreateLabel(line).SetText(n).SetColor(TEXTCOLOR);
        labels.PotentiallyAddedLabel = UI.CreateLabel(line).SetText("").SetColor("#00DD00");
        labels.PotentiallyRemovedLabel = UI.CreateLabel(line).SetText("").SetColor("#DD0000");
        labels.PotentiallyAdded = 0;
        labels.PotentiallyRemoved = 0;
        ResourceLabels[i] = labels;
    end
end

---Shows the expected gains for the upcoming 36 turns
---@param game GameClientHook
function showExpectedGains(game)
    local t = getExpectedGainsFromGame(game);

    UI.CreateLabel(vertClientRefresh).SetText("Expected gain score").SetColor(TEXTCOLOR);
    ExpectedGainsLabels = {};
    for i, v in ipairs(t) do
        local labels = {};
        local line = UI.CreateHorizontalLayoutGroup(vertClientRefresh);
        labels.ResourceName = UI.CreateLabel(line).SetText(getResourceName(i)).SetColor(getResourceColor(i));
        UI.CreateLabel(line).SetText(": ").SetColor(TEXTCOLOR);
        labels.NumberOfResourceLabel = UI.CreateLabel(line).SetText(v).SetColor(TEXTCOLOR);
        labels.PotentiallyAddedLabel = UI.CreateLabel(line).SetText("").SetColor("#00DD00");
        labels.PotentiallyRemovedLabel = UI.CreateLabel(line).SetText("").SetColor("#DD0000");
        labels.PotentiallyAdded = 0;
        labels.PotentiallyRemoved = 0;
        ExpectedGainsLabels[i] = labels;
    end
end

---Returns a table with the expected gain score of the player
---@param game table # The table containing the expected gain score of the player
function getExpectedGainsFromGame(game)
    local t = {};
    for _, res in pairs(Catan.Resources) do
        t[res] = 0;
    end

    local futureVillages = extractBuildVillageTerrIDs(Mod.PlayerGameData);
    local upgradedVillages = extractUpgradeVillageTerrIDs(Mod.PlayerGameData);

    local f = function(terrID)
        if valueInTable(upgradedVillages, terrID) then
            return 1;
        end
        return 0;
    end

    for _, terr in pairs(game.LatestStanding.Territories) do
        if terr.OwnerPlayerID == game.Us.ID and (terrHasVillage(terr.Structures) or valueInTable(futureVillages, terr.ID)) then
            for connID, _ in pairs(game.Map.Territories[terr.ID].ConnectedTo) do
                local conn = game.LatestStanding.Territories[connID];
                local res = getResource(conn);
                if res ~= nil and not (terrHasVillage(conn.Structures) or valueInTable(futureVillages, connID)) then
                    if terrHasVillage(terr.Structures) then
                        t[res] = t[res] + ((getNumberOfVillages(terr.Structures) + f(terr.ID)) * getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, conn.ID)));
                    else
                        t[res] = t[res] + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, conn.ID));
                    end
                end
            end
        end
    end
    return t;
end

function updateLabels()
    if not UI.IsDestroyed(rootClientRefresh) then
        for i, labels in ipairs(ResourceLabels) do
            labels.NumberOfResourceLabel.SetText(Mod.PlayerGameData.Resources[i]);
            if labels.PotentiallyAdded ~= 0 then
                labels.PotentiallyAddedLabel.SetText(" + " .. labels.PotentiallyAdded);
            else
                labels.PotentiallyAddedLabel.SetText("");
            end
            if labels.PotentiallyRemoved ~= 0 then
                labels.PotentiallyRemovedLabel.SetText(" - " .. labels.PotentiallyRemoved);
            else
                labels.PotentiallyRemovedLabel.SetText("");
            end
        end
    end
end

function updateExpectedGainsLabels(game, b);
    b = b or false;
    if not UI.IsDestroyed(rootClientRefresh) then
        local t;
        if not b then
            t = getExpectedGainsFromGame(game);
        end
        for res, labels in ipairs(ExpectedGainsLabels) do
            if not b then
                labels.NumberOfResourceLabel.SetText(t[res]);
            end
            if labels.PotentiallyAdded ~= 0 then
                labels.PotentiallyAddedLabel.SetText(" + " .. labels.PotentiallyAdded);
            else
                labels.PotentiallyAddedLabel.SetText("");
            end
            if labels.PotentiallyRemoved ~= 0 then
                labels.PotentiallyRemovedLabel.SetText(" - " .. labels.PotentiallyRemoved);
            else
                labels.PotentiallyRemovedLabel.SetText("");
            end
        end
    end
end

function resourceWindowIsOpen()
    return rootClientRefresh ~= nil and not UI.IsDestroyed(vertClientRefresh);
end

function TripleTerrClickInterceptor(game, terrDetails)
    if terrDetails == nil then return; end

    if terrDetails.ID == LastTerrIDClick then
        TerrClickCount = (TerrClickCount or 0) + 1;
        if TerrClickCount > 2 then
            TerrClickCount = 0;
            if RootTerritoryInfoDialog == nil or UI.IsDestroyed(RootTerritoryInfoDialog) then
                game.CreateDialog(territoryInfoDialog)
            else
                UI.Destroy(VertTerritoryInfoDialog);
                VertTerritoryInfoDialog = UI.CreateVerticalLayoutGroup(RootTerritoryInfoDialog);
                showTerritoryInfoWindow(game);
            end
        end
    else
        LastTerrIDClick = terrDetails.ID;
        TerrClickCount = 1;
    end

    UI.InterceptNextTerritoryClick(function(d)
        TripleTerrClickInterceptor(game, d);
        return WL.CancelClickIntercept
    end)
end

function territoryInfoDialog(rootParent, setMaxSize, setScrollable, game, close)
    RootTerritoryInfoDialog = rootParent;
    VertTerritoryInfoDialog = UI.CreateVerticalLayoutGroup(rootParent);

    showTerritoryInfoWindow(game);
end

function showTerritoryInfoWindow(game);
    local details = game.Map.Territories[LastTerrIDClick];
    UI.CreateButton(VertTerritoryInfoDialog).SetText(details.Name).SetColor(game.Us.Color.HtmlColor).SetOnClick(function()
        game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY);
        game.HighlightTerritories({details.ID});
    end);
    UI.CreateEmpty(VertTerritoryInfoDialog).SetPreferredHeight(5);

    local terr = game.LatestStanding.Territories[LastTerrIDClick];
    if not canSeeStructure(terr) then
        UI.CreateLabel(VertTerritoryInfoDialog).SetText("You don't have enough of this territory to show more information").SetColor(TEXTCOLOR);
    end

    if terrHasVillage(terr.Structures) then
        UI.CreateLabel(VertTerritoryInfoDialog).SetText("This territory has a village").SetColor(TEXTCOLOR);
        local line = UI.CreateHorizontalLayoutGroup(VertTerritoryInfoDialog);
        UI.CreateLabel(line).SetText("Level: ").SetColor(TEXTCOLOR);
        UI.CreateLabel(line).SetText(getNumberOfVillages(terr.Structures)).SetColor("#00FF8C");

        for res, n in ipairs(getGainScoreFromOneTerr(game.LatestStanding.Territories, details.ConnectedTo, Mod.PublicGameData, getNumberOfVillages(terr.Structures))) do
            local line = UI.CreateHorizontalLayoutGroup(VertTerritoryInfoDialog);
            UI.CreateLabel(line).SetText(getResourceName(res)).SetColor(getResourceColor(res));
            UI.CreateLabel(line).SetText(": ").SetColor(TEXTCOLOR);
            UI.CreateLabel(line).SetText(n).SetColor("#00FF8C");
        end
    elseif terrHasArmyCamp(terr.Structures) then
        UI.CreateLabel(VertTerritoryInfoDialog).SetText("This territory has an army camp").SetColor(TEXTCOLOR);
    else
        if getResource(terr) ~= nil then
            local line = UI.CreateHorizontalLayoutGroup(VertTerritoryInfoDialog);
            UI.CreateLabel(line).SetText("This territory produces ").SetColor(TEXTCOLOR);
            UI.CreateLabel(line).SetText(getResourceNameFromStructure(terr)).SetColor(getResourceColor(getResource(terr)));
            local dieValue = getTerritoryDiceValue(Mod.PublicGameData, terr.ID);
            line = UI.CreateHorizontalLayoutGroup(VertTerritoryInfoDialog);
            UI.CreateLabel(line).SetText("Die value:").SetColor(TEXTCOLOR);
            UI.CreateLabel(line).SetText(dieValue).SetColor("#00FF8C");
            line = UI.CreateHorizontalLayoutGroup(VertTerritoryInfoDialog);
            UI.CreateLabel(line).SetText("Exp. gain score: ").SetColor(TEXTCOLOR);
            UI.CreateLabel(line).SetText(getExpectedGainsIn36Turns(dieValue)).SetColor("#00FF8C");

            local vert;
            UI.CreateLabel(VertTerritoryInfoDialog).SetText("Press the button below to show what the stats the village stats of this territory are");
            local villageStatsButton = UI.CreateButton(VertTerritoryInfoDialog).SetText("Show").SetColor(game.Us.Color.HtmlColor)
            villageStatsButton.SetOnClick(function()
                if villageStatsButton.GetText() == "Show" then
                    villageStatsButton.SetText("Hide");
                    vert = UI.CreateVerticalLayoutGroup(VertTerritoryInfoDialog);
                    
                    for res, n in ipairs(getGainScoreFromOneTerr(game.LatestStanding.Territories, details.ConnectedTo, Mod.PublicGameData, 1)) do
                        local line = UI.CreateHorizontalLayoutGroup(vert);
                        UI.CreateLabel(line).SetText(getResourceName(res)).SetColor(getResourceColor(res));
                        UI.CreateLabel(line).SetText(": ").SetColor(TEXTCOLOR);
                        UI.CreateLabel(line).SetText(n).SetColor("#00FF8C");
                    end
                else
                    villageStatsButton.SetText("Show");
                    UI.Destroy(vert);
                end 
            end)
        end
    end
end

function createPlayerSettingsDialog(rootParent, setMaxSize, setScrollable, game, close)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("Settings").SetColor(TEXTCOLOR);
    local line = UI.CreateHorizontalLayoutGroup(vert);
    local autoOpenResWindow = UI.CreateCheckBox(line).SetIsChecked(Mod.PlayerGameData.Settings.AutoOpenResourceWindow).SetText(" ");
    UI.CreateLabel(line).SetText("Automatically open resource dialog when game refreshes").SetColor(TEXTCOLOR);
    
    UI.CreateEmpty(vert).SetPreferredHeight(5);
    
    line = UI.CreateHorizontalLayoutGroup(vert);
    local unusedUnitsWarn = UI.CreateCheckBox(line).SetIsChecked(Mod.PlayerGameData.Settings.UnusedUnitsWarning).SetText(" ");
    UI.CreateLabel(line).SetText("Warn me when I commit my orders, but did not move some units\nComing soon...").SetColor(TEXTCOLOR);

    UI.CreateEmpty(vert).SetPreferredHeight(10);

    UI.CreateButton(vert).SetText("Save").SetColor(game.Us.Color.HtmlColor).SetOnClick(function()
        game.SendGameCustomMessage("Saving inputs...", {Command = "SaveSettings", AutoOpenResourceWindow = autoOpenResWindow.GetIsChecked(), UnusedUnitsWarning = unusedUnitsWarn.GetIsChecked()}, function(t) end);
        close();
    end)
end

function createWelcomeDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(400, 500);

    local vert = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1);
    local line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
    UI.CreateEmpty(line).SetFlexibleWidth(1);
    UI.CreateLabel(line).SetText("Catan").SetColor(ORANGE);
    UI.CreateEmpty(line).SetFlexibleWidth(1);

    UI.CreateEmpty(vert).SetPreferredHeight(10);

    createBlockButtons(vert, "Introduction", {
        "Welcome to Catan! If you have never played with this mod before, please read me carefully or you'll likely to have a hard time understanding the game. Even if you have played with this mod, I really recommend reading me.",
        "The Catan mod is all about managing infrastructure and raising your army. As you probably already saw, every territory in the game has a specific structure. But before we dive into that the functions of these structures, let me explain how this mod works.",
    })
    
    createBlockButtons(vert, "Note", {
        "There are no normal armies. All territories have 0 armies, and after the first turn you're income will also always be 0. You can only conquer your opponents by using the units Catan provides, but more about that later.",
        "In the main menu, at all times you will 4 buttons in the top of the menu. The most right button, the one with the '?', will give you more information about the window you're currently on. Handy for when you want to know what exactly everything in the mod is for",
    })
    
    createBlockButtons(vert, "Resources", {
        "If you have played the board game Catan, this will sound familiar to you. This mod brings 5 new resources to the table: 'Wood', 'Stone', 'Metal', 'Wheat', 'Livestock'. All these resources are vital for your path to victory. With these resources, you can expand your infrastructure and build your army.",
        "To gather resources, you need a village. A village is indicated by the city structure. Villages gain resources from territories they border, so villages don't actually generate resources themselves. Each resource has its own structure on the map.",
        "Now you have your first ingredient, a village. The second ingredient however, is luck. As in the board game Catan, each territory has a assigned die (die = multiple of dice, I actually didn't know that) value. Each turn, depending on the game speed, the mod will throw some number of die (6 sides) pairs. The sum of each pair is the die value for that turn, only territories with that die value generate resources to their bordering villages.",
        "One last note on this topic, villages can be upgraded. The level of the village is simply shown by the number of villages on that territory. If a territory generates resources for a village, it will generate the same amount of resources as the level of the village",
    })
    
    createBlockButtons(vert, "Infrastructure", {
        "Each starting territory has a village, but you can build more to expand your infrastructure. Building and upgrading villages will increase the number of resources you obtain each turn",
        "Beware though, building a village completely removes the chance of generating resources on that territory. Building villages next to each other can sometimes be worthwhile, but generally building villages next to eachother is bad.",
        "Another important part for your infrastructure are army camps. These army camps can be build, just like cities, on any territory. But they will also remove the resource from that territory.",
    })

    createBlockButtons(vert, "Army", {
        "On the topic of army camps, these are your sources for your army. You can recruit/fabricate units only in army camps. In the beginning this will be slow, but over time you will be able to create an army worthwhile to take down any opponent!",
        "Your army will exist of different units. I won't ruin the suprise for you which units are in the mod, so you can find it out yourself. It is however important to note that, in order to reduce the number of unit objects, units of the same type that end up on the same territory merge together. But don't worry, you can split units if you like, to maximize your strategy",
        "Units can also be upgraded. Have I mentioned that this mod includes research trees? No? Oops, I spoiled the suprise, my bad.",
    })

    createBlockButtons(vert, "Research Trees", {
        "You can research and dive into the tech trees to improve/unlock your army, resource gathering and development cards.",
        "While traversing the research/tech trees, you will encounter 2 types of layouts: 'Serial' and 'Parallel'. Once you unlock a parallel layout, all researches and direct children will also be unlocked. On the contrary, once you unlock a serial layout, only the first research or direct child is unlocked and has to be researched before the next research or child is unlocked",
        "If this above doesn't really make sense, I recommend not to take to much notice about it the first times you play with the mod",
    })

    createBlockButtons(vert, "Development Cards", {
        "COMING SOON...",
    })
end

function createBlockButtons(parent, buttonText, labels)
    local button;
    local vert;
    local childVert;
    button = UI.CreateButton(parent).SetText(buttonText).SetColor(ORANGE).SetOnClick(function()
        if button.GetColor() == ORANGE then
            button.SetColor(YELLOW);
            for i, message in ipairs(labels) do
                if i > 1 then UI.CreateEmpty(childVert).SetPreferredHeight(3); end
                UI.CreateLabel(childVert).SetText(message).SetColor(TEXTCOLOR);
            end
        else
            button.SetColor(ORANGE);
            UI.Destroy(childVert);
            childVert = UI.CreateVerticalLayoutGroup(vert);
        end
    end);
    vert = UI.CreateVerticalLayoutGroup(parent);
    childVert = UI.CreateVerticalLayoutGroup(vert);
end