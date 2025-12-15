require("Enums.ServerMessageEnum");

require("Triggers.Trigger");

require("Menus.MenuUtil");
require("Menus.SlotMenu");
require("Menus.StructuresMenu");
require("Menus.ConfirmMenu");

TriggerMenu = {};
local registeredMenus = {};

function TriggerMenu.AddTriggerMenu(index, func)
    registeredMenus[index] = func;
end

function TriggerMenu.ShowTriggerMenu(func, reqFunc)
    reqFunc = reqFunc or True;
    History.AddToHistory(TriggerMenu.ShowTriggerMenu, func, reqFunc);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    TriggerMenu.CreateTriggerFilter(root, func, reqFunc);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateButton(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Create Trigger").SetColor(colors.Green).SetOnClick(TriggerMenu.ShowChooseTriggerType);

    if getTableLength(Mod.PublicGameData.Triggers) > 0 then
        UI2.CreateEmpty(root).SetPreferredHeight(10);
        UI2.CreateLabel(root).SetText("The following triggers have been created:").SetColor(colors.TextColor);
        TriggerMenu.ShowTriggers(root, func, reqFunc);
    else
        UI2.CreateLabel(root).SetText("There are currently no triggers").SetColor(colors.TextColor);
    end
end

function TriggerMenu.CreateTriggerFilter(root, func, reqFunc)
    TriggerFilterType = TriggerFilterType or 0;
    local updateFilterButton = function(but)
        if TriggerFilterType == 0 then
            but.SetText("All types").SetColor(colors.Green);
        else
            but.SetText(TriggerTypeEnum.GetTriggerTypeName(TriggerFilterType)).SetColor(TriggerTypeEnum.GetTriggerTypeColor(TriggerFilterType));
        end
    end

    local line = HomeButtons.Create(root);
    local filterButton;
    filterButton = UI2.CreateButton(line).SetColor(colors.Green).SetOnClick(function()
        TriggerFilterType = TriggerFilterType + 1;
        if TriggerFilterType > getTableLength(registeredMenus) then
            TriggerFilterType = 0;
        end
        updateFilterButton(filterButton);
        TriggerMenu.ShowTriggers(root, func, reqFunc);
    end)
    updateFilterButton(filterButton);
end

function TriggerMenu.ShowChooseTriggerType()
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    UI2.CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(MainMenu.ShowMain);
    UI2.CreateLabel(root).SetText("Please select the type of trigger you want to create:").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(5);

    for type, _ in pairs(registeredMenus) do
        UI2.CreateInfoButtonLine(root, function(line)
            UI2.CreateButton(line).SetText(TriggerTypeEnum.GetTriggerTypeName(type)).SetColor(TriggerTypeEnum.GetTriggerTypeColor(type)).SetOnClick(function()
                local trigger = Trigger.Create(Mod.PublicGameData.Triggers, type);
                registeredMenus[type](trigger);
            end);
        end, TriggerTypeEnum.GetTriggerTypeInfo(type))
    end
end

function TriggerMenu.ShowTriggers(root, func, reqFunc, pageN)
    pageN = pageN or 1
    local NperPage = 8;

    local win = "ShowTriggers";
    UI2.DestroyWindow(win);
    local par = UI2.CreateSubWindow(UI2.CreateVert(root).SetFlexibleWidth(1), win);
    local counter = 0;
    for _, trigger in pairs(Mod.PublicGameData.Triggers) do
        if (TriggerFilterType == 0 or trigger.Type == TriggerFilterType) and reqFunc(trigger) then
            if counter < pageN * NperPage and counter >= (pageN - 1) * NperPage then
                UI2.CreateInfoButtonLine(par, function(line)
                    UI2.CreateButton(line).SetText(trigger.Name).SetColor(TriggerTypeEnum.GetTriggerTypeColor(trigger.Type)).SetOnClick(function()
                        printTable(trigger);
                        (func or registeredMenus[trigger.Type])(trigger);
                    end);
                end, "TODO");
            end
            counter = counter + 1;
        end
    end

    if counter > NperPage then
        local line = UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
        UI2.CreateButton(line).SetText("Down").SetColor(colors.RoyalBlue).SetOnClick(function()
            TriggerMenu.ShowTriggers(root, func, reqFunc, pageN - 1);
        end).SetInteractable(pageN > 0);
        UI2.CreateEmpty(line).SetMinWidth(5);
        UI2.CreateLabel(line).SetText(pageN .. " / " .. math.ceil(getTableLength(Mod.PublicGameData.Triggers) / NperPage)).SetColor(colors.TextDefault);
        UI2.CreateButton(line).SetText("Up").SetColor(colors.RoyalBlue).SetOnClick(function()
            TriggerMenu.ShowTriggers(root, func, reqFunc, pageN + 1);
        end).SetInteractable(math.ceil(getTableLength(Mod.PublicGameData.Triggers) / NperPage) > pageN);
    end
end

function TriggerMenu.ShowTriggerHeader(trigger, inputs, root, saveTriggerFunc, modifyFunc)
    local header = UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
    UI2.CreateButton(header).SetText("Return").SetColor(colors.Orange).SetOnClick(function()
        UI2.CloseAllDialogs();
        MainMenu.ShowMain();
    end);
    UI2.CreateButton(header).SetText("Delete").SetColor(colors.Red).SetOnClick(function()
        ConfirmMenu.CreateConfirmPage("Are you sure you want to delete this trigger? If you delete this button, every custom event where this trigger is involved in will also be removed", function()
            RefreshFunction = TriggerMenu.ShowTriggerMenu();
            UI2.CloseAllDialogs();
            Game.SendGameCustomMessage("Deleting trigger...", { Type = ServerMessageEnum.DELETE_TRIGGER, Trigger = trigger}, void);
            Close();
        end);
    end).SetInteractable(Mod.PublicGameData.Triggers[trigger.ID] ~= nil);
    UI2.CreateButton(header).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        saveTriggerFunc(trigger, inputs);
        Game.SendGameCustomMessage("Updating data...", {Type = ServerMessageEnum.UPDATE_TRIGGER, Trigger = trigger}, void);
        RefreshFunction = TriggerMenu.ShowTriggerMenu;
    end)
    UI2.CreateLabel(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Modify trigger").SetColor(colors.TextColor);
end

function TriggerMenu.showTrigger(trigger, inputs, root, saveTriggerFunc, modifyFunc)
    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Trigger type: ").SetColor(colors.TextColor);
        UI2.CreateLabel(line).SetText(TriggerTypeEnum.GetTriggerTypeName(trigger.Type)).SetColor(colors.Yellow);
    end, "This is the type of trigger. " .. TriggerTypeEnum.GetTriggerTypeInfo(trigger.Type));
    
    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Name: ").SetColor(colors.TextColor);
        inputs.Name = UI2.CreateTextInputField(line).SetText(trigger.Name).SetPreferredWidth(290).SetCharacterLimit(50);
    end, Trigger.Info.TriggerName);

    UI2.CreateInfoButtonLine(root, function(line)
        inputs.IsGlobalTrigger = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.IsGlobalTrigger or false);
        UI2.CreateLabel(line).SetText("Is global trigger").SetColor(colors.TextColor);
    end, Trigger.Info.TriggerIsGlobal);
    
    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Slots: ").SetColor(colors.TextColor);
        UI2.CreateButton(line).SetText(#(trigger.Slots or {}) .. " slots").SetColor(colors.Green).SetOnClick(function()
            TriggerMenu.SaveTrigger(trigger, inputs);
            SlotMenu.ShowMenu(trigger, "Slots", function() modifyFunc(trigger); end);
        end);
    end, Trigger.Info.TriggerSlots);
    
    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Structures: ").SetColor(colors.TextColor);
        UI2.CreateButton(line).SetText(getTableLength(trigger.Structures or {}) .. " conditions").SetColor(colors.Yellow).SetOnClick(function()
            TriggerMenu.SaveTrigger(trigger, inputs);
            StructuresMenu.ShowMenu(trigger, inputs, "Structures", function() modifyFunc(trigger); end, {Maximum = Trigger.Info.MaximumStructuresOnTerritoryString, Minimum = Trigger.Info.MinimumStructuresOnTerritoryString});
        end);
    end, Trigger.Info.TriggerStructures);

    UI2.CreateInfoButtonLine(root, function(line)
        inputs.BlacklistSlots = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.BlacklistSlots or false);
        UI2.CreateLabel(line).SetText("Only non-included slots can fire this trigger").SetColor(colors.TextColor);
    end, Trigger.Info.TriggerBlacklistSlots);

    UI2.CreateInfoButtonLine(root, function(line)
        inputs.NeutralCanFireThis = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.NeutralCanFireThis or false);
        UI2.CreateLabel(line).SetText("Fire trigger if territory is neutral").SetColor(colors.TextColor);
    end, Trigger.Info.TriggerFireIfNeutral);
    
    UI2.CreateEmpty(root).SetPreferredHeight(10);
    
    TriggerMenu.ShowModifyCooldownCondition(root, trigger, inputs, saveTriggerFunc, modifyFunc);
    
    TriggerMenu.ShowModifyChanceCondition(root, trigger, inputs, saveTriggerFunc, modifyFunc);
    
    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "NumArmies", "number of armies", Trigger.Info.MinimumNumberOfArmiesCondition, saveTriggerFunc, modifyFunc);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "NumArmies", "number of armies", Trigger.Info.MaximumNumberOfArmiesCondition, saveTriggerFunc, modifyFunc);
    
    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "NumSpecialUnits", "number of special units", Trigger.Info.MinimumNumberOfSpecialUnitsCondition, saveTriggerFunc, modifyFunc, 0, 5);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "NumSpecialUnits", "number of special units", Trigger.Info.MaximumNumberOfSpecialUnitsCondition, saveTriggerFunc, modifyFunc, 0, 5);
    
    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "DefensePower", "total defense power", Trigger.Info.MinimumDefensePowerCondition, saveTriggerFunc, modifyFunc);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "DefensePower", "total defense power", Trigger.Info.MaximumDefensePowerCondition, saveTriggerFunc, modifyFunc);
    
    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "AttackPower", "total attack power", Trigger.Info.MinimumAttackPowerCondition, saveTriggerFunc, modifyFunc);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "AttackPower", "total attack power", Trigger.Info.MaximumAttackPowerCondition, saveTriggerFunc, modifyFunc);
