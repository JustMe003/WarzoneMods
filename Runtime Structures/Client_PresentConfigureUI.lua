require("UI");
require("Util");

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    Init();
    GlobalRoot = CreateVert(rootParent).SetCenter(true);
    colors = GetColors();

    inputs = {};

    config = Mod.Settings.Config or {};

    showMain();
end

function showMain()
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true);

    local line = CreateHorz(root).SetCenter(true);
    CreateLabel(root).SetText("Note that structures will only be added to a random neutral territory").SetColor(colors.TextColor);
    CreateButton(line).SetText("Create Group").SetColor(colors.Green).SetOnClick(createNewGroup);

    CreateEmpty(root).SetPreferredHeight(10);

    for i, group in ipairs(config) do
        local groupLine = CreateHorz(root);
        CreateButton(groupLine).SetText("Select").SetColor(colors.Green).SetOnClick(function()
            showGroupSettings(group);
        end);
        CreateLabel(groupLine).SetText(getGroupText(group)).SetColor(colors.TextColor);
        CreateButton(groupLine).SetText("X").SetColor(colors.Red).SetOnClick(function()
            table.remove(config, i);
            showMain();
        end);
    end
end

function createNewGroup()
    local group = {
        Structures = {},
        Interval = 3,
        Amount = 1
    };
    table.insert(config, group);
    showGroupSettings(group);
end

function showGroupSettings(group)
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true);

    inputs = {
        Group = group;
    };

    local line = CreateHorz(root).SetCenter(true);
    CreateButton(line).SetText("Save").SetColor(colors.Green).SetOnClick(function() 
        saveInputs(inputs);
        showMain();
    end);
    CreateButton(line).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);

    CreateEmpty(root).SetPreferredHeight(10);
    
    CreateLabel(root).SetText("The interval of turns a structure of this group is added").SetColor(colors.TextColor);
    line = CreateHorz(root);
    inputs.Interval = CreateNumberInputField(line).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(group.Interval);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.RoyalBlue).SetOnClick(function()
        UI.Alert("The interval in which a structure of this group will be added to a neutral territory. Setting this to 3 for example, will make the mod add a structure in this group every 3 turns (so turns 3, 6, 9, etc)");
    end);
    
    CreateEmpty(root).SetPreferredHeight(3);

    CreateLabel(root).SetText("The amount of structures to be added").SetColor(colors.TextColor);
    line = CreateHorz(root);
    inputs.Amount = CreateNumberInputField(line).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(group.Amount);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.RoyalBlue).SetOnClick(function()
        UI.Alert("The amount of structures that are added. Note that always only 1 structure type will be added, so this setting determines how many structures of that type will be added.");
    end);

    if #group.Structures > 0 then
        CreateLabel(root).SetText("One of the following structures will be chosen").SetColor(colors.TextColor);
        local structuresMap = getStructuresMap();
        for _, structID in ipairs(group.Structures) do
            local structureLine = CreateHorz(root).SetFlexibleWidth(1);
            CreateButton(structureLine).SetText("X").SetColor(colors.Red).SetOnClick(function()
                UI.Destroy(structureLine);
                local i = 0;
                for k, id in ipairs(group.Structures) do
                    if id == structID then
                        i = k;
                        break;
                    end
                end
                table.remove(group.Structures, i);
            end);
            CreateLabel(structureLine).SetText(structuresMap[structID]).SetColor(colors.TextColor);
        end
    else
        CreateLabel(root).SetText("No structures have been selected yet").SetColor(colors.TextColor);
    end

    CreateButton(root).SetText("Add structure").SetColor(colors.Blue).SetOnClick(function()
        saveInputs(inputs);
        selectStructure(group); 
    end);
end

function selectStructure(group)
    DestroyWindow();
    local root = CreateWindow(CreateVert(GlobalRoot));

    for name, structID in pairs(WL.StructureType) do
        if not valueInTable(group.Structures, structID) then
            CreateButton(root).SetText(name).SetColor(colors.Blue).SetOnClick(function()
                table.insert(group.Structures, structID);
                showGroupSettings(group);
            end);
        end
    end
end

function saveInputs(inputs)
    if inputs and inputs.Group and canReadObject(inputs.Amount) and canReadObject(inputs.Interval) then
        inputs.Group.Interval = inputs.Interval.GetValue();
        inputs.Group.Amount = inputs.Amount.GetValue();
    end
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end


