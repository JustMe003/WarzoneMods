function Server_StartGame(game, standing)
	local s = standing;
    for _, territory in pairs(s.Territories) do
        if territory.OwnerPlayerID ~= WL.PlayerID.Neutral then
            local terr = territory;
            local armies = terr.NumArmies;
            table.insert(armies.SpecialUnits, getDragon(terr.OwnerPlayerID));
            terr.NumArmies = WL.Armies.Create(armies.NumArmies, armies.SpecialUnits);
            s.Territories[territory.ID] = terr;
        end
    end
    standing = s;
end

function getDragon(p)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.Name = "Dragon";
    builder.TextOverHeadOpt = "Dragon";
    builder.IncludeABeforeName = true;
    builder.ImageFilename = 'dragon.png';
    builder.AttackPower = 20;
    builder.DefensePower = 20;
    builder.Health = 20;
    builder.CombatOrder = 1362;
    builder.CanBeGiftedWithGiftCard = true;
    builder.CanBeTransferredToTeammate = true;
    builder.CanBeAirliftedToSelf = true;
    builder.CanBeAirliftedToTeammate = true;
    builder.IsVisibleToAllPlayers = false;
    return builder.Build();
end