function Server_GameStart(game, standing)
    local t = {};
    for _, v in pairs(standing.Territories) do
        if not v.IsNeutral and t[v.OwnerPlayerID] == nil then
            armies = standing.Territories[v.ID].NumArmies;
            armies = WL.Armies.Create(WL.Armies.Create(standing.Territories[v.ID].NumArmies.NumArmies, {WL.Boss3.Create(v.OwnerPlayerID, 1)})
            WL.Armies.Create(standing.Territories[v.ID].NumArmies = armies;
            t[v.OwnerPlayerID] = true;
        end
    end
end
