require("util");
function Server_StartGame(game, standing)
	local playerTerrs = {};
	for p, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		playerTerrs[p] = {};
	end
	for _, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
			table.insert(playerTerrs[terr.OwnerPlayerID], terr.ID)
		end
	end
	if Mod.Settings.AutoDistributeUnits then
		local s = standing;
		local numUnits = getAmountOfUnits(playerTerrs);
		for p, _ in pairs(playerTerrs) do
			local terrs = clone(playerTerrs[p]);
			for i = 1, numUnits do
				local rand = math.random(#terrs);
				s.Territories[terrs[rand]].NumArmies = WL.Armies.Create(s.Territories[terrs[rand]].NumArmies.NumArmies, includeUnit(s.Territories[terrs[rand]].NumArmies.SpecialUnits, buildUnit(p)))
				table.remove(terrs, rand);
				if #terrs == 0 then terrs = clone(playerTerrs[p]); end
			end
		end
		standing = s;
	end
	local data = Mod.PublicGameData;
	data.NumUnits = getAmountOfUnits(playerTerrs);
	Mod.PublicGameData = data;
end

function includeUnit(t, u)
	table.insert(t, u);
	return t;
end

function clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[clone(orig_key)] = clone(orig_value)
        end
        setmetatable(copy, clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
