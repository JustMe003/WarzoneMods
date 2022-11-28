require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    colors = GetColors();
    local root = GetRoot();

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Auto-distribute units: ").SetColor(colors.Tan);
    SetTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.AutoDistributeUnits)), Mod.Settings.AutoDistributeUnits);
    createQuestionMark(line, "When enabled, the mod will automatically (but efficiently) distribute the link units for players. When this option is disabled and players do not deploy all their link units, the mod will auto distribute the remaining units for them regardless of this setting");
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Number of units = number of starting territories: ").SetColor(colors.Tan);
    SetTrueFalseColor(CreateLabel(line).SetText(tostring(Mod.Settings.NUnitsIsNTerrs)), Mod.Settings.NUnitsIsNTerrs);
    createQuestionMark(line, "When enabled, the mod will allow the same amount of link units to be placed as players have territories. The maximum unit count with this option enabled is 5.");

    
    
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