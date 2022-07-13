require("util");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	UI.CreateLabel(rootParent).SetText("The income threshold this turn is: " .. round(getIncomeThreshold(game.Game.TurnNumber)))
end