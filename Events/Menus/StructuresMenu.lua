require("Util.Structures");

StructuresMenu = {};

function StructuresMenu.ShowMenu(trigger, inputs, field, returnFunc, infoTable)
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    trigger[field] = trigger[field] or {};
    local structures = trigger[field];

    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(function()
        StructuresMenu.SaveStructures(trigger, field, inputs);
        returnFunc()
    end);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Modify Structures").SetColor(colors.TextColor);

    for struct, _ in pairs(WL.StructureType) do
        if struct ~= "ToString" then
            local name = getReadableString(struct);
            if structures[struct] ~= nil then
                if structures[struct].Minimum ~= nil then
                    StructuresMenu.ShowModifyStructureMinimum(root, trigger, inputs, field, struct, name, infoTable);
                end
                if structures[struct].Maximum ~= nil then
                    StructuresMenu.ShowModifyStructureMaximum(root, trigger, inputs, field, struct, name, infoTable);
                end
            end
        end
    end

    UI2.CreateButton(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Add structure condition").SetColor(colors.Blue).SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("ModifyStructures", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);

            local list = {};
            local index = 1;
            for struct, enum in pairs(WL.StructureType) do
                if struct ~= "ToString" then
                    local name = getReadableString(struct);
                    list[index] = (structures == nil or structures[struct] == nil or structures[struct].Minimum == nil) and {
                        Name = "Minimum number of " .. name .. "s";
                        Action = function()
                            StructuresMenu.SaveStructures(trigger, field, inputs);
                            structures[struct] = structures[struct] or {};
                            structures[struct].Minimum = 1;
                            StructuresMenu.ShowMenu(trigger, inputs, field, returnFunc, infoTable);
                            close();
                        end;
                        Info = replaceStructWord(infoTable.Minimum, name);
                    } or nil;
                    index = index + 1;
                    list[index] = (structures == nil or structures[struct] == nil or structures[struct].Maximum == nil) and {
                        Name = "Maximum number of " .. name .. "s";
                        Action = function()
                            StructuresMenu.SaveStructures(trigger, field, inputs);
                            structures[struct] = structures[struct] or {};
                            structures[struct].Maximum = 1;
                            StructuresMenu.ShowMenu(trigger, inputs, field, returnFunc, infoTable);
                            close();
                        end;
                        Info = replaceStructWord(infoTable.Maximum, name);
                    } or nil;
                    index = index + 1;
                end
            end
            MenuUtil.SelectFromList(vert, list, function() close(); end);
        end)
    end);
end

function StructuresMenu.ShowModifyStructureMinimum(root, trigger, inputs, field, struct, structName, infoTable)
    inputs[field] = inputs[field] or {};
    local input = inputs[field][struct] or {};
    local t = trigger[field][struct];
    if t.Minimum then
        UI2.CreateInfoButtonLine(root, function(line)
            UI2.CreateLabel(line).SetText("Minimum number of " .. structName).SetColor(colors.TextColor);
        end, replaceStructWord(infoTable.Maximum, structName));
        UI2.CreateDeleteButtonLine(root, function(line)
            input.Minimum = UI2.CreateNumberInputField(line).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(t.Minimum);
        end, function()
            TriggerMenu.SaveTrigger(trigger, inputs);
            t.Minimum = nil;
            if t.Maximum == nil then
                t = nil;
            end
            trigger[field][struct] = t;
            TriggerMenu.showTrigger(trigger);
        end);
    end
    inputs[field][struct] = input;
end

function StructuresMenu.ShowModifyStructureMaximum(root, trigger, inputs, field, struct, structName, infoTable)
    inputs[field] = inputs[field] or {};
    local input = inputs[field][struct] or {};
    local t = trigger[field][struct];
    if trigger[field][struct].Maximum then
        UI2.CreateInfoButtonLine(root, function(line)
            UI2.CreateLabel(line).SetText("Maximum number of " .. structName).SetColor(colors.TextColor);
        end, replaceStructWord(infoTable.Maximum, structName));
        UI2.CreateDeleteButtonLine(root, function(line)
            input.Maximum = UI2.CreateNumberInputField(line).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(t.Maximum);
        end, function()
            TriggerMenu.SaveTrigger(trigger, inputs);
            t.Maximum = nil;
            if t.Minimum == nil then
                t = nil;
            end
            trigger[field][struct] = t;
            TriggerMenu.showTrigger(trigger);
        end);
    end
    inputs[field][struct] = input;
end

function StructuresMenu.CountStructureConditions(cons)
    local c = 0;
    for _, t in pairs(cons) do
        if t.Minimum ~= nil then c = c + 1; end
        if t.Maximum ~= nil then c = c + 1; end
    end
    return c;
end

function StructuresMenu.SetStructure(line, input)
    input.Value = input.Value or 0;
    UI2.CreateEmpty(line).SetFlexibleWidth(1);
    local but = UI2.CreateButton(line).SetText(getStructureName(input.Value)).SetColor(MenuUtil.GetColorFromList(input.Value));
    but.SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("SetStructure", rootParent, close);
            setMaxSize(300, 300);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromList(vert, StructuresMenu.GenerateStructuresList(function(enum)
                input.Value = enum;
                but.SetText(getStructureName(input.Value)).SetColor(MenuUtil.GetColorFromList(input.Value));
                close();
            end), function() close(); end);
        end);
    end);
end

function StructuresMenu.GenerateStructuresList(selectFun, blackList)
    blackList = blackList or {};
    local list = {};
    for name, enum in pairs(WL.StructureType) do
        if type(enum) == "string" and not valueInTable(blackList, enum) then
            list[#list + 1] = {
                Name = getReadableString(name),
                Action = function()
                    selectFun(enum);
                end,
                Color = MenuUtil.GetColorFromList(enum);
            };
        end
    end
    return list;
end

function StructuresMenu.SaveStructures(trigger, field, inputs)
    for enum, data in pairs(inputs[field] or {}) do
        trigger[field][enum] = trigger[field][enum] or {};
        if data.Minimum then trigger[field][enum].Minimum = data.Minimum.GetValue(); end
        if data.Maximum then trigger[field][enum].Maximum = data.Maximum.GetValue(); end
    end
end