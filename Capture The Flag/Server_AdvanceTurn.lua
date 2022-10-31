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
		if game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID ~= WL.PlayerID.Neutral and result.IsAttack and result.IsSuccessful then
			if getNumFlags(result.DefendingArmiesKilled, true) > 0 then
				lostFlag(game, addNewOrder, order.To, result.DefendingArmiesKilled, order.PlayerID, game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID);
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

function lostFlag(game, addNewOrder, terrID, armies, p, flagLoser)
	for _, unit in pairs(armies.SpecialUnits) do			-- there can be more than 1 flag that get's captured
		if unit.Name == "Flag" or unit.Name == "Captured Flag" then
			local mod = WL.TerritoryModification.Create(terrID);
			mod.AddSpecialUnits = {getCapturedFlag(p)};
			local event = WL.GameOrderEvent.Create(p, "Captured Flag", {}, {mod});
			event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
			addNewOrder(event);
			if unit.Name == "Flag" then
				if game.Game.PlayingPlayers[flagLoser].Team ~= -1 then
					if not teamHasEnoughFlags(game, terrID, game.Game.PlayingPlayers[flagLoser].Team) then
						event = WL.GameOrderEvent.Create(flagLoser, getTeamName(game.Game.PlayingPlayers[flagLoser].Team) .. " lost to many flags", nil,  eliminateTeam(game, terrID, game.Game.PlayingPlayers[flagLoser].Team));
						event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
						addNewOrder(event);
					end
				else
					if not playerHasEnoughFlags(game, terrID, flagLoser) then
						event = WL.GameOrderEvent.Create(flagLoser, game.Game.PlayingPlayers[flagLoser].DisplayName(nil, false) .. " lost to many flags", nil, eliminatePlayer(game, terrID, flagLoser));
						event.JumpToActionSpotOpt = WL.RectangleVM.Create(game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY, game.Map.Territories[terrID].MiddlePointX, game.Map.Territories[terrID].MiddlePointY);
						addNewOrder(event);
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

