require("Catan");

TEXTCOLOR = "#DDDDDD";

---Client_GameRefresh hook
---@param game GameClientHook # The client game
function Client_GameRefresh(game);
    if game.Us ~= nil and LastRecordedTurn ~= nil and game.Game.TurnNumber < LastRecordedTurn then
        LastRecordedTurn = game.Game.TurnNumber;
        if rootClientRefresh == nil or UI.IsDestroyed(vertClientRefresh) then
            game.CreateDialog(CreateResourcesWindow);
        else
            UI.Destroy(vertClientRefresh);
            vertClientRefresh = UI.CreateVerticalLayoutGroup(rootClientRefresh);
            initResourceDataWindow(game);
        end
    elseif game.Us ~= nil and game.Game.TurnNumber > 0 then
        LastRecordedTurn = game.Game.TurnNumber;
        if rootClientRefresh == nil or UI.IsDestroyed(vertClientRefresh) then
            game.CreateDialog(CreateResourcesWindow);
        else
            updateLabels();
            updateExpectedGainsLabels(game);
        end
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
    vertClientRefresh = UI.CreateVerticalLayoutGroup(rootParent);
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
        local line = UI.CreateHorizontalLayoutGroup(vertClientRefresh);
        labels.ResourceName = UI.CreateLabel(line).SetText(getResourceName(i) .. ": ").SetColor(TEXTCOLOR);
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
        labels.ResourceName = UI.CreateLabel(line).SetText(getResourceName(i) .. ": ").SetColor(TEXTCOLOR);
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

    local futureVillages = extractBuildVillageTerrIDs();

    for _, terr in pairs(game.LatestStanding.Territories) do
        if terr.OwnerPlayerID == game.Us.ID and (terrHasVillage(terr.Structures) or valueInTable(futureVillages, terr.ID)) then
            for connID, _ in pairs(game.Map.Territories[terr.ID].ConnectedTo) do
                local conn = game.LatestStanding.Territories[connID];
                local res = getResource(conn);
                if res ~= nil and not (terrHasVillage(conn.Structures) or valueInTable(futureVillages, connID)) then
                    if terrHasVillage(terr.Structures) then
                        t[res] = t[res] + (getNumberOfVillages(terr.Structures) * getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, conn.ID)));
                    else
                        t[res] = t[res] + getExpectedGainsIn36Turns(getTerritoryDiceValue(Mod.PublicGameData, conn.ID));
                    end
                end
            end
        end
    end
    return t;
end

function extractBuildVillageTerrIDs()
    if Mod.PlayerGameData == nil or Mod.PlayerGameData.OrderList == nil then return {}; end
    local t = {};
    local enum = getBuildVillageEnum();
    for _, order in ipairs(Mod.PlayerGameData.OrderList) do
        if order.OrderType == enum then
            table.insert(t, order.TerritoryID);
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


--[[Hi Fizzer,

I'm working on a mod and keep running into this issue. It comes up now when I start the game, and it disallows me to play any turn.

I think it has to do with [i]Client_GameRefresh[/i], I create a dialog here]]