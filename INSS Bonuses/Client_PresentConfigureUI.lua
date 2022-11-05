function Client_PresentConfigureUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local useSuperBonuses = Mod.Settings.UseSuperBonuses;
    if useSuperBonuses == nil then useSuperBonuses = false; end
    local useNegativeBonuses = Mod.Settings.UseNegativeBonuses;
    if useNegativeBonuses == nil then useNegativeBonuses = false; end

    SBInput = UI.CreateCheckBox(vert).SetText("Use this bonus system also for super bonuses").SetIsChecked(useSuperBonuses);
    NBInput = UI.CreateCheckBox(vert).SetText("Use this bonus system also for negative bonuses").SetIsChecked(useNegativeBonuses);
    SBInput.SetOnValueChanged(function() if SBInput.GetIsChecked() then UI.Alert("You sure?\nThe game might become unplayable with this setting enabled!"); end);
end