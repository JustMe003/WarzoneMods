require("Util");

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder, skipIfOriginalSkipped: boolean) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderPlayCardCustom" then
		---@cast order GameOrderPlayCardCustom
		if order.CustomCardID == Mod.Settings.CardID then
			local data = Mod.PrivateGameData;
			local target = getTargetPlayerID(order.ModData);
			if target ~= nil then
				table.insert(data.ActiveCards, {PlayerID = order.PlayerID, Target = target, LastTillTurn = game.Game.TurnNumber + Mod.Settings.Duration - 1});
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Played forced local deployment card on " .. game.Game.PlayingPlayers[target].DisplayName(nil, false), aOrB(game.Settings.CardPlayingsFogged, mergeLists(getPlayerOrAllTeamPlayers(game, game.Game.Players[target]), getPlayerOrAllTeamPlayers(game, game.Game.Players[order.PlayerID])), nil), {}));
			else
				addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Something went wrong: Could not extract PlayerID from GameOrderPlayCardCustom", ""), true);
			end
			Mod.PrivateGameData = data;
		end
	end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
	local data = Mod.PrivateGameData;
		
	-- Save which players were targetted by a Forced LD card
	local forcedLDPlayers = {};
	local indexes = {};
	for i, playedCard in ipairs(data.ActiveCards) do
		forcedLDPlayers[playedCard.Target] = true;
		if playedCard.LastTillTurn == game.Game.TurnNumber then
			table.insert(indexes, i);
		end
	end

	for i = #indexes, 1, -1 do
		table.remove(data.ActiveCards, indexes[i]);
	end

	-- Update income of all players, if they were not targetted by a Forced LD card
	local bonuses = game.Map.Bonuses;
	for p, player in pairs(game.Game.PlayingPlayers) do
		if not forcedLDPlayers[p] then
			local incomeMods = {};
			local total = 0;
			for bonusID, n in pairs(player.Income(0, game.ServerGame.LatestTurnStanding, true, true).BonusRestrictions) do
				if n ~= 0 then
					table.insert(incomeMods, WL.IncomeMod.Create(p, -n, "Cancel out " .. bonuses[bonusID].Name, bonusID));
					total = total + n;
				end
			end
			table.insert(incomeMods, WL.IncomeMod.Create(p, total, "Added free income"));
			local event = WL.GameOrderEvent.Create(p, "Added free income", getPlayerOrAllTeamPlayers(game, player), {}, {}, incomeMods);
			addNewOrder(event);
		end
    end

    Mod.PrivateGameData = data;
end

---Returns the used bonus value
---@param bonus BonusDetails
---@param bonusOverrides table<BonusID, integer>
---@return integer
function getBonusValue(bonus, bonusOverrides)
    if bonusOverrides[bonus.ID] then return bonusOverrides[bonus.ID]; end
    return bonus.Amount;
end


---Returns the playerID of teamID of the player
---@param player GamePlayer # The player in question
---@return PlayerID | TeamID | integer # The ID to use to index the data
function getPlayerOrTeamID(player)
    if player.Team == -1 then return player.ID; else return player.Team; end
end

---Gets all the players of a team, or just the player in question, used for setting the visibility of an order
---@param game GameServerHook # The game object
---@param player GamePlayer # The source player
---@return PlayerID[] # The list of playerIDs
function getPlayerOrAllTeamPlayers(game, player)
	if getPlayerOrTeamID(player) == player.Team then
		return getTeamPlayers(game, player.Team);
	else
		return {player.ID};
	end
end

---Returns all the players who have the same teamID as the passed argument
---@param game GameServerHook # The game object
---@param teamID TeamID # The teamID
---@return PlayerID[] # The list of all the playerIDs who are in the team
function getTeamPlayers(game, teamID)
	local t = {};
	for i, p in pairs(game.Game.PlayingPlayers) do
		if p.State == WL.GamePlayerState.Playing and p.Team == teamID then
			table.insert(t, i);
		end
	end
	return t;
end

---Returns true if the whole team is AI, returns false otherwise
---@param game GameServerHook # The game object
---@param playerIDs PlayerID[] # The list of playerIDs
---@return boolean # True if the whole team is AI, false otherwise
function teamIsAI(game, playerIDs)
	for _, pID in pairs(playerIDs) do
		local p = game.Game.Players[pID];
		if p.State == WL.GamePlayerState.Playing and not p.IsAIOrHumanTurnedIntoAI then return false; end
	end
	return true;
end

---Helper function to return either `r1` or `r2`
---@param b boolean # Boolean to determine to return `r1` or `r2`
---@param r1 any # If `b` is true, return this
---@param r2 any # If `b` is false, return this
---@return any # Either `r1` or `r2`, depending on `b` is true
function aOrB(b, r1, r2)
	if b then return r1; else return r2; end
end

---Merges the 2 lists together
---@param t1 any[] # List 1
---@param t2 any[] # List 2
---@return any[] # The merged lists
function mergeLists(t1, t2)
	if not t1 or not t2 then return t1 or t2 or {}; end
	if #t1 < #t2 then
		for _, v in pairs(t1) do
			table.insert(t2, v);
		end
		return t2;
	else
		for _, v in pairs(t2) do
			table.insert(t1, v);
		end
		return t1;
	end
end