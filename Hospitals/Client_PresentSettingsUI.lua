function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText("Note that the number of hospitals can be overridden by the mod").SetColor("#AA3333");
	UI.CreateEmpty(vert).SetPreferredHeight(20);
	
	UI.CreateLabel(vert).SetText("Number of hospitals set by the game creator: " .. Mod.Settings.numberOfHospitals).SetColor("#DDDDDD");
	UI.CreateLabel(vert).SetText("Minimum recover percentage: " .. Mod.Settings.recoverPercentageMinimum).SetColor("#DDDDDD");
	UI.CreateLabel(vert).SetText("Maximum recover percentage: " .. Mod.Settings.recoverPercentageMaximum).SetColor("#DDDDDD");
	UI.CreateLabel(vert).SetText("Maximum recover range: " .. Mod.Settings.maximumHospitalRange).SetColor("#DDDDDD");
end