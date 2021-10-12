
function Client_PresentSettingsUI(rootParent)
--	UI.CreateLabel(rootParent).SetText("AI's can play reinforcement cards: " .. Mod.Settings.CanPlayReinforcement);
	UI.CreateLabel(rootParent).SetText("AI's can play emergency blockade cards: ", Mod.Settings.CanPlayEMB,false,true, "");
	UI.CreateLabel(rootParent).SetText("AI's can play diplomacy cards: ", Mod.Settings.CanPlayDiplomacy,false,true, "");
	UI.CreateLabel(rootParent).SetText("AI's can play sanctions cards: ", Mod.Settings.CanPlaySanctions,false,true, "");
	UI.CreateLabel(rootParent).SetText("AI's can play blockade cards: ", Mod.Settings.CanPlayBlockade,false,true, "");
	UI.CreateLabel(rootParent).SetText("AI's can play bomb cards: ", Mod.Settings.CanPlayBomb,false,true, "");
end

