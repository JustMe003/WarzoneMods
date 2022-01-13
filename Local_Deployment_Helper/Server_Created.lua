function Server_Created(Game, settings)
	game = Game;
	if Mod.Settings.DeployTransferHelper == true and Mod.Settings.OverridePercentage == true then 
		settings.AllowPercentageAttacks = true; 
	end
	if Mod.Settings.BonusOverrider == true then
		OverriddenBonuses = settings.OverriddenBonuses;
		loopTerritories();
		for i, v in pairs(OverriddenBonuses) do print(i, v); end
		settings.OverriddenBonuses = OverriddenBonuses;
	end
	settings.LocalDeployments = true;
end

function loopTerritories()
	if OverriddenBonuses == nil then OverriddenBonuses = {}; end
	for terrID, terr in pairs(game.Map.Territories) do
		if getBonusCount(terr) > 1 then
			overrideBonuses(terr, getSmallestBonusID(terr));
		end
	end
end

function overrideBonuses(terr, exceptForBonusID)
	for _, bonusID in pairs(terr.PartOfBonuses) do
		if bonusID ~= exceptForBonusID and getBonusValue(bonusID) ~= 0 then
			OverriddenBonuses[bonusID] = 0;
		end
	end
end

function getBonusCount(terr)
	local amount = 0;
	for _, bonusID in pairs(terr.PartOfBonuses) do
		if getBonusValue(bonusID) ~= 0 then
			amount = amount + 1;
		end
	end
	return amount;
end

function getBonusValue(bonusID)
	if OverriddenBonuses[bonusID] ~= nil then
		return OverriddenBonuses[bonusID];
	else
		return game.Map.Bonuses[bonusID].Amount;
	end
end

function getSmallestBonusID(terr)
	local terrCount = 10000;
	local smallestBonusID = 0;
	for _, bonusID in pairs(terr.PartOfBonuses) do
		if getBonusValue(bonusID) ~= 0 then
			if #game.Map.Bonuses[bonusID].Territories < terrCount then
				terrCount = #game.Map.Bonuses[bonusID].Territories;
				smallestBonusID = bonusID;
			end
		end
	end
	return smallestBonusID;
end