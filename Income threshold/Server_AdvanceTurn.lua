require("util");
function Server_AdvanceTurn_Start(game, addNewOrder)
	print(getIncomeThreshold(game.ServerGame.Game.TurnNumber));
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local highestIncome = 0;
	local incomeThreshold = getIncomeThreshold(game.ServerGame.Game.TurnNumber);
	local playersBelowThreshold = {};
	local someoneAboveThreshold = false;
	for _, p in pairs(game.ServerGame.Game.PlayingPlayers) do
		if p.Income(0, game.ServerGame.LatestTurnStanding, true, true).Total < incomeThreshold then
			table.insert(playersBelowThreshold, p);
			highestIncome = math.max(highestIncome, p.Income(0, game.ServerGame.LatestTurnStanding, true, true).Total);
		else
			someoneAboveThreshold = true;
		end
	end
	for _, p in pairs(playersBelowThreshold) do
		if someoneAboveThreshold or p.Income(0, game.ServerGame.LatestTurnStanding, true, true).Total ~= highestIncome then
			local mods = {};
			for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
				if terr.OwnerPlayerID == p.ID then
					local mod = WL.TerritoryModification.Create(terr.ID);
					mod.SetOwnerOpt = WL.PlayerID.Neutral;
					table.insert(mods, mod);
				end
			end
			addNewOrder(WL.GameOrderEvent.Create(p.ID, p.DisplayName(nil, false) .. " was with " .. p.Income(0, game.ServerGame.LatestTurnStanding, true, true).Total .. " income below the income threshold", nil, mods));
		end
	end
end

function getIncomeThreshold(n)
	local choice_table =
	{
		["a.x + c"] = Mod.Settings.A * n + Mod.Settings.C,
		["a.x² + b.x + c"] = Mod.Settings.A * n^2 + Mod.Settings.B * n + Mod.Settings.C,
		["a.x² + d.x.√x + b.x + e.√x + c"] = Mod.Settings.A * n^2 + Mod.Settings.D * n^1.5 + Mod.Settings.B * n + Mod.Settings.E * n^0.5 + Mod.Settings.C,
		["a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"] = Mod.Settings.A * n^2 + Mod.Settings.D * n^1.5 + Mod.Settings.B * n + Mod.Settings.E * n^0.5 + Mod.Settings.F * math.log(n) + Mod.Settings.C,
	}
	return choice_table[Mod.Settings.Formula]
end