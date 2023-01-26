require("UI");
function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
    
    dragons = Mod.Settings.Dragons
    if dragons == nil then dragons = {}; end

    root = GetRoot().SetFlexibleWidth(1).SetPreferredHeight(500);
    colors = GetColors();
    showMain();
end

function showMain()
    DestroyWindow(GetCurrentWindow(), true);
    SetWindow("Main");

    for _, dragon in pairs(dragons) do
        CreateButton(root).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() modifyDragon(dragon); end);
    end

    CreateEmpty(root).SetPreferredHeight(10);
    
    CreateButton(root).SetText("Add Dragon").SetColor(colors.Lime).SetOnClick(function() table.insert(dragons, initDragon()); modifyDragon(dragons[#dragons]) end).SetInteractable(#dragons < 5);
end

function modifyDragon(dragon)
    DestroyWindow(GetCurrentWindow(), true);
    SetWindow("modifyDragon");
    
    dragonInputs = {};
    currentDragon = dragon.ID;
    
    CreateButton(root).SetOnClick(function() saveDragon(dragon, dragonInputs); showMain(); end).SetColor(colors.Orange).SetText("Return");
    
    CreateEmpty(root).SetPreferredHeight(10);
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("General").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Dragon name: ").SetColor(colors.Textcolor);
    dragonInputs.Name = CreateTextInputField(line).SetText(dragon.Name).SetFlexibleWidth(1);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Dragon color: ").SetColor(colors.Textcolor);
    CreateButton(line).SetText(dragon.ColorName).SetColor(dragon.Color).SetOnClick(function() if #dragons < 5 then saveDragon(dragon, dragonInputs); changeColor(dragon); else UI.Alert("To pick a different color for '" .. dragonInputs.Name.GetText() .. "', you must first delete another dragon. You can at most have 5 dragons, all with distinct colors") end end);
    
    CreateEmpty(root).SetPreferredHeight(10);
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Health and Damage").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(root).SetPreferredHeight(5);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    dragonInputs.UseHealth = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.UseHealth);
    CreateLabel(line).SetText("Use dynamic health").SetColor(colors.Textcolor);

    local vert = CreateVert(root);
    
    CreateEmpty(root).SetPreferredHeight(10);
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Permissions").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(root).SetPreferredHeight(5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    dragonInputs.DragonBreathAttack = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.DragonBreathAttack);
    CreateLabel(line).SetText("Enable Dragon Breath Attack").SetColor(colors.Textcolor);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    dragonInputs.IsVisibleToAllPlayers = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.IsVisibleToAllPlayers);
    CreateLabel(line).SetText("This dragon is always visible for every player").SetColor(colors.Textcolor);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    dragonInputs.CanBeAirliftedToSelf = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.CanBeAirliftedToSelf);
    CreateLabel(line).SetText("Players can airlift this dragon").SetColor(colors.Textcolor);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    dragonInputs.CanBeGiftedWithGiftCard = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.CanBeGiftedWithGiftCard);
    CreateLabel(line).SetText("Players can gift this dragon to other players").SetColor(colors.Textcolor);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    dragonInputs.IncludeABeforeName = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.IncludeABeforeName);
    CreateLabel(line).SetText("automatically put the word 'A' before the name of this dragon").SetColor(colors.Textcolor);

    dragonInputs.UseHealth.SetOnValueChanged(function() saveDragon(dragon, dragonInputs); healthAndDamage(dragon, vert, dragonInputs) end);
    healthAndDamage(dragon, vert, dragonInputs);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Save and Return").SetColor(colors.Green).SetOnClick(function() saveDragon(dragon, dragonInputs); showMain(); end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Remove Dragon").SetColor(colors["Orange Red"]).SetOnClick(function() saveDragon(dragon, dragonInputs); removeDragon(dragon); end)
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function healthAndDamage(dragon, vert, inputs)
    local win = "healthAndDamage";
    local parent = GetCurrentWindow();
    AddSubWindow(parent, win);
    DestroyWindow(win, false);
    SetWindow(win);

    if dragon.UseHealth then
        CreateLabel(vert).SetText("The initial health of this dragon").SetColor(colors.Textcolor);
        inputs.Health = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(dragon.Health);

        local line = CreateHorz(vert).SetFlexibleWidth(1);
        inputs.DynamicDefencePower = CreateCheckBox(line).SetText(" ").SetIsChecked(dragon.DynamicDefencePower).SetOnValueChanged(function() saveDragon(dragon, inputs); healthAndDamage(dragon, vert, inputs); end);
        CreateLabel(line).SetText("Use the Dragon's health as defence power")
        
        if not dragon.DynamicDefencePower then
            CreateLabel(vert).SetText("The defence power of the Dragon").SetColor(colors.Textcolor);
            inputs.DefensePower = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(dragon.DefensePower);
        end
    
    else
        CreateLabel(vert).SetText("The number of damage points it takes to kill this dragon").SetColor(colors.Textcolor)
        inputs.DamageToKill = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(dragon.DamageToKill);
        CreateLabel(vert).SetText("When this dragon takes damage, it will reduce the amount of damage remaining to other units on this territory by this value").SetColor(colors.Textcolor)
        inputs.DamageAbsorbedWhenAttacked = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(dragon.DamageAbsorbedWhenAttacked);
    end

    CreateLabel(vert).SetText("The attack power of the Dragon").SetColor(colors.Textcolor);
    inputs.AttackPower = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(dragon.AttackPower);

    CreateLabel(vert).SetText("The attack modifier of the Dragon (percentage)").SetColor(colors.Textcolor);
    inputs.AttackPowerPercentage = CreateNumberInputField(vert).SetWholeNumbers(false).SetSliderMinValue(-100).SetSliderMaxValue(100).SetValue(dragon.AttackPowerPercentage)

    CreateLabel(vert).SetText("The defence modifier of the Dragon (percentage)").SetColor(colors.Textcolor);
    inputs.DefensePowerPercentage = CreateNumberInputField(vert).SetWholeNumbers(false).SetSliderMinValue(-100).SetSliderMaxValue(100).SetValue(dragon.DefensePowerPercentage)

    SetWindow(parent);
