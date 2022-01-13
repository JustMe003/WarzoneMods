function Server_Created(game, settings)
	if Mod.Settings.DeployTransferHelper == true and Mod.Settings.OverridePercentage == true then 
		settings.AllowPercentageAttacks = true; 
	end
	if Mod.Settings.BonusOverrider == true then
		local OverriddenBonuses = settings.OverriddenBonuses
		local bonuses = OverriddenBonuses
		OverriddenBonuses = LoopTerritories(game, OverriddenBonuses)
		for i, v in pairs(bonuses) do
			print(OverriddenBonuses[i]);
			if OverriddenBonuses[i] == nil then
				OverriddenBonuses[i] = v;
			end
		end
		settings.OverriddenBonuses = OverriddenBonuses;
	end
--	settings.LocalDeployments = true;
end

function LoopTerritories(game, OverriddenBonuses)
	print(OverridenBonuses)
	if OverriddenBonuses == nil then OverriddenBonuses = {}; end
	for terrID, terr in pairs(game.Map.Territories) do
		OverriddenBonuses = SetToOneBonus(game, terr, OverriddenBonuses);
	end
	return OverriddenBonuses;
end


function SetToOneBonus(game, terr, OverriddenBonuses)
	if AmountOfBonuses(game, terr, OverriddenBonuses) > 1 then
		local smallestBonus = 10000;
		local smallestBonusID = -1;
		local bonusValueZero = {};
		for _, bonusID in pairs(terr.PartOfBonuses) do
			if GetValue(game, OverriddenBonuses, bonusID) ~= 0 then
				if smallestBonus > #game.Map.Bonuses[bonusID].Territories then
--					print(smallestBonus, #game.Map.Bonuses[bonusID].Territories);
					smallestBonus = #game.Map.Bonuses[bonusID].Territories;
					smallestBonusID = bonusID;
				end
			else
				table.insert(bonusValueZero, bonusID);
			end
		end
		OverriddenBonuses = OverrideBonuses(game, terr, OverriddenBonuses, smallestBonusID, bonusValueZero);
	end
	return OverriddenBonuses;
end

function OverrideBonuses(game, terr, OverriddenBonuses, exceptForBonus, bonusValueZero)
	print(game.Map.Bonuses[exceptForBonus].Name);
	for _, bonusID in pairs(terr.PartOfBonuses) do
		bool = true;
		if bonusID ~= exceptForBonus then		
			OverriddenBonuses[bonusID] = 0;
			print("overridden bonus " .. game.Map.Bonuses[bonusID].Name);
		end
	end
	return OverriddenBonuses;
end

function GetValue(game, OverriddenBonuses, bonusID)
	print(game.Map.Bonuses[bonusID].Name, OverriddenBonuses[bonusID]);
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