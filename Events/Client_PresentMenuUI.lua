---@diagnostic disable: undefined-field

require("Events");
require("UI");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, refreshed)
    if not game.Settings.SinglePlayer then
        UI.Alert("This mod can only be used in singleplayer!");
        close();
        return;
    end 
    
    GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1);
    setMaxSize(500, 600);
    
    if refreshed and Close ~= nil and RefreshFunction ~= nil then
        Close();
        RefreshFunction();
        RefreshFunction = nil;
        Close = close;
        return;
    end
    
    Init();
    colors = GetColors();
    Game = game;
    Close = close;
    CancelClickIntercept = true;

    printTable(Mod.PublicGameData.TerritoryMap);

    showMain();
end

function showMain()
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    CenterObject(root, UI2.LABEL).SetText("Events").SetColor(colors.Yellow);
    local t = CenterMultipleObjects(root, {Text = UI2.LABEL, Name = UI2.LABEL}, 0);
    t.Text.SetText("Created by: ").SetColor(colors.TextColor);
    t.Name.SetText("Just_A_Dutchman_").SetColor(colors.Lime);

    CreateEmpty(root).SetPreferredHeight(10);
    local objs = CenterMultipleObjects(root, {Triggers = UI2.BUTTON, Events = UI2.BUTTON}, 0.25);
    objs.Triggers.SetText("Triggers").SetColor(colors.Green).SetOnClick(showExistingTriggers);
    objs.Events.SetText("Events").SetColor(colors["Light Blue"]).SetOnClick(showExistingEvents);
    objs = CenterMultipleObjects(root, {Assign = UI2.BUTTON, Inspect = UI2.BUTTON}, 0.25);
    objs.Assign.SetText("Assign").SetColor(colors.Yellow).SetOnClick(selectTriggerForAssignment);
    objs.Inspect.SetText("inspect").SetColor(colors["Orange Red"]).SetOnClick(inspectTerritory);
end

function showExistingTriggers(func)
    DestroyWindow();
    
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    createTriggerFilter(root, func);

    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.BUTTON).SetText("Create Trigger").SetColor(colors.Green).SetOnClick(showChooseTriggerType);


    if getTableLength(Mod.PublicGameData.Triggers) > 0 then
        CreateEmpty(root).SetPreferredHeight(10);
        CreateLabel(root).SetText("The following triggers have been created:").SetColor(colors.TextColor);
        showTriggers(root, func);
    else
        CreateLabel(root).SetText("There are currently no triggers").SetColor(colors.TextColor);
    end
end

function createTriggerFilter(root, func)
    TriggerFilterType = TriggerFilterType or 0;
    local updateFilterButton = function(but)
        if TriggerFilterType == 0 then
            but.SetText("All types").SetColor(colors.Green);
        else
            but.SetText(getTriggerTypeName(TriggerFilterType)).SetColor(getTriggerTypeColor(TriggerFilterType));
        end
    end

    local buttons = CenterMultipleObjects(root, {ReturnButton = UI2.BUTTON, FilterButton = UI2.BUTTON}, 0.1);
    buttons.ReturnButton.SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    buttons.FilterButton.SetColor(colors.Green).SetOnClick(function()
        TriggerFilterType = TriggerFilterType + 1;
        if TriggerFilterType > getNumOfTriggers() then
            TriggerFilterType = 0;
        end
        updateFilterButton(buttons.FilterButton);
        showTriggers(root, func);
    end)
    updateFilterButton(buttons.FilterButton);
end

function showTriggers(root, func, pageN)
    pageN = pageN or 1
    local NperPage = 8;

    local win = "ShowTriggers";
    DestroyWindow(win);
    local par = CreateSubWindow(CreateVert(root).SetFlexibleWidth(1), win);
    local counter = 0;
    for _, trigger in pairs(Mod.PublicGameData.Triggers) do
        if TriggerFilterType == 0 or trigger.Type == TriggerFilterType then
            if counter < pageN * NperPage and counter >= (pageN - 1) * NperPage then
                CreateInfoButtonLine(par, function(line)
                    CreateButton(line).SetText(trigger.Name).SetColor(getTriggerTypeColor(trigger.Type)).SetOnClick(function()
                        printTable(trigger);
                        (func or showModifyTrigger)(trigger);
                    end);
                end, "TODO");
            end
            counter = counter + 1;
        end
    end

    if counter > NperPage then
        createPageButtons(par, pageN, math.ceil(counter / NperPage), function()
            showTriggers(root, func, pageN - 1);
        end, function()
            showTriggers(root, func, pageN + 1);
        end);
    end
end

function showExistingEvents(func, reqFunc)
    reqFunc = reqFunc or function(_) return true; end;
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    createEventFilter(root, func, reqFunc);
    
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.BUTTON).SetText("Create Event").SetColor(colors.Green).SetOnClick(showChooseEventType);

    if getTableLength(Mod.PublicGameData.Events) > 0 then
        CreateEmpty(root).SetPreferredHeight(10);
        CreateLabel(root).SetText("The following events have been created:").SetColor(colors.TextColor);
        showEvents(root, func)
    else
        CreateLabel(root).SetText("There are currently no events").SetColor(colors.TextColor);
    end
end

function createEventFilter(root, func, reqFunc)
    EventFilterType = EventFilterType or 0;
    local updateFilterButton = function(but)
        if EventFilterType == 0 then
            but.SetText("All types").SetColor(colors.Green);
        else
            but.SetText(getEventTypeName(EventFilterType)).SetColor(getEventTypeColor(EventFilterType));
        end
    end

    local buttons = CenterMultipleObjects(root, {ReturnButton = UI2.BUTTON, FilterButton = UI2.BUTTON}, 0.1);
    buttons.ReturnButton.SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    buttons.FilterButton.SetColor(colors.Green).SetOnClick(function()
        EventFilterType = EventFilterType + 1;
        if EventFilterType > getNumOfEvents() then
            EventFilterType = 0;
        end
        updateFilterButton(buttons.FilterButton);
        showEvents(root, func, reqFunc);
    end)
    updateFilterButton(buttons.FilterButton);

end

function showEvents(root, func, reqFunc, pageN)
    pageN = pageN or 1;
    local NperPage = 8;

    reqFunc = reqFunc or function(_) return true; end;
    local win = "ShowEvents";
    DestroyWindow(win);
    local par = CreateSubWindow(CreateVert(root).SetFlexibleWidth(1), win);
    local counter = 0;
    for _, event in pairs(Mod.PublicGameData.Events) do
        if (EventFilterType == 0 or EventFilterType == event.Type) and reqFunc(event) then
            if counter < pageN * NperPage and counter >= (pageN - 1) * NperPage then
                CreateInfoButtonLine(par, function(line)
                    CreateButton(line).SetText(event.Name).SetColor(getEventTypeColor(event.Type)).SetOnClick(function()
                        printTable(event);
                        (func or showModifyEvent)(event);
                    end)
                end, "TODO");
            end
            counter = counter + 1;
        end
    end

    if counter > NperPage then
        createPageButtons(par, pageN, math.ceil(counter / NperPage), function()
            showEvents(root, func, reqFunc, pageN - 1);
        end, function()
            showEvents(root, func, reqFunc, pageN + 1);
        end);
    end
