function Server_StartGame(game, standing)
    local data = Mod.PublicGameData;
    data.DragonPlacements = Mod.Settings.DragonPlacements;
    data.DragonPlacements = {};
    if data.DragonPlacements == nil then data.DragonPlacements = {}; end
    Mod.PublicGameData = data;
    local s = standing;
    for _, terr in pairs(s.Territories) do
        if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
            s.Territories[terr.ID].NumArmies = s.Territories[terr.ID].NumArmies.Add(WL.Armies.Create(0, {getDragon(terr.OwnerPlayerID)}))
        end
    end
    standing = s;
end

function getDragon(p)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.Name = "Dragon";
    builder.IncludeABeforeName = true;
    builder.ImageFilename = 'dragon.png';
    builder.AttackPower = 200;
    builder.DefensePower = 200;
    builder.Health = 200;
    builder.CombatOrder = 1362;
    builder.CanBeGiftedWithGiftCard = true;
    builder.CanBeTransferredToTeammate = true;
    builder.CanBeAirliftedToSelf = true;
    builder.CanBeAirliftedToTeammate = true;
    builder.IsVisibleToAllPlayers = false;
    return builder.Build();
end