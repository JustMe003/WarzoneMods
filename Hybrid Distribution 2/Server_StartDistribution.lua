require('Utilities');

function Server_StartDistribution(game, standing)
    
	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher("5.17")) then
		print("You must update your app to the latest version to use the Hybrid Distribution mod");
		return;
	end

    local terrs = {};
	local doNotDistribute;
	if (Mod.Settings.takeDistributionTerr == nil or Mod.Settings.takeDistributionTerr == false) then
		doNotDistribute = WL.PlayerID.AvailableForDistribution;
	else
		doNotDistribute = WL.PlayerID.Neutral;
	end
    --Collect every territory that we could distribute to
    for _, territory in pairs(standing.Territories) do
        if (territory.OwnerPlayerID ~= doNotDistribute) then
            table.insert(terrs, territory);
        end
    end

    --Randomize order
    shuffle(terrs);

    --Collect all players that are eligible for being distributed to
    local players = {};

    for _,gp in pairs(game.Game.PlayingPlayers) do
        table.insert(players, gp);
    end
	
    local numTerrs = Mod.Settings.NumTerritories; --num territories each player will get
	if (Mod.Settings.takeDistributionTerr == nil or Mod.Settings.takeDistributionTerr == false) then
		if (numTerrs * #players > #terrs) then numTerrs = math.floor(#terrs / #players); end; --if there are fewer terrs than what's requested, reduce how many we'll change
	else
		if (numTerrs * #players > #terrs - (game.Settings.LimitDistributionTerritories * #players)) then numTerrs = math.floor((#terrs - (game.Settings.LimitDistributionTerritories * #players)) / #players); end; --Try to remain the original setting LimitDistributionTerritories and to modify the number or auto distributed territories
	end	

    --Change owners to players
	local numberOfArmies = 0;
	if (Mod.Settings.setArmiesToInDistribution == nil or Mod.Settings.setArmiesToInDistribution == false) then
		numberOfArmies = game.Settings.InitialNonDistributionArmies; --Without this line it can occur that players get wastelands and thus more or less armies than their opponents
	else
		numberOfArmies = game.Settings.InitialPlayerArmiesPerTerritory;
	end
	
    local i = 1;
    for terrIndex=1,numTerrs do
        for _,gp in pairs(players) do
            terrs[i].OwnerPlayerID = gp.ID;
			terrs[i].NumArmies = WL.Armies.Create(numberOfArmies, {});
            i = i + 1;	
        end
    end
end