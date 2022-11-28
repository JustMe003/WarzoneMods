require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    colors = GetColors();
    local root = GetRoot();

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Auto-distribute units: \t").SetColor(colors.Tan);
    setTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.AutoDistributeUnits)), Mod.Settings.AutoDistributeUnits);
    createQuestionMark(line, "When enabled, the mod will automatically (but efficiently) distribute the link units for players. When players do not deploy all their link units, the mod will auto distribute the remaining units for them regardless of this setting");
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Number of units = number of starting territories: \t").SetColor(colors.Tan);
    setTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.NUnitsIsNTerrs)), Mod.Settings.NUnitsIsNTerrs);
    createQuestionMark(line, "When enabled, the mod will allow the same amount of link units to be placed as players have territories. The maximum unit count with this option enabled is 5.");

    if not Mod.Settings.NUnitsIsNTerrs then
        line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText("Number of units: \t").SetColor(colors.Tan);
        CreateLabel(line).SetText(Mod.Settings.NumberOfUnits).SetColor(colors.Cyan);
        createQuestionMark(line, "The number of link units each player gets. This is only used if the setting above (Number of units = number of territories) is not enabled");
    end

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Commanders act like link units: \t").SetColor(colors.Tan);
    setTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.IncludeCommanders)), Mod.Settings.IncludeCommanders);
    createQuestionMark(line, "When enabled, commanders also work as a 'source' territory. Any territory connected to a commander will not turn neutral. This is to avoid players losing their commanders to neutral territories");

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Link units can be airlifted: \t").SetColor(colors.Tan);
    setTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.TeamsCountAsOnePlayer)), Mod.Settings.TeamsCountAsOnePlayer);
    createQuestionMark(line, "When enabled, link units can be airlifted to the player themselves. In a team game, players can also airlift link units to teammembers if the teams act like 1 player (see setting below)");
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Teams count as 1 player: \t").SetColor(colors.Tan);
    setTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.TeamsCountAsOnePlayer)), Mod.Settings.TeamsCountAsOnePlayer);
    createQuestionMark(line, "When enabled, and the game uses teams, the mod will see teams as player, instead of each player individually. This means that you can have territories that are connected to a link unit of a teammember, instead of the need of having the territories connected one of your link units. This setting is also required if you want to airlift link units to your teammembers");
end

function createQuestionMark(line, text)
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert(text); end)
end

function setTrueFalseColor(object, bool)
    if bool then
        object.SetColor(colors.Lime);
    else
        object.SetColor(colors["Orange Red"]);
    end
end