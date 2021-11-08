
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent).SetText("AI's can play emergency blockade cards: " .. tostring(Mod.Settings.CanPlayEMB));
	UI.CreateLabel(rootParent).SetText("AI's can play diplomacy cards: " .. tostring(Mod.Settings.CanPlayDiplomacy));
	UI.CreateLabel(rootParent).SetText("AI's can play sanctions cards: " .. tostring(Mod.Settings.CanPlaySanctions));
	UI.CreateLabel(rootParent).SetText("AI's can play blockade cards: " .. tostring(Mod.Settings.CanPlayBlockade));
	UI.CreateLabel(rootParent).SetText("AI's can play bomb cards: " .. tostring(Mod.Settings.CanPlayBomb));
end

