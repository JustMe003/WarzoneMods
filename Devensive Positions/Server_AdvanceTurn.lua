function Server_AdvanceTurn_Start(game, addNewOrder)
	playerData = Mod.PlayerGameData;
	newDevPos = {};
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if order.proxyType == "GameOrderCustom" and startsWith(order.Payload, "buildDevPos_") then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
		if playerData[order.PlayerID] == nil then return; end;
		if playerData[order.PlayerID].NumDevpos == nil then return; end;
		if playerData[order.PlayerID].NumDevpos <= 0 then return; end;
		playerData[order.PlayerID].NumDevpos = playerData[order.PlayerID].NumDevpos - 1;
		
		table.insert(newDevPos, order.Payload .. "_" .. order.PlayerID);
	elseif order.proxyType == "GameOrderAttackTransfer" then
		if orderResult.IsAttack then
			if game.ServerGame.LatestTurnStanding.Territories[order.To].Structures ~= nil then
				if game.ServerGame.LatestTurnStanding.Territories[order.To].Structures[WL.StructureType.MercenaryCamp] ~= nil then
					local armiesKilled = round(game.ServerGame.LatestTurnStanding.Territories[order.From].NumArmies.AttackPower * (game.Settings.DefenseKillRate - Mod.Settings.ExtraDevKillrate));
					print(armiesKilled);
					orderResult.DefendingArmiesKilled = WL.Armies.Create(math.max(armiesKilled, 0), orderResult.DefendingArmiesKilled.SpecialUnits);
				end
			end
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local terrList = {};
	for i, v in pairs(newDevPos) do
		local info = split(v, "_");
		local terr = tonumber(info[2]);
		local p = tonumber(info[3]);
		if game.ServerGame.LatestTurnStanding.Territories[terr].OwnerPlayerID == p and terrList[terr] == nil then
			terrList[terr] = true;
			local structures = game.ServerGame.LatestTurnStanding.Territories[terr].Structures;
			if structures == nil then structures = {}; end
			if structures[WL.StructureType.MercenaryCamp] ~= nil then
				if structures[WL.StructureType.MercenaryCamp] >= 1 then
					addNewOrder(WL.GameOrderCustom.Create(p, "Devensive position was not build since there already is a devensive position on " .. game.Map.Territories[terr].Name, " "))
					playerData[p].NumDevpos = playerData[p].NumDevpos + 1;
				else
					addNewOrder(WL.GameOrderEvent.Create(p, "built a devensive position on " .. game.Map.Territories[terr].Name, {}, {addDevPos(terr, structures)}))
				end
			else
				addNewOrder(WL.GameOrderEvent.Create(p, "built a devensive position on " .. game.Map.Territories[terr].Name, {}, {addDevPos(terr, structures)}))
			end
		end
	end
	if game.Game.TurnNumber % Mod.Settings.TurnsToGetDevPos == 0 then
		for i, p in pairs(game.Game.PlayingPlayers) do
			if not p.IsAI then 
				if playerData[i] == nil then playerData[i] = {}; end
				if playerData[i].NumDevpos == nil then playerData[i].NumDevpos = 0; end
				playerData[i].NumDevpos = playerData[i].NumDevpos + 1;
			end
		end
	end
	Mod.PlayerGameData = playerData;
end

function addDevPos(terr, s)
	local mod = WL.TerritoryModification.Create(terr);
	s[WL.StructureType.MercenaryCamp] = 1;
	mod.SetStructuresOpt = s;
	return mod;
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function filter(array, func)
	local new_array = {}
	local i = 1;
	for _,v in pairs(array) do
		if (func(v)) then
			new_array[i] = v;
			i = i + 1;
		end
	end
	return new_array
end

function startsWith(str, sub)
	return string.sub(str, 1, string.len(sub)) == sub;
end

function round(n)
	if n % 1 > 0.5 then
		return math.floor(n);
	else
		return math.ceil(n);
	end
end
--[[
local players = {};
	if (game.Game.TurnNumber - 1) % 5 == 0 then
		for i, _ in pairs(game.Game.PlayingPlayers) do
			table.insert(players, i);
		end
		local mods = {};
		for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
			if #terr.NumArmies.SpecialUnits ~= 0 then
				local ownCom = false
				for _, v in pairs(terr.NumArmies.SpecialUnits) do
					if v.OwnerID == terr.OwnerPlayerID then ownCom = true; break; end
				end
				if ownCom then
					local mod = WL.TerritoryModification.Create(terr.ID);
					local specOps = {};
					local rand = math.random(1, #players);
					while players[rand] == terr.OwnerPlayerID do
						rand = math.random(1, #players);
					end
					print(terr.ID, terr.OwnerPlayerID, players[rand]);
					table.insert(specOps, WL.Commander.Create(players[rand]));
					table.remove(players, rand);
					mod.AddSpecialUnits = specOps;
					table.insert(mods, mod);
				end
			end
		end
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "added Spec Ops", nil, mods))
	end
]]--
--[[
if #game.ServerGame.LatestTurnStanding.Territories[order.To].NumArmies.SpecialUnits ~= 0 then
				if #orderResult.DefendingArmiesKilled.SpecialUnits ~= 0 then
					local killSpecOps = {};
					local saved = 0;
					for i, v in pairs(orderResult.DefendingArmiesKilled.SpecialUnits) do
						if v.OwnerID ~= order.PlayerID then
							table.insert(killSpecOps, v);
						else
							saved = saved + (WL.Armies.Create(0, {v}).AttackPower * game.Settings.DefenseKillRate);
						end
					end
					orderResult.DefendingArmiesKilled = WL.Armies.Create(orderResult.DefendingArmiesKilled.NumArmies, killSpecOps);
					if saved > 0 then
						orderResult.AttackingArmiesKilled = WL.Armies.Create(orderResult.AttackingArmiesKilled.NumArmies - round(saved), orderResult.AttackingArmiesKilled.SpecialUnits);
					end
					if orderResult.IsSuccessful then
						local mod = WL.TerritoryModification.Create(order.To);
						mod.SetOwnerOpt = order.PlayerID;
						addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "successfully captured " .. game.Map.Territories[order.To].Name, {}, {mod}))
						addNewOrder(order);
					end
				end
			end
]]--