end

function showChooseTriggerType()
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    CreateLabel(root).SetText("Please select the type of trigger you want to create:").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(5);

    for _, type in pairs(UTIL.TriggerTypes) do
        CreateInfoButtonLine(root, function(line)
            CreateButton(line).SetText(getTriggerTypeName(type)).SetColor(getTriggerTypeColor(type)).SetOnClick(function()
                local trigger = createNewTrigger(Mod.PublicGameData.Triggers, type);
                showModifyTrigger(trigger);
            end);
        end, getTriggerTypeInfo(type))
    end
end

function showModifyTrigger(trigger)
    DestroyWindow();

    local inputs = {};
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    local t = CenterMultipleObjects(root, {Return = UI2.BUTTON, Delete = UI2.BUTTON, Submit = UI2.BUTTON}, 0.1);
    t.Return.SetText("Return").SetColor(colors.Orange).SetOnClick(showExistingTriggers);
    t.Delete.SetText("Delete").SetColor(colors.Red).SetOnClick(function()
        CreateConfirmPage("Are you sure you want to delete this trigger? If you delete this button, every custom event where this trigger is involved in will also be removed", function()
            RefreshFunction = showExistingTriggers();
            Game.SendGameCustomMessage("Deleting trigger...", { Type = "DeleteTrigger", Trigger = trigger}, void);
            Close();
        end);
    end).SetInteractable(Mod.PublicGameData.Triggers[trigger.ID] ~= nil);
    t.Submit.SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        saveTrigger(trigger, inputs);
        Game.SendGameCustomMessage("Updating data...", {Type = "UpdateTrigger", Trigger = trigger}, function(p) end);
        RefreshFunction = showExistingTriggers;
    end)
    CenterObject(root, UI2.LABEL).SetText("Modify trigger").SetColor(colors.TextColor);
    
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Trigger type: ").SetColor(colors.TextColor);
        CreateLabel(line).SetText(getTriggerTypeName(trigger.Type)).SetColor(colors.Yellow);
    end, "This is the type of trigger. " .. getTriggerTypeInfo(trigger.Type));
    
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Name: ").SetColor(colors.TextColor);
        inputs.Name = CreateTextInputField(line).SetText(trigger.Name).SetPreferredWidth(290).SetCharacterLimit(50);
    end, INFO.TriggerName);
    
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Slots: ").SetColor(colors.TextColor);
        CreateButton(line).SetText(#(trigger.Slots or {}) .. " slots").SetColor(colors.Green).SetOnClick(function()
            saveTrigger(trigger, inputs);
            showModifySlots(trigger, "Slots", function() showModifyTrigger(trigger); end);
        end);
    end, INFO.TriggerSlots);
    
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Structures: ").SetColor(colors.TextColor);
        CreateButton(line).SetText(getTableLength(trigger.Structures or {}) .. " conditions").SetColor(colors.Yellow).SetOnClick(function()
            saveTrigger(trigger, inputs);
            showModifyStructures(trigger, inputs, "Structures", function() showModifyTrigger(trigger); end);
        end);
    end, INFO.TriggerStructures);

    CreateInfoButtonLine(root, function(line)
        inputs.BlacklistSlots = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.BlacklistSlots or false);
        CreateLabel(line).SetText("Only non-included slots can fire this trigger").SetColor(colors.TextColor);
    end, INFO.TriggerBlacklistSlots);

    CreateInfoButtonLine(root, function(line)
        inputs.NeutralCanFireThis = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.NeutralCanFireThis or false);
        CreateLabel(line).SetText("Fire trigger if territory is neutral").SetColor(colors.TextColor);
    end, INFO.TriggerFireIfNeutral);
    
    CreateEmpty(root).SetPreferredHeight(10);
    
    showModifyCooldownCondition(root, trigger, inputs);
    
    showModifyChanceCondition(root, trigger, inputs);
    
    showModifyMinimumCondition(root, trigger, inputs, "NumArmies", "number of armies", INFO.MinimumNumberOfArmiesCondition);
    showModifyMaximumCondition(root, trigger, inputs, "NumArmies", "number of armies", INFO.MaximumNumberOfArmiesCondition);
    
    showModifyMinimumCondition(root, trigger, inputs, "NumSpecialUnits", "number of special units", INFO.MinimumNumberOfSpecialUnitsCondition, 0, 5);
    showModifyMaximumCondition(root, trigger, inputs, "NumSpecialUnits", "number of special units", INFO.MaximumNumberOfSpecialUnitsCondition, 0, 5);
    
    showModifyMinimumCondition(root, trigger, inputs, "DefensePower", "total defense power", INFO.MinimumDefensePowerCondition);
    showModifyMaximumCondition(root, trigger, inputs, "DefensePower", "total defense power", INFO.MaximumDefensePowerCondition);
    
    showModifyMinimumCondition(root, trigger, inputs, "AttackPower", "total attack power", INFO.MinimumAttackPowerCondition);
    showModifyMaximumCondition(root, trigger, inputs, "AttackPower", "total attack power", INFO.MaximumAttackPowerCondition);
    
    if trigger.Type == UTIL.TriggerTypes.OnDeploy then
        showModifyOnDeployTrigger(trigger, inputs, root);
    elseif trigger.Type == UTIL.TriggerTypes.OnMove then
        showModifyOnMoveTrigger(trigger, inputs, root);
    elseif trigger.Type == UTIL.TriggerTypes.OnStructureChange then
        showModifyOnStructureChange(trigger, inputs, root);
    end

    CenterObject(root, UI2.BUTTON).SetText("Add condition").SetColor(colors.Blue).SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, generateConditionList(trigger, inputs, showModifyTrigger, close), function() close(); end);
        end)
    end);
end

function selectFromList(root, list, cancelAction)
    CreateButton(root).SetText("Cancel").SetColor(colors.Orange).SetOnClick(cancelAction);

    CreateEmpty(root).SetPreferredHeight(10);

    CenterObject(root, UI2.LABEL).SetText("Select one of the following options").SetColor(colors.TextColor);
    
    CreateEmpty(root).SetPreferredHeight(5);

    for i, t in pairs(list) do
        if t.Info ~= nil then
            CreateInfoButtonLine(root, function(line)
                CreateButton(line).SetText(t.Name).SetColor(t.Color or getColorFromList(i)).SetOnClick(t.Action);
            end, t.Info);
        else
            CreateButton(root).SetText(t.Name).SetColor(t.Color or getColorFromList(i)).SetOnClick(t.Action);
        end
    end
