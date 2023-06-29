require("GiveIncome")

function Server_AdvanceTurn_End(game, addNewOrder)
	if Mod.PublicGameData.IsValid then
		local incomeMods = {};
		for p, _ in pairs(game.Game.PlayingPlayers) do
			incomeMods[p] = {};
		end
		for bonusID, bonus in pairs(Mod.PublicGameData.Bonuses) do
			local p = WL.PlayerID.Neutral;
			for _, terr in pairs(bonus) do
				local owner = game.ServerGame.LatestTurnStanding.Territories[terr].OwnerPlayerID;
				if owner ~= WL.PlayerID.Neutral and (p == WL.PlayerID.Neutral or p == owner) then
					p = owner;
				else
					p = WL.PlayerID.Neutral;
					break;
				end
			end
			if p ~= WL.PlayerID.Neutral then
				table.insert(incomeMods[p], WL.IncomeMod.Create(p, #bonus, "Controls bonus " .. bonusID));
			end
		end
		for p, _ in pairs(game.Game.PlayingPlayers) do
			addNewOrder(WL.GameOrderEvent.Create(p, "Added income", {}, {}, {}, incomeMods[p]));
		end
	end
end