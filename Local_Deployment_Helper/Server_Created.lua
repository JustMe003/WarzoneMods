function Server_Created(game, settings)
	if Mod.Settings.DeployTransferHelper == true and Mod.Settings.OverridePercentage == true then 
		settings.AllowPercentageAttacks = true; 
	end
	if Mod.Settings.BonusOverrider == true then
		OverriddenBonuses = LoopTerritories(game, settings.OverriddenBonuses)
	end
	settings.OverriddenBonuses = OverriddenBonuses;
	settings.LocalDeployments = true;
end

function LoopTerritories(game, OverriddenBonuses)
	if OverriddenBonuses == nil then OverriddenBonuses = {}; end
	for terrID, terr in pairs(game.Map.Territories) do
--		print("Territory " .. terr.Name);
		OverriddenBonuses = SetToOneBonus(game, terr, OverriddenBonuses);
	end
	return OverriddenBonuses;
end


function SetToOneBonus(game, terr, OverriddenBonuses)
	if AmountOfBonuses(game, terr, OverriddenBonuses) > 1 then
		local smallestBonus = 10000;
		local smallestBonusID = -1;
		for _, bonusID in pairs(terr.PartOfBonuses) do
			if GetValue(game, OverriddenBonuses, bonusID) ~= 0 then
				if math.min(smallestBonus, #game.Map.Bonuses[bonusID].Territories) == #game.Map.Bonuses[bonusID].Territories then
--					print(smallestBonus, #game.Map.Bonuses[bonusID].Territories);
					smallestBonus = #game.Map.Bonuses[bonusID].Territories;
					smallestBonusID = bonusID;
				end
			end
		end
		OverriddenBonuses = OverrideBonuses(game, terr, OverriddenBonuses, smallestBonusID);
	end
	return OverriddenBonuses;
end

function OverrideBonuses(game, terr, OverriddenBonuses, exceptForBonus)
--	print(game.Map.Bonuses[exceptForBonus].Name);
	for _, bonusID in pairs(terr.PartOfBonuses) do
		if bonusID ~= exceptForBonus then
			OverriddenBonuses[bonusID] = 0;
--			print("overridden bonus " .. game.Map.Bonuses[bonusID].Name);
		end
	end
	return OverriddenBonuses;
end

function GetValue(game, OverriddenBonuses, bonusID)
	if OverriddenBonuses[bonusID] ~= nil then
		return OverriddenBonuses[bonusID];
	else
		return game.Map.Bonuses[bonusID].Amount;
	end
end

function AmountOfBonuses(game, terr, OverriddenBonuses)
	local amount = 0;
	for _, bonusID in pairs(terr.PartOfBonuses) do
--		print(terr.Name .. " exists in " .. game.Map.Bonuses[bonusID].Name, bonusID);
		if GetValue(game, OverriddenBonuses, bonusID) ~= 0 then amount = amount + 1; end
	end
--	print(amount, terr.Name);
	return amount;
end