end

function showModifyCooldownCondition(root, trigger, inputs)
    if trigger.Cooldown then
        CreateDeleteButtonLine(root, function(line)
            CreateLabel(line).SetText("The cooldown until this trigger can be triggered again").SetColor(colors.TextColor);
            inputs.Cooldown = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(trigger.Cooldown);
        end, function()
            saveTrigger(trigger, inputs);
            trigger.Cooldown = nil;
            showModifyTrigger(trigger);
        end);
    end
end

function showModifyChanceCondition(root, trigger, inputs)
    if trigger.Chance then
        CreateDeleteButtonLine(root, function(line)
            CreateLabel(line).SetText("The chance of the trigger firing").SetColor(colors.TextColor);
            inputs.Chance = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(trigger.Chance or 100).SetWholeNumbers(false);
        end, function()
            saveTrigger(trigger, inputs);
            trigger.Chance = nil;
            showModifyTrigger(trigger);
        end);
    end
end


function showModifyMinimumCondition(root, trigger, inputs, field, text, info, min, max)
    if trigger[field] then
        inputs[field] = inputs[field] or {};
        if trigger[field].Minimum then
            CreateInfoButtonLine(root, function(line)
                CreateLabel(line).SetText("Minimum " .. text).SetColor(colors.TextColor);
            end, info);
            CreateDeleteButtonLine(root, function(line)
                inputs[field].Minimum = CreateNumberInputField(line).SetSliderMinValue(min or 0).SetSliderMaxValue(max or 50).SetValue(trigger[field].Minimum);
            end, function()
                saveTrigger(trigger, inputs);
                trigger[field].Minimum = nil;
                if trigger[field].Maximum == nil then
                    trigger[field] = nil;
                end
                showModifyTrigger(trigger);
            end);
        end
    end
end

function showModifyMaximumCondition(root, trigger, inputs, field, text, info, min, max)
    if trigger[field] then
        inputs[field] = inputs[field] or {};
        if trigger[field].Maximum then
            CreateInfoButtonLine(root, function(line)
                CreateLabel(line).SetText("Maximum " .. text).SetColor(colors.TextColor);
            end, info);
            CreateDeleteButtonLine(root, function(line)
                inputs[field].Maximum = CreateNumberInputField(line).SetSliderMinValue(min or 0).SetSliderMaxValue(max or 50).SetValue(trigger[field].Maximum);
            end, function()
                saveTrigger(trigger, inputs);
                trigger[field].Maximum = nil;
                if trigger[field].Minimum == nil then
                    trigger[field] = nil;
                end
                showModifyTrigger(trigger);
            end);
        end
    end
end

function showModifyOnDeployTrigger(trigger, inputs, root)
    showModifyMinimumCondition(root, trigger, inputs, "NumDeployed", "number of deployed armies", INFO.MinimumArmiesDeployedCondition);
    showModifyMaximumCondition(root, trigger, inputs, "NumDeployed", "number of deployed armies", INFO.MaximumArmiesDeployedCondition);
end

function showModifyOnMoveTrigger(trigger, inputs, root)
    CenterObject(root, UI2.LABEL).SetText("Attack/transfer specific conditions").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(10);
    
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Attacking slots: ").SetColor(colors.TextColor);
        CreateButton(line).SetText(countStructureConditions(trigger.Structures or {}) .. " slots").SetColor(colors.Green).SetOnClick(function()
            saveTrigger(trigger, inputs);
            showModifySlots(trigger, "AttackerSlots", function() showModifyTrigger(trigger); end);
        end);
    end, INFO.TriggerAttackerSlots);
    
    CreateInfoButtonLine(root, function(line)
        inputs.BlacklistAttackerSlots = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.BlacklistAttackerSlots or false);
        CreateLabel(line).SetText("Only non-included attacking slots can fire this trigger").SetColor(colors.TextColor);
    end, INFO.TriggerBlacklistAttackerSlots);
    
    CreateInfoButtonLine(root, function(line)
        inputs.MustBeSuccessful = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustBeSuccessful or false);
        CreateLabel(line).SetText("Attack must be successful").SetColor(colors.TextColor);
    end, INFO.TriggerMustBeSuccessful);
    
    CreateInfoButtonLine(root, function(line)
        inputs.MustNotBeSuccessful = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustNotBeSuccessful or false);
        CreateLabel(line).SetText("Attack must be not successful").SetColor(colors.TextColor);
    end, INFO.TriggerMustNotBeSuccessful);

    CreateInfoButtonLine(root, function(line)
        inputs.MustBeAttack = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustBeAttack or false);
        CreateLabel(line).SetText("Must be an attack").SetColor(colors.TextColor);
    end, INFO.TriggerMustBeAttack);
    
    CreateInfoButtonLine(root, function(line)
        inputs.MustBeTransfer = CreateCheckBox(line).SetText(" ").SetIsChecked(trigger.MustBeTransfer or false);
        CreateLabel(line).SetText("Must be a transfer").SetColor(colors.TextColor);
    end, INFO.TriggerMustBeTransfer);
    
    inputs.MustBeSuccessful.SetOnValueChanged(function()
        if inputs.MustBeSuccessful.GetIsChecked() then
            inputs.MustNotBeSuccessful.SetIsChecked(false);
        end
    end);

    inputs.MustNotBeSuccessful.SetOnValueChanged(function()
        if inputs.MustNotBeSuccessful.GetIsChecked() then
            inputs.MustBeSuccessful.SetIsChecked(false);
        end
    end);

    inputs.MustBeAttack.SetOnValueChanged(function()
        if inputs.MustBeAttack.GetIsChecked() then
            inputs.MustBeTransfer.SetIsChecked(false);
        end
    end);
    inputs.MustBeTransfer.SetOnValueChanged(function()
        if inputs.MustBeTransfer.GetIsChecked() then
            inputs.MustBeAttack.SetIsChecked(false);
        end
    end);

    showModifyMinimumCondition(root, trigger, inputs, "NumAttackerArmies", "number of attacking armies", INFO.MinimumNumberOfAttackingArmiesCondition);
    showModifyMaximumCondition(root, trigger, inputs, "NumAttackerArmies", "number of attacking armies", INFO.MaximumNumberOfAttackingArmiesCondition);
    
    showModifyMinimumCondition(root, trigger, inputs, "NumAttackerSpecialUnits", "number of attacking special units", INFO.MinimumNumberOfAttackingSpecialUnitsCondition, 1, 5);
    showModifyMaximumCondition(root, trigger, inputs, "NumAttackerSpecialUnits", "number of attacking special units", INFO.MaximumNumberOfAttackingSpecialUnitsCondition, 1, 5);

    showModifyMinimumCondition(root, trigger, inputs, "AttackersAttackPower", "number attackers attack power", INFO.MinimumAttackersAttackPowerCondition);
