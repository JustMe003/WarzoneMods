require("Annotations");

---Server_AdvanceTurn_Start hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Start(game, addNewOrder)
	capturedTerritory = {};
    for p, _ in pairs(game.Game.PlayingPlayers) do
        capturedTerritory[p] = false;
    end
	data = Mod.PublicGameData;
end

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder, skipIfOriginalSkipped: boolean) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderAttackTransfer" then
        ---@diagnostic disable-next-line: undefined-field
        if orderResult.IsSuccessful then
            capturedTerritory[order.PlayerID] = true;
        end
	---@diagnostic disable-next-line: undefined-field
	elseif order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #"ForcedLD_") ~= nil then
		local cardData = data.CardData[getPlayerOrTeamID(game.Game.PlayingPlayers[order.PlayerID])];
		if cardData.WholeCards > 0 then
			---@diagnostic disable-next-line: undefined-field
			local target = tonumber(string.sub(order.Payload, #"ForcedLD_" + 1, -1));
			if target ~= nil then
				table.insert(data.ActiveCards, {PlayerID = order.PlayerID, Target = target, LastTillTurn = game.Game.TurnNumber + Mod.Settings.Duration});
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Played Forced LD card on " .. game.Game.PlayingPlayers[target].DisplayName(nil, false), aOrB(game.Settings.CardPlayingsFogged, mergeLists(getPlayerOrAllTeamPlayers(game, game.Game.Players[target]), getPlayerOrAllTeamPlayers(game, game.Game.Players[order.PlayerID])), nil), {}));
			else
				addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "Something went wrong: Could not extract PlayerID from game order custom", ""), true);
			end
		else
			addNewOrder(WL.GameOrderCustom.Create(order.PlayerID, "You don't have enough cards left over to play a Forced LD card!", ""), true);
		end
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
	-- Automate AI playing cards
	if Mod.Settings.AIAutoplayCards then
		for teamID, cardData in pairs(Mod.PublicGameData.CardData) do
			if cardData.WholeCards > 0 then
				if Mod.PublicGameData.IsTeamGame and teamIsAI(game, getTeamPlayers(game, teamID)) then
					local players = getTeamPlayers(game, teamID);
					local targets = {};
					for _, p in pairs(game.Game.PlayingPlayers) do
						if p.Team ~= teamID then
							table.insert(targets, p.ID);
						end
					end
					while cardData.WholeCards > 0 and #targets > 0 and #players > 0 do
						local randTar = math.random(1, #targets);
						local target = targets[randTar];
						table.remove(targets, randTar);
						local player = players[math.random(1, #players)];
						table.insert(data.ActiveCards, {PlayerID = player, Target = target, LastTillTurn = game.Game.TurnNumber + Mod.Settings.Duration})
						addNewOrder(WL.GameOrderEvent.Create(player, "Played Forced LD card on " .. game.Game.PlayingPlayers[target].DisplayName(nil, false), aOrB(game.Settings.CardPlayingsFogged, mergeLists(players, getPlayerOrAllTeamPlayers(game, game.Game.Players[target])), nil), {}));
						cardData.WholeCards = cardData.WholeCards - 1;
					end
				elseif not Mod.PublicGameData.IsTeamGame and game.Game.Players[teamID].State == WL.GamePlayerState.Playing and game.Game.Players[teamID].IsAIOrHumanTurnedIntoAI then
					local targets = {};
					for p, _ in pairs(game.Game.PlayingPlayers) do
						if p ~= teamID then
							table.insert(targets, p);
						end
					end
					while cardData.WholeCards > 0 and #targets > 0 do
						local randTar = math.random(1, #targets);
						local target = targets[randTar];
						table.remove(targets, randTar);
						table.insert(data.ActiveCards, {PlayerID = teamID, Target = target, LastTillTurn = game.Game.TurnNumber + Mod.Settings.Duration})
						addNewOrder(WL.GameOrderEvent.Create(teamID, "Played Forced LD card on " .. game.Game.PlayingPlayers[target].DisplayName(nil, false), {target}, {}));
						cardData.WholeCards = cardData.WholeCards - 1;
					end
				end
				data.CardData[teamID] = cardData;
			end
		end
	end
	
	local forcedLDPlayers = {};
	for _, playedCard in pairs(data.ActiveCards) do
		forcedLDPlayers[playedCard.Target] = true;
	end

	local start = WL.TickCount();
	for p, player in pairs(game.Game.PlayingPlayers) do
		if not forcedLDPlayers[p] then
			local incomeMods = {};
			local total = 0;
			for _, n in pairs(player.Income(0, game.ServerGame.LatestTurnStanding, true, true).BonusRestrictions) do
				total = total + n;
			end
			table.insert(incomeMods, WL.IncomeMod.Create(p, total, "Added free income"));
			for _, bonus in pairs(game.Map.Bonuses) do
				local value = getBonusValue(bonus, game.Settings.OverriddenBonuses or {});
				if value ~= 0 then
					table.insert(incomeMods, WL.IncomeMod.Create(p, -value, "Cancel out " .. bonus.Name, bonus.ID));
				end
			end
			local event = WL.GameOrderEvent.Create(p, "Added free income", getPlayerOrAllTeamPlayers(game, player), {}, {}, incomeMods);
			addNewOrder(event);
		end
    end
	print("Income orders: " .. WL.TickCount() - start);

	for i, playedCard in pairs(data.ActiveCards) do
		if playedCard.LastTillTurn <= game.Game.TurnNumber then
			addNewOrder(WL.GameOrderEvent.Create(playedCard.PlayerID, "Forced LD card wore off on " .. game.Game.Players[playedCard.Target].DisplayName(nil, false), aOrB(game.Settings.CardPlayingsFogged, mergeLists(getPlayerOrAllTeamPlayers(game, game.Game.Players[playedCard.PlayerID]), getPlayerOrAllTeamPlayers(game, game.Game.Players[playedCard.Target])), nil), {}));
			data.ActiveCards[i] = nil;
		end
	end

    for _, player in pairs(game.Game.PlayingPlayers) do
		data.CardsPlayedThisTurn[player.ID] = 0;
		local cardData = data.CardData[getPlayerOrTeamID(player)];
        if capturedTerritory[player.ID] then
            addCardPieces(cardData, player, game, addNewOrder);
        end
    end
    Mod.PublicGameData = data;
end

---Returns the used bonus value
---@param bonus BonusDetails
---@param bonusOverrides table<BonusID, integer>
---@return integer
function getBonusValue(bonus, bonusOverrides)
    if bonusOverrides[bonus.ID] then return bonusOverrides[bonus.ID]; end
    return bonus.Amount;
end

function addCardPieces(cardData, player, game, addNewOrder)
    cardData.Pieces = cardData.Pieces + Mod.Settings.PiecesPerTurn;
    while cardData.Pieces >= Mod.Settings.NumPieces do
        cardData.WholeCards = cardData.WholeCards + 1;
        cardData.Pieces = cardData.Pieces - Mod.Settings.NumPieces;
    end
	addNewOrder(WL.GameOrderEvent.Create(player.ID, "Received Forced LD card pieces", getPlayerOrAllTeamPlayers(game, player), {}));
end

function getPlayerOrTeamID(player)
    if Mod.PublicGameData.IsTeamGame then return player.Team; end
    return player.ID;
end

function getPlayerOrAllTeamPlayers(game, player)
	if Mod.PublicGameData.IsTeamGame then
		return getTeamPlayers(game, player.Team);
	else
		return {player.ID};
	end
end

function getTeamPlayers(game, teamID)
	local t = {};
	for i, p in pairs(game.Game.PlayingPlayers) do
		if p.State == WL.GamePlayerState.Playing and p.Team == teamID then
			table.insert(t, i);
		end
	end
	return t;
end

function teamIsAI(game, playerIDs)
	for _, pID in pairs(playerIDs) do
		local p = game.Game.Players[pID];
		if p.State == WL.GamePlayerState.Playing and not p.IsAIOrHumanTurnedIntoAI then return false; end
	end
	return true;
end

function aOrB(b, r1, r2)
	if b then return r1; else return r2; end
end

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