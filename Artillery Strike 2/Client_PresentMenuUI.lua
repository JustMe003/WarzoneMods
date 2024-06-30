require("Annotations");
require("UI");
require("Util");
require("DataConverter");
require("Client_PresentSettingsUI");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, art)
    if game.Us == nil then
        close();
        UI.Alert("You cannot use this mod if you're a spectator");
        return;
    end
    Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
    colors = GetColors();
    Game = game;
    Close = close;
    setMaxSize(400, 500);
    CancelClickIntercept = true;
    if art ~= nil then
        buyArtilleryWindow(art);
    else
        showMain();
    end
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    local line = CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Mod Author:  ").SetColor(colors.TextColor);
    CreateLabel(line).SetText("  Just_A_Dutchman_").SetColor(colors.Lime);
    CreateEmpty(line).SetFlexibleWidth(0.5);

    CreateEmpty(root).SetPreferredHeight(50);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Buy Artillery").SetColor(colors.Blue).SetOnClick(chooseArtillery);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Artillery Strike").SetColor(colors.Red).SetOnClick(artilleryStrike);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function artilleryStrike()
    DestroyWindow();
    SetWindow("ArtilleryStrike");

    showPickTerritory("Click the territory you want to target.\nNote that you can only select territories you do not control", targetTerritory, function() return not terrIsControlledByPlayer(); end);
end

