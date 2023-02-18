function Server_StartGame(game, standing)
    local s = standing;
    if s.Territories[1] ~= nil then
        s.Territories[1].NumArmies = s.Territories[1].NumArmies.Add(WL.Armies.Create(0, {}))
    end
    standing = s;
    for i, _ in pairs(game.Game.Players) do
        print(i)
    end
end
