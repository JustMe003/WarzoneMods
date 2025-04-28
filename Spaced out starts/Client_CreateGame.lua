local WL = WL
---@cast WL WL

---Client_CreateGame hook
---@param settings GameSettings
---@param alert fun(msg: string)
function Client_CreateGame(settings, alert)
    if not settings.AutomaticTerritoryDistribution then
        alert("To use this mod, the game must use the automatic territory distribution setting");
    end
end