function targetTerritory()
    DestroyWindow();
    SetWindow("TargetTerritory");

    local availableArtillery = getAllControlledArtilleries();
    local labels = {};
    local strikeDetails = {
        Cost = 0;
        MinDamageFixed = 0;
        MaxDamageFixed = 0;
        MinDamagePercentage = 0;
        MaxDamagePercentage = 0;
    }

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.4);
    CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(artilleryStrike);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Strike!").SetColor(colors.Red).SetOnClick(function()
        createStrikeOrder(availableArtillery, PickedTerr.ID, strikeDetails.Cost);
    end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Help?").SetColor(colors["Royal Blue"]).SetOnClick(function()
        Game.CreateDialog(function(par, size, scroll, game, close)
            size(400, 400);
            local vert = UI.CreateVerticalLayoutGroup(par).SetFlexibleWidth(1);

            UI.CreateLabel(vert).SetText("This page will explain what each component displays").SetColor(colors.TextColor);
            
            UI.CreateEmpty(vert).SetPreferredHeight(10);
            
            local line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
            UI.CreateLabel(line).SetText("Target:").SetColor(colors.TextColor);
            UI.CreateButton(line).SetText(PickedTerr.Name).SetColor(getTerrOwnerColor(Game.LatestStanding.Territories[PickedTerr.ID])).SetOnClick(function()
                highlightTerritory(PickedTerr);
            end);
            UI.CreateLabel(vert).SetText("This line shows which territory you have selected as target. The name of the territory will be shown in the button, and when you click the button the territory will be highlighted");
            
            UI.CreateEmpty(vert).SetPreferredHeight(10);
            
            line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
            UI.CreateLabel(line).SetText("Cost:").SetColor(colors.TextColor);
            UI.CreateLabel(line).SetText("9").SetColor(colors.Yellow);
            UI.CreateLabel(vert).SetText("This line shows the total amount of gold you will have to pay for the artillery strike. The amount of gold you need to pay depends on how many artillery units participate in the artillery strike and the type of the artillery units");

            UI.CreateEmpty(vert).SetPreferredHeight(10);
            
            line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
            UI.CreateLabel(line).SetText("Fixed damage: ").SetColor(colors.TextColor);
            UI.CreateLabel(line).SetText("10").SetColor(colors["Orange Red"]);
            UI.CreateLabel(line).SetText(" - ").SetColor(colors.TextColor);
            UI.CreateLabel(line).SetText(20).SetColor(colors.Lime);
            UI.CreateLabel(vert).SetText("This line shows the amount of fixed damage the artillery strike will inflict. The red number is the minimum damage. The green number is the maximum damage. The final damage will be determined by a random number between the minimum and maximum damage. The values of both the minimum and maximum damage depend on the number of artillery units participating in the artillery strike and the type of the participating artillery units");
            
            UI.CreateEmpty(vert).SetPreferredHeight(10);
            
            line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
            UI.CreateLabel(line).SetText("Percentage damage: ").SetColor(colors.TextColor);
            UI.CreateLabel(line).SetText("10").SetColor(colors["Orange Red"]);
            UI.CreateLabel(line).SetText(" - ").SetColor(colors.TextColor);
            UI.CreateLabel(line).SetText(20).SetColor(colors.Lime);
            UI.CreateLabel(vert).SetText("This line shows the amount of percentage damage the artillery strike will inflict. The damage it will inflict depends on the number of armies on the target territory. The red number is the minimum percentage damage. The green number is the maximum percentage damage. The final percentage damage will be determined by a random number between the minimum and maximum percentage damage. The values of both the minimum and maximum percentage damage depend on the number of artillery units participating in the artillery strike and the type of the participating artillery units");
            
            UI.CreateEmpty(vert).SetPreferredHeight(10);
            
            line = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
            UI.CreateCheckBox(line).SetIsChecked(false).SetText(" ");
            UI.CreateButton(line).SetText((Mod.Settings.Artillery[1] or {Name = "Artillery Unit"}).Name).SetColor((Mod.Settings.Artillery[1] or {Color = colors.Green}).Color);
            UI.CreateLabel(line).SetText("10% - 25%").SetColor(colors.Orange);
            UI.CreateEmpty(line).SetFlexibleWidth(1);
            UI.CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function()
                UI.Alert("Normally this box will display information about the artillery unit, why it can't participate for example or how much damage it does, etc");
            end);
            UI.CreateLabel(vert).SetText("This is an example of how an artillery as an option will be shown. \nChecking the checkbox will make the artillery participate in the artillery strike, unchecking the checkbox undoes this. If you cannot interact with the checkbox, it means that something is interfering to allow the artillery unit to participate in the artillery strike.\nThe button can be used to locate the artillery. In this example it does not work, but you can try it out in the actual window.\nThe orange text shows the damage the artillery will add to the artillery strike, the first number is the minimum damage and the second number is the maximum damage. If there is a '%' after both numbers, the damage is a percentage damage, otherwise it will deal fixed damage\nLastly the '?' button will give you more information on why you can't add the artillery unit to the artillery strike, its damage, range, etc");
            
            UI.CreateEmpty(vert).SetPreferredHeight(10);

            UI.CreateButton(vert).SetText("Got it!").SetColor(colors.Green).SetOnClick(function() close(); end);
        end)
    end)
    CreateEmpty(line).SetFlexibleWidth(0.4);
    CreateEmpty(root).SetPreferredHeight(10);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Target: ").SetColor(colors.TextColor);
    CreateButton(line).SetText(PickedTerr.Name).SetColor(getTerrOwnerColor(Game.LatestStanding.Territories[PickedTerr.ID])).SetOnClick(function() 
        highlightTerritory(PickedTerr);
    end);
    
    line = CreateHorz(root);
    CreateLabel(line).SetText("Cost: ").SetColor(colors.TextColor);
    labels.Cost = CreateLabel(line).SetText(strikeDetails.Cost).SetColor(colors.Yellow);

    line = CreateHorz(root);
    CreateLabel(line).SetText("Fixed damage: ").SetColor(colors.TextColor);
    labels.MinDamageFixed = CreateLabel(line).SetText(strikeDetails.MinDamageFixed).SetColor(colors["Orange Red"]);
    CreateLabel(line).SetText(" - ").SetColor(colors.TextColor);
    labels.MaxDamageFixed = CreateLabel(line).SetText(strikeDetails.MaxDamageFixed).SetColor(colors.Lime);
    
    line = CreateHorz(root);
    CreateLabel(line).SetText("Percentage damage: ").SetColor(colors.TextColor);
    labels.MinDamagePercentage = CreateLabel(line).SetText(strikeDetails.MinDamagePercentage).SetColor(colors["Orange Red"]);
    CreateLabel(line).SetText("% - ").SetColor(colors.TextColor);
    labels.MaxDamagePercentage = CreateLabel(line).SetText(strikeDetails.MaxDamagePercentage).SetColor(colors.Lime);
    CreateLabel(line).SetText("%").SetColor(colors.TextColor);

    CreateEmpty(root).SetPreferredHeight(5);

    for _, data in ipairs(availableArtillery) do
        data.Selected = false;
        local art = Mod.Settings.Artillery[nameToArtilleryID(data.Unit.Name)];
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateCheckBox(line).SetText(" ").SetIsChecked(false).SetOnValueChanged(function()
            data.Selected = not data.Selected;
            if data.Selected then
                if art.UsingCostGold then
                    strikeDetails.Cost = strikeDetails.Cost + art.UseCost;
                end
                if art.DealsPercentageDamage then
                    strikeDetails.MinDamagePercentage = strikeDetails.MinDamagePercentage + art.MinimumDamage;
                    strikeDetails.MaxDamagePercentage = strikeDetails.MaxDamagePercentage + art.MaximumDamage;
                else
                    strikeDetails.MinDamageFixed = strikeDetails.MinDamageFixed + art.MinimumDamage;
                    strikeDetails.MaxDamageFixed = strikeDetails.MaxDamageFixed + art.MaximumDamage;
                end
            else
                if art.UsingCostGold then
                    strikeDetails.Cost = strikeDetails.Cost - art.UseCost;
                end
                if art.DealsPercentageDamage then
                    strikeDetails.MinDamagePercentage = strikeDetails.MinDamagePercentage - art.MinimumDamage;
                    strikeDetails.MaxDamagePercentage = strikeDetails.MaxDamagePercentage - art.MaximumDamage;
                else
                    strikeDetails.MinDamageFixed = strikeDetails.MinDamageFixed - art.MinimumDamage;
                    strikeDetails.MaxDamageFixed = strikeDetails.MaxDamageFixed - art.MaximumDamage;
                end
            end
            updateStrikeLabels(labels, strikeDetails);
        end).SetInteractable(data.Available);
        CreateButton(line).SetText(data.Unit.Name).SetColor(art.Color).SetOnClick(function() highlightTerritory(Game.Map.Territories[data.Terr]); end);
        CreateLabel(line).SetText(round(art.MinimumDamage, 2) .. addPercentageIfTrue(art.DealsPercentageDamage) .. " - " .. round(art.MaximumDamage, 2) .. addPercentageIfTrue(art.DealsPercentageDamage)).SetColor(colors.Orange);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert(data.Message); end);
    end
