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
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("This dragon can be bought: ").SetColor(colors.Textcolor);
    if dragon.CanBeBought then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green).SetPreferredWidth(30);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("Every player alive can buy this dragon (species) during the game"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Price of this dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.Cost).SetColor(colors.Teal).SetPreferredWidth(10 * getNumDigits(dragon.Cost));
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
        CreateLabel(line).SetText("Yes").SetColor(colors.Green).SetPreferredWidth(10);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon type will automatically reduce its health when it's part of combat where it receives damage, and automatically die if the health goes below 1\n\nNote that health and defence power are different things! Health determines when the unit dies, defence power determines how much damage it will deal when defending"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The initial health of this dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.Health).SetColor(colors.Teal).SetPreferredWidth(10 * getNumDigits(dragon.Health));
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon type has started with " .. dragon.Health .. " health but it's health will reduce when it takes damage in combat, so it might have less health\n\nNote that health and defence power are different things! Health determines when the unit dies, defence power determines how much damage it will deal when defending"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The defence power always equals the health: ").SetColor(colors.Textcolor);
        if dragon.DynamicDefencePower then
            CreateLabel(line).SetText("Yes").SetColor(colors.Green).SetPreferredWidth(30);
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This mod will update the defence power of this dragon type every time it takes damage in combat. This makes sure that the number of attacking armies this dragon type kills is equal to it's health (for most of the times)"); end);
        else
            CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]).SetPreferredWidth(20);
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This mod will NOT update the defence power of this dragon type every time it takes damage in combat\n\nNote that health and defence power are different things! Health determines when the unit dies, defence power determines how much damage it will deal when defending"); end);
            
            line = CreateHorz(vert).SetFlexibleWidth(1);
            CreateLabel(line).SetText("The fixed defence power of the dragon: ").SetColor(colors.Textcolor);
            CreateLabel(line).SetText(dragon.DefensePower).SetColor(colors.Teal).SetPreferredWidth(10 * getNumDigits(dragon.Health));
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon type has a fixed defense power of " .. dragon.DefensePower .. ". This is the amount of damage it will deal when defending a territory"); end);
        end
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]).SetPreferredWidth(10);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon type will NOT automatically reduce its health when it's part of combat where it receives damage"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The number of damage points it takes to kill this dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DamageToKill).SetColor(colors.Teal);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("To kill / remove this dragon from the game, you'll have to deal at least " .. dragon.DamageToKill .. " damage points in 1 blow (so not multiple attacks!). Note that you first need to kill all the normal armies on this territory before you can take down a dragon"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Damage absorbed when this dragon takes damage: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DamageAbsorbedWhenAttacked).SetColor(colors.Teal);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("When this dragon is attacked and this dragon is killed, it will reduce the remaining damage points (that would normally deal damage to the left over special units / dragons) by " .. dragon.DamageAbsorbedWhenAttacked); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The fixed defence power of the dragon: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DefensePower).SetColor(colors.Teal).SetPreferredWidth(10 * getNumDigits(dragon.Health));
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon type has a fixed defense power of " .. dragon.DefensePower .. ". This is the amount of damage it will deal when defending a territory"); end);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The attack power of the dragon: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(dragon.AttackPower).SetColor(colors.Teal);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon will deal " .. dragon.AttackPower .. " when it attacks"); end);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The attack modifier of the dragon: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(round(dragon.AttackPowerPercentage, 2) .. "%").SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("When part of an attack, this dragon will add " .. round(dragon.AttackPowerPercentage, 2) .. " damage. That is, when your attack (including this dragon) is 100 attack power, this dragon will buff it to " .. round(((dragon.AttackPowerPercentage / 100) + 1) * 100, 0)); end);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("The defence modifier of the dragon: ").SetColor(colors.Textcolor);
    CreateLabel(line).SetText(round(dragon.DefensePowerPercentage, 2) .. "%").SetColor(colors.Cyan);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("When defending, this dragon will add " .. round(dragon.DefensePowerPercentage, 2) .. " damage. That is, when your defence (including this dragon) is equal to 100 defence power, this dragon will buff it to " .. round(((dragon.DefensePowerPercentage / 100) + 1) * 100, 0)); end);
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Has Dragon Breath attack: ").SetColor(colors.Textcolor);
    if dragon.DragonBreathAttack then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon uses his dragon breath every time it attacks an territory. See 'Dragon Breath Attack damage' for a better explanation"); end);
        
        line = CreateHorz(vert).SetFlexibleWidth(1);
        CreateLabel(line).SetText("The damage of the Dragon Breath attack: ").SetColor(colors.Textcolor);
        CreateLabel(line).SetText(dragon.DragonBreathAttackDamage).SetColor(colors.Cyan);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon uses his breath to damage bordering territories (of the attacked territory) when it attacks. It will remove " .. dragon.DragonBreathAttackDamage .. " armies from each bordering territory that is not controlled by the player who owns the dragon or their teammates"); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon does not uses his dragon breath every time it attacks an territory"); end);
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
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("Whatever fog your game uses, everyone can see the territory that contains a dragon of this type"); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("Whatever fog your game uses, everyone can NOT see the territory that contains a dragon of this type"); end);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Players can airlift this dragon: ").SetColor(colors.Textcolor);
    if dragon.CanBeAirliftedToSelf then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon can be airlifted"); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon cannot be airlifted"); end);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Players can gift this dragon to other players: ").SetColor(colors.Textcolor);
    if dragon.CanBeGiftedWithGiftCard then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon can be gifted to other players"); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This dragon cannot be gifted to other players"); end);
    end
    
    line = CreateHorz(vert).SetFlexibleWidth(1);
    CreateLabel(line).SetText("automatically put the word 'A' before the name of this dragon: ").SetColor(colors.Textcolor);
    if dragon.IncludeABeforeName then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("For better language, this mod and Warzone will put 'A' before the name of this dragon, indicating that there can be more than one of this dragon in the game"); end);
    else
        CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function() UI.Alert("This mod and Warzone will not put 'A' before the name of this dragon"); end);
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
    return getNumDigits(n / 10) + 1;
end

function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces > 0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
  end