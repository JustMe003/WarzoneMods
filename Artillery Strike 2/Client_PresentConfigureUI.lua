require("UI");
require("Util");

function Client_PresentConfigureUI(rootParent)
	Init(rootParent);


    artilleryList = Mod.Settings.Artillery
    if artilleryList == nil then artilleryList = {}; end
    placements = Mod.Settings.ArtilleryPlacements;
    if placements == nil then placements = ""; end

    root = GetRoot().SetFlexibleWidth(1);
    colors = GetColors();
    local line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
    UI.CreateEmpty(line).SetFlexibleWidth(0.5);
    UI.CreateLabel(line).SetText("Mod Author:  ").SetColor(colors.TextColor);
    UI.CreateLabel(line).SetText("  Just_A_Dutchman_").SetColor(colors.Lime);
    UI.CreateEmpty(line).SetFlexibleWidth(0.5);

    UI.CreateEmpty(root).SetPreferredHeight(10);

    showMain();
end

function showMain()
    DestroyWindow(GetCurrentWindow(), true);
    SetWindow("Main");


    local line = CreateHorz(root);
    CreateButton(line).SetText("Add Artillery").SetColor(colors.Lime).SetOnClick(function()
        table.insert(artilleryList, initNewArtillery());
        modifyArtillery(artilleryList[#artilleryList]);
    end).SetInteractable(#artilleryList < 5);
    CreateButton(line).SetText("Change combat order").SetColor(colors["Royal Blue"]).SetOnClick(changeCombatOrder);
    CreateButton(line).SetText("Set Artillery positions").SetColor(colors.Yellow).SetOnClick(setArtilleryPlacements);
    
    CreateEmpty(root).SetPreferredHeight(10);

    for _, artillery in pairs(artilleryList) do
        CreateButton(root).SetText(artillery.Name).SetColor(artillery.Color).SetOnClick(function() modifyArtillery(artillery); end);
    end
end

function modifyArtillery(artillery)
    DestroyWindow(GetCurrentWindow(), true);
    SetWindow("modifyArtillery");

    artilleryInputs = {};
    currentArtillery = artillery.ID;

    CreateButton(root).SetOnClick(function() saveArtillery(artillery, artilleryInputs); showMain(); end).SetColor(colors.Orange).SetText("Return");

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Artillery name: ").SetColor(colors.TextColor);
    artilleryInputs.Name = CreateTextInputField(line).SetText(artillery.Name).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The name of an artillery unit can be used to differentiate between the different artillery units");
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Artillery color: ").SetColor(colors.TextColor);
    CreateButton(line).SetText(artillery.ColorName).SetColor(artillery.Color).SetOnClick(function() if #artilleryList < 5 then saveArtillery(artillery, artilleryInputs); changeColor(artillery); else UI.Alert("To pick a different color for '" .. artilleryInputs.Name.GetText() .. "', you must first delete another artillery. You can at most have 5 artilleryList, all with distinct colors") end end);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The color of an artillery unit can be used to differentiate between the different artillery units");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    local generalCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(true);
    local generalLabel = CreateLabel(line).SetText("Hide general settings").SetColor(colors.Tan);
    local vertGeneral = CreateVert(root).SetFlexibleWidth(1);
    generalSettings(artillery, vertGeneral, artilleryInputs);

    line = CreateHorz(root).SetFlexibleWidth(1);
    local healthAndDamageCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(true);
    local healthAndDamageLabel = CreateLabel(line).SetText("Hide health and damage settings").SetColor(colors.Tan);
    local vertHealthAndDamage = CreateVert(root).SetFlexibleWidth(1);
    healthAndDamage(artillery, vertHealthAndDamage, artilleryInputs);

    line = CreateHorz(root).SetFlexibleWidth(1);
    local artilleryStrikeCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(true);
    local artilleryStrikeLabel = CreateLabel(line).SetText("Hide artillery strike settings").SetColor(colors.Tan);
    local vertArtilleryStrike = CreateVert(root);
    artilleryStrikeSettings(artillery, vertArtilleryStrike, artilleryInputs);

    line = CreateHorz(root).SetFlexibleWidth(1);
    local otherCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(true);
    local otherLabel = CreateLabel(line).SetText("Hide permissions").SetColor(colors.Tan);
    local vertOther = CreateVert(root).SetFlexibleWidth(1);
    permissionsSettings(artillery, vertOther, artilleryInputs);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Save and Return").SetColor(colors.Green).SetOnClick(function() saveArtillery(artillery, artilleryInputs); showMain(); end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("Remove Artillery").SetColor(colors["Orange Red"]).SetOnClick(function() saveArtillery(artillery, artilleryInputs); removeArtillery(artillery); end)
    CreateEmpty(line).SetFlexibleWidth(0.45);

    generalCheckBox.SetOnValueChanged(function()
        if generalLabel.GetText():sub(1, 4) == "Show" then
            generalLabel.SetText("Hide" .. generalLabel.GetText():sub(5, -1));
            generalSettings(artillery, vertGeneral, artilleryInputs);
        else
            generalLabel.SetText("Show" .. generalLabel.GetText():sub(5, -1));
            saveArtillery(artillery, artilleryInputs);
            DestroyWindow("generalSettings", false);
        end
    end);
    healthAndDamageCheckBox.SetOnValueChanged(function()
        if healthAndDamageLabel.GetText():sub(1, 4) == "Show" then
            healthAndDamageLabel.SetText("Hide" .. healthAndDamageLabel.GetText():sub(5, -1));
            healthAndDamage(artillery, vertHealthAndDamage, artilleryInputs);
        else
            healthAndDamageLabel.SetText("Show" .. healthAndDamageLabel.GetText():sub(5, -1));
            saveArtillery(artillery, artilleryInputs);
            DestroyWindow("healthAndDamage", false);
        end
    end);
    artilleryStrikeCheckBox.SetOnValueChanged(function()
        if artilleryStrikeLabel.GetText():sub(1, 4) == "Show" then
            artilleryStrikeLabel.SetText("Hide" .. artilleryStrikeLabel.GetText():sub(5, -1));
            artilleryStrikeSettings(artillery, vertArtilleryStrike, artilleryInputs);
        else
            artilleryStrikeLabel.SetText("Show" .. artilleryStrikeLabel.GetText():sub(5, -1));
            saveArtillery(artillery, artilleryInputs);
            DestroyWindow("artilleryStrike", false);
        end
    end)
    otherCheckBox.SetOnValueChanged(function()
        if otherLabel.GetText():sub(1, 4) == "Show" then
            otherLabel.SetText("Hide" .. otherLabel.GetText():sub(5, -1));
            permissionsSettings(artillery, vertOther, artilleryInputs);
        else
            otherLabel.SetText("Show" .. otherLabel.GetText():sub(5, -1));
            saveArtillery(artillery, artilleryInputs);
            DestroyWindow("permissionsSettings", false);
        end
    end);
end


function generalSettings(artillery, root, inputs)
    local win = "generalSettings";
    local parent = GetCurrentWindow();
    DestroyWindow(win, false);
    AddSubWindow(parent, win);
    SetWindow(win);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(25).SetFlexibleWidth(0);
    vert = CreateVert(line).SetFlexibleWidth(1);


    CreateEmpty(vert).SetPreferredHeight(10);
    local line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("General").SetColor(colors.Orange);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);

    line = CreateHorz(vert).SetFlexibleWidth(1);
    inputs.CanBeBought = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.CanBeBought);
    CreateLabel(line).SetText("This artillery can be purchased with gold").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, all players will be able to buy this artillery unit if they can afford it. If not checked, the only way to acquire this unit is by getting it at the start of the game, or from other players")

    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The cost of this artillery").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The amount of gold this artillery can be bought for")
    inputs.Cost = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(artillery.Cost).SetInteractable(inputs.CanBeBought.GetIsChecked());
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The maximum number of this artillery each player may have").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "This sets the limit of units a player might have of this artillery type. If they have reached this limit, they cannot buy more artillery units of this type");
    inputs.MaxNumOfArtillery = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(artillery.MaxNumOfArtillery);

    inputs.CanBeBought.SetOnValueChanged(function() saveArtillery(artillery, inputs); generalSettings(artillery, root, inputs); end)
    SetWindow(parent);
end

function healthAndDamage(artillery, root, inputs)
    local win = "healthAndDamage";
    local parent = GetCurrentWindow();
    AddSubWindow(parent, win);
    DestroyWindow(win, false);
    SetWindow(win);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(25).SetFlexibleWidth(0);
    vert = CreateVert(line).SetFlexibleWidth(1);

    CreateEmpty(vert).SetPreferredHeight(10);
    local line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Health and Damage").SetColor(colors.Orange);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);

    line = CreateHorz(vert).SetFlexibleWidth(1);
    inputs.UseHealth = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.UseHealth);
    CreateLabel(line).SetText("Use dynamic health").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, any damage that is done to this artillery modifies the amount of health it has. If not checked, damage done to the unit does not modify the amount of health it has, resulting in that this unit must be killed in one attack")
    
    if artillery.UseHealth then
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The initial health of this artillery").SetColor(colors.TextColor);
        CreateEmpty(line).SetFlexibleWidth(1);
        createInfoButton(line, "The starting health of this artillery unit")
        inputs.Health = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(artillery.Health);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        inputs.DynamicDefencePower = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.DynamicDefencePower).SetOnValueChanged(function() saveArtillery(artillery, inputs); healthAndDamage(artillery, root, inputs); end);
        CreateLabel(line).SetText("Use the Artillery's health as defense power")
        CreateEmpty(line).SetFlexibleWidth(1);
        createInfoButton(line, "If checked, the mod will update these units when they receive damage from an attack, to set the defense power of the artillery unit equal to the amount of health it has remaining. If unchecked, you are opted to set a fixed defense power");
        
        if not artillery.DynamicDefencePower then
            line = CreateHorz(vert).SetFlexibleWidth(1);
            CreateLabel(line).SetText("The defense power of the Artillery").SetColor(colors.TextColor);
            CreateEmpty(line).SetFlexibleWidth(1);
            createInfoButton(line, "The fixed defense power of this artillery unit");
            inputs.DefensePower = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(artillery.DefensePower);
        end
        
    else
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The number of damage points it takes to kill this artillery").SetColor(colors.TextColor)
        CreateEmpty(line).SetFlexibleWidth(1);
        createInfoButton(line, "The amount of damage this unit needs to reveice to be killed. This damage amount has to be dealt in one attack")
        inputs.DamageToKill = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(artillery.DamageToKill);
        
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("When this artillery takes damage, it will reduce the amount of damage remaining to other units on this territory by this value").SetColor(colors.TextColor)
        CreateEmpty(line).SetFlexibleWidth(1);
        createInfoButton(line, "When the unit dies, and this value is bigger than 0, it will subtract this value from the remaining damage that still has to be applied to the other armies / units")
        inputs.DamageAbsorbedWhenAttacked = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(artillery.DamageAbsorbedWhenAttacked);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The defense power of the Artillery").SetColor(colors.TextColor);
        createInfoButton(line, "The fixed defense power of this artillery unit");
        inputs.DefensePower = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(artillery.DefensePower);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The attack power of the Artillery").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The fixed attack power of this artillery unit");
    inputs.AttackPower = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(artillery.AttackPower);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The attack modifier of the Artillery (percentage)").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "When this unit participates in an attack, it boosts the total damage done by this value. 0 means no boost at all, negative values reduces the damage done and positive values boosts the damage done");
    inputs.AttackPowerPercentage = CreateNumberInputField(vert).SetWholeNumbers(false).SetSliderMinValue(-100).SetSliderMaxValue(100).SetValue(artillery.AttackPowerPercentage)
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The defense modifier of the Artillery (percentage)").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "When this unit participates in a defense, it boosts the total damage done by this value. 0 means no boost at all, negative values reduces the damage done and positive values boosts the damage done");
    inputs.DefensePowerPercentage = CreateNumberInputField(vert).SetWholeNumbers(false).SetSliderMinValue(-100).SetSliderMaxValue(100).SetValue(artillery.DefensePowerPercentage)

    inputs.UseHealth.SetOnValueChanged(function() saveArtillery(artillery, artilleryInputs); healthAndDamage(artillery, root, artilleryInputs); end);
    SetWindow(parent);