end

function updateStrikeLabels(labels, details)
    for i, label in pairs(labels) do
        label.SetText(round(details[i], 2));
    end
end 

function chooseArtillery()
    DestroyWindow();
    SetWindow("chooseArtillery");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    CreateEmpty(root).SetPreferredHeight(10);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Choose an artillery unit to buy").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    for _, art in ipairs(Mod.Settings.Artillery) do
        local numArt = countArtilleryOfType(Game.LatestStanding.Territories, art.Name, Game.Us.ID, true);
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateButton(line).SetText(art.Name).SetColor(art.Color).SetOnClick(function()
            buyArtilleryWindow(art);
        end).SetInteractable(art.CanBeBought and numArt < art.MaxNumOfArtillery);
        if art.CanBeBought then
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateLabel(line).SetText(numArt .. " / " .. art.MaxNumOfArtillery).SetColor(colors.TextColor);
        else
            CreateLabel(line).SetText("This artillery cannot be bought").SetColor(colors.TextColor);
        end
        UI.CreateButton(line).SetText("?").SetColor("#23A0FF").SetOnClick(function()
            Game.CreateDialog(function(rootPar, size, scroll, game, closeSettings)
                local oldRoot = root;
                root = UI.CreateVerticalLayoutGroup(rootPar).SetFlexibleWidth(1);
                size(400, 400);
                showArtillerySettings(art, true, function() closeSettings(); end);
                root = oldRoot;
            end)
        end);
    end
