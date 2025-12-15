require("Enums.EventEnums");

require("Events.AddArmiesEvent");

require("Menus.EventMenus.EventMenu");
require("Menus.EventMenus.ExpressionMenu");

AddArmiesEventMenu = {}

function AddArmiesEventMenu.ShowMenu(event)
    History.AddToHistory(AddArmiesEventMenu.ShowMenu, event);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    EventMenu.ShowEventHeader(event, inputs, root, AddArmiesEventMenu.SaveEvent);

    EventMenu.ShowEvent(event, inputs, root);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add Armies Event Options").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Number of armies").SetColor(colors.TextColor);
    end, AddArmiesEvent.Info.EventAddArmies);

    event.Expression = event.Expression or {};
    
    ExpressionMenu.ShowMenu(root, event, event, inputs, "Expression", function() AddArmiesEventMenu.SaveEvent(event, inputs); AddArmiesEventMenu.ShowMenu(event); end);
end

EventMenu.AddEventMenu(EventTypeEnum.ADD_ARMIES_EVENT, AddArmiesEventMenu.ShowMenu);

---Save AddArmiesEvent
---@param event AddArmiesEvent
---@param inputs table
function AddArmiesEventMenu.SaveEvent(event, inputs)
    event.Expression = ExpressionMenu.SaveExpression(event.Expression, inputs.Expression or {});
    event.CompatibleTriggerType = ExpressionMenu.GetTriggerTypeFromExpression(event.Expression);
    EventMenu.SaveEvent(event, inputs);
end