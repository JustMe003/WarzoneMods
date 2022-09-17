function Server_StartGame(game, standing)
    local t = {};
    for _, v in pairs(standing.Territories) do
        if not v.IsNeutral and t[v.OwnerPlayerID] == nil then
            standing.Territories[v.ID].NumArmies = WL.Armies.Create(standing.Territories[v.ID].NumArmies.NumArmies, {WL.Boss3.Create(v.OwnerPlayerID)})
            t[v.OwnerPlayerID] = true;
        end
    end
end
