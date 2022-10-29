require("UI");
function Client_PresentConfigureUI(rootParent)
    Init(rootParent);

    local cost = Mod.Settings.Cost;
    if cost == nil then cost = 10; end
    local increment = Mod.Settings.Increment;
    if increment == nil then increment = 5; end

    local root = GetRoot();
    local colors = GetColors();

    CreateLabel(root).SetText("The initial amount of gold to purchase the No-split Curse").SetColor(colors.Ivory);
    costInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(cost);
    CreateLabel(root).SetText("The extra gold added for the next purchase").SetColor(colors.Ivory);
    incrementInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(3).SetValue(increment);

end