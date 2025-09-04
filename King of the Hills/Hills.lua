require("Annotations");

---Sets up the hills and storage
---@param standing GameStanding
function setUpHills(standing)
	local hill = WL.StructureType.Custom("Hill");
    local list = {};
    for terrID, _ in pairs(standing.Territories) do
        table.insert(list, terrID);
    end

	local terrs = {};
    local i = 0;
    while i < Mod.Settings.NumHills and #list > 0 do
		local rand = math.random(1, #list);
		local terrID = list[rand];
		table.remove(list, rand);

		local terr = standing.Territories[terrID];
		terr.NumArmies = WL.Armies.Create(10, terr.NumArmies.SpecialUnits or {});
		local structures = terr.Structures or {};
		structures[hill] = (structures[hill] or 0) + 1;
		terr.Structures = structures;
		standing.Territories[terrID] = terr;
		table.insert(terrs, terrID);
        i = i + 1;
    end
	
	local data = Mod.PublicGameData;
	data.Hills = terrs;
	data.LastControllingPlayer = -1;
	data.NumTurnsControlling = 0;
	Mod.PublicGameData = data;
end

---Checks whether a playerOrTeam controls all the hills
---@param territories TerritoryStanding[]
function checkOwnerHills(territories, players)
	local playerOrTeam = -1;
    for _, terrID in ipairs(Mod.PublicGameData.Hills) do
        local terr = territories[terrID];
        if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then	-- No team can have all the hills if one hill is still neutral
            if playerOrTeam == -1 then	-- First iteration
                playerOrTeam = getTeamOrPlayerID(players, terr.OwnerPlayerID);
            else	-- other iterations
                if playerOrTeam ~= getTeamOrPlayerID(players, terr.OwnerPlayerID) then
                    return -1;	-- Different team owns the hill
                end
            end
        else
			return -1;
        end
    end
	return playerOrTeam;
end

---Makes the winner(s) win the game, eliminates all the other players
---@param winner integer
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder)
function endGame(winner, game, addNewOrder)
	local players = game.Game.Players;
	local mods = {};
	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and winner ~= getTeamOrPlayerID(players, terr.OwnerPlayerID) then
			local mod = WL.TerritoryModification.Create(terr.ID);
			mod.SetOwnerOpt = WL.PlayerID.Neutral;
			table.insert(mods, mod);
		end
	end

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, getTeamOrPlayerName(game, Mod.PublicGameData.LastControllingPlayer) .. " captured all the hills, and held them for " .. Mod.Settings.NumTurns .. " turn" .. aOrB(Mod.Settings.NumTurns ~= 1, "s", "") .. "!", {}, mods));
end

---returns the teamID if the team is a team game, otherwise returns the playerID
---@param players table<PlayerID, table>
---@param pID PlayerID
---@return integer
function getTeamOrPlayerID(players, pID)
	---@diagnostic disable-next-line: return-type-mismatch
	if Mod.PublicGameData.IsTeamGame then return players[pID].Team; else return pID; end
end

function getTeamOrPlayerName(game, teamID)
	if Mod.PublicGameData.IsTeamGame then
		return getTeamName(teamID);
	else
		return game.Game.Players[teamID].DisplayName(nil, false);
	end
end

function getTeamName(team)
	local s = "";
	team = team + 1;
    while team > 0 do
        local n = team % 26;
        if n == 0 then
            -- team % 26 == 26
            n = 26;
        end
        team = (team - n) / 26;
        s = string.char(n + 64) .. s;
    end
    return "Team " .. s;
end

function aOrB(b, r1, r2)
	if b then return r1; else return r2; end
end