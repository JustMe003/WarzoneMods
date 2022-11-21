function Server_AdvanceTurn_Start(game,addNewOrder)
	data = Mod.PublicGameData;
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
		if getNumFlags(result.ActualArmies, true) > 0 then
			local t = {};
			for _, unit in pairs(result.ActualArmies.SpecialUnits) do
				if not ((unit.Name == "Flag" or unit.Name == "Captured Flag") and data.Cooldowns[unit.ID] ~= nil) then
					table.insert(t, unit);
				elseif unit.Name == "Flag" or unit.Name == "Captured Flag" and Mod.Settings.Cooldown > 0 then
					data.Cooldowns[unit.ID] = Mod.Settings.Cooldown;
				end
			end
			result.ActualArmies = WL.Armies.Create(result.ActualArmies.NumArmies, t);
		end
		if getNumFlags(result.AttackingArmiesKilled, true) > 0 then
			local arr = {};
			for _, unit in ipairs(result.AttackingArmiesKilled.SpecialUnits) do
				if not (unit.Name == "Flag" or unit.Name == "Captured Flag") then
					table.insert(arr, unit);
				end
			end
			result.AttackingArmiesKilled = WL.Armies.Create(result.AttackingArmiesKilled.NumArmies, arr);
		end
		if result.IsAttack then
			if getNumFlags(result.DefendingArmiesKilled, true) > 0 then
				if result.IsSuccessful then
					lostFlag(game, addNewOrder, order.To, result.DefendingArmiesKilled, order.PlayerID);
				else
					local t = {};
					for _, unit in pairs(result.DefendingArmiesKilled.SpecialUnits) do
						if not (unit.Name == "Flag" or unit.Name == "Captured Flag") then
							table.insert(t, unit);
						end
					end
					result.DefendingArmiesKilled = WL.Armies.Create(result.DefendingArmiesKilled.NumArmies, t);
				end
			end
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local t = {};
	for p, _ in pairs(game.Game.PlayingPlayers) do
		t[p] = 0;
	end
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if getNumFlags(terr.NumArmies, true) > 0 then
			for _, unit in pairs(terr.NumArmies.SpecialUnits) do
				if (unit.Name == "Flag" or unit.Name == "Captured Flag") and data.Cooldowns[unit.ID] ~= nil then
					data.Cooldowns[unit.ID] = data.Cooldowns[unit.ID] - 1;
					if data.Cooldowns[unit.ID] == 0 then data.Cooldowns[unit.ID] = nil; end
				end
				if unit.Name == "Captured Flag" and terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
					t[terr.OwnerPlayerID] = t[terr.OwnerPlayerID] + 1;
				end
			end
		end
	end
	for p, v in pairs(t) do
		if v > 0 and Mod.Settings.IncomeBoost > 0 then
			addNewOrder(WL.GameOrderEvent.Create(p, "Income for controlling captured flags", {}, {}, {}, {WL.IncomeMod.Create(p, v * Mod.Settings.IncomeBoost, "Controlling captured flags")}));
		end
	end
	Mod.PublicGameData = data;
end


function getNumFlags(armies, allFlags)
	local c = 0;
	for _, unit in pairs(armies.SpecialUnits) do
		if unit.Name == "Flag" or (allFlags and unit.Name == "Captured Flag") then
			c = c + 1;
		end
	end
	return c;
end

