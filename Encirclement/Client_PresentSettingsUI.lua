require("UI");
function Client_PresentSettingsUI(rootParent)
	Init(rootParent);
    local root = GetRoot();
    local colors = GetColors();

    local line = CreateHorz(root);
    CreateLabel(line).SetText("Deployments made on encircled territories are skipped: ").SetColor(colors.TextColor);
    if Mod.Settings.DoNotAllowDeployments then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
    else
        CreateLabel(line).SetText("No").SetColor(colors.Red);
    end
    
    line = CreateHorz(root);
    CreateLabel(line).SetText("Modify amies/owner from encircled territories: ").SetColor(colors.TextColor);
    if Mod.Settings.RemoveArmiesFromEncircledTerrs then
        CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        
        line = CreateHorz(root);
        CreateLabel(line).SetText("Encircled territories turn neutral immediately: ").SetColor(colors.TextColor);
        if Mod.Settings.TerritoriesTurnNeutral then
            CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        else
            CreateLabel(line).SetText("No").SetColor(colors.Red);
            
            line = CreateHorz(root);
            CreateLabel(line).SetText("The percentage of armies lost when encircled: ").SetColor(colors.TextColor);
            CreateLabel(line).SetText(rounding(Mod.Settings.PercentageLost, 2)).SetColor(colors.Cyan);
        end    
    else
        CreateLabel(line).SetText("No").SetColor(colors.Red);
    end
end

function rounding(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
