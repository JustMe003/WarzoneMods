function Client_SaveConfigureUI(alert)
    Mod.Settings.DoNotAllowDeployments = disallowDeploymentsInput.GetIsChecked();
    Mod.Settings.RemoveArmiesFromEncircledTerrs = removeArmiesInput.GetIsChecked();
    if Mod.Settings.RemoveArmiesFromEncircledTerrs then
        Mod.Settings.TerritoriesTurnNeutral = turnNeutralInput.GetIsChecked();
        if percentageLostInput ~= nil then
            Mod.Settings.PercentageLost = percentageLostInput.GetValue();
            if Mod.Settings.PercentageLost <= 0 then
                alert("the percentage of armies lost must be greater than 0!")
            elseif Mod.Settings.PercentageLost >= 100 then
                alert("the percentage of armies lost must be lower than 100!\nIf you wish to remove all armies from the territory, enable the 'Territories turn neutral immediately' setting")
            end
        else
            Mod.Settings.PercentageLost = 50;
        end
    end
end