showModifyMaximumCondition(root, trigger, inputs, "AttackersAttackPower", "number attackers attack power", INFO.MaximumAttackersAttackPowerCondition);
end

function showModifyOnStructureChange(trigger, inputs, root)
    CenterObject(root, UI2.LABEL).SetText("Structure change specific conditions").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(10);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Structure changes: ").SetColor(colors.TextColor);
    CreateButton(line).SetText(countStructureConditions(trigger.Structures or {}) .. " structures").SetColor(colors.Green).SetOnClick(function()
        saveTrigger(trigger, inputs);
        showModifyStructures(trigger, inputs, "StructureChanges", function() showModifyTrigger(trigger); end);
    end);
end

function showChooseEventType()
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    CreateLabel(root).SetText("Please select the type of trigger you want to create:").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(5);

    for _, type in pairs(UTIL.EventTypes) do
        CreateInfoButtonLine(root, function(line)
            CreateButton(line).SetText(getEventTypeName(type)).SetColor(getEventTypeColor(type)).SetOnClick(function()
                local event = createNewEvent(Mod.PublicGameData.Events, type);
                showModifyEvent(event);
            end);
        end, getEventTypeInfo(type));
    end
end

function showModifyEvent(event)
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    local buttons = CenterMultipleObjects(root, { Return = UI2.BUTTON, Delete = UI2.BUTTON, Submit = UI2.BUTTON }, 0.1);
    buttons.Submit.SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        saveEvent(event, inputs);
        Game.SendGameCustomMessage("Updating event...", { Type = "UpdateEvent", Event = event }, void);
        showExistingEvents();
        Close();
    end);
    buttons.Delete.SetText("Delete").SetColor(colors.Red).SetOnClick(function()
        CreateConfirmPage("Are you sure you want to delete this event? It will be removed from every custom event you have assigned to the map already", function()
            RefreshFunction = showExistingEvents();
            Game.SendGameCustomMessage("Deleting event...", { Type = "DeleteEvent", Event = event }, void);
            Close();
        end)
    end).SetInteractable(Mod.PublicGameData.Events[event.ID] ~= nil);
    buttons.Return.SetText("Return").SetColor(colors.Orange).SetOnClick(showExistingEvents);

    CreateEmpty(root).SetPreferredHeight(5);

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Event type: ").SetColor(colors.TextColor);
        CreateLabel(line).SetText(getEventTypeName(event.Type)).SetColor(colors.Yellow);
    end, "This is the type of the event. " .. getEventTypeInfo(event.Type));

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Name: ").SetColor(colors.TextColor);
        inputs.Name = CreateTextInputField(line).SetText(event.Name).SetCharacterLimit(50).SetPreferredWidth(290);
    end, INFO.EventName);

    local nextFun = {
        [UTIL.EventTypes.MessageEvent] = showModifyMessageEvent;
        [UTIL.EventTypes.SetOwnerEvent] = showModifySetOwnerEvent;
        [UTIL.EventTypes.AddArmiesEvent] = showModifyAddArmiesEvent;
        [UTIL.EventTypes.AddStructuresEvent] = showModifyAddStructuresEvent;
        [UTIL.EventTypes.IncomeModificationEvent] = showModifyIncomeModificationEvent;
        [UTIL.EventTypes.FireManualTrigger] = showModifyFireManualTriggerEvent;
    }
    nextFun[event.Type](root, event, inputs);
end

function showModifyMessageEvent(root, event, inputs)
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.LABEL).SetText("Message Event Options").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);

    CreateInfoButtonLine(root, function(line)
        inputs.BroadcastMessage = CreateCheckBox(line).SetText(" ").SetIsChecked(event.BroadcastMessage or false).SetOnValueChanged(function()
            inputs.ReceiversButton.SetInteractable(not inputs.BroadcastMessage.GetIsChecked());
        end);
        CreateLabel(line).SetText("Broadcast message").SetColor(colors.TextColor);
    end, INFO.EventBroadcastMessage);

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Slots: ").SetColor(colors.TextColor);
        inputs.ReceiversButton = CreateButton(line).SetText(#(event.Receivers or {}) .. " slots").SetColor(colors.Green).SetOnClick(function()
            saveEvent(event, inputs);
            showModifySlots(event, "Receivers", function() showModifyEvent(event); end);
        end).SetInteractable(not inputs.BroadcastMessage.GetIsChecked());
    end, INFO.EventMessageReceivers);

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Put your message together").SetColor(colors.TextColor);
    end, INFO.EventMessage);

    event.Message = event.Message or {""};
    inputs.Message = {};
    for _, _ in ipairs(event.Message) do
        table.insert(inputs.Message, true);
    end
    local valueClickFuncs = getEventValueFunctions();
    local deleteSubPart = function(i)
        table.remove(event.Message, i);
        table.remove(inputs.Message, i);
        saveEvent(event, inputs);
        showModifyEvent(event);
    end;
    local updateOrder = getRefreshEventFunc(event, inputs);

    for i, sub in ipairs(event.Message) do
        if type(sub) == "string" then
            CreateDeleteButtonLine(root, function(line)
                createUpDownButtons(line, inputs.Message, i, updateOrder);
                inputs.Message[i] = CreateTextInputField(line).SetText(sub).SetPlaceholderText("Type here the message").SetFlexibleWidth(9);
            end, function()
                deleteSubPart(i);
            end);
        else
            inputs.Message[i] = sub;
            CreateDeleteButtonLine(root, function(line)
                createUpDownButtons(line, inputs.Message, i, updateOrder);
                CreateButton(line).SetText(getValueTypeName(sub.Type)).SetColor(getValueTypeColor(sub.Type)).SetOnClick(function()
                    Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
                        setMaxSize(500, 400);
                        local vert = CreateVert(rootParent).SetFlexibleWidth(1);
                        selectFromList(vert, generateEventValueList(event, function(enum)
                            ---@diagnostic disable-next-line: assign-type-mismatch
                            event.Message[i] = createValueTable(enum);
                            updateOrder()
                        end, close), function() close(); end);
                    end);
                end);
                (valueClickFuncs[sub.Type] or void)(line, sub);
            end, function()
                deleteSubPart(i);
            end);
        end
    end

    CreateEmpty(root).SetPreferredHeight(5);

    local buttons = CenterMultipleObjects(root, { Text = UI2.BUTTON, Value = UI2.BUTTON }, 0.1);
    buttons.Text.SetText("Add text").SetColor(colors.Blue).SetOnClick(function()
        table.insert(event.Message, "");
        updateOrder()
    end);
    buttons.Value.SetText("Add value").SetColor(colors["Orange Red"]).SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, generateEventValueList(event, function(enum)
                table.insert(event.Message, createValueTable(enum));
                updateOrder()
            end, close), function() close(); end);
        end);
    end);
