require("Annotations");
require("UI");

---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
	Init();
    local colors = GetColors();

    local root = CreateVert(rootParent);
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("The number of hills: ").SetColor(colors.TextColor);
        CreateLabel(line).SetText(Mod.Settings.NumHills).SetColor(colors.Aqua);
        CreateLabel(line).SetPreferredWidth(10);
    end, "The total number of hills that are in the game. Check in the mod menu where they are");
    
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("The number of turns: ").SetColor(colors.TextColor);
        CreateLabel(line).SetText(Mod.Settings.NumTurns).SetColor(colors.Aqua);
        CreateLabel(line).SetPreferredWidth(10);
    end, "The number of successive turns you need to control all the hills in order to win the game");
end