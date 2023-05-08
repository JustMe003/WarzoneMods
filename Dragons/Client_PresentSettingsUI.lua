require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
    colors = GetColors();

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Show all settings").SetColor(colors.Blue).SetOnClick(showAllSettings);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Select a Dragon to see the settings").SetColor(colors.Textcolor);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    for _, dragon in pairs(Mod.Settings.Dragons) do
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(0.5);
        CreateButton(line).SetText(dragon.Name).SetColor(dragon.Color).SetOnClick(function() showDragonSettings(dragon, false, showMain); end);
        CreateEmpty(line).SetFlexibleWidth(0.5);
    end
    CreateEmpty(root).SetPreferredHeight(5);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Combat Order").SetColor(colors.Orange).SetOnClick(showCombatOrder);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    CreateEmpty(root).SetPreferredHeight(5);
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("For the dragon placements, see the mod menu").SetColor(colors.Textcolor);
    CreateEmpty(line).SetFlexibleWidth(0.5);

end

function showDragonSettings(dragon, showAll, returnFunction)
    if showAll == false then
        DestroyWindow();
        SetWindow("dragonMain" .. dragon.ID);

        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(returnFunction);
    end
    showAll = true;

    showSetting(root, "Dragon name", "'" .. dragon.Name .. "' is the name of this particular dragon (species). Together with it's color it will allow you to identify which dragon you're dealing/playing with", dragon.Name, colors.Tan);

    showSetting(root, "Dragon color", "'" .. dragon.ColorName .. "' is the color if this dragon icon on the map. Together with the name of this dragon (species) it will allow you to identify which dragon you're dealing/playing with", dragon.ColorName, dragon.Color);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local generalCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local generalLabel = CreateLabel(line).SetText("Show general settings");
    local generalVert = CreateVert(root).SetFlexibleWidth(1);
    generalCheckBox.SetOnValueChanged(function() if generalCheckBox.GetIsChecked() then showGeneralSettings(dragon, generalVert); generalLabel.SetText("Hide" .. generalLabel.GetText():sub(5, -1)); else DestroyWindow("generalSettings" .. dragon.ID, false); generalLabel.SetText("Show" .. generalLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local healthAndDamageCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local healthAndDamageLabel = CreateLabel(line).SetText("Show health and damage");
    local healthAndDamageVert = CreateVert(root).SetFlexibleWidth(1);
    healthAndDamageCheckBox.SetOnValueChanged(function() if healthAndDamageCheckBox.GetIsChecked() then showHealthAndDamage(dragon, healthAndDamageVert); healthAndDamageLabel.SetText("Hide" .. healthAndDamageLabel.GetText():sub(5, -1)); else DestroyWindow("healthAndDamage" .. dragon.ID, false); healthAndDamageLabel.SetText("Show" .. healthAndDamageLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local permissionsCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local permissionsLabel = CreateLabel(line).SetText("Show permissions");
    local permissionsVert = CreateVert(root).SetFlexibleWidth(1);
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
    
    if dragon.CanBeBought then
        showSetting(vert, "This dragon can be bought", "Every player alive can buy this dragon (species) during the game", "Yes", colors.Green);

        showSetting(vert, "Price of this dragon", "A '" .. dragon.Name .. "' will cost you " .. dragon.Cost .. " gold to purchase", dragon.Cost, colors.Teal);

        showSetting(vert, "The maximum number of dragons a player may have", "When a player has " .. dragon.MaxNumOfDragon .. " of these dragons, it can not purchase any more of this type", dragon.MaxNumOfDragon, colors.Teal);
    else
        showSetting(vert, "This dragon can be bought", "No player can buy this dragon during the game. The only way to acquire this dragon (species) is to start with one or when one is given to you by another player", "No", colors["Orange Red"]);
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
    
    if dragon.UseHealth then
        showSetting(vert, "This dragon uses dynamic health", "This dragon type will automatically reduce its health when it's part of combat where it receives damage, and automatically die if the health goes below 1\n\nNote that health and defence power are different things! Health determines when the unit dies, defence power determines how much damage it will deal when defending", "Yes", colors.Green);
        
        showSetting(vert, "The initial health of this dragon", "This dragon type has started with " .. dragon.Health .. " health but it's health will reduce when it takes damage in combat, so it might have less health\n\nNote that health and defence power are different things! Health determines when the unit dies, defence power determines how much damage it will deal when defending", dragon.Health, colors.Teal)
        
        if dragon.DynamicDefencePower then
            showSetting(vert, "The defence power always equals the health", "This mod will update the defence power of this dragon type every time it takes damage in combat. This makes sure that the number of attacking armies this dragon type kills is equal to it's health (for most of the times)", "Yes", colors.Green);
        else
            showSetting(vert, "The defence power always equals the health", "This mod will NOT update the defence power of this dragon type every time it takes damage in combat\n\nNote that health and defence power are different things! Health determines when the unit dies, defence power determines how much damage it will deal when defending", "No", colors["Orange Red"]);

            showSetting(vert, "The fixed defence power of the dragon", "This dragon type has a fixed defense power of " .. dragon.DefensePower .. ". This is the amount of damage it will deal when defending a territory", dragon.DefensePower, colors.Teal);
        end
    else
        showSetting(vert, "This dragon uses dynamic health", "This dragon type will NOT automatically reduce its health when it's part of combat where it receives damage", "No", colors["Orange Red"]);
        
        showSetting(vert, "The number of damage points it takes to kill this dragon", "To kill / remove this dragon from the game, you'll have to deal at least " .. dragon.DamageToKill .. " damage points in 1 blow (so not multiple attacks!). Note that you first need to kill all the normal armies on this territory before you can take down a dragon", dragon.DamageToKill, colors.Teal);
        
        showSetting(vert, "Damage absorbed when this dragon takes damage", "When this dragon is attacked and this dragon is killed, it will reduce the remaining damage points (that would normally deal damage to the left over special units / dragons) by " .. dragon.DamageAbsorbedWhenAttacked, dragon.DamageAbsorbedWhenAttacked, colors.Teal);
        
        showSetting(vert, "The fixed defence power of the dragon", "This dragon type has a fixed defense power of " .. dragon.DefensePower .. ". This is the amount of damage it will deal when defending a territory", dragon.DefensePower, colors.Teal);
    end
    
    showSetting(vert, "The attack power of the dragon", "This dragon will deal " .. dragon.AttackPower .. " when it attacks", dragon.AttackPower, colors.Teal)
    
    showSetting(vert, "The attack modifier of the dragon", "When part of an attack, this dragon will add " .. round(dragon.AttackPowerPercentage, 2) .. "% damage. That is, when your attack (including this dragon) is 100 attack power, this dragon will buff it to " .. round(((dragon.AttackPowerPercentage / 100) + 1) * 100, 0), round(dragon.AttackPowerPercentage, 2) .. "%", colors.Cyan);
    
    showSetting(vert, "The defence modifier of the dragon", "When defending, this dragon will add " .. round(dragon.DefensePowerPercentage, 2) .. "% damage. That is, when your defence (including this dragon) is equal to 100 defence power, this dragon will buff it to " .. round(((dragon.DefensePowerPercentage / 100) + 1) * 100, 0), round(dragon.DefensePowerPercentage, 2) .. "%", colors.Cyan);
    
    if dragon.DragonBreathAttack then
        showSetting(vert, "Has Dragon Breath attack", "This dragon uses his dragon breath every time it attacks an territory. See 'Dragon Breath Attack damage' for a better explanation", "Yes", colors.Green);
        showSetting(vert, "The damage of the Dragon Breath attack", "This dragon uses his breath to damage bordering territories (of the attacked territory) when it attacks. It will remove " .. dragon.DragonBreathAttackDamage .. " armies from each bordering territory that is not controlled by the player who owns the dragon or their teammates", dragon.DragonBreathAttackDamage, colors.Cyan);
    else
        showSetting(vert, "Has Dragon Breath attack", "This dragon does not uses his dragon breath every time it attacks an territory", "No", colors["Orange Red"]);
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
    
    if dragon.IsVisibleToAllPlayers then
        showSetting(vert, "This dragon is always visible for everyone", "Whatever fog your game uses, everyone can see the territory that contains a dragon of this type", "Yes", colors.Green);
    else
        showSetting(vert, "This dragon is always visible for everyone", "Whatever fog your game uses, everyone can NOT see the territory that contains a dragon of this type", "No", colors["Orange Red"]);
    end
    
    if dragon.CanBeAirliftedToSelf then
        showSetting(vert, "Players can airlift this dragon:", "This dragon can be airlifted using an airlift card", "Yes", colors.Green);
    else
        showSetting(vert, "Players can airlift this dragon:", "This dragon cannot be airlifted using an airlift card", "No", colors["Orange Red"]);
    end
    
    if dragon.CanBeTransferredToTeammate ~= nil then
        if dragon.CanBeTransferredToTeammate then
            showSetting(vert, "Players can transfer this dragon to teammates:", "This dragon can be transferred to teammates. If this dragon can be airlifted, then players can also airlift this dragon to their teammates", "Yes", colors.Green);
        else
            showSetting(vert, "Players can transfer this dragon to teammates:", "This dragon cannot be transferred to teammates. Players can also not airlift this dragon to their teammates", "No", colors["Orange Red"]);
        end
    end

    if dragon.CanBeGiftedWithGiftCard then
        showSetting(vert, "Players can gift this dragon to other players:", "This dragon can be gifted to other players", "Yes", colors.Green);
    else
        showSetting(vert, "Players can gift this dragon to other players:", "This dragon cannot be gifted to other players", "No", colors["Orange Red"]);
    end
    
    if dragon.IncludeABeforeName then
        showSetting(vert, "automatically put the word 'A' before the name of this dragon:", "For better language, this mod and Warzone will put 'A' before the name of this dragon, indicating that there can be more than one of this dragon in the game", "Yes", colors.Green);
    else
        showSetting(vert, "automatically put the word 'A' before the name of this dragon:", "This mod and Warzone will not put 'A' before the name of this dragon", "No", colors["Orange Red"]);
    end
    
    SetWindow(parent);
end

function showAllSettings()
    DestroyWindow();
    SetWindow("showAll");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    
    for _, dragon in pairs(Mod.Settings.Dragons) do
        showDragonSettings(dragon, true);
        CreateEmpty(root).SetPreferredHeight(20);
    end
    
    showCombatOrder(true);
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
end

function showCombatOrder(showAll)
    showAll = showAll or false;
    if not showAll then
        DestroyWindow();
        SetWindow("CombatOrder");
        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
    end

    CreateEmpty(root).SetPreferredHeight(5);

    CreateLabel(root).SetText("The combat order determines in what order dragons take damage. When there are multiple dragons of different types on a territory, this is the order in which dragons are killed / take damage:").SetColor(colors.Textcolor);
    local t = {};
    for i, dragon in pairs(Mod.Settings.Dragons) do
        t[dragon.CombatOrder + 1] = dragon;
    end
    for i, dragon in ipairs(t) do
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(0.5);
        CreateLabel(line).SetText(i .. ". ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.Name).SetColor(dragon.Color);
        CreateEmpty(line).SetFlexibleWidth(0.5);
    end
end

function showSetting(parent, settingName, helpText, setting, color)
    local line = CreateHorz(parent).SetFlexibleWidth(1);
    local vertLeft = CreateVert(line).SetFlexibleWidth(0.5).SetPreferredWidth(1000);
    local lineLeft = CreateHorz(vertLeft).SetFlexibleWidth(1);
    CreateEmpty(lineLeft).SetFlexibleWidth(0.5);
    CreateLabel(lineLeft).SetText(settingName).SetColor(colors.Textcolor);
    CreateEmpty(lineLeft).SetFlexibleWidth(0.5);
    local vertButton = CreateVert(line);
    CreateButton(vertButton).SetText("?").SetColor(colors["Light Blue"]).SetOnClick(function() UI.Alert(helpText); end);
    local vertRight = CreateVert(line).SetFlexibleWidth(0.5).SetPreferredWidth(1000);
    CreateLabel(vertRight).SetText(setting).SetColor(color);
end

function getNumDigits(n)
    if n < 10 then
        return 1;
    end
    return getNumDigits(n / 10) + 1;
end

function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces > 0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
  end