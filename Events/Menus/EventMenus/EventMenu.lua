require("Enums.EventEnums");
require("Enums.InjectValueEnums");
require("Enums.ServerMessageEnum");

require("Events.EventUtil");

require("Menus.SlotMenu");
require("Menus.StructuresMenu");
require("Menus.ConfirmMenu");

EventMenu = {};
local registeredMenus = {};

function EventMenu.AddEventMenu(type, func)
    registeredMenus[type] = func;
end

function EventMenu.ShowExistingEvents(func, reqFunc)
    History.AddToHistory(EventMenu.ShowExistingEvents, func, reqFunc);
    reqFunc = reqFunc or True;
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    EventMenu.CreateEventFilter(root, func, reqFunc);
    
    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Create Event").SetColor(colors.Green).SetOnClick(EventMenu.ShowChooseEventType);

    if getTableLength(Mod.PublicGameData.Events) > 0 then
        UI2.CreateEmpty(root).SetPreferredHeight(10);
        UI2.CreateLabel(root).SetText("The following events have been created:").SetColor(colors.TextColor);
        EventMenu.ShowEvents(root, func)
    else
        UI2.CreateLabel(root).SetText("There are currently no events").SetColor(colors.TextColor);
    end
end

function EventMenu.CreateEventFilter(root, func, reqFunc)
    EventFilterType = EventFilterType or 0;
    local updateFilterButton = function(but)
        if EventFilterType == 0 then
            but.SetText("All types").SetColor(colors.Green);
        else
            but.SetText(EventTypeEnum.GetEventTypeName(EventFilterType)).SetColor(EventTypeEnum.GetEventTypeColor(EventFilterType));
        end
    end

    local filterButton;
    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(MainMenu.ShowMain);
    filterButton = UI2.CreateButton(line).SetColor(colors.Green).SetOnClick(function()
        EventFilterType = EventFilterType + 1;
        if EventFilterType > getTableLength(registeredMenus) then
            EventFilterType = 0;
        end
        updateFilterButton(filterButton);
        EventMenu.ShowEvents(root, func, reqFunc);
    end)
    updateFilterButton(filterButton);

end

function EventMenu.ShowEvents(root, func, reqFunc, pageN)
    pageN = pageN or 1;
    local NperPage = 8;

    reqFunc = reqFunc or True;
    local win = "ShowEvents";
    UI2.DestroyWindow(win);
    local par = UI2.CreateSubWindow(UI2.CreateVert(root).SetFlexibleWidth(1), win);
    local counter = 0;
    for _, event in pairs(Mod.PublicGameData.Events) do
        if (EventFilterType == 0 or EventFilterType == event.Type) and reqFunc(event) then
            if counter < pageN * NperPage and counter >= (pageN - 1) * NperPage then
                UI2.CreateInfoButtonLine(par, function(line)
                    UI2.CreateButton(line).SetText(event.Name).SetColor(EventTypeEnum.GetEventTypeColor(event.Type)).SetOnClick(function()
                        printTable(event);
                        (func or registeredMenus[event.Type])(event);
                    end)
                end, "TODO");
            end
            counter = counter + 1;
        end
    end

    if counter > NperPage then
        local line = UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
        UI2.CreateButton(line).SetText("Down").SetColor(colors.RoyalBlue).SetOnClick(function()
            EventMenu.ShowEvents(root, func, reqFunc, pageN - 1);
        end).SetInteractable(pageN > 0);
        UI2.CreateEmpty(line).SetMinWidth(5);
        UI2.CreateLabel(line).SetText(pageN .. " / " .. math.ceil(getTableLength(Mod.PublicGameData.Events) / NperPage)).SetColor(colors.TextDefault);
        UI2.CreateButton(line).SetText("Up").SetColor(colors.RoyalBlue).SetOnClick(function()
            EventMenu.ShowEvents(root, func, reqFunc, pageN + 1);
        end).SetInteractable(math.ceil(getTableLength(Mod.PublicGameData.Events) / NperPage) > pageN);
    end
end

function EventMenu.ShowChooseEventType()
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    UI2.CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(MainMenu.ShowMain);
    UI2.CreateLabel(root).SetText("Please select the type of trigger you want to create:").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(5);

    for type, _ in pairs(registeredMenus) do
        UI2.CreateInfoButtonLine(root, function(line)
            UI2.CreateButton(line).SetText(EventTypeEnum.GetEventTypeName(type)).SetColor(EventTypeEnum.GetEventTypeColor(type)).SetOnClick(function()
                local event = Event.Create(Mod.PublicGameData.Events, type);
                registeredMenus[type](event);
            end);
        end, EventTypeEnum.GetEventTypeInfo(type));
    end
end