end

function removeDragon(dragon)
    DestroyWindow();
    SetWindow("removeDragon");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Are you sure you want to remove this dragon?").SetColor(colors.Textcolor);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Yes").SetColor(colors.Green).SetOnClick(function() table.remove(dragons, dragon.ID); showMain(); end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("No").SetColor(colors.Red).SetOnClick(function() modifyDragon(dragon); end);
    CreateEmpty(line).SetFlexibleWidth(0.45);
end

function changeColor(dragon)
    DestroyWindow();
    SetWindow("modifyDragon");

    local c = {Blue=colors.Blue, Green=colors.Green, Red=colors.Red, Yellow=colors.Yellow, White=colors.Ivory};
    CreateLabel(root).SetText("Pick the color you want").SetColor(colors.Textcolor);
    for _, d in pairs(dragons) do
        if d ~= dragon then
            c[d.ColorName] = nil;
        end
    end
    for name, color in pairs(c) do
        CreateButton(root).SetText(name).SetColor(color).SetOnClick(function() dragon.Color = color; dragon.ColorName = name; modifyDragon(dragon); end)
    end
end

function saveDragon(dragon, inputs)
    dragons[dragon.ID].Name = inputs.Name.GetText();
    dragons[dragon.ID].DragonBreathAttack = inputs.DragonBreathAttack.GetIsChecked();
    dragons[dragon.ID].IsVisibleToAllPlayers = inputs.IsVisibleToAllPlayers.GetIsChecked();
    dragons[dragon.ID].CanBeAirliftedToSelf = inputs.CanBeAirliftedToSelf.GetIsChecked();
    dragons[dragon.ID].CanBeGiftedWithGiftCard = inputs.CanBeGiftedWithGiftCard.GetIsChecked();
    dragons[dragon.ID].IncludeABeforeName = inputs.IncludeABeforeName.GetIsChecked();
    dragons[dragon.ID].UseHealth = inputs.UseHealth.GetIsChecked();
    if inputs.Health ~= nil then dragons[dragon.ID].Health = inputs.Health.GetValue(); end
    if inputs.DynamicDefencePower ~= nil then dragons[dragon.ID].DynamicDefencePower = inputs.DynamicDefencePower.GetIsChecked(); end
    if inputs.DefensePower ~= nil then dragons[DefensePower].DefensePower = inputs.DefensePower.GetValue(); end
    if inputs.DamageAbsorbedWhenAttacked ~= nil then dragons[dragon.ID].DamageAbsorbedWhenAttacked = inputs.DamageAbsorbedWhenAttacked.GetValue(); end
    if inputs.DamageToKill ~= nil then dragons[dragon.ID].DamageToKill = inputs.DamageToKill.GetValue(); end
    dragons[dragon.ID].AttackPower = inputs.AttackPower.GetValue();
    dragons[dragon.ID].AttackPowerPercentage = inputs.AttackPowerPercentage.GetValue();
    dragons[dragon.ID].DefensePowerPercentage = inputs.DefensePowerPercentage.GetValue();
end

function initDragon()
    local t = {};
    t.Name = "Dragon #" .. #dragons + 1;
    local c = {colors.Blue, colors.Green, colors.Red, colors.Yellow, colors.Ivory};
    for _, dragon in ipairs(dragons) do
        for i, v in ipairs(c) do
            if v == dragon.Color then
                table.remove(c, i);
            end
        end
    end
    t.Color = c[math.random(#c)];
    t.ColorName = getColorName(t.Color);
    t.DragonBreathAttack = true;
    t.IsVisibleToAllPlayers = false;
    t.CanBeAirliftedToSelf = true;
    t.CanBeGiftedWithGiftCard = false;
    t.IncludeABeforeName = true;
    t.UseHealth = true;
    t.Health = 20;
    t.DynamicDefencePower = true;
    t.DamageAbsorbedWhenAttacked = 10;
    t.DamageToKill = 10;
    t.AttackPower = 10;
    t.AttackPowerPercentage = 0;
    t.DefensePowerPercentage = 0;
    t.ID = #dragons + 1;
    return t;
end

function getColorName(s)
    if s == colors.Blue then
        return "Blue";
    elseif s == colors.Red then
        return "Red";
    elseif s == colors.Green then
        return "Green";
    elseif s == colors.Yellow then
        return "Yellow";
    else
        return "White"
    end
end