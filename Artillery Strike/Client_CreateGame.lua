---Client_CreateGame hook
---@param settings GameSettings
---@param alert fun(msg: string)
function Client_CreateGame(settings, alert)
    if not settings.CommerceGame and Mod.Settings.UseGold then
        alert("The Artillery Strike mod was configured to use gold, but the game does not use the commerce mode. Please either enable commerce or disable the gold cost in the Artillery Strike mod")
    end
    if not (Mod.Settings.Cannons or Mod.Settings.Mortars) then
        alert("The Artillery Strike mod was configured with both cannons and mortars disabled. You must enable either cannons or mortars to use this mod.")
    end
end