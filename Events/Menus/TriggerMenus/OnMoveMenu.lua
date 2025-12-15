require("Enums.TriggerEnums");

require("Triggers.OnMove");

require("Menus.TriggerMenus.TriggerMenu");

OnMoveMenu = {};

function OnMoveMenu.ShowMenu(trigger)
    History.AddToHistory(OnMoveMenu.ShowMenu, trigger);
    UI2.DestroyWindow();

    local inputs = {};
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    TriggerMenu.ShowTriggerHeader(trigger, inputs, root, OnMoveMenu.SaveTrigger);

    TriggerMenu.showTrigger(trigger, inputs, root, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu);

    UI2.CreateLabel(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Attack/transfer specific conditions").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(10);
    
    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Attacking slots: ").SetColor(colors.TextColor);
        UI2.CreateButton(line).SetText(#(trigger.AttackerSlots or {}) .. " slots").SetColor(colors.Green).SetOnClick(function()
            OnMoveMenu.SaveTrigger(trigger, inputs);
            SlotMenu.ShowMenu(trigger, "AttackerSlots", function() OnMoveMenu.ShowMenu(trigger); end);
        end);
    end, OnMove.Info.TriggerAttackerSlots);
    
    UI2.CreateInfoButtonLine(root, function(line)
        inputs.BlacklistAttackerSlots = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.BlacklistAttackerSlots or false);
        UI2.CreateLabel(line).SetText("Only non-included attacking slots can fire this trigger").SetColor(colors.TextColor);
    end, OnMove.Info.TriggerBlacklistAttackerSlots);
    
    UI2.CreateInfoButtonLine(root, function(line)
        inputs.MustBeSuccessful = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustBeSuccessful or false).SetOnValueChanged(function()
            if inputs.MustNotBeSuccessful.GetIsChecked() and inputs.MustBeSuccessful.GetIsChecked() then
                inputs.MustNotBeSuccessful.SetIsChecked(false);
            end
        end);
        UI2.CreateLabel(line).SetText("Attack must be successful").SetColor(colors.TextColor);
    end, OnMove.Info.TriggerMustBeSuccessful);
    
    UI2.CreateInfoButtonLine(root, function(line)
        inputs.MustNotBeSuccessful = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustNotBeSuccessful or false).SetOnValueChanged(function()
            if inputs.MustBeSuccessful.GetIsChecked() and inputs.MustNotBeSuccessful.GetIsChecked() then
                inputs.MustBeSuccessful.SetIsChecked(false);
            end
        end);
        UI2.CreateLabel(line).SetText("Attack must be not successful").SetColor(colors.TextColor);
    end, OnMove.Info.TriggerMustNotBeSuccessful);

    UI2.CreateInfoButtonLine(root, function(line)
        inputs.MustBeAttack = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustBeAttack or false).SetOnValueChanged(function()
            if inputs.MustBeTransfer.GetIsChecked() and inputs.MustBeAttack.GetIsChecked() then
                inputs.MustBeTransfer.SetIsChecked(false);
            end
        end);
        UI2.CreateLabel(line).SetText("Must be an attack").SetColor(colors.TextColor);
    end, OnMove.Info.TriggerMustBeAttack);
    
    UI2.CreateInfoButtonLine(root, function(line)
        inputs.MustBeTransfer = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustBeTransfer or false).SetOnValueChanged(function()
            if inputs.MustBeAttack.GetIsChecked() and inputs.MustBeTransfer.GetIsChecked() then
                inputs.MustBeAttack.SetIsChecked(false);
            end
        end);
        UI2.CreateLabel(line).SetText("Must be a transfer").SetColor(colors.TextColor);
    end, OnMove.Info.TriggerMustBeTransfer);

    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "NumAttackerArmies", "number of attacking armies", OnMove.Info.MinimumNumberOfAttackingArmiesCondition, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "NumAttackerArmies", "number of attacking armies", OnMove.Info.MaximumNumberOfAttackingArmiesCondition, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu);
    
    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "NumAttackerSpecialUnits", "number of attacking special units", OnMove.Info.MinimumNumberOfAttackingSpecialUnitsCondition, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu, 1, 5);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "NumAttackerSpecialUnits", "number of attacking special units", OnMove.Info.MaximumNumberOfAttackingSpecialUnitsCondition, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu, 1, 5);

    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "AttackersAttackPower", "number attackers attack power", OnMove.Info.MinimumAttackersAttackPowerCondition, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "AttackersAttackPower", "number attackers attack power", OnMove.Info.MaximumAttackersAttackPowerCondition, OnMoveMenu.SaveTrigger, OnMoveMenu.ShowMenu);

    TriggerMenu.ShowAddConditionsButton(trigger, inputs, root, OnMoveMenu.GenerateConditionList, OnMoveMenu.ShowMenu);
end

TriggerMenu.AddTriggerMenu(TriggerTypeEnum.ON_MOVE, OnMoveMenu.ShowMenu)