end

function artilleryStrikeSettings(artillery, root, inputs)
    local win = "artilleryStrike";
    local parent = GetCurrentWindow();
    AddSubWindow(parent, win);
    DestroyWindow(win, false);
    SetWindow(win);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(25).SetFlexibleWidth(0);
    vert = CreateVert(line).SetFlexibleWidth(1);

    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Artillery Strike").SetColor(colors.Orange);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);

    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.UsingCostGold = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.UsingCostGold);
    CreateLabel(line).SetText("Firing an artillery of this type cost gold").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "When a player orders this unit to artillery strike a target, they'll need to pay some gold");
    
    if artillery.UsingCostGold then
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The cost of firing this type of artillery gun").SetColor(colors.TextColor);
        CreateEmpty(line).SetFlexibleWidth(1);
        createInfoButton(line, "The amount of gold a player has to pay to use this unit in an artillery strike");
        artilleryInputs.UseCost = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(25).SetValue(artillery.UseCost);
    end

    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.DealsPercentageDamage = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.DealsPercentageDamage);
    CreateLabel(line).SetText("damage is in percentages").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, the damage dealt is a percentage of the total number of armies on the target territory, just like the bomb cards removes 50% of armies from its target territory. If not checked, the damage done by this unit in an artillery strike is fixed");
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Mininum damage done").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The minimum damage that will be done by this unit in an artillery strike. The final damage is determined by rolling a random number between the minimum and maximum damage");
    artilleryInputs.MinimumDamage = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(artillery.MinimumDamage).SetWholeNumbers(not artillery.DealsPercentageDamage);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Maximum damage done").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The maximum damage that will be done by this unit in an artillery strike. The final damage is determined by rolling a random number between the minimum and maximum damage")
    artilleryInputs.MaximumDamage = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(artillery.MaximumDamage).SetWholeNumbers(not artillery.DealsPercentageDamage);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Maximum range of artillery").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "This value determines how far this unit can target territories. Setting this value to 1 means that it can only target territories directly bordering it. Note that setting this value to a high value will likely result in long load times!");
    artilleryInputs.MaximumRange = CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(25).SetValue(artillery.MaximumRange);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The chance of missing the target territory").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The chance to miss the target territory. Setting this value to 25 means that approximately 25% of artillery strikes will miss the target territory. When a artillery 'misses' the target territory, they will instead inflict damage to one of the neighbouring territories.")
    artilleryInputs.MissPercentage = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(100).SetValue(artillery.MissPercentage).SetWholeNumbers(false);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Reload duration").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "The amount of turns it takes to reload the artillery unit again. When an artillery is reloading, it cannot be used in another artillery strike and it cannot be moved.");
    artilleryInputs.ReloadDuration = CreateNumberInputField(vert).SetSliderMinValue(0).SetSliderMaxValue(5).SetValue(artillery.ReloadDuration);

    artilleryInputs.UsingCostGold.SetOnValueChanged(function()
        saveArtillery(artillery, artilleryInputs);
        artilleryStrikeSettings(artillery, root, artilleryInputs);
    end)
    artilleryInputs.DealsPercentageDamage.SetOnValueChanged(function()
        saveArtillery(artillery, artilleryInputs);
        artilleryStrikeSettings(artillery, root, artilleryInputs);
    end)
    SetWindow(parent);
