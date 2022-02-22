function Client_SaveConfigureUI(alert)
	Mod.Settings.NumberOfTurns = getValue("duration");
	Mod.Settings.CardPieces = getValue("cardPieces");
	Mod.Settings.StartAmount = getValue("startAmount");
	
	if Mod.Settings.NumberOfTurns < 1 then alert("The duration cannot be smaller than 1"); end
	if Mod.Settings.CardPieces < 1 then alert("The amount of card pieces needed for a card cannot be smaller than 1"); end
	if Mod.Settings.StartAmount < 0 then alert("The amount of pieces each player starts with cannot be smaller than 0"); end
end