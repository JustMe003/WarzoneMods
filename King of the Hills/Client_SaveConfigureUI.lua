require("Annotations");

---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)
	Mod.Settings.NumHills = numHills.GetValue();
    Mod.Settings.NumTurns = numTurns.GetValue();
end