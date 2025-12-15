InspectMenu = {};

local PickedTerr;
local SubmitButton;
local TerrLabel;

function InspectMenu.ShowMenu()
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1)).SetCenter(true);
    UI2.CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(MainMenu.ShowMain);

    UI2.CreateEmpty(root).SetPreferredHeight(10);
    UI2.CreateLabel(root).SetText("Do you with to inspect global or local events?").SetColor(colors.TextDefault);
    UI2.CreateEmpty(root).SetPreferredHeight(5);

    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Global").SetColor(colors.Lime).SetOnClick(InspectMenu.InspectGlobalMap);
    UI2.CreateEmpty(line).SetMinWidth(15);
    UI2.CreateButton(line).SetText("Local").SetColor(colors.RoyalBlue).SetOnClick(InspectMenu.InspectTerritory);
end

function InspectMenu.InspectGlobalMap()
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(InspectMenu.ShowMenu);

    if getTableLength(Mod.PublicGameData.GlobalTriggers) > 0 then
    else
        UI2.CreateLabel(root).SetText("There are currently no global triggers").SetColor(colors.TextDefault);
    end
end

function InspectMenu.InspectTerritory(terrDetails)
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(InspectMenu.ShowMenu);

    if terrDetails == nil then
        UI2.CreateLabel(root).SetText("Please select a territory to inspect").SetColor(colors.TextColor);
        InspectMenu.ShowPickTerritory(root, function(details)
            InspectMenu.InspectTerritory(details)
        end);
    else
        local map = Mod.PublicGameData.TerritoryMap[terrDetails.ID];
        if map ~= nil then
            printTable(map);
            for _, arr in pairs(map) do
                for _, triggerObj in pairs(arr) do
                    local trigger = Mod.PublicGameData.Triggers[triggerObj.TriggerID];
                    UI2.CreateButton(root).SetText(trigger.Name).SetColor(TriggerTypeEnum.GetTriggerTypeColor(trigger.Type));
                    for _, eventID in pairs(triggerObj.EventIDs) do
                        local event = Mod.PublicGameData.Events[eventID];
                        local line = UI2.CreateHorz(root).SetFlexibleWidth(1);
                        UI2.CreateEmpty(line).SetMinWidth(40);
                        UI2.CreateButton(line).SetText(event.Name).SetColor(EventTypeEnum.GetEventTypeColor(event.Type));
                    end
                end
            end
        else
            UI2.CreateLabel(root).SetText("There are no triggers/events on this territory").SetColor(colors.TextColor);
        end
    end
end

function InspectMenu.ShowPickTerritory(root, func)
    UI2.CreateEmpty(root).SetPreferredHeight(5);
    
    PickedTerr = nil;
    SubmitButton = nil;

    local line = UI2.CreateHorz(root).SetFlexibleWidth(1);
    UI2.CreateLabel(line).SetText("Selected: ").SetColor(colors.TextColor);
    TerrLabel = UI2.CreateLabel(line);
    InspectMenu.UpdateTerrPickedLabel();
    
    UI2.CreateEmpty(root).SetPreferredHeight(5);

    line = UI2.CreateHorz(root).SetFlexibleWidth(1);
    UI2.CreateEmpty(line).SetFlexibleWidth(0.45);
    SubmitButton = UI2.CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        CancelClickIntercept = true;
        local details = PickedTerr;
        PickedTerr = nil;
        SubmitButton = nil;
        func(details);
    end).SetInteractable(PickedTerr ~= nil);
    UI2.CreateEmpty(line).SetFlexibleWidth(0.45);

    CancelClickIntercept = false;
    UI2.InterceptNextTerritoryClick(InspectMenu.InterceptedTerritoryClick);
end

function InspectMenu.InterceptedTerritoryClick(terrDetails)
    if terrDetails == nil or CancelClickIntercept or UI2.IsDestroyed(GlobalRoot) then return WL.CancelClickIntercept; end
    PickedTerr = terrDetails;
    InspectMenu.UpdateTerrPickedLabel();
    UI2.InterceptNextTerritoryClick(InspectMenu.InterceptedTerritoryClick);
end

function InspectMenu.UpdateTerrPickedLabel()
    if PickedTerr then
        TerrLabel.SetText(PickedTerr.Name).SetColor(colors.Green);
        if SubmitButton ~= nil then
            SubmitButton.SetInteractable(true);
        end
    else
        TerrLabel.SetText("None").SetColor(colors.Yellow);
        if SubmitButton ~= nil then
            SubmitButton.SetInteractable(false);
        end
    end
end