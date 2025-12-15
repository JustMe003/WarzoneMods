require("Enums.TriggerEnums");

require("Triggers.OnTurnEnd");

require("Menus.TriggerMenus.TriggerMenu");

OnTurnEndMenu = {}

function OnTurnEndMenu.ShowMenu(trigger)
    History.AddToHistory(OnTurnEndMenu.ShowMenu, trigger);
    UI2.DestroyWindow();

    local inputs = {};
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    TriggerMenu.ShowTriggerHeader(trigger, inputs, root, TriggerMenu.SaveTrigger);

    TriggerMenu.showTrigger(trigger, inputs, root, TriggerMenu.SaveTrigger, OnTurnEndMenu.ShowMenu);

    TriggerMenu.ShowAddConditionsButton(trigger, inputs, root, TriggerMenu.GenerateConditionList, OnTurnEndMenu.ShowMenu);
end

TriggerMenu.AddTriggerMenu(TriggerTypeEnum.MANUAL_TRIGGER, OnTurnEndMenu.ShowMenu);