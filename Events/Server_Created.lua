---Server_Created hook
---@param game GameServerHook
---@param settings GameSettings
function Server_Created(game, settings)
	local data = Mod.PublicGameData;
    data.Triggers = {};
    data.Events = {};
    data.TerritoryMap = {};
    Mod.PublicGameData = data;
end