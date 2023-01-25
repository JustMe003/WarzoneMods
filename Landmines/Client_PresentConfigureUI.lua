require("UI");
function Client_PresentConfigureUI(rootParent)
    Init(rootParent);

    local cost = Mod.Settings.Cost;
    if cost == nil then cost = 10; end
    local damageAbsorbed = Mod.Settings.DamageAbsorbed;
    if damageAbsorbed == nil then damageAbsorbed = 20; end
    local costIncrease = Mod.Settings.CostIncrease;
    if costIncrease == nil then costIncrease = 3; end

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The amount of gold to purchase a Landmine").SetColor(colors.Textcolor);
    costInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(cost);
    CreateLabel(root).SetText("The amount of gold that get added to the cost after each purchase").SetColor(colors.Textcolor);
    costIncreaseInput = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(costIncrease);
    CreateLabel(root).SetText("The damage that is absorbed by a land mine").SetColor(colors.Textcolor);
    damageAbsorbedInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(damageAbsorbed);

end