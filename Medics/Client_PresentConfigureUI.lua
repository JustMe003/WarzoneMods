require("UI");
function Client_PresentConfigureUI(rootParent)
    Init(rootParent);

    local cost = Mod.Settings.Cost;
    if cost == nil then cost = 10; end
    local percentage = Mod.Settings.Percentage;
    if percentage == nil then percentage = 50; end
    local health = Mod.Settings.Health;
    if health == nil then health = 5; end
    local maxUnits = Mod.Settings.MaxUnits;
    if maxUnits == nil then maxUnits = 2; end

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a Medic").SetColor(colors.Ivory);
    costInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(cost);
    CreateLabel(root).SetText("The percentage of armies that are recovered by Medics").SetColor(colors.Ivory);
    percentageInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(percentage);
    CreateLabel(root).SetText("The amount of armies a Medic is worth (note that it cannot be damaged, only be killed in one attack)").SetColor(colors.Ivory);
    healthInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(health);
    CreateLabel(root).SetText("The maximum number of Medic units a player can have").SetColor(colors.Ivory);
    maxUnitsInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(maxUnits);

end