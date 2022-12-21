function Client_PresentSettingsUI(rootParent)
	local line = UI.CreateHorizontalLayoutGroup(rootParent);
    UI.CreateLabel(line).SetText("Players who got booted, eliminated or surrendered will also spectate the game: ").SetColor("#DDDDDD");
    if Mod.Settings.IncludeInGamePlayers == nil or Mod.Settings.IncludeInGamePlayers then
        UI.CreateLabel(line).SetText("True").SetColor("#00FF00");
    else
        UI.CreateLabel(line).SetText("False").SetColor("#FF5349");
    end
end