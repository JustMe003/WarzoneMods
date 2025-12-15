require("Enums.TriggerEnums");

require("Triggers.OnStructureChange");

require("Menus.TriggerMenus.TriggerMenu");

OnStructureChangeMenu = {}

function OnStructureChangeMenu.ShowMenu(trigger)
    History.AddToHistory(OnStructureChangeMenu.ShowMenu, trigger);
    UI2.DestroyWindow();

    local inputs = {};
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    TriggerMenu.ShowTriggerHeader(trigger, inputs, root, TriggerMenu.SaveTrigger);

    TriggerMenu.showTrigger(trigger, inputs, root, TriggerMenu.SaveTrigger, OnStructureChangeMenu.ShowMenu);
    
    UI2.CreateLabel(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Structure change specific conditions").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(10);

    local line = UI2.CreateHorz(root).SetFlexibleWidth(1);
    UI2.CreateLabel(line).SetText("Structure changes: ").SetColor(colors.TextColor);
    UI2.CreateButton(line).SetText(StructuresMenu.CountStructureConditions(trigger.StructureChanges or {}) .. " structures").SetColor(colors.Green).SetOnClick(function()
        TriggerMenu.SaveTrigger(trigger, inputs);
        StructuresMenu.ShowMenu(trigger, inputs, "StructureChanges", function() OnStructureChangeMenu.ShowMenu(trigger); end, {Maximum = OnStructureChange.Info.MaximumStructuresChangeString, Minimum = OnStructureChange.Info.MinimumStructuresChangeString});
    end);

    TriggerMenu.ShowAddConditionsButton(trigger, inputs, root, TriggerMenu.GenerateConditionList, OnStructureChangeMenu.ShowMenu);
end

TriggerMenu.AddTriggerMenu(TriggerTypeEnum.ON_STRUCTURE_CHANGE, OnStructureChangeMenu.ShowMenu);