end

function TriggerMenu.ShowAddConditionsButton(trigger, inputs, root, generateListFunc, showModifyTriggerFunc)
    UI2.CreateButton(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Add condition").SetColor(colors.Blue).SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("AddConditionDialog", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromSubList(vert, generateListFunc(trigger, inputs, showModifyTriggerFunc, close), function() close(); end, "Generic");
        end)
    end);
end

---Saves the trigger
---@param trigger Trigger
---@param inputs table
function TriggerMenu.SaveTrigger(trigger, inputs)
    if not UI2.IsDestroyed(inputs.Name) then trigger.Name = inputs.Name.GetText(); end
    if not UI2.IsDestroyed(inputs.IsGlobalTrigger) then trigger.IsGlobalTrigger = inputs.IsGlobalTrigger.GetIsChecked(); end
    if not UI2.IsDestroyed(inputs.BlacklistSlots) then trigger.BlacklistSlots = inputs.BlacklistSlots.GetIsChecked(); end
    if not UI2.IsDestroyed(inputs.NeutralCanFireThis) then trigger.NeutralCanFireThis = inputs.NeutralCanFireThis.GetIsChecked(); end
    if not UI2.IsDestroyed(inputs.Cooldown) then trigger.Cooldown = inputs.Cooldown.GetValue(); end
    if not UI2.IsDestroyed(inputs.Chance) then trigger.Chance = inputs.Chance.GetValue(); end
    if inputs.NumArmies ~= nil then
        trigger.NumArmies = trigger.NumArmies or {};
        if not UI2.IsDestroyed(inputs.NumArmies.Minimum) then trigger.NumArmies.Minimum = inputs.NumArmies.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.NumArmies.Maximum) then trigger.NumArmies.Maximum = inputs.NumArmies.Maximum.GetValue(); end
    end
    if inputs.NumSpecialUnits ~= nil then
        trigger.NumSpecialUnits = trigger.NumSpecialUnits or {};
        if not UI2.IsDestroyed(inputs.NumSpecialUnits.Minimum) then trigger.NumSpecialUnits.Minimum = inputs.NumSpecialUnits.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.NumSpecialUnits.Maximum) then trigger.NumSpecialUnits.Maximum = inputs.NumSpecialUnits.Maximum.GetValue(); end
    end
    if inputs.DefensePower ~= nil then
        trigger.DefensePower = trigger.DefensePower or {};
        if not UI2.IsDestroyed(inputs.DefensePower.Minimum) then trigger.DefensePower.Minimum = inputs.DefensePower.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.DefensePower.Maximum) then trigger.DefensePower.Maximum = inputs.DefensePower.Maximum.GetValue(); end
    end
    if inputs.AttackPower ~= nil then
        trigger.AttackPower = trigger.AttackPower or {};
        if not UI2.IsDestroyed(inputs.AttackPower.Minimum) then trigger.AttackPower.Minimum = inputs.AttackPower.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.AttackPower.Maximum) then trigger.AttackPower.Maximum = inputs.AttackPower.Maximum.GetValue(); end
    end

    removeEmptyTables(trigger);
