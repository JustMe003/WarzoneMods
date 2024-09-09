require("Annotations");

---Server_Created hook
---@param game GameServerHook
---@param settings GameSettings
function Server_Created(game, settings)
	settings.LocalDeployments = true;
end