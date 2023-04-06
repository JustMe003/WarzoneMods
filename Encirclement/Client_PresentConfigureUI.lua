require("UI");

function Client_PresentConfigureUI(rootParent)
    Init(rootParent);
    textColor = GetColors().TextColor;

    SetWindow("Main");

    disallowDeployments = Mod.Settings.DoNotAllowDeployments;
    if disallowDeployments == nil then disallowDeployments = false; end
    removeArmies = Mod.Settings.RemoveArmiesFromEncircledTerrs;
    if removeArmies == nil then removeArmies = true; end
    turnNeutral = Mod.Settings.TerritoriesTurnNeutral;
    if turnNeutral == nil then turnNeutral = true; end
    percentageLost = Mod.Settings.PercentageLost;
    if percentageLost == nil then percentageLost = 50; end

    root = GetRoot();

    local line = CreateHorz(root).SetFlexibleWidth(1);
    disallowDeploymentsInput = CreateCheckBox(line).SetText(" ").SetIsChecked(disallowDeployments);
    CreateLabel(line).SetText("Do not allow deployments on encircled territories").SetColor(textColor);

    line = CreateHorz(root).SetFlexibleWidth(1);
    removeArmiesInput = CreateCheckBox(line).SetText(" ").SetIsChecked(removeArmies);
    CreateLabel(line).SetText("modify encircled territories").SetColor(textColor);
    
    removeArmiesInput.SetOnValueChanged(updateSubWindow)

    updateSubWindow();
end

function updateSubWindow()
    if turnNeutralInput ~= nil then turnNeutral = turnNeutralInput.GetIsChecked(); end
    if percentageLostInput ~= nil then percentageLost = percentageLostInput.GetValue(); end
    DestroyWindow("subWindow", false);
    if removeArmiesInput.GetIsChecked() then
        showSubWindow(); 
    end
end

function showSubWindow()
    local win = "subWindow";
    local cur = GetCurrentWindow();
    
    AddSubWindow(cur, win);
    SetWindow(win);
    
    CreateLabel(root).SetText("Note that encircled territories with 1 or 0 armies will always turn neutral").SetColor(textColor);
    local line = CreateHorz(root).SetFlexibleWidth(1);
    turnNeutralInput = CreateCheckBox(line).SetText(" ").SetIsChecked(turnNeutral).SetOnValueChanged(updateSubWindow);
    CreateLabel(line).SetText("Territories turn neutral immediately").SetColor(textColor);
    
    CreateLabel(root).SetText("The percentage of armies that get lost").SetColor(textColor);
    percentageLostInput = CreateNumberInputField(root).SetWholeNumbers(false).SetSliderMinValue(10).SetSliderMaxValue(90).SetValue(percentageLost).SetInteractable(not turnNeutralInput.GetIsChecked());

    SetWindow(cur);
end