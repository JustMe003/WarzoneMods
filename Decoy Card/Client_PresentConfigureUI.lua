require("UI");
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	UI.Alert("This mod is very incompatible with some other mods. For more information, please check the Essentials mod")
	showConfiguration();
end

function showConfiguration();
	local win = "config";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "numberOfTurnsLabel", vert, "The maximum number of turns a decoy card will last", "Lime");
		local numberOfTurns = Mod.Settings.NumberOfTurns;
		if numberOfTurns == nil then numberOfTurns = 3; end
		newNumberField("duration", vert, 1, 10, numberOfTurns);
		newLabel(win .. "cardPiecesLabel", vert, "The number of card pieces a player need for a card", "Lime");
		local cardPieces = Mod.Settings.CardPieces;
		if cardPieces == nil then cardPieces = 6; end
		newNumberField("cardPieces", vert, 1, 15, cardPieces);
		newLabel(win .. "startAmountLabel", vert, "The number of pieces each player starts with", "Lime");
		local startAmount = Mod.Settings.StartAmount;
		if startAmount == nil then startAmount = 0; end
		newNumberField("startAmount", vert, 1, 15, startAmount);
	end
end