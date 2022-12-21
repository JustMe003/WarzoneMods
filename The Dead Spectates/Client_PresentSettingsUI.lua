function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
    UI.CreateLabel(vert).SetText("Players who got booted, eliminated or surrendered will also spectate the game: " .. Mod.Settings.IncludeInGamePlayers).SetColor("#DDDDDD");
end