end

function buyArtilleryWindow(art)
    DestroyWindow();
    SetWindow("BuyArtillery");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Purchasing: ").SetColor(colors.TextColor);
    CreateLabel(line).SetText(art.Name).SetColor(art.Color);
    showPickTerritory("Please select a territory to deploy the artillery on.\nNote that you can only select territories you control", function()
        purchaseArtillery(art, PickedTerr.ID);
    end, terrIsControlledByPlayer);
end

function showPickTerritory(message, func, reqFunc)
    CreateEmpty(root).SetPreferredHeight(5);
    
    PickedTerr = nil;
    SubmitButton = nil;
    ReqFunc = reqFunc;

    CreateLabel(root).SetText(message).SetColor(colors.TextColor);
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Selected: ").SetColor(colors.TextColor);
    TerrLabel = CreateLabel(line);
    updateTerrPickedLabel();
    
    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    SubmitButton = CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        CancelClickIntercept = true;
        func();
    end).SetInteractable(PickedTerr ~= nil and (reqFunc == nil or reqFunc()));
    CreateEmpty(line).SetFlexibleWidth(0.45);

    CancelClickIntercept = false;
    UI.InterceptNextTerritoryClick(interceptedTerritoryClick);
end

function interceptedTerritoryClick(terrDetails)
    if terrDetails == nil or CancelClickIntercept or UI.IsDestroyed(root) then return WL.CancelClickIntercept; end
    PickedTerr = terrDetails;
    updateTerrPickedLabel();
    UI.InterceptNextTerritoryClick(interceptedTerritoryClick);
end

