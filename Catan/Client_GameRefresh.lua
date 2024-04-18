require("Catan");

TEXTCOLOR = "#DDDDDD";

---Client_GameRefresh hook
---@param game GameClientHook # The client game
function Client_GameRefresh(game);
    print(1);
    if game.Us ~= nil and LastRecordedTurn ~= nil and game.Game.TurnNumber < LastRecordedTurn then
        print(2);
        LastRecordedTurn = game.Game.TurnNumber;
        print(3);
        if not resourceWindowIsOpen() then
            print(4);
            game.CreateDialog(CreateResourcesWindow);
            print(5);
        else
            print(6);
            UI.Destroy(vertClientRefresh);
            print(7);
            vertClientRefresh = UI.CreateVerticalLayoutGroup(rootClientRefresh);
            print(8);
            initResourceDataWindow(game);
            print(9);
        end
        print(10);
    elseif game.Us ~= nil and game.Game.TurnNumber > 0 then
        print(11);
        LastRecordedTurn = game.Game.TurnNumber;
        print(12);
        if not resourceWindowIsOpen() then
            print(13);
            game.CreateDialog(CreateResourcesWindow);
            print(14);
        else
            print(15);
            updateLabels();
            print(16);
            updateExpectedGainsLabels(game);
            print(17);
        end
    end
    print(18);
    
    print(19);
    if game.Us ~= nil and menuWindowIsOpen ~= nil and menuWindowIsOpen() and clientIsWaiting() then
        print(20);
        print("Waiting! Showing main menu again");
        print(21);
        showMain();
        print(22);
        toggleWaiting();
        print(23);
    end
    print(24);
    
    LastTerrIDClick = -1;
    print(25);
    TerrClickCount = 0;
    print(26);
    UI.InterceptNextTerritoryClick(function(d) 
        print(27);
        TripleTerrClickInterceptor(game, d); 
        print(28);
        return WL.CancelClickIntercept;
    end);
    print(30);
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
            if UI.IsDestroyed(RootTerritoryInfoDialog) then
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
    UI.CreateButton(VertTerritoryInfoDialog).SetText(details.Name).SetColor("#00FF8C").SetOnClick(function()
        game.CreateLocatorCircle(details.MiddlePointX, details.MiddlePointY);
        game.HighlightTerritories({details.ID});
    end);
    UI.CreateEmpty(VertTerritoryInfoDialog).SetPreferredHeight(5);

    local terr = game.LatestStanding.Territories[LastTerrIDClick];
    if not canSeeStructure(terr) then
        UI.CreateLabel(VertTerritoryInfoDialog).SetText("You don't have enough of this territory to show more information");
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
            local villageStatsButton = UI.CreateButton(VertTerritoryInfoDialog).SetText("Show").SetColor("#00FF8C")
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