end

function permissionsSettings(artillery, root, inputs)
    local win = "permissionsSettings";
    local parent = GetCurrentWindow();
    AddSubWindow(parent, win);
    DestroyWindow(win, false);
    SetWindow(win);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(25).SetFlexibleWidth(0);
    vert = CreateVert(line).SetFlexibleWidth(1);

    CreateEmpty(vert).SetPreferredHeight(10);
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Permissions").SetColor(colors.Orange);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);

    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.IsVisibleToAllPlayers = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.IsVisibleToAllPlayers);
    CreateLabel(line).SetText("This artillery is always visible for every player").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, everyone will get full vision on the territory the artillery unit is located at all times");
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.CanBeAirliftedToSelf = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.CanBeAirliftedToSelf);
    CreateLabel(line).SetText("Players can airlift this artillery").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, players can airlift this artillery unit to themselves. If players are allowed to transfer this unit to teammates and they are allowed to airlift them, they can also be airlifted to teammates. If not checked, this unit cannot be airlifted. ");
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.CanBeTransferredToTeammate = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.CanBeTransferredToTeammate);
    CreateLabel(line).SetText("Players can transfer this artillery to teammates").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, players can transfer this unit to teammates. If players are allowed to transfer this unit to teammates and they are allowed to airlift them, they can also be airlifted to teammates. If not checked, this unit cannot be transfered to teammates")
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.CanBeGiftedWithGiftCard = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.CanBeGiftedWithGiftCard);
    CreateLabel(line).SetText("Players can gift this artillery to other players").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, this unit can be gifted to other players. If not checked, it will prevent the territory it is located from being gifted")
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    artilleryInputs.IncludeABeforeName = CreateCheckBox(line).SetText(" ").SetIsChecked(artillery.IncludeABeforeName);
    CreateLabel(line).SetText("automatically put the word 'A' before the name of this artillery").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    createInfoButton(line, "If checked, Warzone will put 'A' before the name of the artillery");
    
    SetWindow(parent);