end

function showModifySetOwnerEvent(root, event, inputs)
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.LABEL).SetText("Message Event Options").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);

    local reloadEvent = getRefreshEventFunc(event, inputs);

    inputs.NewPlayer = event.NewPlayer;
    local valueClickFuncs = getEventValueFunctions();
    local createOptionsList = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, generateEventValueList(event, function(enum)
                inputs.NewPlayer = createValueTable(enum);
                reloadEvent();
            end, close), function() close(); end);
        end);
    end

    if inputs.NewPlayer == nil then
        CenterObject(root, UI2.BUTTON).SetText("Select player").SetColor(colors.Blue).SetOnClick(createOptionsList);
    else
        CreateDeleteButtonLine(root, function(line)
            CreateButton(line).SetText(getValueTypeName(inputs.NewPlayer.Type)).SetColor(getValueTypeColor(inputs.NewPlayer.Type)).SetOnClick(createOptionsList);   
            (valueClickFuncs[inputs.NewPlayer.Type] or void)(line, inputs.NewPlayer);
        end, function()
            inputs.NewPlayer = nil;
            reloadEvent();
        end);
    end
end

function showModifyAddArmiesEvent(root, event, inputs)
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.LABEL).SetText("Add Armies Event Options").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Number of armies").SetColor(colors.TextColor);
    end, INFO.EventAddArmies);

    event.Expression = event.Expression or {};

    showModifyExpression(root, event, event, inputs, "Expression", getRefreshEventFunc(event, inputs));
end

function showModifyAddStructuresEvent(root, event, inputs)
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.LABEL).SetText("Add Structures Event Options").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);

    event.Addition = event.Addition or {};
    inputs.Addition = {};

    local reloadEvent = getRefreshEventFunc(event, inputs);
    local pickedEnums = {};
    local pickStructure = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, generateStructuresList(function(enum)
                inputs.Addition[enum] = {};
                reloadEvent();
                close();
            end, pickedEnums), function() close(); end);
        end);
    end

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Structure modifications").SetColor(colors.TextColor);
    end, INFO.EventStructureModification);

    for enum, expr in pairs(event.Addition) do
        table.insert(pickedEnums, enum);
        local but = CreateButton(root).SetFlexibleWidth(1).SetText("").SetInteractable(false).SetColor(getColorFromList(enum));
        local inButton = CreateVert(but).SetFlexibleWidth(1);
        inputs.Addition[enum] = expr;
        CreateDeleteButtonLine(inButton, function(line)
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateLabel(line).SetText(getStructureName(enum)).SetColor(colors.TextColor);
        end, function()
            inputs.Addition[enum] = nil;
            reloadEvent();
        end);
        showModifyExpression(inButton, event, event.Addition, inputs.Addition, enum, reloadEvent);
    end

    CenterObject(root, UI2.BUTTON).SetText("Add structure").SetColor(colors.Blue).SetOnClick(pickStructure);
end

function showModifyIncomeModificationEvent(root, event, inputs)
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.LABEL).SetText("Add Structures Event Options").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("The amount of turns the income modification will be applied").SetColor(colors.TextColor);
    end, INFO.EventIncomeModDuration);
    inputs.Duration = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(5).SetValue(event.Duration or 2);

    inputs.Player = event.Player;
    local valueClickFuncs = getEventValueFunctions();
    local reloadEvent = getRefreshEventFunc(event, inputs);
    local playerSelected = function(enum)
        inputs.Player = createValueTable(enum);
        reloadEvent();
    end
    local selectPlayer = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, (function() 
                local list = {};
                for _, enum in ipairs({UTIL.InjectValues.TriggerTerrOwner, UTIL.InjectValues.MoveOrderPlayer, UTIL.InjectValues.SlotPlayer}) do
                    table.insert(list, {
                        Name = getValueTypeName(enum),
                        Action = function() playerSelected(enum); close(); end,
                        Info = getValueTypeInfo(enum),
                        Color = getValueTypeColor(enum)
                    });
                end
                return list;
             end)(), function() close(); end);
        end);
    end

    CreateEmpty(root).SetPreferredHeight(3);

    if inputs.Player == nil then
        CenterObject(root, UI2.BUTTON).SetText("Select player").SetColor(colors.Blue).SetOnClick(selectPlayer);
    else
        CreateDeleteButtonLine(root, function(line)
            CreateButton(line).SetText(getValueTypeName(inputs.Player.Type)).SetColor(getValueTypeColor(inputs.Player.Type)).SetOnClick(selectPlayer);
            (valueClickFuncs[inputs.Player.Type] or void)(line, inputs.Player);
        end, function()
            inputs.Player = nil;
            reloadEvent();
        end);
    end

    CreateEmpty(root).SetPreferredHeight(3);
    
    CreateLabel(root).SetText("Added income").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);
    showModifyExpression(root, event, event, inputs, "IncomeMod", reloadEvent);
end

function showModifyFireManualTriggerEvent(root, event, inputs)
    CreateEmpty(root).SetPreferredHeight(5);
    CenterObject(root, UI2.LABEL).SetText("Fire Manual Trigger event").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(3);

    inputs.TriggerID = event.TriggerID;
    inputs.TerritoryID = event.TerritoryID;

    local reloadEvent = getRefreshEventFunc(event, inputs);
    local selectTrigger = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            TriggerFilterType = UTIL.TriggerTypes.ManualTrigger;
            showTriggers(vert, function(trigger)
                inputs.TriggerID = trigger.ID;
                reloadEvent();
                close();
            end);

            CenterObject(vert, UI2.BUTTON).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() close(); end);
        end);
    end

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Linked trigger").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(5);
        if event.TriggerID ~= nil then
            CreateButton(line).SetText(Mod.PublicGameData.Triggers[event.TriggerID].Name).SetColor(getTriggerTypeColor(UTIL.TriggerTypes.ManualTrigger)).SetOnClick(selectTrigger);
        else
            CreateButton(line).SetText("Select").SetColor(colors["Orange Red"]).SetOnClick(selectTrigger)
        end
    end, INFO.EventSelectManualTrigger);

    local selectTerritory = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            showPickTerritory(vert, function(terrDetails)
                inputs.TerritoryID = terrDetails.ID;
                reloadEvent();
                print(event.TerritoryID);
                close();
            end)
        end);
    end

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Linked territory").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(5);
        if event.TerritoryID ~= nil then
            CreateButton(line).SetText(Game.Map.Territories[event.TerritoryID].Name).SetColor(colors.Green).SetOnClick(selectTerritory);
        else
            CreateButton(line).SetText("Select").SetColor(colors["Orange Red"]).SetOnClick(selectTerritory);
        end
    end, INFO.EventSelectTerritory);
