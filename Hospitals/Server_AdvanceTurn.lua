function Server_AdvanceTurn_Start(game, addNewOrder)
	Game = game;
	AddNewOrder = addNewOrder;
	data = Mod.PublicGameData;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
		if not orderResult.IsNullified and orderResult.IsAttack then
			if game.ServerGame.LatestTurnStanding.Territories[order.To].Structures ~= nil then
				if game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.Hospital] ~= nil then
					if data.Hospitals[order.To] ~= nil then
						if Mod.Settings.upgradeSystem then
							print("hospital has been taken");
							data.Hospitals[order.To].Level = 1;
							data.Hospitals[order.To].Progress = 0;
							data.Hospitals[order.To].Territories = setTerritories(order.To);
							for i, v in pairs(data.Hospitals[order.To].Territories) do print(i, v); end
						end
					else
						data.Hospitals[order.To] = createHospital(order.To);
					end
				end
			end
			recoverArmies(game, data, addNewOrder, orderResult.AttackingArmiesKilled.NumArmies, order.From);
			if game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID ~= WL.PlayerID.Neutral then
				recoverArmies(game, data, addNewOrder, orderResult.DefendingArmiesKilled.NumArmies, order.To);
			end
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	if Mod.Settings.upgradeSystem then
		for hosID,_ in pairs(data.Hospitals) do
			if hospitalLeveledUp(data.Hospitals[hosID]) then
				data.Hospitals[hosID].Level = data.Hospitals[hosID].Level + 1;
				data.Hospitals[hosID].Progress = 0;
				data.Hospitals[hosID].Territories = increaseRange(data.Hospitals[hosID].Territories);
				addNewOrder(WL.GameOrderCustom.Create(game.ServerGame.LatestTurnStanding.Territories[hosID].OwnerPlayerID, "Hospital at " .. game.Map.Territories[hosID].Name .. " leveled up! It is now level " .. data.Hospitals[hosID].Level, ""))
			else
				data.Hospitals[hosID].Progress = data.Hospitals[hosID].Progress + 1;
			end
		end
	end
	Mod.PublicGameData = data;
end

function setTerritories(terrID)
	local t = {};
	t[terrID] = 0;
	for i = 1, Mod.Settings.maximumHospitalRange do
--		print(i, getValue(i), Mod.PublicGameData.Values[i])
		if i == 1 then
			for connID, _ in pairs(Game.Map.Territories[terrID].ConnectedTo) do
				t[connID] = getValue(i);
--				print(Game.Map.Territories[connID].Name, t[connID]);
			end
		else
			for j, v in pairs(t) do
				for connID, _ in pairs(Game.Map.Territories[j].ConnectedTo) do
					if t[connID] == nil then
						if v == getValue(i-1) then
							t[connID] = getValue(i);
--							print(Game.Map.Territories[connID].Name, t[connID]);
						end
					end
				end
			end
		end
	end
	return t;
end

function getValue(range)
	if Mod.Settings.upgradeSystem then
		return 2 - range;
	else
		return Mod.Settings.maximumHospitalRange - range + 1;
	end
end

function createHospital(terrID)
	local hospital = {};
	hospital.Territories = setTerritories(terrID);
	if Mod.Settings.upgradeSystem then
		hospital.Progress = 0;
		hospital.Level = 1;
	end
	return hospital;
end

function recoverArmies(game, Data, addNewOrder, armiesKilled, terrID)
	for hosID, hospital in pairs(Data.Hospitals) do
		if hospital.Territories[terrID] ~= nil then
			if hosID ~= terrID then
				if game.ServerGame.LatestTurnStanding.Territories[hosID].OwnerPlayerID == game.ServerGame.LatestTurnStanding.Territories[terrID].OwnerPlayerID then
				--	print(game.Map.Territories[terrID].Name, game.Map.Territories[hosID].Name, hospital.Territories[terrID])
					if hospital.Territories[terrID] > 0 then
						if math.floor(armiesKilled / 100 * data.Values[hospital.Territories[terrID]]) > 0 then
							local numArmies = game.ServerGame.LatestTurnStanding.Territories[hosID].NumArmies.NumArmies
							local mod = WL.TerritoryModification.Create(hosID);
							mod.SetArmiesTo = numArmies + math.floor(armiesKilled / 100 * Data.Values[hospital.Territories[terrID]]);
						--	print(mod.SetArmiesTo, tostring(Mod.PublicGameData.Values[hospital.Territories[order.To]]) .. "%")
							addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[hosID].OwnerPlayerID, "recovered " .. math.floor(armiesKilled / 100 * Data.Values[hospital.Territories[terrID]]) .. " (" .. Data.Values[hospital.Territories[terrID]] .. "%) armies at " .. game.Map.Territories[hosID].Name, {}, {mod}), false);
							if Mod.Settings.upgradeSystem then
								if hospitalLeveledUp(data.Hospitals[hosID]) then
									data.Hospitals[hosID].Progress = 0;
									data.Hospitals[hosID].Level = data.Hospitals[hosID].Level + 1;
									data.Hospitals[hosID].Territories = increaseRange(data.Hospitals[hosID].Territories)
									addNewOrder(WL.GameOrderCustom.Create(game.ServerGame.LatestTurnStanding.Territories[hosID].OwnerPlayerID, "Hospital at " .. game.Map.Territories[hosID].Name .. " leveled up! It is now level " .. data.Hospitals[hosID].Level, ""))
								else
									data.Hospitals[hosID].Progress = data.Hospitals[hosID].Progress + 1;
								end
							end
						end
					end
				end
			end
		end
	end
end

function hospitalLeveledUp(hospital)
--	print(hospital.Progress + 1, math.pow(Mod.Settings.amountOfLevels, hospital.Level), hospital.Level < Mod.Settings.maximumHospitalRange - 1);
	return hospital.Progress + 1 >= math.pow(Mod.Settings.amountOfLevels, hospital.Level) and hospital.Level < Mod.Settings.maximumHospitalRange - 1;
end

function increaseRange(listOfTerr, int)
	int = int or 1
	for i,_ in pairs(listOfTerr) do
		listOfTerr[i] = math.min(listOfTerr[i] + int, Mod.Settings.maximumHospitalRange);
	end
	return listOfTerr;
end