require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    Game = game;
    Close = close;

    setMaxSize(500, 400);

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");
    
    if Game.Settings.SinglePlayer and Game.Game.TurnNumber > 0 then
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateButton(line).SetText("Place Dragon").SetColor(colors.Lime).SetOnClick(pickTerr);
        CreateButton(line).SetText("Get Data").SetColor(colors.Orange).SetOnClick(showDragonPlacements);
    end

    CreateEmpty(root).SetPreferredHeight(10);

    CreateLabel(root).SetText("These are all the Dragons that are / will be placed at the start of the game").SetColor(colors.Textcolor);
    if Game.Settings.SinglePlayer then
        CreateLabel(root).SetText("(note that you still have to copy the data input over to the mod settings if you haven't done that!)").SetColor(colors.Tan);
    end
    for terr, arr in pairs(Mod.PublicGameData.DragonPlacements) do
        for _, dragonID in pairs(arr) do
            addDragonPlacementLabel(terr, dragonID);
        end
    end
end

function pickTerr()
    DestroyWindow();
    SetWindow("pickTerr");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    label = CreateLabel(root).SetText("click / tap a territory to deploy a Dragon").SetColor(colors.Textcolor);
    local line = CreateHorz(root);
    nextButton = CreateButton(line).SetText("Next").SetColor(colors.Green).SetOnClick(chooseDragon).SetInteractable(false);
    againButton = CreateButton(line).SetText("Change territory").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.InterceptNextTerritoryClick(terrChosen); end).SetInteractable(false);
    UI.InterceptNextTerritoryClick(terrChosen)
end

function terrChosen(terrDetails)
    if terrDetails ~= nil then
        chosenTerr = terrDetails;
        label.SetText("Territory chosen: " .. terrDetails.Name);
        nextButton.SetInteractable(true);
        againButton.SetInteractable(true);
    end
end

function chooseDragon()
    DestroyWindow();
    SetWindow("chooseDragon");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(pickTerr);
    CreateEmpty(root).SetPreferredHeight(10);
    CreateLabel(root).SetText("Choose which dragon will be put on " .. chosenTerr.Name);
    CreateEmpty(root).SetPreferredHeight(5);

    for _, dragon in ipairs(Mod.Settings.Dragons) do
        CreateButton(root).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() addDragon(dragon.ID) end);
    end
end

function addDragon(dragonID)
    Game.SendGameCustomMessage("Updating data...", {Type="addDragon", TerrID=chosenTerr.ID, DragonID=dragonID}, function(t) showMain(); addDragonPlacementLabel(chosenTerr.ID, dragonID) end);
end

function showDragonPlacements()
    DestroyWindow();
    SetWindow("setDragonPlacements");

    local s = "";
    for terr, arr in pairs(Mod.PublicGameData.DragonPlacements) do 
        if #arr > 0 then
            if #s > 0 then 
                s = s .. ","; 
            else
                s = "[" .. Game.Map.ID .. "]{";
            end
            s = s .. terr .. ":{";
            for i = 1, #arr - 1 do
                s = s .. arr[i] .. ",";
            end
            s = s .. arr[#arr] .. "}"
        end
    end
    if #s == 0 then
        s = "[" .. Game.Map.ID .. "]{";
    end
    s = s .. "}"

    CreateTextInputField(root).SetText(s).SetPlaceholderText("Copy from here the Dragons placement data").SetFlexibleWidth(1);
    CreateLabel(root).SetText("Paste this data in the Mod configuration")
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
end

function addDragonPlacementLabel(terr, dragonID)
    local line = CreateHorz(root).SetFlexibleWidth(1);
    local s = "";
    if Mod.Settings.Dragons[dragonID].IncludeABeforeName then
        s = s .. "A ";
    end
    CreateLabel(line).SetText(s .. Mod.Settings.Dragons[dragonID].Name).SetColor(Mod.Settings.Dragons[dragonID].Color);
    CreateLabel(line).SetText(" on: ").SetColor(colors.Textcolor);
    CreateEmpty(line).SetPreferredWidth(5);
    if Game.Map.Territories[terr] ~= nil then
        CreateButton(line).SetText(Game.Map.Territories[terr].Name).SetColor(colors.Tan).SetOnClick(function() if WL.IsVersionOrHigher or WL.IsVersionOrHigher("5.21") then Game.HighlightTerritories({terr}); Game.CreateLocatorCircle(Game.Map.Territories[terr].MiddlePointX, Game.Map.Territories[terr].MiddlePointY); end; end);
    else
        CreateButton(line).SetText("[" .. terr .. "]").SetColor(colors.Red);
    end
    if Game.Settings.SinglePlayer and Game.Game.TurnNumber > 0 then
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("DEL").SetColor(colors.Red).SetOnClick(function() deleteDragonConfirmation(terr, dragonID); end);
    end
end

function deleteDragonConfirmation(terr, dragonID)
    if Game.Map.Territories[terr] == nil then
        Game.SendGameCustomMessage("Updating data...", {Type="removeDragon", TerrID=terr, DragonID=dragonID}, function(t) Close(); end);
        return;
    end

    DestroyWindow();
    SetWindow("deleteDragonConfirmation");

    CreateLabel(root).SetText("Are you sure you want to remove 1 " .. Mod.Settings.Dragons[dragonID].Name .. " from " .. Game.Map.Territories[terr].Name .. "?").SetColor(colors.Textcolor);
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.475);
    CreateButton(line).SetText("Yes").SetColor(colors.Green).SetOnClick(function() Game.SendGameCustomMessage("Updating data...", {Type="removeDragon", TerrID=terr, DragonID=dragonID}, function(t) end); Close(); end)
    CreateEmpty(line).SetFlexibleWidth(0.05);
    CreateButton(line).SetText("No").SetColor(colors.Red).SetOnClick(showMain);
    CreateEmpty(line).SetFlexibleWidth(0.475);
end