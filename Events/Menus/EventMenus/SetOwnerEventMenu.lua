require("Enums.EventEnums");

require("Events.SetOwnerEvent");

require("Menus.EventMenus.EventMenu");

SetOwnerEventMenu = {};

function SetOwnerEventMenu.ShowMenu(event)
    History.AddToHistory(SetOwnerEventMenu.ShowMenu);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    EventMenu.ShowEventHeader(event, inputs, root, SetOwnerEventMenu.SaveEvent);

    EventMenu.ShowEvent(event, inputs, root);
    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Message Event Options").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);

    local reloadEvent = function()
        SetOwnerEventMenu.SaveEvent(event, inputs);
        SetOwnerEventMenu.ShowMenu(event);
    end;

    inputs.NewPlayer = event.NewPlayer;
    local valueClickFuncs = EventMenu.GetEventValueFunctions();
    local createOptionsList = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("SetOwnerEvent", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromList(vert, EventMenu.GenerateEventValueList(event, function(enum)
                inputs.NewPlayer = EventUtil.CreateValueTable(enum);
                reloadEvent();
            end, close), function() close(); end);
        end);
    end

    if inputs.NewPlayer == nil then
        UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Select player").SetColor(colors.Blue).SetOnClick(createOptionsList);
    else
        UI2.CreateDeleteButtonLine(root, function(line)
            UI2.CreateButton(line).SetText(InjectValueEnum.GetValueTypeName(inputs.NewPlayer.Type)).SetColor(InjectValueEnum.GetValueTypeColor(inputs.NewPlayer.Type)).SetOnClick(createOptionsList);   
            (valueClickFuncs[inputs.NewPlayer.Type] or void)(line, inputs.NewPlayer);
        end, function()
            inputs.NewPlayer = nil;
            reloadEvent();
        end);
    end
end

EventMenu.AddEventMenu(EventTypeEnum.SET_OWNER_EVENT, SetOwnerEventMenu.ShowMenu);


---Save SetOwnerEvent
---@param event SetOwnerEvent
---@param inputs table
function SetOwnerEventMenu.SaveEvent(event, inputs)
    event.NewPlayer = inputs.NewPlayer;
    EventUtil.SaveEventValue(event.NewPlayer, inputs.NewPlayer);
    if event.NewPlayer then
        ---@diagnostic disable-next-line: undefined-field
        event.CompatibleTriggerType = InjectValueEnum.InjectValueConstraints[event.NewPlayer.Type].TriggerType or 0;
    else
        event.CompatibleTriggerType = 0;
    end
    EventMenu.SaveEvent(event, inputs);
end