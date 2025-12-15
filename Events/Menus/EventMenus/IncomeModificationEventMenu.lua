require("Enums.EventEnums");

require("Events.IncomeModificationEvent");

require("Menus.EventMenus.EventMenu");
require("Menus.EventMenus.ExpressionMenu");

IncomeModificationEventMenu = {};

function IncomeModificationEventMenu.ShowMenu(event)
    History.AddToHistory(IncomeModificationEventMenu.ShowMenu, event);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    EventMenu.ShowEventHeader(event, inputs, root, IncomeModificationEventMenu.SaveEvent);

    EventMenu.ShowEvent(event, inputs, root);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add Structures Event Options").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("The amount of turns the income modification will be applied").SetColor(colors.TextColor);
    end, IncomeModificationEvent.Info.EventIncomeModDuration);
    inputs.Duration = UI2.CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(event.Duration or 2);

    inputs.Player = event.Player;
    local valueClickFuncs = EventMenu.GetEventValueFunctions();
    local reloadEvent = function()
        IncomeModificationEventMenu.SaveEvent(event, inputs);
        IncomeModificationEventMenu.ShowMenu(event);
    end;
    local playerSelected = function(enum)
        inputs.Player = EventUtil.CreateValueTable(enum);
        reloadEvent();
    end
    local selectPlayer = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("ModifyIncomeEvent", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromList(vert, (function() 
                local list = {};
                for _, enum in ipairs(IncomeModificationEventMenu.GetAvailablePlayerValues()) do
                    table.insert(list, {
                        Name = InjectValueEnum.GetValueTypeName(enum),
                        Action = function() playerSelected(enum); close(); end,
                        Info = InjectValueEnum.getValueTypeInfo(enum),
                        Color = InjectValueEnum.GetValueTypeColor(enum)
                    });
                end
                return list;
             end)(), function() close(); end);
        end);
    end

    UI2.CreateEmpty(root).SetPreferredHeight(3);

    if inputs.Player == nil then
        UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Select player").SetColor(colors.Blue).SetOnClick(selectPlayer);
    else
        UI2.CreateDeleteButtonLine(root, function(line)
            UI2.CreateButton(line).SetText(InjectValueEnum.GetValueTypeName(inputs.Player.Type)).SetColor(InjectValueEnum.GetValueTypeColor(inputs.Player.Type)).SetOnClick(selectPlayer);
            (valueClickFuncs[inputs.Player.Type] or void)(line, inputs.Player);
        end, function()
            inputs.Player = nil;
            reloadEvent();
        end);
    end

    UI2.CreateEmpty(root).SetPreferredHeight(3);
    
    UI2.CreateLabel(root).SetText("Added income").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);
    ExpressionMenu.ShowMenu(root, event, event, inputs, "IncomeMod", reloadEvent);
end

EventMenu.AddEventMenu(EventTypeEnum.INCOME_MODIFICATION_EVENT, IncomeModificationEventMenu.ShowMenu);

function IncomeModificationEventMenu.GetAvailablePlayerValues()
    return {InjectValueEnum.SLOT_PLAYER, InjectValueEnum.MOVE_ORDER_PLAYER, InjectValueEnum.TRIGGER_TERR_OWNER};
end

---Save IncomeModificationEvent
---@param event IncomeModificationEvent
---@param inputs table
function IncomeModificationEventMenu.SaveEvent(event, inputs)
    if not UI2.IsDestroyed(inputs.Duration) then event.Duration = inputs.Duration.GetValue(); end
    event.Player = inputs.Player;
    EventUtil.SaveEventValue(event.Player, inputs.Player);
    event.IncomeMod = ExpressionMenu.SaveExpression(event.IncomeMod, inputs.IncomeMod or {});
    if EventUtil.IsValueTable(event.Player or {}) then
        event.CompatibleTriggerType = InjectValueEnum.InjectValueConstraints[event.Player.Type].TriggerType or 0;
    else
        event.CompatibleTriggerType = 0;
    end
    if event.CompatibleTriggerType == 0 then
        event.CompatibleTriggerType = ExpressionMenu.GetTriggerTypeFromExpression(event.IncomeMod);
    end
    EventMenu.SaveEvent(event, inputs);
end