function createStrikeOrder(arts, terrID, cost);
    local t = {};
    for _, data in ipairs(arts) do
        if data.Selected then
            table.insert(t, data);
        end
    end
    if #t == 0 then
        UI.Alert("You must select at least 1 artillery, or cancel the action");
        return;
    end

    local payload = PREFIX_AS2 .. SEPARATOR_AS2 .. ARTILLERY_STRIKE .. SEPARATOR_AS2 .. terrID;
    for _, data in pairs(t) do
        payload = payload .. SEPARATOR_AS2 .. data.Terr .. GROUP_SEPARATOR_AS2 .. data.Unit.ID;
    end
    if #payload >= 1000 then
        UI.Alert("You have picked to many artillery pieces! Please pick less");
        return;
    end
    addOrderToList(WL.GameOrderCustom.Create(Game.Us.ID, "Artillery strike on " .. Game.Map.Territories[terrID].Name .. ", involving " .. #t .. " artillery unit" .. addSIfMultiple(#t), payload, {[WL.ResourceType.Gold] = cost}, WL.TurnPhase.Deploys + 2));
    Close();
end

function purchaseArtillery(art, terrID)
    addOrderToList(WL.GameOrderCustom.Create(Game.Us.ID, "Purchase " .. art.Name, PREFIX_AS2 .. SEPARATOR_AS2 .. BUY_ARTILLERY .. SEPARATOR_AS2 .. art.ID .. SEPARATOR_AS2 .. terrID, {[WL.ResourceType.Gold] = art.Cost}, WL.TurnPhase.Deploys));
    Close();
end

function addOrderToList(order)
    local orders = Game.Orders;
    local index = 0;
    for i, o in pairs(orders) do
        if o.OccursInPhase ~= nil and o.OccursInPhase > order.OccursInPhase then
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders + 1; end
    table.insert(orders, index, order);
    Game.Orders = orders;
end

function updateTerrPickedLabel()
    if PickedTerr then
        if ReqFunc == nil or ReqFunc() then
            TerrLabel.SetText(PickedTerr.Name).SetColor(colors.Green);
            if SubmitButton ~= nil then
                SubmitButton.SetInteractable(true);
            end
        else
            TerrLabel.SetText(PickedTerr.Name).SetColor(colors["Orange Red"]);
            if SubmitButton ~= nil then
                SubmitButton.SetInteractable(false);
            end
        end
    else
        TerrLabel.SetText("None").SetColor(colors.Yellow);
        if SubmitButton ~= nil then
            SubmitButton.SetInteractable(false);
        end
    end
end

function terrIsControlledByPlayer()
    local terrStanding = Game.LatestStanding.Territories[PickedTerr.ID];
    return terrStanding.OwnerPlayerID == Game.Us.ID;
end

function highlightTerritory(t)
    Game.CreateLocatorCircle(t.MiddlePointX, t.MiddlePointY);
    Game.HighlightTerritories({t.ID});
end

function getAllControlledArtilleries()
    local t = {};
    local artilleryInUse = getArtilleryInUse(Game.Orders);
    for _, terr in pairs(Game.LatestStanding.Territories) do
        if #terr.NumArmies.SpecialUnits > 0 then
            for _, sp in pairs(terr.NumArmies.SpecialUnits) do
                if isArtillery(sp) and sp.OwnerID == Game.Us.ID then
                    local unitData = DataConverter.StringToData(sp.ModData);
                    local unitID = unitData.AS2.TypeID;
                    if valueInTable(artilleryInUse, sp.ID) then
                        table.insert(t, {Unit = sp, Terr = terr.ID, Message = "This artillery unit is already included in an artillery strike", Available = false})
                        break;
                    end
                    if unitData.AS2.ReloadTurn >= Game.Game.TurnNumber then
                        table.insert(t, {Unit = sp, Terr = terr.ID, Message = "This artillery unit is still reloading! You can use and move this unit again after turn " .. unitData.AS2.ReloadTurn, Available = false})
                        break;
                    end
                    local distance = getDistanceBetweenTerrs(Game.Map.Territories, PickedTerr, Game.Map.Territories[terr.ID], Mod.Settings.Artillery[unitID].MaximumRange);
                    if Mod.Settings.Artillery[unitID].MaximumRange < distance then
                        table.insert(t, {Unit = sp, Terr = terr.ID, Message = "This artillery unit is to far away for the current target!", Available = false});
                        break;
                    end
                    local art = Mod.Settings.Artillery[nameToArtilleryID(sp.Name)];
                    table.insert(t, {Unit = sp, Terr = terr.ID, Message = "Cost: " .. art.UseCost .. "\nMinimum damage: " .. art.MinimumDamage .. addPercentageIfTrue(art.DealsPercentageDamage) .. "\nMaximum damage: " .. art.MaximumDamage .. addPercentageIfTrue(art.DealsPercentageDamage) .. "\nDistance: " .. distance .. "\nMaximum range: " .. art.MaximumRange .. "\nMiss chance: " .. art.MissPercentage .. "%", Available = true});
                end
            end
        end
    end
    return t;
end

function getTerrOwnerColor(terr)
    if terr.OwnerPlayerID == WL.PlayerID.Neutral or terr.FogLevel == WL.StandingFogLevel.Fogged then return "#ABCDEF"; end
    return Game.Game.Players[terr.OwnerPlayerID].Color.HtmlColor;
end

function addPercentageIfTrue(b)
    if b then return "%"; end
    return "";
end

function getArtilleryInUse(orders)
    local t = {};
    for _, order in ipairs(orders) do
        if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #(PREFIX_AS2 .. SEPARATOR_AS2 .. ARTILLERY_STRIKE)) == PREFIX_AS2 .. SEPARATOR_AS2 .. ARTILLERY_STRIKE then
            print(order.Payload);
            local splits = split(order.Payload, SEPARATOR_AS2);
            for i = 4, #splits, 2 do
                table.insert(t, split(splits[i], GROUP_SEPARATOR_AS2)[2]);
                print(t[#t]);
            end
        end
    end
    return t;
end