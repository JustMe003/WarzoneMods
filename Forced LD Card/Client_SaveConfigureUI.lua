require("Annotations");

---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)
	Mod.Settings.NumPieces = numPieces.GetValue();
    if Mod.Settings.NumPieces < 1 then alert("The number of pieces the card is divided into must be bigger or equal to 1"); end
    Mod.Settings.PiecesPerTurn = piecesPerTurn.GetValue();
    if Mod.Settings.PiecesPerTurn < 1 then alert("The number of pieces awarded per turn must be bigger or equal to 1"); end
    Mod.Settings.StartingPieces = startingPieces.GetValue();
    if Mod.Settings.StartingPieces < 0 then alert("The number of pieces given to each player at the start of the game must be a positive number"); end
    Mod.Settings.Duration = duration.GetValue();
    if Mod.Settings.Duration < 1 then alert("The card duration must be bigger or equal to 1"); end
    Mod.Settings.AIAutoplayCards = AIAutoplayCards.GetIsChecked();
    Mod.Settings.CanPlayOnTeammates = canPlayOnTeammates.GetIsChecked();
end