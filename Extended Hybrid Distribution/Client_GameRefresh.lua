require("utilities");

function Client_GameRefresh(Game)
	game = Game;
	if game.Us == nil then return; end
	local playerData = Mod.PlayerGameData;
	print(playerData.LastTurnSinceMessage)
	if playerData.LastTurnSinceMessage == nil and game.Settings.AutomaticTerritoryDistribution then 
		local payload = {};
		payload.Message = "LastTurnSinceMessage";
		payload.TurnNumber = game.Game.TurnNumber;
		game.SendGameCustomMessage("updating alerts...", payload, function() end);
	elseif playerData.LastTurnSinceMessage == nil then
		local payload = {};
		payload.Message = "LastTurnSinceMessage";
		payload.TurnNumber = game.Game.TurnNumber;
		game.SendGameCustomMessage("updating alerts...", payload, function() end);
	end
	if game.Game.TurnNumber > 0 then
		if playerShouldPick(game.Us.ID) and game.Game.TurnNumber <= Mod.PublicGameData.DurationDistributionStage and game.Game.TurnNumber > playerData.LastTurnSinceMessage then
			UI.Alert("In this turn you're able to pick 1 more territory. Open the Extended Distribution Phase mod menu to pick");
			local payload = {};
			payload.Message = "LastTurnSinceMessage";
			payload.TurnNumber = game.Game.TurnNumber;
			game.SendGameCustomMessage("updating alerts...", payload, function() end)
		end
	end
	if (game.Game.TurnNumber - 1 == Mod.PublicGameData.DurationDistributionStage or Mod.PublicGameData.AbortDistribution) and Mod.PlayerGameData.HasSeenPlayMessage ~= nil then
		UI.Alert("From this turn the game will advance normally again, any picks made will get ignored")
		local payload = {};
		payload.Message = "HasSeenPlayMessage";
		game.SendGameCustomMessage("updating alerts...", payload, function() end)
	end
end


function playerShouldPick(PlayerID)
	if Mod.Settings.numberOfGroups == 1 then return true; end
	return valueInTable(Mod.PublicGameData.Groups[getGroup(game.Game.TurnNumber, Mod.PublicGameData.numberOfGroups)], PlayerID);
end