function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
    data.IsSuperBonus = {};
    if not Mod.Settings.UseSuperBonuses then
        for _, terr in pairs(game.Map.Territories) do
            local min = 999999;
            for k, bonusID in ipairs(terr.PartOfBonuses) do
                if #game.Map.Bonuses[bonusID].Territories > min then
                    data.IsSuperBonus[bonusID] = true;
                else
                    for i = 1, k - 1 do
                        data.IsSuperBonus[bonusID] = true;
                    end
                    min = #game.Map.Bonuses[bonusID].Territories;
                end
            end
        end
    end
    Mod.PublicGameData = data;
end