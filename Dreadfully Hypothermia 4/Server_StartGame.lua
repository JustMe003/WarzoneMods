function Server_StartGame(game, standing)
    print("Mod: DH4")
    local t = {};
    local s = standing;
    for _, v in pairs(s.Territories) do
        if not v.IsNeutral and t[v.OwnerPlayerID] == nil then
            local armies = s.Territories[v.ID].NumArmies.Add(WL.Armies.Create(0, {WL.Boss3.Create(v.OwnerPlayerID, 1)}))
            s.Territories[v.ID].NumArmies = armies;
            t[v.OwnerPlayerID] = true;
        end
    end
    standing = s;
end