end

function removeArtillery(artillery)
    DestroyWindow();
    SetWindow("removeArtillery");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Are you sure you want to remove this artillery?").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    CreateButton(line).SetText("Yes").SetColor(colors.Green).SetOnClick(function() table.remove(artilleryList, artillery.ID); for i, artillery in ipairs(artilleryList) do artillery.ID = i; end; showMain(); end);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    CreateButton(line).SetText("No").SetColor(colors.Red).SetOnClick(function() modifyArtillery(artillery); end);
    CreateEmpty(line).SetFlexibleWidth(0.45);

    CreateEmpty(root).SetFlexibleHeight(1);
end

function changeColor(artillery)
    DestroyWindow();
    SetWindow("modifyArtillery");

    local c = {Blue=colors.Blue, Green=colors.Green, Red=colors.Red, Yellow=colors.Yellow, White=colors.Ivory};
    CreateLabel(root).SetText("Pick the color you want").SetColor(colors.TextColor);
    for _, d in pairs(artilleryList) do
        if d ~= artillery then
            c[d.ColorName] = nil;
        end
    end
    for name, color in pairs(c) do
        CreateButton(root).SetText(name).SetColor(color).SetOnClick(function() artillery.Color = color; artillery.ColorName = name; modifyArtillery(artillery); end)
    end
