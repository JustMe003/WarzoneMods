function Server_StartGame(game, standing)
    local data = Mod.PublicGameData;
    local s = standing;
    for terr, arr in pairs(data.DragonPlacements) do
        if type(terr) == type(0) and game.Map.Territories[terr] ~= nil then
            if type(arr) == type({}) then
                local t = {};
                for _, v in pairs(arr) do
                    table.insert(t, getDragon(s.Territories[terr].OwnerPlayerID, v))
                end
                s.Territories[terr].NumArmies = s.Territories[terr].NumArmies.Add(WL.Armies.Create(0, t));
            else
                table.insert(data.Errors, "The inputted data didn't have the right format. DO NOT CHANGE ANYTHING MANUALLY TO THE INPUT DATA. If you didn't, please let me know so I can fix it.");
            end
        else
            table.insert(data.Errors, "There does not exist a territory with ID [" .. terr .. "]");
        end
    end
    standing = s;
    Mod.PublicGameData = data;

    local pd = Mod.PlayerGameData;
    if pd == nil then pd = {}; end
    for p, _ in pairs(game.Game.Players) do
        pd[p] = {};
        pd[p].HasSeenCrashMessage = true;
    end
    Mod.PlayerGameData = pd;
end

function getDragon(p, dragonID)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.ImageFilename = "Dragon_" .. Mod.Settings.Dragons[dragonID].ColorName .. ".png";
    builder.Name = Mod.Settings.Dragons[dragonID].Name;
    builder.IsVisibleToAllPlayers = Mod.Settings.Dragons[dragonID].IsVisibleToAllPlayers;
    builder.CanBeAirliftedToSelf = Mod.Settings.Dragons[dragonID].CanBeAirliftedToSelf;
    builder.CanBeGiftedWithGiftCard = Mod.Settings.Dragons[dragonID].CanBeGiftedWithGiftCard;
    builder.CanBeTransferredToTeammate = Mod.Settings.Dragons[dragonID].CanBeTransferredToTeammate;
    builder.CanBeAirliftedToTeammate = builder.CanBeAirliftedToSelf and builder.CanBeTransferredToTeammate;
    builder.IncludeABeforeName = Mod.Settings.Dragons[dragonID].IncludeABeforeName;
    builder.AttackPower = Mod.Settings.Dragons[dragonID].AttackPower;
    builder.AttackPowerPercentage = (Mod.Settings.Dragons[dragonID].AttackPowerPercentage / 100) + 1;
    builder.DefensePowerPercentage = (Mod.Settings.Dragons[dragonID].DefensePowerPercentage / 100) + 1;
    builder.CombatOrder = Mod.Settings.Dragons[dragonID].CombatOrder + 6971;
    if Mod.Settings.Dragons[dragonID].UseHealth then
        builder.Health = Mod.Settings.Dragons[dragonID].Health;
        if Mod.Settings.Dragons[dragonID].DynamicDefencePower then
            builder.DefensePower = Mod.Settings.Dragons[dragonID].Health;
        else
            builder.DefensePower = Mod.Settings.Dragons[dragonID].DefensePower;
        end
    else
        builder.DamageAbsorbedWhenAttacked = Mod.Settings.Dragons[dragonID].DamageAbsorbedWhenAttacked;
        builder.DamageToKill = Mod.Settings.Dragons[dragonID].DamageToKill;
        builder.DefensePower = Mod.Settings.Dragons[dragonID].DefensePower;
    end
    return builder.Build();
end
