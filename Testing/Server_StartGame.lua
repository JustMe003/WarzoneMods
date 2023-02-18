function Server_StartGame(game, standing)
    local s = standing;
    if s.Territories[1] ~= nil then
        s.Territories[1].NumArmies = s.Territories[1].NumArmies.Add(WL.Armies.Create(0, {WL.Boss1.Create(s.Territories[1].OwnerPlayerID), WL.Boss2.Create(s.Territories[1].OwnerPlayerID), WL.Boss1.Create(s.Territories[1].OwnerPlayerID)}))
    end
    standing = s;
    for i, _ in pairs(game.Game.Players) do
        print(i)
    end
end
