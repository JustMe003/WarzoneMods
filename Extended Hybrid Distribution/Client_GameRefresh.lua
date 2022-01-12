require("utilities");

function Client_GameRefresh(Game)
	game = Game;
	if game.Us == nil then return; end
	if game.Game.TurnNumber > 0 then
		if playerShouldPick(game.Us.ID) and game.Game.TurnNumber <= Mod.PublicGameData.DurationDistributionStage then
			UI.Alert("In this turn you're able to pick " .. Mod.Settings.picksPerTurn .. " more territories. Open the Extended Distribution Phase mod menu to pick");
		end
	end
	if (game.Game.TurnNumber - 1 == Mod.PublicGameData.DurationDistributionStage or Mod.PublicGameData.AbortDistribution) and Mod.PlayerGameData.hasSeenPlayMessage ~= nil then
		UI.Alert("From this turn the game will advance normally again, any picks made will get ignored")
		local playerData = Mod.PlayerGameData;
		playerData.hasPlayeenMessage = true
		Mod.PlayerGameData = playerData;
	end
end


function playerShouldPick(PlayerID)
	if Mod.Settings.numberOfGroups == 1 then return true; end
	return valueInTable(Mod.PublicGameData.Groups[getGroup(game.Game.TurnNumber, Mod.PublicGameData.numberOfGroups)], PlayerID);
end