function EventMenu.ShowEventHeader(event, inputs, root, saveFunc);
    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        saveFunc(event, inputs);
        UI2.CloseAllDialogs();
        RefreshFunction = EventMenu.ShowExistingEvents();
        Game.SendGameCustomMessage("Updating event...", { Type = ServerMessageEnum.UPDATE_EVENT, Event = event }, void);
        Close();
    end);
    UI2.CreateEmpty(line).SetMinWidth(5);
    UI2.CreateButton(line).SetText("Delete").SetColor(colors.Red).SetOnClick(function()
        ConfirmMenu.CreateConfirmPage("Are you sure you want to delete this event? It will be removed from every custom event you have assigned to the map already", function()
            RefreshFunction = EventMenu.ShowExistingEvents();
            Game.SendGameCustomMessage("Deleting event...", { Type = ServerMessageEnum.DELETE_EVENT, Event = event }, void);
            Close();
        end);
    end).SetInteractable(Mod.PublicGameData.Events[event.ID] ~= nil);
    UI2.CreateEmpty(line).SetMinWidth(5);
    UI2.CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(function()
        UI2.CloseAllDialogs();
        EventMenu.ShowExistingEvents();
    end);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
end

function EventMenu.ShowEvent(event, inputs, root);
    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Event type: ").SetColor(colors.TextColor);
        UI2.CreateLabel(line).SetText(EventTypeEnum.GetEventTypeName(event.Type)).SetColor(colors.Yellow);
    end, "This is the type of the event. " .. EventTypeEnum.GetEventTypeInfo(event.Type));

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Name: ").SetColor(colors.TextColor);
        inputs.Name = UI2.CreateTextInputField(line).SetText(event.Name).SetCharacterLimit(50).SetPreferredWidth(290);
    end, Event.Info.EventName);

    -- local nextFun = {
    --     [UTIL.EventTypes.MessageEvent] = showModifyMessageEvent;
    --     [UTIL.EventTypes.SetOwnerEvent] = showModifySetOwnerEvent;
    --     [UTIL.EventTypes.AddArmiesEvent] = showModifyAddArmiesEvent;
    --     [UTIL.EventTypes.AddStructuresEvent] = showModifyAddStructuresEvent;
    --     [UTIL.EventTypes.IncomeModificationEvent] = showModifyIncomeModificationEvent;
    --     [UTIL.EventTypes.FireManualTrigger] = showModifyFireManualTriggerEvent;
    -- }
    -- nextFun[event.Type](root, event, inputs);
end

function EventMenu.GetEventValueFunctions()
    return {
        [InjectValueEnum.SLOT_PLAYER] = SlotMenu.SetSingleSlot,
        [InjectValueEnum.INTEGER_CONSTANT] = EventMenu.SetNumber,
        [InjectValueEnum.NUMBER_CONSTANT] = function(line, input) EventMenu.SetNumber(line, input, true); end,
        [InjectValueEnum.TRIGGER_TERR_STRUCTURE_COUNT] = StructuresMenu.SetStructure
    };
end

function EventMenu.SetNumber(line, input, nonWhole)
    UI2.CreateEmpty(line).SetFlexibleWidth(1);
    input.Input = UI2.CreateNumberInputField(line).SetSliderMinValue(-20).SetSliderMaxValue(20).SetWholeNumbers(not (nonWhole or false)).SetValue(input.Value or 0);
end

---Saves the passed Event with the given inputs
---@param event Event
---@param inputs table
function EventMenu.SaveEvent(event, inputs)
    if inputs.Name ~= nil then event.Name = inputs.Name.GetText(); end
    -- local t = {
    --     [UTIL.EventTypes.MessageEvent] = saveMessageEvent;
    --     [UTIL.EventTypes.SetOwnerEvent] = saveSetOwnerEvent;
    --     [UTIL.EventTypes.AddArmiesEvent] = saveAddArmiesEvent;
    --     [UTIL.EventTypes.AddStructuresEvent] = saveAddStructuresEvent;
    --     [UTIL.EventTypes.IncomeModificationEvent] = saveIncomeModificationEvent;
    --     [UTIL.EventTypes.FireManualTrigger] = saveFireManualTriggerEvent;
    -- }
    -- t[event.Type](event, inputs);
end

function EventMenu.GenerateEventValueList(event, selectFun, close)
    local list = {};
    for _, type in pairs(InjectValueEnum.GetAllInjectValues()) do
        list[#list + 1] = InjectValueEnum.ValueIsCompatible(event, type) and {
            Name = InjectValueEnum.GetValueTypeName(type),
            Action = function()
                EventMenu.AddValueToEvent(event, type);
                selectFun(type);
                close();
            end,
            Info = InjectValueEnum.getValueTypeInfo(type),
            Color = InjectValueEnum.GetValueTypeColor(type)
        } or nil;
    end
    return list;
end

function EventMenu.AddValueToEvent(event, enum)
    if event.CompatibleTriggerType == 0 then
        event.CompatibleTriggerType = InjectValueEnum.InjectValueConstraints[enum].TriggerType or 0;
    end
end