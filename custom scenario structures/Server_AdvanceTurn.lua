function Server_AdvanceTurn_Start(game, addNewOrder)
	
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if game.Settings.MultiPlayer then return; end
	if Mod.Settings.Testing then return; end
	if order.proxyType == "GameOrderCustom" then
		if string.find(order.Payload, "CustomScenarioStructures_") ~= nil then
			local info = split(order.Payload, "_");
			local structure = tonumber(info[3]);
			local mods = {};
			for i = 4, #info do
				local terr = tonumber(info[i]);
				local mod = WL.TerritoryModification.Create(terr);
				local structures = game.ServerGame.LatestTurnStanding.Territories[terr].Structures;
				if (structures == nil) then structures = {}; end;
				if (structures[structure] == nil) then
					if info[2] == "Add" then
						structures[structure] = 1;
					end
				else
					if info[2] == "Add" then
						structures[structure] = structures[structure] + 1;
					else
						structures[structure] = structures[structure] - 1;
					end
				end
				mod.SetStructuresOpt = structures;
				table.insert(mods, mod);
			end
			addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, order.Message, nil, mods));
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		else
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		end
	elseif order.proxyType ~= "GameOrderEvent" then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	if not game.Settings.MultiPlayer and not Mod.Settings.Testing then
		local mods = {};
		for _, p in pairs(game.Game.PlayingPlayers) do
			table.insert(mods, WL.IncomeMod.Create(p.ID, -100000, "removes the must to deploy"));
		end
		addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "disabling deploying", nil, {}, {}, mods))
	end
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
