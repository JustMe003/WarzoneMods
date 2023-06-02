require("UI");
function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
    local textcolor = GetColors().TextColor;
    local root = GetRoot();

    local unitCost = Mod.Settings.UnitCost;
    if unitCost == nil then unitCost = 10; end
    local damage = Mod.Settings.Damage;
    if damage == nil then damage = 25; end
    local maxUnits = Mod.Settings.MaxUnits;
    if maxUnits == nil then maxUnits = 3; end
    local guessCooldown = Mod.Settings.GuessCooldown;
    if guessCooldown == nil then guessCooldown = 3; end

    CreateLabel(root).SetText("The amount of gold a landmine will cost").SetColor(textcolor);
    unitCostInput = CreateNumberInputField(root).SetSliderMaxValue(100).SetSliderMinValue(5).SetValue(unitCost);

    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateLabel(root).SetText("The damage this unit will inflict upon exploding").SetColor(textcolor);
    damageInput = CreateNumberInputField(root).SetSliderMaxValue(100).SetSliderMinValue(1).SetValue(damage);
    
    CreateEmpty(root).SetPreferredHeight(5);
    
    CreateLabel(root).SetText("The maximum number of landmines a player may control").SetColor(textcolor);
    maxUnitsInput = CreateNumberInputField(root).SetSliderMaxValue(5).SetSliderMinValue(1).SetValue(maxUnits);
    
    CreateEmpty(root).SetPreferredHeight(5);

    CreateLabel(root).SetText("The number of turns a player has to wait when he guesses wrong").SetColor(textcolor);
    guessCooldownInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(guessCooldown);
end