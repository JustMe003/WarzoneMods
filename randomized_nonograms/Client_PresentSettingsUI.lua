
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent).SetText("Heigth of nonogram: " .. Mod.Settings.NonogramHeigth);
	UI.CreateLabel(rootParent).SetText("Width of nonogram: " .. Mod.Settings.NonogramWidth);
	UI.CreateLabel(rootParent).SetText("Density of nonogram: " .. Mod.Settings.NonogramDensity);
	UI.CreateLabel(rootParent).SetText("Custom local deployments: " .. tostring(Mod.Settings.LocalDeployments));
end