end

function TriggerMenu.ShowModifyCooldownCondition(root, trigger, inputs, saveFunc, modifyFunc)
    if trigger.Cooldown then
        UI2.CreateDeleteButtonLine(root, function(line)
            UI2.CreateLabel(line).SetText("The cooldown until this trigger can be triggered again").SetColor(colors.TextColor);
            inputs.Cooldown = UI2.CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(trigger.Cooldown);
        end, function()
            saveFunc(trigger, inputs);
            trigger.Cooldown = nil;
            modifyFunc(trigger);
        end);
    end
end

function TriggerMenu.ShowModifyChanceCondition(root, trigger, inputs, saveFunc, modifyFunc)
    if trigger.Chance then
        UI2.CreateDeleteButtonLine(root, function(line)
            UI2.CreateLabel(line).SetText("The chance of the trigger firing").SetColor(colors.TextColor);
            inputs.Chance = UI2.CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(trigger.Chance or 100).SetWholeNumbers(false);
        end, function()
            saveFunc(trigger, inputs);
            trigger.Chance = nil;
            modifyFunc(trigger);
        end);
    end
end

function TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, field, text, info, saveFunc, modifyFunc, min, max)
    if trigger[field] then
        inputs[field] = inputs[field] or {};
        if trigger[field].Minimum then
            UI2.CreateInfoButtonLine(root, function(line)
                UI2.CreateLabel(line).SetText("Minimum " .. text).SetColor(colors.TextColor);
            end, info);
            UI2.CreateDeleteButtonLine(root, function(line)
                inputs[field].Minimum = UI2.CreateNumberInputField(line).SetSliderMinValue(min or 0).SetSliderMaxValue(max or 50).SetValue(trigger[field].Minimum);
            end, function()
                saveFunc(trigger, inputs);
                trigger[field].Minimum = nil;
                if trigger[field].Maximum == nil then
                    trigger[field] = nil;
                end
                modifyFunc(trigger);
            end);
        end
    end
