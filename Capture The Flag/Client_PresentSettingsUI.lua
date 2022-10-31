require("UI");
function Client_PresentSettingsUI(rootParent)
    init(rootParent);

    local vert = newVerticalGroup("vert", "root");

    newLabel("1", vert, "The number of flags for each player / team: " .. Mod.Settings.FlagsPerTeam, "Tan");
    newLabel("2", vert, "The number of flags each team / player has to lose to be eliminated: " .. Mod.Settings.NFlagsForLose, "Tan");
    newLabel("2", vert, "The amount of income you get for controlling a captured flag each: " .. Mod.Settings.IncomeBoost, "Tan");
    newLabel("2", vert, "The move cooldown for flags: " .. Mod.Settings.Cooldown .. " turns", "Tan");
end