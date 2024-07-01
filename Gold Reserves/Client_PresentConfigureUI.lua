require("Annotations");
require("UI");
require("Util")

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    if not WL.IsVersionOrHigher or not WL.IsVersionOrHigher("5.26.1") then 
        UI.Alert("You must use a newer version of the game to be able to use this mod!");
        return;
    end
	Init(rootParent);
    root = GetRoot();
    colors = GetColors();

    config = Mod.Settings.Config;
    defaultReserveValue = Mod.Settings.DefaultReserve;
    if config == nil then config = {}; end
    if defaultReserveValue == nil then defaultReserveValue = 0; end
    sliders = {};
    labels = {};

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    CreateButton(root).SetText("Add slot").SetColor(colors.Green).SetOnClick(function() addSlotConfig(); end);
    CreateLabel(root).SetText("Default value when creating new slot reserve").SetColor(colors.TextColor);
    defaultReserve = CreateNumberInputField(root).SetSliderMinValue(-100).SetSliderMaxValue(100).SetValue(defaultReserveValue);

    CreateEmpty(root).SetPreferredHeight(10);

    for slot, _ in pairs(config) do
        local vert;
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateButton(line).SetText(getSlotName(slot)).SetColor(getSlotColor(slot)).SetOnClick(function()
            if sliders[slot] then
                saveSliders();
                UI.Destroy(sliders[slot]);
                sliders[slot] = nil;
            else
                showSlotNumberSlider(vert, slot, config[slot]);
            end
        end);
        CreateEmpty(line).SetFlexibleWidth(0.2);
        labels[slot] = CreateLabel(line).SetText(getReserveText(config[slot])).SetColor(getReserveTextColor(config[slot]));
        CreateEmpty(line).SetFlexibleWidth(0.8);
        CreateButton(line).SetText("X").SetColor(colors["Orange Red"]).SetOnClick(function()
            config[slot] = nil;
            sliders[slot] = nil;
            labels[slot] = nil;
            saveSliders();
            showMain();
        end)
        vert = CreateVert(root).SetFlexibleWidth(1);
        if sliders[slot] ~= nil then
            showSlotNumberSlider(vert, slot, config[slot]);
        end
    end
end

function showSlotNumberSlider(vert, slot, reserve)
    sliders[slot] = CreateNumberInputField(vert).SetSliderMinValue(-100).SetSliderMaxValue(100).SetValue(reserve);
end

function saveSliders()
    defaultReserveValue = defaultReserve.GetValue();
    for slot, slider in pairs(sliders) do
        config[slot] = slider.GetValue();
        setSlotLabel(slot);
    end
end

function setSlotLabel(slot)
    if labels[slot] ~= nil then
        labels[slot].SetText(getReserveText(config[slot])).SetColor(getReserveTextColor(config[slot]));
    end
end

function addSlotConfig()
    saveSliders();
    DestroyWindow();
    SetWindow("AddSlotConfig");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Slot ").SetColor(colors.TextColor);
    local textInput = CreateTextInputField(line).SetPlaceholderText("Slot name").SetFlexibleWidth(1);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Create").SetColor(colors.Green).SetOnClick(function() 
        local s = textInput.GetText();
        if validateSlotName(s) then
            local slot = getSlotIndex(s);
            if config[slot] == nil then
                config[slot] = defaultReserveValue;
                sliders[slot] = 0;
            end
            showMain();
        else 
            UI.Alert("The slot name must consist out of only capitalized letters");
        end
    end)
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Cancel").SetColor(colors["Orange Red"]).SetOnClick(showMain)
    CreateEmpty(line).SetFlexibleWidth(0.45);
end