function lostFlag(game, addNewOrder, terrID, armies, p)
	for _, unit in pairs(armies.SpecialUnits) do			-- there can be more than 1 flag that gets captured
		if unit.Name == "Flag" or unit.Name == "Captured Flag" then
			if unit.OwnerID == p and unit.Name == "Flag" then
				local mod = WL.TerritoryModification.Create(terrID);
				mod.AddSpecialUnits = {getFlag(p)};
				local event = WL.GameOrderEvent.Create(p, "Re-captured Flag", {}, {mod});
				event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
				addNewOrder(event, true);
				return;
			else
				local mod = WL.TerritoryModification.Create(terrID);
				mod.AddSpecialUnits = {getCapturedFlag(p)};
				local event = WL.GameOrderEvent.Create(p, "Captured Flag", {}, {mod});
				event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
				addNewOrder(event, true);
			end
			if unit.Name == "Flag" then
				print(unit.OwnerID);
				if game.Game.PlayingPlayers[unit.OwnerID].Team ~= -1 then
					if not teamHasEnoughFlags(game, terrID, game.Game.PlayingPlayers[unit.OwnerID].Team) then
						event = WL.GameOrderEvent.Create(unit.OwnerID, getTeamName(game.Game.PlayingPlayers[unit.OwnerID].Team) .. " lost to many flags", nil,  eliminateTeam(game, terrID, game.Game.PlayingPlayers[unit.OwnerID].Team));
						event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
						addNewOrder(event, true);
					end
				else
					if not playerHasEnoughFlags(game, terrID, unit.OwnerID) then
						event = WL.GameOrderEvent.Create(unit.OwnerID, game.Game.PlayingPlayers[unit.OwnerID].DisplayName(nil, false) .. " lost to many flags", nil, eliminatePlayer(game, terrID, unit.OwnerID));
						event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
						addNewOrder(even, true);
					end
				end
			end
		end
	end
end

function playerHasEnoughFlags(game, terrID, p)
	local c = 0;
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID == p and terr.ID ~= terrID then
			c = c + getNumFlags(terr.NumArmies);
		end
	end
	return c > math.max(data.NFlags - Mod.Settings.NFlagsForLose, 0);
end

function teamHasEnoughFlags(game, terrID, team)
	local c = 0;
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and game.Game.PlayingPlayers[terr.OwnerPlayerID].Team == team and terrID ~= terr.ID then
			c = c + getNumFlags(terr.NumArmies);
		end
	end
	return c > math.max(data.NFlags - Mod.Settings.NFlagsForLose, 0);
end

function eliminatePlayer(game, terrID, p)
	local mods = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID == p and terr.ID ~= terrID then
			local mod = WL.TerritoryModification.Create(terr.ID);
			mod.SetOwnerOpt = WL.PlayerID.Neutral;
			table.insert(mods, mod);
		end
	end
	return mods;
end

function eliminateTeam(game, terrID, teamID)
	local mods = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and terr.ID ~= terrID then
			if game.Game.PlayingPlayers[terr.OwnerPlayerID].Team == teamID then
				local mod = WL.TerritoryModification.Create(terr.ID);
				mod.SetOwnerOpt = WL.PlayerID.Neutral;
				table.insert(mods, mod);
			end
		end
	end
	return mods;
end

function getTeamName(n)
	local list = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	local ret = "Team ";
	if n > #list then
		ret = ret .. list[math.floor(n/#list)];
	end
	ret = ret .. list[n % #list + 1];
	return ret;
end

function getCapturedFlag(p)
	local builder = WL.CustomSpecialUnitBuilder.Create(p);
	builder.Name = "Captured Flag";
	builder.IncludeABeforeName = true;
	builder.ImageFilename = "FlagCaptured.png";
	builder.AttackPower = 0;
	builder.DefensePower = 0;
	builder.DamageToKill = 0;
	builder.DamageAbsorbedWhenAttacked = 0;
	builder.CombatOrder = 0;
	builder.CanBeGiftedWithGiftCard = false;
	builder.CanBeTransferredToTeammate = true;
	builder.CanBeAirliftedToSelf = true;
	builder.CanBeAirliftedToTeammate = true;
	builder.IsVisibleToAllPlayers = false;
	return builder.Build();
end

function getFlag(p)
	local builder = WL.CustomSpecialUnitBuilder.Create(p);
	builder.Name = 'Flag';
	builder.IncludeABeforeName = true;
	builder.ImageFilename = 'Flag.png';
	builder.AttackPower = 0;
	builder.DefensePower = 0;
	builder.DamageToKill = 0;
	builder.DamageAbsorbedWhenAttacked = 0;
	builder.CombatOrder = 0;
	builder.CanBeGiftedWithGiftCard = false;
	builder.CanBeTransferredToTeammate = true;
	builder.CanBeAirliftedToSelf = true;
	builder.CanBeAirliftedToTeammate = true;
	builder.IsVisibleToAllPlayers = false;
	return builder.Build();
end