end

function showModifyExpression(root, event, data, inputs, parField, reloadEvent)
    data[parField] = data[parField] or {};
    inputs[parField] = data[parField];
    local valueClickFuncs = getEventValueFunctions();
    local pickValue = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, generateEventValueList(event, function(type)
                if type == UTIL.InjectValues.Expression then
                    inputs[parField] = createExpression(0);
                else
                    inputs[parField] = createValueTable(type);
                end
                reloadEvent();
            end, close), function() close(); end);
        end);
    end;

    if isValueTable(data[parField]) then
        CreateDeleteButtonLine(root, function(line)
            CreateButton(line).SetText(getValueTypeName(data[parField].Type)).SetColor(getValueTypeColor(data[parField].Type)).SetOnClick(pickValue);
            (valueClickFuncs[data[parField].Type] or void)(line, inputs[parField]);
        end, function()
            inputs[parField] = removeValueFromExpression(data[parField]);
            reloadEvent();
        end)
    elseif isExpression(data[parField]) then
        local operatorFunc = function()
            Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
                setMaxSize(500, 400);
                local vert = CreateVert(rootParent).SetFlexibleWidth(1);
                selectFromList(vert, generateOperatorList(function(type)
                    data[parField].Operator = type;
                    reloadEvent();
                    close();
                end), function() close(); end);
            end)
        end;

        showModifyExpression(root, event, data[parField], inputs[parField], "Left", reloadEvent);

        if data[parField].Operator == 0 then
            CreateDeleteButtonLine(root, function(line)
                CenterObject(line, UI2.BUTTON).SetText("Select operator").SetColor(colors.Yellow).SetOnClick(operatorFunc)
            end, function()
                inputs[parField] = removeValueFromExpression(data[parField]);
                reloadEvent();
            end);
        else
            CreateDeleteButtonLine(root, function(line)
                CenterObject(line, UI2.BUTTON).SetText(getOperatorName(data[parField].Operator, 15)).SetColor(getColorFromList(data[parField].Operator)).SetOnClick(operatorFunc);
            end, function()
                inputs[parField] = removeValueFromExpression(data[parField]);
                reloadEvent();
            end);
        end

        showModifyExpression(root, event, data[parField], inputs[parField], "Right", reloadEvent);
    else
        CreateButton(root).SetText("Add expression").SetColor(colors.Blue).SetOnClick(pickValue);
    end
end


function getEventValueFunctions()
    return {
        [UTIL.InjectValues.SlotPlayer] = setSingleSlot,
        [UTIL.InjectValues.IntegerConstant] = setNumber,
        [UTIL.InjectValues.NumberConstant] = function(line, input) setNumber(line, input, true); end,
        [UTIL.InjectValues.TriggerTerrStructureCount] = setStructure
    };
end

function createUpDownButtons(line, list, index, final)
    CreateButton(line).SetText("^").SetColor(colors["Royal Blue"]).SetOnClick(function()
        local this = list[index];
        if index == 1 then
            list[index] = list[#list];
            list[#list] = this;
        else
            list[index] = list[index - 1];
            list[index - 1] = this;
        end
        final();
    end).SetInteractable(#list > 1);
    CreateButton(line).SetText("v").SetColor(colors["Royal Blue"]).SetOnClick(function()
        local this = list[index];
        if #list == index then
            list[index] = list[1];
            list[1] = this;
        else
            list[index] = list[index + 1];
            list[index + 1] = this;
        end
        final();
    end).SetInteractable(#list > 1);
end

function setSingleSlot(line, input)
    input.Value = input.Value or 0;
    CreateEmpty(line).SetFlexibleWidth(1);
    local but = CreateButton(line).SetText(getSlotName(input.Value)).SetColor(getColorFromList(input.Value));
    but.SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(300, 300);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            local textField = CreateTextInputField(vert).SetText("").SetPlaceholderText("Slot name").SetPreferredWidth(250);
            local buttons = CenterMultipleObjects(vert, { Submit = UI2.BUTTON, Cancel = UI2.BUTTON }, 0.1);
            buttons.Submit.SetText("Submit").SetColor(colors.Green).SetOnClick(function()
                local text = string.upper(textField.GetText());
                if validateSlotName(text) then
                    input.Value = getSlotIndex(text);
                    close();
                    but.SetText(getSlotName(input.Value)).SetColor(getColorFromList(input.Value));
                else
                    UI.Alert(INFO.SlotNameFormat)
                end
            end);
            buttons.Cancel.SetText("Cancel").SetColor(colors.Red).SetOnClick(function()
                close();
            end)
        end);
    end);
end

function setNumber(line, input, nonWhole)
    CreateEmpty(line).SetFlexibleWidth(1);
    input.Input = CreateNumberInputField(line).SetSliderMinValue(-20).SetSliderMaxValue(20).SetWholeNumbers(not (nonWhole or false)).SetValue(input.Value or 0);
end

function setStructure(line, input)
    input.Value = input.Value or 0;
    CreateEmpty(line).SetFlexibleWidth(1);
    local but = CreateButton(line).SetText(getStructureName(input.Value)).SetColor(getColorFromList(input.Value));
    but.SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(300, 300);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);
            selectFromList(vert, generateStructuresList(function(enum)
                input.Value = enum;
                but.SetText(getStructureName(input.Value)).SetColor(getColorFromList(input.Value));
                close();
            end), function() close(); end);
        end);
    end);
end

function getRefreshEventFunc(event, inputs)
    return function()
        saveEvent(event, inputs);
        showModifyEvent(event);
    end
end


function selectTriggerForAssignment()
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    local select = function(trigger)
        selectEventsForAssignment(trigger);
    end
    createTriggerFilter(root, select);
    
    -- First select trigger
    TriggerFilterType = 0;

    CenterObject(root, UI2.LABEL).SetText("Select trigger").SetColor(colors.TextColor);
    showTriggers(root, select);
end

