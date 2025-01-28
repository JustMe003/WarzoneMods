require("UI");
require("Util");

function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    root = GetRoot().SetFlexibleWidth(1);
    colors = GetColors();

    showMainSettings();
end

function showMainSettings()
    DestroyWindow();
    SetWindow("Main");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateButton(line).SetText("Show all settings").SetColor(colors.Blue).SetOnClick(showAllSettings);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Select an Artillery to see the settings").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    for _, artillery in pairs(Mod.Settings.Artillery) do
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(0.5);
        CreateButton(line).SetText(artillery.Name).SetColor(artillery.Color).SetOnClick(function() showArtillerySettings(artillery, false, showMainSettings); end);
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
    CreateLabel(line).SetText("For the artillery placements, see the mod menu").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.5);

end

function showArtillerySettings(artillery, showAll, returnFunction)
    if showAll == false then
        DestroyWindow();
        SetWindow("artilleryMain" .. artillery.ID);

        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(returnFunction or (function() end));
    end
    showAll = true;

    showSetting(root, "Artillery name", "'" .. artillery.Name .. "' is the name of this particular artillery unit. Together with it's color it will allow you to identify which artillery you're dealing/playing with", artillery.Name, colors.Tan);

    showSetting(root, "Artillery color", "'" .. artillery.ColorName .. "' is the color if this artillery icon on the map. Together with the name of this artillery (species) it will allow you to identify which artillery you're dealing/playing with", artillery.ColorName, artillery.Color);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local generalCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local generalLabel = CreateLabel(line).SetText("Hide general settings");
    local generalVert = CreateVert(root).SetFlexibleWidth(1);
    generalCheckBox.SetOnValueChanged(function() if generalCheckBox.GetIsChecked() then showGeneralSettings(artillery, generalVert); generalLabel.SetText("Hide" .. generalLabel.GetText():sub(5, -1)); else DestroyWindow("generalSettings" .. artillery.ID, false); generalLabel.SetText("Show" .. generalLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local healthAndDamageCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local healthAndDamageLabel = CreateLabel(line).SetText("Hide health and damage");
    local healthAndDamageVert = CreateVert(root).SetFlexibleWidth(1);
    healthAndDamageCheckBox.SetOnValueChanged(function() if healthAndDamageCheckBox.GetIsChecked() then showHealthAndDamage(artillery, healthAndDamageVert); healthAndDamageLabel.SetText("Hide" .. healthAndDamageLabel.GetText():sub(5, -1)); else DestroyWindow("healthAndDamage" .. artillery.ID, false); healthAndDamageLabel.SetText("Show" .. healthAndDamageLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local artilleryStrikeCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local artilleryStrikeLabel = CreateLabel(line).SetText("Hide artillery strike");
    local artilleryStrikeVert = CreateVert(root).SetFlexibleWidth(1);
    artilleryStrikeCheckBox.SetOnValueChanged(function() if artilleryStrikeCheckBox.GetIsChecked() then showArtilleryStrikeSettings(artillery, artilleryStrikeVert); artilleryStrikeLabel.SetText("Hide" .. artilleryStrikeLabel.GetText():sub(5, -1)); else DestroyWindow("ArtilleryStrike" .. artillery.ID, false); artilleryStrikeLabel.SetText("Show" .. artilleryStrikeLabel.GetText():sub(5, -1)); end; end)
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    local permissionsCheckBox = CreateCheckBox(line).SetText(" ").SetIsChecked(showAll);
    local permissionsLabel = CreateLabel(line).SetText("Hide permissions");
    local permissionsVert = CreateVert(root).SetFlexibleWidth(1);
    permissionsCheckBox.SetOnValueChanged(function() if permissionsCheckBox.GetIsChecked() then showPermissions(artillery, permissionsVert); permissionsLabel.SetText("Hide" .. permissionsLabel.GetText():sub(5, -1)); else DestroyWindow("permissions" .. artillery.ID, false); permissionsLabel.SetText("Show" .. permissionsLabel.GetText():sub(5, -1)); end; end)

    if showAll then
        showGeneralSettings(artillery, generalVert);
        showHealthAndDamage(artillery, healthAndDamageVert);
        showArtilleryStrikeSettings(artillery, artilleryStrikeVert);
        showPermissions(artillery, permissionsVert);
    end
end

function showGeneralSettings(artillery, root)
    local win = "generalSettings" .. artillery.ID;
    local parent = GetCurrentWindow();
    if WindowExists(win) then
        DestroyWindow(win, false);
    end
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
    
    if artillery.CanBeBought then
        showSetting(vert, "This artillery can be bought", "Every player alive can buy this artillery (species) during the game", "Yes", colors.Green);

        showSetting(vert, "Price of this artillery", "A '" .. artillery.Name .. "' will cost you " .. artillery.Cost .. " gold to purchase", artillery.Cost, colors.Teal);

        showSetting(vert, "The maximum number of artillery a player may have", "When a player has " .. artillery.MaxNumOfArtillery .. " of these artillery, they can not purchase any more of this type", artillery.MaxNumOfArtillery, colors.Teal);
    else
        showSetting(vert, "This artillery can be bought", "No player can buy this artillery during the game. The only way to acquire this artillery (species) is to start with one or when one is given to you by another player", "No", colors["Orange Red"]);
    end
    
    SetWindow(parent);
end

function showHealthAndDamage(artillery, root)
    local win = "healthAndDamage" .. artillery.ID;
    local parent = GetCurrentWindow();
    if WindowExists(win) then
        DestroyWindow(win, false);
    end
    AddSubWindow(parent, win);
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
    
    if artillery.UseHealth then
        showSetting(vert, "This artillery uses dynamic health", "This artillery type will automatically reduce its health when it's part of combat where it receives damage, and automatically die if the health goes below 1\n\nNote that health and defense power are different things! Health determines when the unit dies, defense power determines how much damage it will deal when defending", "Yes", colors.Green);
        
        showSetting(vert, "The initial health of this artillery", "This artillery type has started with " .. artillery.Health .. " health but it's health will reduce when it takes damage in combat, so it might have less health\n\nNote that health and defense power are different things! Health determines when the unit dies, defense power determines how much damage it will deal when defending", artillery.Health, colors.Teal)
        
        if artillery.DynamicDefencePower then
            showSetting(vert, "The defense power always equals the health", "This mod will update the defense power of this artillery type every time it takes damage in combat. This makes sure that the number of attacking armies this artillery type kills is equal to it's health (for most of the times)", "Yes", colors.Green);
        else
            showSetting(vert, "The defense power always equals the health", "This mod will NOT update the defense power of this artillery type every time it takes damage in combat\n\nNote that health and defense power are different things! Health determines when the unit dies, defense power determines how much damage it will deal when defending", "No", colors["Orange Red"]);

            showSetting(vert, "The fixed defense power of the artillery", "This artillery type has a fixed defense power of " .. artillery.DefensePower .. ". This is the amount of damage it will deal when defending a territory", artillery.DefensePower, colors.Teal);
        end
    else
        showSetting(vert, "This artillery uses dynamic health", "This artillery type will NOT automatically reduce its health when it's part of combat where it receives damage", "No", colors["Orange Red"]);
        
        showSetting(vert, "The number of damage points it takes to kill this artillery", "To kill / remove this artillery from the game, you'll have to deal at least " .. artillery.DamageToKill .. " damage points in 1 blow (so not multiple attacks!). Note that you first need to kill all the normal armies on this territory before you can take down a artillery", artillery.DamageToKill, colors.Teal);
        
        showSetting(vert, "Damage absorbed when this artillery takes damage", "When this artillery is attacked and this artillery is killed, it will reduce the remaining damage points (that would normally deal damage to the left over special units / artillery) by " .. artillery.DamageAbsorbedWhenAttacked, artillery.DamageAbsorbedWhenAttacked, colors.Teal);
        
        showSetting(vert, "The fixed defense power of the artillery", "This artillery type has a fixed defense power of " .. artillery.DefensePower .. ". This is the amount of damage it will deal when defending a territory", artillery.DefensePower, colors.Teal);
    end
    
    showSetting(vert, "The attack power of the artillery", "This artillery will deal " .. artillery.AttackPower .. " damage when it attacks", artillery.AttackPower, colors.Teal)
    
    showSetting(vert, "The attack modifier of the artillery", "When part of an attack, this artillery will add " .. round(artillery.AttackPowerPercentage, 2) .. "% damage. That is, when your attack (including this artillery) is 100 attack power, this artillery will buff it to " .. round(((artillery.AttackPowerPercentage / 100) + 1) * 100, 0), round(artillery.AttackPowerPercentage, 2) .. "%", colors.Cyan);
    
    showSetting(vert, "The defense modifier of the artillery", "When defending, this artillery will add " .. round(artillery.DefensePowerPercentage, 2) .. "% damage. That is, when your defense (including this artillery) is equal to 100 defense power, this artillery will buff it to " .. round(((artillery.DefensePowerPercentage / 100) + 1) * 100, 0), round(artillery.DefensePowerPercentage, 2) .. "%", colors.Cyan);
    
    SetWindow(parent);
end

function showArtilleryStrikeSettings(artillery, root)
    local win = "ArtilleryStrike" .. artillery.ID;
    local parent = GetCurrentWindow();
    if WindowExists(win) then
        DestroyWindow(win, false);
    end
    AddSubWindow(parent, win);
    SetWindow(win);

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateVert(line).SetPreferredWidth(25).SetFlexibleWidth(0);
    vert = CreateVert(line).SetFlexibleWidth(1);
    
    CreateEmpty(vert).SetPreferredHeight(10);
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Artillery Strike").SetColor(colors.Tan);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateEmpty(vert).SetPreferredHeight(5);
    
    if artillery.UsingCostGold then
        showSetting(vert, "Firing this artillery cost gold", "Artillery can be free to use, or they cost gold every time you shoot them. Check the settings for each artillery to see how much gold they cost to shoot", "Yes", colors.Green);
    
        showSetting(vert, "The cost of shooting this artillery", "When a player orders an artillery unit of this type to strike a target, they will need to pay " .. artillery.UseCost .. " gold to do so", artillery.UseCost, colors.Teal)
    else
        showSetting(vert, "Firing this artillery cost gold", "Artillery can be free to use, or they cost gold every time you shoot them. Check the settings for each artillery to see how much gold they cost to shoot", "no", colors["Orange Red"]);
    end

    if artillery.DealsPercentageDamage then
        showSetting(vert, "Damage is dealt as a percentage", "The damage is dealt as a percentage of the number of armies on the target territory. If a territory has 50 armies, and this unit deals 20% damage in a strike, it will remove deal 10 final damage. Note that percentage damage scales with the number of armies on the target territory", "Yes", colors.Green);
    
        showSetting(vert, "Minimum damage", "This is the minimum damage that this unit will deal in an artillery strike. The final damage is a random number between the minimum and maximum damage", round(artillery.MinimumDamage, 2) .. "%", colors.Cyan);

        showSetting(vert, "Maximum damage", "This is the maximum damage that this unit will deal in an artillery strike. The final damage is a random number between the minimum and maximum damage", round(artillery.MaximumDamage, 2) .. "%", colors.Cyan);
    else
        showSetting(vert, "Damage is dealt as a percentage", "The damage dealt is a fixed number. No matter the number of armies on the target territory, this artillery unit will only deal a fixed number of damage", "No", colors["Orange Red"]);
        
        showSetting(vert, "Minimum damage", "This is the minimum damage that this unit will deal in an artillery strike. The final damage is a random number between the minimum and maximum damage", artillery.MinimumDamage, colors.Teal);

        showSetting(vert, "Maximum damage", "This is the maximum damage that this unit will deal in an artillery strike. The final damage is a random number between the minimum and maximum damage", artillery.MaximumDamage, colors.Teal);
    end

    showSetting(vert, "Maximum range of artillery", "The maximum number of territories away the target may be. If you try to launch an artillery strike on a target that is further away than " .. artillery.MaximumRange .. ", this artillery unit cannot participate in the artillery strike", artillery.MaximumRange, colors.Teal);

    showSetting(vert, "The chance of missing the target territory", "If the miss chance is bigger than 0, there is a chance of the missing the target territory. If the strike misses, one of the neighbouring territories is hit instead", round(artillery.MissPercentage, 2) .. "%", colors.Cyan);

    showSetting(vert, "Reload time", "The amount of turns it takes to reload this artillery after it has shot. While reloading, the artillery unit cannot shoot or move", artillery.ReloadDuration, colors.Teal);

    SetWindow(parent);
end

function showPermissions(artillery, root)
    local win = "permissions" .. artillery.ID;
    local parent = GetCurrentWindow();
    if WindowExists(win) then
        DestroyWindow(win, false);
    end
    AddSubWindow(parent, win);
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
    
    if artillery.IsVisibleToAllPlayers then
        showSetting(vert, "This artillery is always visible for everyone", "Whatever fog your game uses, everyone can see the territory that contains a artillery of this type", "Yes", colors.Green);
    else
        showSetting(vert, "This artillery is always visible for everyone", "Whatever fog your game uses, everyone can NOT see the territory that contains a artillery of this type", "No", colors["Orange Red"]);
    end
    
    if artillery.CanBeAirliftedToSelf then
        showSetting(vert, "Players can airlift this artillery", "This artillery can be airlifted using an airlift card", "Yes", colors.Green);
    else
        showSetting(vert, "Players can airlift this artillery", "This artillery cannot be airlifted using an airlift card", "No", colors["Orange Red"]);
    end
    
    if artillery.CanBeTransferredToTeammate ~= nil then
        if artillery.CanBeTransferredToTeammate then
            showSetting(vert, "Players can transfer this artillery to teammates", "This artillery can be transferred to teammates. If this artillery can be airlifted, then players can also airlift this artillery to their teammates", "Yes", colors.Green);
        else
            showSetting(vert, "Players can transfer this artillery to teammates", "This artillery cannot be transferred to teammates. Players can also not airlift this artillery to their teammates", "No", colors["Orange Red"]);
        end
    end

    if artillery.CanBeGiftedWithGiftCard then
        showSetting(vert, "Players can gift this artillery to other players", "This artillery can be gifted to other players", "Yes", colors.Green);
    else
        showSetting(vert, "Players can gift this artillery to other players", "This artillery cannot be gifted to other players", "No", colors["Orange Red"]);
    end
    
    if artillery.IncludeABeforeName then
        showSetting(vert, "automatically put the word 'A' before the name of this artillery", "For better language, this mod and Warzone will put 'A' before the name of this artillery, indicating that there can be more than one of this artillery in the game", "Yes", colors.Green);
    else
        showSetting(vert, "automatically put the word 'A' before the name of this artillery", "This mod and Warzone will not put 'A' before the name of this artillery", "No", colors["Orange Red"]);
    end
    
    SetWindow(parent);
end

function showAllSettings()
    DestroyWindow();
    SetWindow("showAll");

    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMainSettings);
    
    for _, artillery in pairs(Mod.Settings.Artillery) do
        showArtillerySettings(artillery, true);
        CreateEmpty(root).SetPreferredHeight(20);
    end
    
    showCombatOrder(true);
    
    CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMainSettings);
end

function showCombatOrder(showAll)
    showAll = showAll or false;
    if not showAll then
        DestroyWindow();
        SetWindow("CombatOrder");
        CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMainSettings);
    end

    CreateEmpty(root).SetPreferredHeight(5);

    CreateLabel(root).SetText("The combat order determines in what order artillery take damage. When there are multiple artillery of different types on a territory, this is the order in which artillery are killed / take damage:").SetColor(colors.TextColor);
    local t = {};
    for i, artillery in pairs(Mod.Settings.Artillery) do
        t[artillery.CombatOrder + 1] = artillery;
    end
    for i, artillery in ipairs(t) do
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateEmpty(line).SetFlexibleWidth(0.5);
        CreateLabel(line).SetText(i .. ". ").SetColor(colors.TextColor);
        CreateLabel(line).SetText(artillery.Name).SetColor(artillery.Color);
        CreateEmpty(line).SetFlexibleWidth(0.5);
    end
end

function showSetting(parent, settingName, helpText, setting, color)
    local line = CreateHorz(parent).SetFlexibleWidth(1);
    local vertLeft = CreateVert(line).SetFlexibleWidth(0.5).SetPreferredWidth(1000);
    local lineLeft = CreateHorz(vertLeft).SetFlexibleWidth(1);
    CreateEmpty(lineLeft).SetFlexibleWidth(0.5);
    CreateLabel(lineLeft).SetText(settingName).SetColor(colors.TextColor);
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