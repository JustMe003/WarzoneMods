function Server_StartGame(game, standing)
    local data = Mod.PrivateGameData;
    data.ActiveCards = {};
    Mod.PrivateGameData = data;

    local incomeMods = standing.IncomeMods or {};
    local bonuses = game.Map.Bonuses;
    for p, player in pairs(game.Game.PlayingPlayers) do
        local restrictions = player.Income(0, standing, false, false).BonusRestrictions;
        local total = 0;
        for b, n in pairs(restrictions) do
            total = total + n;
            table.insert(incomeMods, WL.IncomeMod.Create(p, -n, "cancel out " .. bonuses[b].Name, b));
        end
        table.insert(incomeMods, WL.IncomeMod.Create(p, total, "free income"));
    end
    standing.IncomeMods = incomeMods;
end