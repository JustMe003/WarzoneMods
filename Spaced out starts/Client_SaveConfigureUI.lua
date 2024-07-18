function Client_SaveConfigureUI(alert)
    local spaceBetweenStarts = minSpacesApart.GetValue();
    if spaceBetweenStarts < 1 then
        alert("The minimum space between starting territories must be higher or equal to 1. Otherwise there is no point in using the mod");
    end
    Mod.Settings.SpaceBetweenStarts = minSpacesApart.GetValue();
end