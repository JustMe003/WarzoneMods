require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	local vert = newVerticalGroup("vert", "root");
	newLabel("durationLabel", vert, "Maximum duration of a decoy card: " .. tostring(Mod.Settings.AmountOfTurns));
	newLabel("cardPiecesLabel", vert, "Card pieces needed for a card: " .. tostring(Mod.Settings.CardPieces));
	newLabel("startAmount", vert, "Card pieces each players starts with: " .. tostring(Mod.Settings.StartAmount));
end