end

function TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, field, text, info, saveFunc, modifyFunc, min, max)
    if trigger[field] then
        inputs[field] = inputs[field] or {};
        if trigger[field].Maximum then
            UI2.CreateInfoButtonLine(root, function(line)
                UI2.CreateLabel(line).SetText("Maximum " .. text).SetColor(colors.TextColor);
            end, info);
            UI2.CreateDeleteButtonLine(root, function(line)
                inputs[field].Maximum = UI2.CreateNumberInputField(line).SetSliderMinValue(min or 0).SetSliderMaxValue(max or 50).SetValue(trigger[field].Maximum);
            end, function()
                saveFunc(trigger, inputs);
                trigger[field].Maximum = nil;
                if trigger[field].Minimum == nil then
                    trigger[field] = nil;
                end
                modifyFunc(trigger);
            end);
        end
    end
end

---Generates the condition list based on the trigger type
---@param trigger Trigger
---@param inputs table
---@param selectFun fun(t: Trigger)
---@param close fun()
---@return ListItem
function TriggerMenu.GenerateConditionList(trigger, inputs, selectFun, close)
    return {
        Generic = {
                trigger.Cooldown == nil and {
                    Name = "Cooldown";
                Action = function() 
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.Cooldown = 3;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.CooldownCondition;
            } or nil;
            
            trigger.Chance == nil and {
                Name = "Chance";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.Chance = 100;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.ChanceCondition;
            } or nil;
        },
        ["Event armies"] = {
            (trigger.NumArmies == nil or trigger.NumArmies.Minimum == nil) and {
                Name = "Min number of armies";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumArmies = trigger.NumArmies or {};
                    trigger.NumArmies.Minimum = 5;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MinimumNumberOfArmiesCondition;
            } or nil;
            (trigger.NumArmies == nil or trigger.NumArmies.Maximum == nil) and {
                Name = "Max number of armies";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumArmies = trigger.NumArmies or {};
                    trigger.NumArmies.Maximum = 20;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MaximumNumberOfArmiesCondition;
            } or nil;
            (trigger.NumSpecialUnits == nil or trigger.NumSpecialUnits.Minimum == nil) and {
                Name = "Min number of special units";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumSpecialUnits = trigger.NumSpecialUnits or {};
                    trigger.NumSpecialUnits.Minimum = 1;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MinimumNumberOfSpecialUnitsCondition;
            } or nil;
            (trigger.NumSpecialUnits == nil or trigger.NumSpecialUnits.Maximum == nil) and {
                Name = "Max number of special units";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumSpecialUnits = trigger.NumSpecialUnits or {};
                    trigger.NumSpecialUnits.Maximum = 3;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MinimumNumberOfSpecialUnitsCondition;
            } or nil;
            (trigger.DefensePower == nil or trigger.DefensePower.Minimum == nil) and {
                Name = "Min defense power";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.DefensePower = trigger.DefensePower or {};
                    trigger.DefensePower.Minimum = 5;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MinimumDefensePowerCondition;
            } or nil;
            (trigger.DefensePower == nil or trigger.DefensePower.Maximum == nil) and {
                Name = "Max defense power";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.DefensePower = trigger.DefensePower or {};
                    trigger.DefensePower.Maximum = 20;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MaximumDefensePowerCondition;
            } or nil;
            (trigger.AttackPower == nil or trigger.AttackPower.Minimum == nil) and {
                Name = "Min attack power";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.AttackPower = trigger.AttackPower or {};
                    trigger.AttackPower.Minimum = 5;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MinimumAttackPowerCondition;
            } or nil;
            (trigger.AttackPower == nil or trigger.AttackPower.Maximum == nil) and {
                Name = "Max attack power";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.AttackPower = trigger.AttackPower or {};
                    trigger.AttackPower.Maximum = 20;
                    selectFun(trigger);
                    close();
                end;
                Info = Trigger.Info.MaximumAttackPowerCondition;
            } or nil;
        }
    };
end