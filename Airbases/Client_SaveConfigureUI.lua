function Client_SaveConfigureUI(alert)
    Mod.Settings.RequiredCities = RequiredCitiesInput.GetValue();
    if Mod.Settings.RequiredCities <= 0 then alert("You nust set the requirement of cities to have an airbase to at least 1 or higher"); end
end
