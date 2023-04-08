function Client_PresentConfigureUI(rootParent)
    requiredCities = Mod.Settings.RequiredCities;
    if requiredCities == nil then requiredCities = 3; end
    local root = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(root).SetText("The number of cities required to have an airbase").SetColor("#DDDDDD");
    RequiredCitiesInput = UI.CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(requiredCities)
end
