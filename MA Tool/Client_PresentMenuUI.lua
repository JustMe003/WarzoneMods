require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    Close = close;
    Game = game;
    if toolInUse == nil then
        specialUnits = {};
        specialUnitsOnTerr = {};
        specialUnitsInOrder = {};
        toolInUse = false;
    end
    setMaxSize(425, 300);

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    if toolInUse then
        CreateLabel(root).SetText("Click the button to stop using the Multi-Attack tool").SetColor(colors.TextColor);
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(0.33);
        CreateButton(line).SetText("End").SetColor(colors.Red).SetOnClick(function() toolInUse = false; showMain(); end);
        CreateEmpty(line).SetFlexibleWidth(0.33);
        CreateButton(line).SetText("Help").SetColor(colors.Orange).SetOnClick(showHelp);
        CreateEmpty(line).SetFlexibleWidth(0.33);
    else
        CreateLabel(root).SetText("Click the button to start using the Multi-Attack tool").SetColor(colors.TextColor);
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(0.33);
        CreateButton(line).SetText("Begin").SetColor(colors.Lime).SetOnClick(function() getSource(); Close(); end);
        CreateEmpty(line).SetFlexibleWidth(0.33);
        CreateButton(line).SetText("Help").SetColor(colors.Orange).SetOnClick(showHelp);
        CreateEmpty(line).SetFlexibleWidth(0.33);
    end
    
end

function getSource()
    toolInUse = true;
    UI.InterceptNextTerritoryClick(validateSource);
end

function validateSource(terrDetails)
    if terrDetails == nil then return; end
    source = terrDetails.ID;
    updateSourceUnits(source);
    getDestination();
end

function getDestination()
    UI.InterceptNextTerritoryClick(validateDestination);
end

function validateDestination(terrDetails)
    if terrDetails == nil or not toolInUse then return WL.CancelClickIntercept; end
    destination = terrDetails.ID;
    if Game.Map.Territories[source].ConnectedTo[destination] ~= nil then
        addOrder();
    else 
        source = destination;
        updateSourceUnits(source);
        getDestination();
    end
end

function addOrder()
    local b, i = getOrderData(Game.Orders, source, destination);
    if not b then
        for GUID, terrID in pairs(specialUnitsOnTerr) do
            if terrID == source then
                table.insert(specialUnitsInOrder, specialUnits[GUID]);
            end
        end
        local orders = Game.Orders;
        local order = WL.GameOrderAttackTransfer.Create(Game.Us.ID, source, destination, 3, true, WL.Armies.Create(100, specialUnitsInOrder), false);
        table.insert(orders, i, order);
        Game.Orders = orders;
        for _, sp in pairs(specialUnitsInOrder) do
            specialUnitsOnTerr[sp.ID] = destination;
            specialUnits[sp.ID] = sp;
        end
    end
    specialUnitsInOrder = {};
    source = destination;
    getDestination();
end

function updateSourceUnits(terrID)
    for _, sp in pairs(Game.LatestStanding.Territories[terrID].NumArmies.SpecialUnits) do
        if specialUnitsOnTerr[sp.ID] == nil and sp.OwnerID == Game.Us.ID then
            table.insert(specialUnitsInOrder, sp);
        end
    end
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do if v2 == v then return true; end; end; return false;
end

function getOrderData(t, s, d)
    local index = 0;
    for i, order in pairs(t) do
        if order.proxyType == "GameOrderAttackTransfer" and order.From == s and order.To == d then
            return true, 0;
        end
        if order.OccursInPhase == nil or order.OccursInPhase <= WL.TurnPhase.Attacks then
            index = i;
        end
    end
    return false, index + 1;
end