function selectEventsForAssignment(trigger, events)
    events = events or {};   
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    local reqFunc = function(event)
        return (event.CompatibleTriggerType == 0 or trigger.Type == event.CompatibleTriggerType)  and not valueInTable(events, event.ID);
    end
    local vert;
    local buttons;
    local button;
    local eventSelected;
    eventSelected = function(event)
        table.insert(events, event.ID);
        showEvents(vert, eventSelected, reqFunc);
        button.SetText(#events .. " events");
        buttons.Submit.SetInteractable(#events > 0);
    end

    CreateInfoButtonLine(root, function(line)
        CreateButton(line).SetText(trigger.Name).SetColor(getTriggerTypeColor(trigger.Type));
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateLabel(line).SetText("-->").SetColor(colors.TextColor);
        CreateEmpty(line).SetFlexibleWidth(1);
        button = CreateButton(line).SetText(#events .. " events").SetColor(colors.Green).SetOnClick(function()
            Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
                setMaxSize(400, 500);
                local vert2;
                local reload;
                reload = function()
                    if not UI.IsDestroyed(vert2) then UI.Destroy(vert2); end
                    vert2 = CreateVert(rootParent).SetFlexibleWidth(1);
                    for i, eventID in pairs(events) do
                        local event = Mod.PublicGameData.Events[eventID];
                        CreateDeleteButtonLine(vert2, function(line2)
                            createUpDownButtons(line2, events, i, function()
                                reload();
                            end);
                            CreateButton(line2).SetText(event.Name).SetColor(getEventTypeColor(event.Type)).SetOnClick(function()
                                print(event);
                            end)
                        end, function()
                            table.remove(events, i);
                            reload();
                            showEvents(vert, eventSelected, reqFunc);
                        end);
                    end
                end

                reload();
            end);
        end);
    end, INFO.AssignSelectEvents);

    EventFilterType = 0;

    CenterObject(root, UI2.LABEL).SetText("Select events").SetColor(colors.TextColor);
    
    vert = CreateVert(root).SetFlexibleWidth(1);
    showEvents(vert, eventSelected, reqFunc);

    buttons = CenterMultipleObjects(root, { Submit = UI2.BUTTON, Cancel = UI2.BUTTON }, 0.1);
    buttons.Submit.SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        selectTerrForCustomEvents(trigger, events);
    end).SetInteractable(#events > 0);
    buttons.Cancel.SetText("Go back").SetColor(colors.Red).SetOnClick(selectTriggerForAssignment);
end

function selectTerrForCustomEvents(trigger, events)
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));

    CreateInfoButtonLine(root, function(line)
        CreateButton(line).SetText(trigger.Name).SetColor(getTriggerTypeColor(trigger.Type));
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateLabel(line).SetText("-->").SetColor(colors.TextColor);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText(#events .. " events").SetColor(colors.Green);
    end, INFO.AssignSelectEvents);

    CenterObject(root, UI2.LABEL).SetText("Select territory to assign events").SetColor(colors.TextColor);

    showPickTerritory(root, function(terrDetails)
        assignCustomEvents(trigger, events, terrDetails.ID);
    end)
end

function assignCustomEvents(trigger, events, terrID)
    ---@diagnostic disable-next-line: undefined-field
    Game.SendGameCustomMessage("Updating...", { Type = "AddToTerritoryMap", Trigger = trigger, Events = events, TerrID = terrID}, function(t) end);
    RefreshFunction = showMain;
end

function inspectTerritory(terrDetails)
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    CenterObject(root, UI2.BUTTON).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);

    if terrDetails == nil then
        CreateLabel(root).SetText("Please select a territory to inspect").SetColor(colors.TextColor);
        showPickTerritory(root, function(details)
            inspectTerritory(details)
        end);
    else
        local map = Mod.PublicGameData.TerritoryMap[terrDetails.ID];
        if map ~= nil then
            printTable(map);
            for _, arr in pairs(map) do
                for _, triggerObj in pairs(arr) do
                    local trigger = Mod.PublicGameData.Triggers[triggerObj.TriggerID];
                    CreateButton(root).SetText(trigger.Name).SetColor(getTriggerTypeColor(trigger.Type));
                    for _, eventID in pairs(triggerObj.EventIDs) do
                        local event = Mod.PublicGameData.Events[eventID];
                        local line = CreateHorz(root).SetFlexibleWidth(1);
                        CreateEmpty(line).SetPreferredWidth(40);
                        CreateButton(line).SetText(event.Name).SetColor(getEventTypeColor(event.Type));
                    end
                end
            end
        else
            CreateLabel(root).SetText("There are no triggers/events on this territory").SetColor(colors.TextColor);
        end
    end
end

function showPickTerritory(root, func)
    CreateEmpty(root).SetPreferredHeight(5);
    
    PickedTerr = nil;
    SubmitButton = nil;

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Selected: ").SetColor(colors.TextColor);
    TerrLabel = CreateLabel(line);
    updateTerrPickedLabel();
    
    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    SubmitButton = CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
        CancelClickIntercept = true;
        local details = PickedTerr;
        PickedTerr = nil;
        SubmitButton = nil;
        func(details);
    end).SetInteractable(PickedTerr ~= nil);
    CreateEmpty(line).SetFlexibleWidth(0.45);

    CancelClickIntercept = false;
    UI.InterceptNextTerritoryClick(interceptedTerritoryClick);
end

function interceptedTerritoryClick(terrDetails)
    if terrDetails == nil or CancelClickIntercept or UI.IsDestroyed(GlobalRoot) then return WL.CancelClickIntercept; end
    PickedTerr = terrDetails;
    updateTerrPickedLabel();
    UI.InterceptNextTerritoryClick(interceptedTerritoryClick);
end

function updateTerrPickedLabel()
    if PickedTerr then
        TerrLabel.SetText(PickedTerr.Name).SetColor(colors.Green);
        if SubmitButton ~= nil then
            SubmitButton.SetInteractable(true);
        end
    else
        TerrLabel.SetText("None").SetColor(colors.Yellow);
        if SubmitButton ~= nil then
            SubmitButton.SetInteractable(false);
        end
    end
end

function showModifySlots(trigger, field, returnFunc)
    DestroyWindow()
    
    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    trigger[field] = trigger[field] or {};
    
    CenterObject(root, UI2.BUTTON).SetText("Return").SetColor(colors.Orange).SetOnClick(returnFunc);
    CenterObject(root, UI2.LABEL).SetText("Modify slots").SetColor(colors.TextColor);

    local slotInput = CenterObject(root, UI2.TEXT_INPUT).SetPlaceholderText("Slot name").SetPreferredWidth(300);
    CenterObject(root, UI2.BUTTON).SetText("Add slot").SetColor(colors.Green).SetOnClick(function()
        local slotName = string.upper(slotInput.GetText());
        if validateSlotName(slotName) then
            local slot = getSlotIndex(slotName);
            if not valueInTable(trigger[field], slot) then
                table.insert(trigger[field], getSlotIndex(slotName));
                showModifySlots(trigger, field, returnFunc);
            else
                UI.Alert("Slot " .. slotName .. " is already included");
            end
        else
            UI.Alert(INFO.SlotNameFormat);
        end
    end)

    CreateEmpty(root).SetPreferredHeight(10);
    
    if #trigger[field] > 0 then
        local objs = {};
        CreateLabel(root).SetText("Slots included:").SetColor(colors.TextColor);
        for i = #trigger[field], 1, -3 do
            local t;
            if i > 2 then
                t = CenterMultipleObjects(root, {[i] = UI2.BUTTON, [i - 1] = UI2.BUTTON, [i - 2] = UI2.BUTTON}, 0.1);
                for k, v in pairs(t) do
                    objs[k] = v;
                end
            elseif i == 2 then
                t = CenterMultipleObjects(root, {[i] = UI2.BUTTON, [i - 1] = UI2.BUTTON}, 0.2);
                for k, v in pairs(t) do
                    objs[k] = v;
                end
            elseif i == 1 then
                objs[1] = CenterObject(root, UI2.BUTTON);
            end
        end
        for i, obj in ipairs(objs) do
            local slot = trigger[field][i];
            obj.SetText(getSlotName(slot)).SetColor(getColorFromList(slot)).SetOnClick(function()
                table.remove(trigger[field], i);
                showModifySlots(trigger, field, returnFunc);
            end);
        end
    end
