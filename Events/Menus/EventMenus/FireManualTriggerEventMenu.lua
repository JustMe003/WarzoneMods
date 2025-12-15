require("Enums.EventEnums");
require("Enums.TriggerEnums");

require("Events.FireManualTrigger");

require("Menus.EventMenus.EventMenu");

FireManualTriggerEventMenu = {};

function FireManualTriggerEventMenu.ShowMenu(event)
    History.AddToHistory(FireManualTriggerEventMenu.ShowMenu, event);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    EventMenu.ShowEventHeader(event, inputs, root, FireManualTriggerEventMenu.SaveEvent);

    EventMenu.ShowEvent(event, inputs, root);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Fire Manual Trigger event").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);

    UI2.CreateInfoButtonLine(root, function(line)
        inputs.NotifyNeighbours = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(event.NotifyNeighbours or false);
        UI2.CreateLabel(line).SetText("Notify neighbours").SetColor(colors.TextColor);
    end, FireManualTriggerEvent.Info.EventNotifyNeighbours);

    inputs.TriggerID = event.TriggerID;
    inputs.TerritoryID = event.TerritoryID;

    local reloadEvent = function()
        FireManualTriggerEventMenu.SaveEvent(event, inputs);
        FireManualTriggerEventMenu.ShowMenu(event);
    end;
    local selectTrigger = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("FireManualTrigger", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            TriggerFilterType = TriggerTypeEnum.MANUAL_TRIGGER;
            TriggerMenu.ShowTriggers(vert, function(trigger)
                inputs.TriggerID = trigger.ID;
                reloadEvent();
                close();
            end, True);

            UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() close(); end);
        end);
    end

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Linked trigger").SetColor(colors.TextColor);
        UI2.CreateEmpty(line).SetPreferredWidth(5);
        if event.TriggerID ~= nil then
            UI2.CreateButton(line).SetText(Mod.PublicGameData.Triggers[event.TriggerID].Name).SetColor(TriggerTypeEnum.GetTriggerTypeColor(TriggerTypeEnum.MANUAL_TRIGGER)).SetOnClick(selectTrigger);
        else
            UI2.CreateButton(line).SetText("Select").SetColor(colors.OrangeRed).SetOnClick(selectTrigger)
        end
    end, FireManualTriggerEvent.Info.EventSelectManualTrigger);

    local selectTerritory = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("FireManualTrigger", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            InspectMenu.ShowPickTerritory(vert, function(terrDetails)
                inputs.TerritoryID = terrDetails.ID;
                reloadEvent();
                close();
            end)
        end);
    end

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Linked territory").SetColor(colors.TextColor);
        UI2.CreateEmpty(line).SetPreferredWidth(5);
        if event.TerritoryID ~= nil then
            UI2.CreateButton(line).SetText(Game.Map.Territories[event.TerritoryID].Name).SetColor(colors.Green).SetOnClick(selectTerritory);
        else
            UI2.CreateButton(line).SetText("Select").SetColor(colors.OrangeRed).SetOnClick(selectTerritory);
        end
    end, FireManualTriggerEvent.Info.EventSelectTerritory);
end

EventMenu.AddEventMenu(EventTypeEnum.FIRE_MANUAL_TRIGGER, FireManualTriggerEventMenu.ShowMenu);

---Save FireManualTrigger
---@param event FireManualTrigger
---@param inputs table
function FireManualTriggerEventMenu.SaveEvent(event, inputs)
    if UI2.canReadObject(inputs.NotifyNeighbours) then event.NotifyNeighbours = inputs.NotifyNeighbours.GetIsChecked(); end
    event.TriggerID = inputs.TriggerID;
    event.TerritoryID = inputs.TerritoryID;
    EventMenu.SaveEvent(event, inputs);
end