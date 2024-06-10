require("Annotations");
require("Util");

---Server_Created hook
---@param game GameServerHook
---@param settings GameSettings
function Server_Created(game, settings)
	if Mod.Settings.Data ~= nil and Mod.Settings.Data.GameData.MapID == settings.MapID then
		settings.Name = "Serialized Game (" .. Mod.Settings.Data.GameData.GameName .. ", turn " .. Mod.Settings.Data.GameData.TurnNumber .. ")";
		map = Mod.Settings.Data.GameData.PropertiesMap;
		local cs = WL.CustomScenario.Create(game.Map);	
		print("Trying to add the slots to `SlotsAvailable`")
		local c = 0;
		for _, p in pairs(Mod.Settings.Data.GameData.PlayerMap) do
			table.insert(cs.SlotsAvailable, p.Slot);
			c = c + 1;
			print("Slot: " .. p.Slot .. ", count should be " .. c .. " but is " .. #cs.SlotsAvailable);
		end

		-- This part works fine
		local numArmiesKey = getKeyFromMap("NumArmies");
		local playerKey = getKeyFromMap("OwnerPlayerID");
		local slotPlayerMap = createSlotPlayerMap(Mod.Settings.Data.GameData.PlayerMap);
		for i, terr in pairs(Mod.Settings.Data[getKeyFromMap("Territories")]) do
			cs.Territories[i].InitialArmies = terr[numArmiesKey][numArmiesKey];
			cs.Territories[i].Slot = slotPlayerMap[terr[playerKey]];
		end
	
		settings.CustomScenario = cs;
		settings.DistributionModeID = -3; -- No WL entry?
	end
end

function createSlotPlayerMap(playerMap)
	local t = {};
	for i, p in pairs(playerMap) do
		t[i] = p.Slot;
	end
	return t;
end