end

function setArtilleryPlacements()
    DestroyWindow();
    SetWindow("setArtilleryPlacements");

    artilleryPlacementsInputs = CreateTextInputField(root).SetText(placements).SetPlaceholderText("Paste here the Artillerys placement data").SetFlexibleWidth(1);
    CreateLabel(root).SetText("You can automatically place Artillery at the start of the game using the in-game territory selector and this input above\nPaste the data generated by the mod when you have placed all the Artillerys into the text field above")
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(function() savePlacement(); showMain(); end);
end

function changeCombatOrder()
    DestroyWindow()
    SetWindow("changeCombatOrder");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    CreateEmpty(root).SetPreferredHeight(5);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Combat order").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);

    CreateEmpty(root).SetPreferredHeight(10);
    CreateLabel(root).SetText("The combat order is very important, although you don't notice it often. It determines the order in which special units take damage. Different configurations can have very different outcomes in an attack").SetColor(colors.TextColor);
    CreateEmpty(root).SetPreferredHeight(5);

    if #artilleryList > 0 then
        CreateLabel(root).SetText("This artillery takes damage first").SetColor(colors.TextColor);
        local arr = {};
        local bool = false;
        for k, artillery in pairs(artilleryList) do
            if #arr == 0 then
                table.insert(arr, artillery);
            else
                bool = false;
                for i, artillery2 in pairs(arr) do
                    if artillery.CombatOrder < artillery2.CombatOrder then
                        table.insert(arr, i, artillery);
                        bool = true;
                        break;
                    end
                end
                if not bool then
                    table.insert(arr, artillery);
                end
            end
        end
        for i, artillery in pairs(arr) do
            local line = CreateHorz(root);
            CreateButton(line).SetText("up").SetColor(colors.Aqua).SetOnClick(function() if artillery.CombatOrder > 0 then artillery.CombatOrder = artillery.CombatOrder - 1; arr[i - 1].CombatOrder = arr[i - 1].CombatOrder + 1; changeCombatOrder(); end; end);
            CreateButton(line).SetText("down").SetColor(colors.Aqua).SetOnClick(function() if artillery.CombatOrder < #artilleryList - 1 then artillery.CombatOrder = artillery.CombatOrder + 1; arr[i + 1].CombatOrder = arr[i + 1].CombatOrder - 1; changeCombatOrder(); end; end);
            CreateLabel(line).SetText(i .. ". ").SetColor(colors.TextColor);
            CreateLabel(line).SetText(artillery.Name).SetColor(artillery.Color);
        end
        CreateLabel(root).SetText("This artillery takes damage last").SetColor(colors.TextColor);
    else
        CreateLabel(root).SetText("Create a artillery first to change the combat order of this unit")
    end
end

function saveArtillery(artillery, inputs)
    if artillery == nil then return; end
    local id = artillery.ID;
    if artilleryList[id] == nil then return; end
    if inputs.Name ~= nil then artilleryList[id].Name = inputs.Name.GetText(); end
    if inputs.IsVisibleToAllPlayers ~= nil then artilleryList[id].IsVisibleToAllPlayers = inputs.IsVisibleToAllPlayers.GetIsChecked(); end
    if inputs.CanBeAirliftedToSelf ~= nil then artilleryList[id].CanBeAirliftedToSelf = inputs.CanBeAirliftedToSelf.GetIsChecked(); end
    if inputs.CanBeGiftedWithGiftCard ~= nil then artilleryList[id].CanBeGiftedWithGiftCard = inputs.CanBeGiftedWithGiftCard.GetIsChecked(); end
    if inputs.IncludeABeforeName ~= nil then artilleryList[id].IncludeABeforeName = inputs.IncludeABeforeName.GetIsChecked(); end
    if inputs.UseHealth ~= nil then artilleryList[id].UseHealth = inputs.UseHealth.GetIsChecked(); end
    if inputs.Health ~= nil then artilleryList[id].Health = inputs.Health.GetValue(); end
    if inputs.DynamicDefencePower ~= nil then artilleryList[id].DynamicDefencePower = inputs.DynamicDefencePower.GetIsChecked(); end
    if inputs.DamageAbsorbedWhenAttacked ~= nil then artilleryList[id].DamageAbsorbedWhenAttacked = inputs.DamageAbsorbedWhenAttacked.GetValue(); end
    if inputs.DamageToKill ~= nil then artilleryList[id].DamageToKill = inputs.DamageToKill.GetValue(); end
    if inputs.DefensePower ~= nil then artilleryList[id].DefensePower = inputs.DefensePower.GetValue(); end
    if inputs.AttackPower ~= nil then artilleryList[id].AttackPower = inputs.AttackPower.GetValue(); end
    if inputs.AttackPowerPercentage ~= nil then artilleryList[id].AttackPowerPercentage = inputs.AttackPowerPercentage.GetValue(); end
    if inputs.DefensePowerPercentage ~= nil then artilleryList[id].DefensePowerPercentage = inputs.DefensePowerPercentage.GetValue(); end
    if inputs.CanBeBought ~= nil then artilleryList[id].CanBeBought = inputs.CanBeBought.GetIsChecked(); end
    if inputs.Cost ~= nil then artilleryList[id].Cost = inputs.Cost.GetValue(); end
    if inputs.MaxNumOfArtillery ~= nil then artilleryList[id].MaxNumOfArtillery = inputs.MaxNumOfArtillery.GetValue(); end
    if inputs.CanBeTransferredToTeammate ~= nil then artilleryList[id].CanBeTransferredToTeammate = inputs.CanBeTransferredToTeammate.GetIsChecked(); end
    if inputs.DealsPercentageDamage ~= nil then artilleryList[id].DealsPercentageDamage = inputs.DealsPercentageDamage.GetIsChecked(); end
    if inputs.MinimumDamage ~= nil then artilleryList[id].MinimumDamage = inputs.MinimumDamage.GetValue(); end
    if inputs.MaximumDamage ~= nil then artilleryList[id].MaximumDamage = inputs.MaximumDamage.GetValue(); end
    if inputs.UsingCostGold ~= nil then artilleryList[id].UsingCostGold = inputs.UsingCostGold.GetIsChecked(); end
    if inputs.UseCost ~= nil then artilleryList[id].UseCost = inputs.UseCost.GetValue(); end
    if inputs.ReloadDuration ~= nil then artilleryList[id].ReloadDuration = inputs.ReloadDuration.GetValue(); end
    if inputs.MaximumRange ~= nil then artilleryList[id].MaximumRange = inputs.MaximumRange.GetValue(); end
    if inputs.MissPercentage ~= nil then artilleryList[id].MissPercentage = inputs.MissPercentage.GetValue(); end
end

function initNewArtillery()
    local t = {};
    t.Name = "Artillery #" .. #artilleryList + 1;
    local c = {colors.Blue, colors.Green, colors.Red, colors.Yellow, colors.Ivory};
    for _, artillery in ipairs(artilleryList) do
        for i, v in ipairs(c) do
            if v == artillery.Color then
                table.remove(c, i);
                break;
            end
        end
    end
    t.Color = c[math.random(#c)];
    t.ColorName = getColorName(t.Color);
    t.IsVisibleToAllPlayers = false;
    t.CanBeAirliftedToSelf = true;
    t.CanBeGiftedWithGiftCard = false;
    t.CanBeTransferredToTeammate = true;
    t.IncludeABeforeName = true;
    t.UseHealth = true;
    t.Health = 20;
    t.DynamicDefencePower = true;
    t.DamageAbsorbedWhenAttacked = 0;
    t.DamageToKill = 10;
    t.AttackPower = 0;
    t.DefensePower = 0;
    t.AttackPowerPercentage = 0;
    t.DefensePowerPercentage = 0;
    t.CanBeBought = true;
    t.Cost = 20;
    t.MaxNumOfArtillery = 3;
    t.ID = #artilleryList + 1;
    t.CombatOrder = #artilleryList;
    t.DealsPercentageDamage = true;
    t.MinimumDamage = 10;
    t.MaximumDamage = 25;
    t.UsingCostGold = false;
    t.UseCost = 10;
    t.ReloadDuration = 1;
    t.MaximumRange = 5;
    t.MissPercentage = 5;
    return t;
end

function savePlacement()
    placements = artilleryPlacementsInputs.GetText();
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