---Saves a OnMove trigger
---@param trigger OnMove
---@param inputs table
function OnMoveMenu.SaveTrigger(trigger, inputs)
    if not UI2.IsDestroyed(inputs.BlacklistAttackerSlots) then trigger.BlacklistAttackerSlots = inputs.BlacklistAttackerSlots.GetIsChecked(); end
    if inputs.NumAttackerArmies ~= nil then
        trigger.NumAttackerArmies = trigger.NumAttackerArmies or {};
        if not UI2.IsDestroyed(inputs.NumAttackerArmies.Minimum) then trigger.NumAttackerArmies.Minimum = inputs.NumAttackerArmies.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.NumAttackerArmies.Maximum) then trigger.NumAttackerArmies.Maximum = inputs.NumAttackerArmies.Maximum.GetValue(); end
    end
    if inputs.NumAttackerSpecialUnits ~= nil then
        trigger.NumAttackerSpecialUnits = trigger.NumAttackerSpecialUnits or {};
        if not UI2.IsDestroyed(inputs.NumAttackerSpecialUnits.Minimum) then trigger.NumAttackerSpecialUnits.Minimum = inputs.NumAttackerSpecialUnits.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.NumAttackerSpecialUnits.Maximum) then trigger.NumAttackerSpecialUnits.Maximum = inputs.NumAttackerSpecialUnits.Maximum.GetValue(); end
    end
    if inputs.AttackersAttackPower ~= nil then
        trigger.AttackersAttackPower = trigger.AttackersAttackPower or {};
        if not UI2.IsDestroyed(inputs.AttackersAttackPower.Minimum) then trigger.AttackersAttackPower.Minimum = inputs.AttackersAttackPower.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.AttackersAttackPower.Maximum) then trigger.AttackersAttackPower.Maximum = inputs.AttackersAttackPower.Maximum.GetValue(); end
    end
    if not UI2.IsDestroyed(inputs.MustBeSuccessful) then trigger.MustBeSuccessful = inputs.MustBeSuccessful.GetIsChecked(); end
    if not UI2.IsDestroyed(inputs.MustNotBeSuccessful) then trigger.MustNotBeSuccessful = inputs.MustNotBeSuccessful.GetIsChecked(); end
    if not UI2.IsDestroyed(inputs.MustBeAttack) then trigger.MustBeAttack = inputs.MustBeAttack.GetIsChecked(); end
    if not UI2.IsDestroyed(inputs.MustBeTransfer) then trigger.MustBeTransfer = inputs.MustBeTransfer.GetIsChecked(); end
    TriggerMenu.SaveTrigger(trigger, inputs);
end

---Generates the condition list based on the trigger type
---@param trigger OnMove
---@param inputs table
---@param selectFun fun(t: OnMove)
---@param close fun()
---@return ListItem
function OnMoveMenu.GenerateConditionList(trigger, inputs, selectFun, close)
    return mergeTables(TriggerMenu.GenerateConditionList(trigger, inputs, selectFun, close), {
        Move = {
            (trigger.NumAttackerArmies == nil or trigger.NumAttackerArmies.Minimum == nil) and {
                Name = "Min number of moving armies";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumAttackerArmies = trigger.NumAttackerArmies or {};
                    trigger.NumAttackerArmies.Minimum = 5;
                    selectFun(trigger);
                    close();
                end;
                Info = OnMove.Info.MinimumNumberOfAttackingArmiesCondition;
            } or nil;
            (trigger.NumAttackerArmies == nil or trigger.NumAttackerArmies.Maximum == nil) and {
                Name = "Max number of moving armies";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumAttackerArmies = trigger.NumAttackerArmies or {};
                    trigger.NumAttackerArmies.Maximum = 20;
                    selectFun(trigger);
                    close();
                end;
                Info = OnMove.Info.MaximumNumberOfAttackingArmiesCondition;
            } or nil;
            (trigger.NumAttackerSpecialUnits == nil or trigger.NumAttackerSpecialUnits.Minimum == nil) and {
                Name = "Min number of moving special units";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumAttackerSpecialUnits = trigger.NumAttackerSpecialUnits or {};
                    trigger.NumAttackerSpecialUnits.Minimum = 1;
                    selectFun(trigger);
                    close();
                end;
                Info = OnMove.Info.MinimumNumberOfAttackingSpecialUnitsCondition;
            } or nil;
            (trigger.NumAttackerSpecialUnits == nil or trigger.NumAttackerSpecialUnits.Maximum == nil) and {
                Name = "Max number of moving special units";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumAttackerSpecialUnits = trigger.NumAttackerSpecialUnits or {};
                    trigger.NumAttackerSpecialUnits.Maximum = 3;
                    selectFun(trigger);
                    close();
                end;
                Info = OnMove.Info.MaximumNumberOfAttackingSpecialUnitsCondition;
            } or nil;
            (trigger.AttackersAttackPower == nil or trigger.AttackersAttackPower.Minimum == nil) and {
                Name = "Min moving attack power";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.AttackersAttackPower = trigger.AttackersAttackPower or {};
                    trigger.AttackersAttackPower.Minimum = 5;
                    selectFun(trigger);
                    close();
                end;
                Info = OnMove.Info.MinimumAttackersAttackPowerCondition;
            } or nil;
            (trigger.AttackersAttackPower == nil or trigger.AttackersAttackPower.Maximum == nil) and {
                Name = "Max moving attack power";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.AttackersAttackPower = trigger.AttackersAttackPower or {};
                    trigger.AttackersAttackPower.Maximum = 20;
                    selectFun(trigger);
                    close();
                end;
                Info = OnMove.Info.MaximumAttackersAttackPowerCondition;
            } or nil;
        };
    });
end