function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent).SetText("Players get a devensive position every " .. Mod.Settings.TurnsToGetDevPos .. " turns");
	UI.CreateLabel(rootParent).SetText("Territories with a devensive position have " .. Mod.Settings.ExtraDevKillrate .. "% higher devensive killrate");
end