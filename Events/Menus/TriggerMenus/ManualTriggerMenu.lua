require("Enums.TriggerEnums");

require("Triggers.ManualTrigger");

require("Menus.TriggerMenus.TriggerMenu");

ManualTriggerMenu = {};

function ManualTriggerMenu.ShowMenu(trigger)
    History.AddToHistory(ManualTriggerMenu.ShowMenu, trigger);
    UI2.DestroyWindow();

    local inputs = {};
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    TriggerMenu.ShowTriggerHeader(trigger, inputs, root, TriggerMenu.SaveTrigger);

    TriggerMenu.showTrigger(trigger, inputs, root, TriggerMenu.SaveTrigger, ManualTriggerMenu.ShowMenu);

    TriggerMenu.ShowAddConditionsButton(trigger, inputs, root, TriggerMenu.GenerateConditionList, ManualTriggerMenu.ShowMenu);
end

TriggerMenu.AddTriggerMenu(TriggerTypeEnum.ON_TURN_END, ManualTriggerMenu.ShowMenu);