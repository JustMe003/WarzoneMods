require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    root = GetRoot();
    colors = GetColors();

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    CreateButton(root).SetText("Show all settings").SetColor(colors.Blue).SetOnClick(showAllSettings);

    CreateEmpty(root).SetPreferredHeight(5);
    CreateLabel(root).SetText("Select a Dragon to see the settings").SetColor(colors.Textcolor);
    for _, dragon in pairs(Mod.Settings.Dragons) do
        CreateButton(root).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() showDragonSettings(dragon); end);
    end
    
    CreateEmpty(root).SetPreferredHeight(5);
    CreateLabel(root).SetText("For the dragon placements, see the mod menu").SetColor(colors.Textcolor);
end

function showDragonSettings(dragon, showAll)
    showAll = showAll or false;
    if not showAll then
        DestroyWindow();
        SetWindow("dragonMain" .. dragon.ID);

        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    end

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Dragon name: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(dragon.Name).SetColor(colors.Tan).SetPreferredWidth(#dragon.Name * 10);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("'" .. dragon.Name .. "' is the name of this particular dragon (species). Together with it's color it will allow you to identify which dragon you're dealing/playing with"); end);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Dragon color: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(dragon.ColorName).SetColor(dragon.Color).SetPreferredWidth(#dragon.Name * 10);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("'" .. dragon.Color .. "' is the color if this dragon icon on the map. Together with the name of this dragon (species) it will allow you to identify which dragon you're dealing/playing with"); end);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local generalCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local generalLabel = CreateLabel(line).SetText("Show general settings");
    local generalVert = CreateVert(root);
    generalCheckBox.SetOnValueChanged(function() if generalCheckBox.GetIsChecked() then showGeneralSettings(dragon, generalVert); generalLabel.SetText("Hide" .. generalLabel.GetText():sub(5, -1)); else DestroyWindow("generalSettings" .. dragon.ID, false); generalLabel.SetText("Show" .. generalLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local healthAndDamageCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local healthAndDamageLabel = CreateLabel(line).SetText("Show health and damage");
    local healthAndDamageVert = CreateVert(root);
    healthAndDamageCheckBox.SetOnValueChanged(function() if healthAndDamageCheckBox.GetIsChecked() then showHealthAndDamage(dragon, healthAndDamageVert); healthAndDamageLabel.SetText("Hide" .. healthAndDamageLabel.GetText():sub(5, -1)); else DestroyWindow("healthAndDamage" .. dragon.ID, false); healthAndDamageLabel.SetText("Show" .. healthAndDamageLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local permissionsCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local permissionsLabel = CreateLabel(line).SetText("Show permissions");
    local permissionsVert = CreateVert(root);
    permissionsCheckBox.SetOnValueChanged(function() if permissionsCheckBox.GetIsChecked() then showPermissions(dragon, permissionsVert); permissionsLabel.SetText("Hide" .. permissionsLabel.GetText():sub(5, -1)); else DestroyWindow("permissions" .. dragon.ID, false); permissionsLabel.SetText("Show" .. permissionsLabel.GetText():sub(5, -1)); end; end)

    if showAll then
        showGeneralSettings(dragon, generalVert);
        showHealthAndDamage(dragon, healthAndDamageVert);
        showPermissions(dragon, permissionsVert);
    end
end

function showGeneralSettings(dragon, root)
    local win = "generalSettings" .. dragon.ID;
    local parent = GetCurrentWindow();
    DestroyWindow(win, false);
    AddSubWindow(parent, win);
    SetWindow(win);
    
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(25).SetFlexibleWidth(0);
    vert = CreateVert(line).SetFlexibleWidth(1);
    
    
    CreateEmpty(vert).SetPreferredHeight(10);
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("General").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("This dragon can be bought: ").SetColor(colors.Textcolor);
    if dragon.CanBeBought then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green).SetPreferredWidth(30);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("Every player alive can buy this dragon (species) during the game"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Price of this dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.Cost).SetColor(colors.Teal).SetPreferredWidth(10 * getNumDigits(dragons.Cost));
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("A '" .. dragon.Name .. "' will cost you " .. dragon.Cost .. " gold to purchase"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The maximum number of dragons a player may have: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.MaxNumOfDragon).SetColor(colors.Teal).SetPreferredWidth(10);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("When a player has " .. dragon.MaxNumOfDragon .. " of these dragons, it can not purchase any more of this type"); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]).SetPreferredWidth(20);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("No player can buy this dragon during the game. The only way to acquire this dragon (species) is to start with one or when one is given to you by another player"); end);
    end
    
    SetWindow(parent);
end

function showHealthAndDamage(dragon, root)
    local win = "healthAndDamage" .. dragon.ID;
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
    CreateLabel(line).SetText("Health and Damage").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("This dragon uses dynamic health: ").SetColor(colors.Textcolor);
    if dragon.UseHealth then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The initial health of this dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.Health).SetColor(colors.Teal);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The defence power always equals the health: ").SetColor(colors.Textcolor);
        if dragon.DynamicDefencePower then
            CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        else
            CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
            
            line = CreateHorz(vert).SetFlexibleWidth(1);
            CreateLabel(line).SetText("The static defence power of the dragon: ").SetColor(colors.Textcolor);
            CreateLabel(line).SetText(dragon.DefensePower).SetColor(colors.Teal);
        end
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The number of damage points it takes to kill this dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DamageToKill).SetColor(colors.Teal);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Damage absorbed when this dragon takes damage: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DamageAbsorbedWhenAttacked).SetColor(colors.Teal);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The static defence power of the dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DefensePower).SetColor(colors.Teal);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The attack power of the dragon: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(dragon.AttackPower).SetColor(colors.Teal);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The attack modifier of the dragon: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(dragon.AttackPowerPercentage .. "%").SetColor(colors.Cyan);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The defence modifier of the dragon: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(dragon.DefensePowerPercentage .. "%").SetColor(colors.Cyan);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Has Dragon Breath attack: ").SetColor(colors.Textcolor);
    if dragon.DragonBreathAttack then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The damage of the Dragon Breath attack: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DragonBreathAttackDamage).SetColor(colors.Cyan);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
    end
    
    SetWindow(parent);
end

function showPermissions(dragon, root)
    local win = "permissions" .. dragon.ID;
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
    CreateLabel(line).SetText("Permissions").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("This dragon is always visible for everyone: ").SetColor(colors.Textcolor);
    if dragon.IsVisibleToAllPlayers then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Players can airlift this dragon: ").SetColor(colors.Textcolor);
    if dragon.CanBeAirliftedToSelf then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Players can gift this dragon to other players: ").SetColor(colors.Textcolor);
    if dragon.CanBeGiftedWithGiftCard then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("automatically put the word 'A' before the name of this dragon: ").SetColor(colors.Textcolor);
    if dragon.IncludeABeforeName then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
    end
    
    SetWindow(parent);
end

function showAllSettings()
    DestroyWindow();
    SetWindow("showAll");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);

    for _, dragon in pairs(Mod.Settings.Dragons) do
        showDragonSettings(dragon, true);
        CreateEmpty(root).SetPreferredHeight(10);
    end
end

function getNumDigits(n)
    if n < 10 then
        return 1;
    end
    return log10(n / 10) + 1;
end