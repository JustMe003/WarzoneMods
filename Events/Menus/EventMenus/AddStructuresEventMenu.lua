require("Enums.EventEnums");

require("Events.AddStructuresEvent");

require("Menus.EventMenus.EventMenu");
require("Menus.EventMenus.ExpressionMenu");

AddStructuresEventMenu = {};

function AddStructuresEventMenu.ShowMenu(event)
    History.AddToHistory(AddStructuresEventMenu.ShowMenu, event);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    EventMenu.ShowEventHeader(event, inputs, root, AddStructuresEventMenu.SaveEvent);

    EventMenu.ShowEvent(event, inputs, root);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add Structures Event Options").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);

    event.Addition = event.Addition or {};
    inputs.Addition = {};

    local reloadEvent = function()
        AddStructuresEventMenu.SaveEvent(event, inputs);
        AddStructuresEventMenu.ShowMenu(event);
    end;
    local pickedEnums = {};
    local pickStructure = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("AddStructuresEvent", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromList(vert, StructuresMenu.GenerateStructuresList(function(enum)
                inputs.Addition[enum] = {};
                reloadEvent();
                close();
            end, pickedEnums), function() close(); end);
        end);
    end

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Structure modifications").SetColor(colors.TextColor);
    end, AddStructuresEvent.Info.EventStructureModification);

    for enum, expr in pairs(event.Addition) do
        table.insert(pickedEnums, enum);
        local inButton = UI2.CreateVert(UI2.CreateButton(root).SetFlexibleWidth(1).SetText("").SetInteractable(false).SetColor(MenuUtil.GetColorFromList(enum))).SetFlexibleWidth(1);
        inputs.Addition[enum] = expr;
        UI2.CreateDeleteButtonLine(inButton, function(line)
            UI2.CreateEmpty(line).SetFlexibleWidth(1);
            UI2.CreateButton(line).SetText(getStructureName(enum)).SetColor(MenuUtil.GetColorFromList(enum)).SetOnClick(pickStructure);
        end, function()
            inputs.Addition[enum] = nil;
            reloadEvent();
        end);
        ExpressionMenu.ShowMenu(inButton, event, event.Addition, inputs.Addition, enum, reloadEvent);
    end

    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add structure").SetColor(colors.Blue).SetOnClick(pickStructure);
end

EventMenu.AddEventMenu(EventTypeEnum.ADD_STRUCTURES_EVENT, AddStructuresEventMenu.ShowMenu);

---Save AddStructuresEvent
---@param event AddStructuresEvent
---@param inputs table
function AddStructuresEventMenu.SaveEvent(event, inputs)
    local triggerType = 0;
    event.Addition = {};
    for enum, input in pairs(inputs.Addition) do
        event.Addition[enum] = ExpressionMenu.SaveExpression(event.Addition[enum], input);
        if triggerType == 0 then
            triggerType = ExpressionMenu.GetTriggerTypeFromExpression(event.Addition[enum]);
        end
    end
    event.CompatibleTriggerType = triggerType;
    EventMenu.SaveEvent(event, inputs);
end