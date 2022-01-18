require("utilities");

function Client_GameRefresh(Game)
	game = Game;
	if game.Us == nil then return; end
	local playerData = Mod.PlayerGameData;
	print(Mod.PlayerGameData.LastTurnSinceMessage)
	if playerData.LastTurnSinceMessage == nil then playerData.LastTurnSinceMessage = game.Game.TurnNumber; end
	if game.Game.TurnNumber > 0 then
		if playerShouldPick(game.Us.ID) and game.Game.TurnNumber <= Mod.PublicGameData.DurationDistributionStage and game.Game.TurnNumber > playerData.LastTurnSinceMessage then
			UI.Alert("In this turn you're able to pick 1 more territory. Open the Extended Distribution Phase mod menu to pick");
			playerData.LastTurnSinceMessage = game.Game.TurnNumber;
			Mod.PlayerGameData = playerData
		end
	end
	if (game.Game.TurnNumber - 1 == Mod.PublicGameData.DurationDistributionStage or Mod.PublicGameData.AbortDistribution) and Mod.PlayerGameData.hasSeenPlayMessage ~= nil then
		UI.Alert("From this turn the game will advance normally again, any picks made will get ignored")
		playerData.hasSeenPlayMessage = true
		Mod.PlayerGameData = playerData;
	end
end


function playerShouldPick(PlayerID)
	if Mod.Settings.numberOfGroups == 1 then return true; end
	return valueInTable(Mod.PublicGameData.Groups[getGroup(game.Game.TurnNumber, Mod.PublicGameData.numberOfGroups)], PlayerID);
end