end

function showModifyStructureMinimum(root, trigger, inputs, field, struct, structName)
    inputs[field] = inputs[field] or {};
    local input = inputs[field][struct] or {};
    local t = trigger[field][struct];
    if t.Minimum then
        CreateInfoButtonLine(root, function(line)
            CreateLabel(line).SetText("Minimum number of " .. structName).SetColor(colors.TextColor);
        end, replaceStructWord(getStructuresInfoText(field).Maximum, structName));
        CreateDeleteButtonLine(root, function(line)
            input.Minimum = CreateNumberInputField(line).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(t.Minimum);
        end, function()
            saveTrigger(trigger, inputs);
            t.Minimum = nil;
            if t.Maximum == nil then
                t = nil;
            end
            trigger[field][struct] = t;
            showModifyTrigger(trigger);
        end);
    end
    inputs[field][struct] = input;
end

function showModifyStructureMaximum(root, trigger, inputs, field, struct, structName)
    inputs[field] = inputs[field] or {};
    local input = inputs[field][struct] or {};
    local t = trigger[field][struct];
    if trigger[field][struct].Maximum then
        CreateInfoButtonLine(root, function(line)
            CreateLabel(line).SetText("Maximum number of " .. structName).SetColor(colors.TextColor);
        end, replaceStructWord(getStructuresInfoText(field).Maximum, structName));
        CreateDeleteButtonLine(root, function(line)
            input.Maximum = CreateNumberInputField(line).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(t.Maximum);
        end, function()
            saveTrigger(trigger, inputs);
            t.Maximum = nil;
            if t.Minimum == nil then
                t = nil;
            end
            trigger[field][struct] = t;
            showModifyTrigger(trigger);
        end);
    end
    inputs[field][struct] = input;
end


function showModifyStructures(trigger, inputs, field, returnFunc)
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local info = getStructuresInfoText(field);
    trigger[field] = trigger[field] or {};

    CenterObject(root, UI2.BUTTON).SetText("Return").SetColor(colors.Orange).SetOnClick(function()
        saveStructures(trigger, field, inputs);
        returnFunc()
    end);
    CenterObject(root, UI2.LABEL).SetText("Modify Structures").SetColor(colors.TextColor);

    for struct, enum in pairs(WL.StructureType) do
        if struct ~= "ToString" then
            local name = getReadableString(struct);
            if trigger[field][struct] ~= nil then
                if trigger[field][struct].Minimum ~= nil then
                    showModifyStructureMinimum(root, trigger, inputs, field, struct, name);
                end
                if trigger[field][struct].Maximum ~= nil then
                    showModifyStructureMaximum(root, trigger, inputs, field, struct, name);
                end
            end
        end
    end

    CenterObject(root, UI2.BUTTON).SetText("Add structure condition").SetColor(colors.Blue).SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            setMaxSize(500, 400);
            local vert = CreateVert(rootParent).SetFlexibleWidth(1);

            local list = {};
            for struct, enum in pairs(WL.StructureType) do
                if struct ~= "ToString" then
                    local name = getReadableString(struct);
                    list[#list + 1] = (trigger[field] ~= nil or trigger[field][struct] ~= nil or trigger[field][struct].Minimum ~= nil) and {
                        Name = "Minimum number of " .. name .. "s";
                        Action = function()
                            saveStructures(trigger, field, inputs);
                            trigger[field] = trigger[field] or {};
                            trigger[field][struct] = trigger[field][struct] or {};
                            trigger[field][struct].Minimum = 1;
                            showModifyStructures(trigger, inputs, field, returnFunc);
                            close();
                        end;
                        Info = replaceStructWord(info.Minimum, name);
                    } or nil;
                    list[#list + 1] = (trigger[field] ~= nil or trigger[field][struct] ~= nil or trigger[field][struct].Maximum ~= nil) and {
                        Name = "Maximum number of " .. name .. "s";
                        Action = function()
                            saveStructures(trigger, field, inputs);
                            trigger[field] = trigger[field] or {};
                            trigger[field][struct] = trigger[field][struct] or {};
                            trigger[field][struct].Maximum = 1;
                            showModifyStructures(trigger, inputs, field, returnFunc);
                            close();
                        end;
                        Info = replaceStructWord(info.Maximum, name);
                    } or nil;
                end
            end
            selectFromList(vert, list, function() close(); end);
        end)
    end);
end

function saveStructures(trigger, field, inputs)
    for enum, data in pairs(inputs[field] or {}) do
        trigger[field][enum] = trigger[field][enum] or {};
        if data.Minimum then trigger[field][enum].Minimum = data.Minimum.GetValue(); end
        if data.Maximum then trigger[field][enum].Maximum = data.Maximum.GetValue(); end
    end
end

function countStructureConditions(cons)
    local c = 0;
    for _, t in pairs(cons) do
        if t.Minimum ~= nil then c = c + 1; end
        if t.Maximum ~= nil then c = c + 1; end
    end
    return c;
end

function CreateConfirmPage(text, func)
    Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
        local root = CreateVert(rootParent).SetFlexibleWidth(1);
        CreateLabel(root).SetText(text).SetColor(colors.TextColor);

        local buttons = CenterMultipleObjects(root, { Yes = UI2.BUTTON, No = UI2.BUTTON }, 0.1);
        buttons.Yes.SetText("Yes").SetColor(colors.Green).SetOnClick(function()
            func();
            close();
        end);
        buttons.No.SetText("No").SetColor(colors.Red).SetOnClick(function()
            close();
        end)
    end);
end


function printTable(t, s)
    s = s or "";
    for k, v in pairs(t) do
        print(s .. k .. " = " .. tostring(v));
        if type(v) == "table" then
            printTable(v, s .. "  ");
        end
    end
end