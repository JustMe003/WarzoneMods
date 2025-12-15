require("Enums.ServerMessageEnum");

require("Menus.TriggerMenus.TriggerMenu");
require("Menus.EventMenus.EventMenu");

AssignMenu = {
    AssignmentInfo = "Select events that happen after the trigger has fired. A trigger is combined with one or multiple events to create and assigned to one or multiple territories. Then, during the game, when the trigger fires, it will play all events.";
}

function AssignMenu.SelectTrigger()
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    local select = function(trigger)
        AssignMenu.SelectEvents(trigger);
    end

    local reqFunc = function(trigger)
        if trigger.IsGlobalTrigger and Mod.PublicGameData.GlobalTriggers[trigger.ID] ~= nil then
            return false;
        end
        return true;
    end

    TriggerMenu.CreateTriggerFilter(root, select, reqFunc);
    
    -- First select trigger
    TriggerFilterType = 0;

    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Select trigger").SetColor(colors.TextColor);
    TriggerMenu.ShowTriggers(root, select, reqFunc);
end


function AssignMenu.SelectEvents(trigger, events)
    events = events or {};   
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    local reqFunc = function(event)
        return (event.CompatibleTriggerType == 0 or trigger.Type == event.CompatibleTriggerType) and not valueInTable(events, event.ID);
    end
    local vert;
    local submitButton;
    local eventButton;
    local eventSelected;
    eventSelected = function(event)
        table.insert(events, event.ID);
        EventMenu.ShowEvents(vert, eventSelected, reqFunc);
        eventButton.SetText(#events .. " events");
        submitButton.SetInteractable(#events > 0);
    end

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateButton(line).SetText(trigger.Name).SetColor(TriggerTypeEnum.GetTriggerTypeColor(trigger.Type));
        UI2.CreateEmpty(line).SetFlexibleWidth(1);
        UI2.CreateLabel(line).SetText("-->").SetColor(colors.TextColor);
        UI2.CreateEmpty(line).SetFlexibleWidth(1);
        eventButton = UI2.CreateButton(line).SetText(#events .. " events").SetColor(colors.Green).SetOnClick(function()
            Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
                UI2.NewDialog("AssignedEventsOrder", rootParent, close);
                setMaxSize(400, 500);
                local vert2;
                local reload;
                reload = function()
                    if not UI2.IsDestroyed(vert2) then UI2.Destroy(vert2); end
                    vert2 = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
                    for i, eventID in pairs(events) do
                        local event = Mod.PublicGameData.Events[eventID];
                        UI2.CreateDeleteButtonLine(vert2, function(line2)
                            UpDownButtons.CreateButtons(line2, events, i, function()
                                reload();
                            end);
                            UI2.CreateButton(line2).SetText(event.Name).SetColor(EventTypeEnum.GetEventTypeColor(event.Type)).SetOnClick(function()
                                print(event);
                            end)
                        end, function()
                            table.remove(events, i);
                            reload();
                            EventMenu.ShowEvents(vert, eventSelected, reqFunc);
                        end);
                    end
                end

                reload();
            end);
        end);
    end, AssignMenu.AssignmentInfo);

    EventFilterType = 0;

    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Select events").SetColor(colors.TextColor);
    
    vert = UI2.CreateVert(root).SetFlexibleWidth(1);
    EventMenu.ShowEvents(vert, eventSelected, reqFunc);

    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    submitButton = UI2.CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        UI2.CloseAllDialogs();
        if trigger.IsGlobalTrigger then
            AssignMenu.AssignCustomEvents(trigger, events);
        else
            AssignMenu.SelectTerritory(trigger, events);
        end
    end).SetInteractable(#events > 0);
    UI2.CreateButton(line).SetText("Go back").SetColor(colors.Red).SetOnClick(function()
        UI2.CloseAllDialogs();
        AssignMenu.SelectTrigger();
    end);
end

function AssignMenu.SelectTerritory(trigger, events)
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateButton(line).SetText(trigger.Name).SetColor(TriggerTypeEnum.GetTriggerTypeColor(trigger.Type));
        UI2.CreateEmpty(line).SetFlexibleWidth(1);
        UI2.CreateLabel(line).SetText("-->").SetColor(colors.TextColor);
        UI2.CreateEmpty(line).SetFlexibleWidth(1);
        UI2.CreateButton(line).SetText(#events .. " events").SetColor(colors.Green);
    end, AssignMenu.AssignmentInfo);

    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Select territory to assign events").SetColor(colors.TextColor);

    InspectMenu.ShowPickTerritory(root, function(terrDetails)
        AssignMenu.AssignCustomEvents(trigger, events, terrDetails.ID);
    end)
end

function AssignMenu.AssignCustomEvents(trigger, events, terrID)
    local type;
    if trigger.IsGlobalTrigger then
        type = ServerMessageEnum.ADD_TO_GLOBAL_TRIGGERS;
    else
        type = ServerMessageEnum.ADD_TO_TERRITORY_MAP;
    end
    Game.SendGameCustomMessage("Updating...", { Type = type, Trigger = trigger, Events = events, TerrID = terrID}, void);
    RefreshFunction = MainMenu.ShowMain;
end

function AssignMenu.AssignCustomGlobalEvent(trigger, events)
    Game.SendGameCustomMessage("Updating...", { Type = ServerMessageEnum.ADD_TO_GLOBAL_TRIGGERS, Trigger = trigger, Events = events}, void);
    RefreshFunction = MainMenu.ShowMain;
end