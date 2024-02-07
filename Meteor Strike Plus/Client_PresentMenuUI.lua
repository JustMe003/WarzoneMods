require("UI");
require("Client_PresentSettingsUI");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    Init(rootParent);
    colors = GetColors();
    root = GetRoot().SetFlexibleWidth(1);
    Game = game;
    TurnNumber = game.Game.TurnNumber;

    setMaxSize(400, 500);

    showMain();
end

function showMain()
    showForecast();
end

function showForecast()
    DestroyWindow();
    SetWindow("Main");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Weather Forecast").SetColor(colors.Orange);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(0.45);
    local vert1 = CreateVert(line);
    CreateEmpty(line).SetFlexibleWidth(0.1);
    local vert2 = CreateVert(line);
    CreateEmpty(line).SetFlexibleWidth(0.45);

    local lineVert1 = CreateHorz(vert1).SetFlexibleWidth(1);
    CreateEmpty(lineVert1).SetFlexibleWidth(1);
    CreateLabel(lineVert1).SetText("Created by: ").SetColor(colors.TextColor);
    lineVert1 = CreateHorz(vert1).SetFlexibleWidth(1);
    CreateEmpty(lineVert1).SetFlexibleWidth(1);
    CreateLabel(lineVert1).SetText("Presented by: ").SetColor(colors.TextColor);
    
    local lineVert2 = CreateHorz(vert2).SetFlexibleWidth(1);
    CreateLabel(lineVert2).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
    CreateEmpty(lineVert2).SetFlexibleWidth(1);
    lineVert2 = CreateHorz(vert2).SetFlexibleWidth(1);
    if Mod.Settings.GeneralSettings.UseDataGameCreator and Game.Settings.StartedBy ~= nil then
        CreateLabel(lineVert2).SetText(Game.Game.Players[Game.Settings.StartedBy].DisplayName(nil, false)).SetColor(getColorIfNil(Game.Game.Players[Game.Settings.StartedBy].Color.HtmlColor));
    else
        CreateLabel(lineVert2).SetText("UnFairerOrb76").SetColor(colors.Yellow);
    end
    CreateEmpty(lineVert2).SetFlexibleWidth(1);

    CreateEmpty(root).SetPreferredHeight(20);


    if Mod.Settings.GeneralSettings.WeatherForcastMessage ~= nil and #Mod.Settings.GeneralSettings.WeatherForcastMessage > 0 then
        CreateLabel(root).SetText(Mod.Settings.GeneralSettings.WeatherForcastMessage).SetColor(colors.TextColor);
    else
        CreateLabel(root).SetText("While the world remains at war, somebody keeps trowing rocks down. Scientists still are not sure whether we are just extremely unfortunate with the weather or UnFairerOrb76 is actually behind all of this. Wait, is he not a big part of this program...?! \nUh... \nMmmmhh... \nOkay, will do \nPlease standby, while we tr| to in<esti@ate w^at /xac'ly i] go*n) o- h#$e (~ tß© s®þæ³o.¼.").SetColor(colors.TextColor);        
    end
    CreateEmpty(root).SetPreferredHeight(10);
    
    if stormsThisTurn == nil then
        stormsThisTurn = {};
        CreateLabel(root).SetText("Expected storms coming turn").SetColor(colors.TextColor);
        for _, rain in ipairs(Mod.Settings.Data.Normal) do
            if not rain.NotEveryTurn or (TurnNumber >= rain.StartStorm and TurnNumber <= rain.EndStorm) or (Mod.PublicGameData.NormalStormsStartTurn[rain.ID] ~= nil and Mod.PublicGameData.NormalStormsStartTurn[rain.ID] ~= 0 and TurnNumber >= Mod.PublicGameData.NormalStormsStartTurn[rain.ID] and TurnNumber <= (rain.EndStorm - rain.StartStorm + 1) + Mod.PublicGameData.NormalStormsStartTurn[rain.ID]) then
                table.insert(stormsThisTurn, {Probability = rain.ChanceofFalling, Name = rain.Name, StormType = "Normal", Data = rain});
            elseif rain.NotEveryTurn and rain.Repeat and Mod.PublicGameData.NormalStormsLastTurn[rain.ID] > 0 and TurnNumber >= Mod.PublicGameData.NormalStormsLastTurn[rain.ID] + rain.RepeatAfterMin and TurnNumber <= Mod.PublicGameData.NormalStormsLastTurn[rain.ID] + rain.RepeatAfterMax then
                table.insert(stormsThisTurn, {Probability = rain.ChanceofFalling * (1 / (rain.RepeatAfterMax - rain.RepeatAfterMin + 1) * (TurnNumber - Mod.PublicGameData.NormalStormsLastTurn[rain.ID] - rain.RepeatAfterMin + 1)), Name = rain.Name, StormType = "Normal", Data = rain});
            end
        end
        for _, rain in ipairs(Mod.Settings.Data.Special) do
            if not rain.RandomTurn and TurnNumber == rain.FixedTurn then
                table.insert(stormsThisTurn, {Probability = 100, Name = rain.Name, StormType = "Doomsday", Data = rain});
            elseif rain.RandomTurn and TurnNumber >= rain.MinTurnNumber and TurnNumber <= rain.MaxTurnNumber and Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] == 0 then
                table.insert(stormsThisTurn, {Probability = 100 / (rain.MaxTurnNumber - rain.MinTurnNumber + 1) * (TurnNumber - rain.MinTurnNumber + 1), Name = rain.Name, StormType = "Doomsday", Data = rain})
            elseif rain.Repeat then
                if not rain.RandomTurn and TurnNumber > rain.FixedTurn and TurnNumber >= Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin and TurnNumber <= Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMax then
                    table.insert(stormsThisTurn, {Probability = 100 / (rain.RepeatAfterMax - rain.RepeatAfterMin + 1) * (TurnNumber - Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] - rain.RepeatAfterMin + 1), Name = rain.Name, StormType = "Doomsday", Data = rain})
                elseif rain.RandomTurn and Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] > 0 and TurnNumber >= Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin and TurnNumber <= Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMax then
                    table.insert(stormsThisTurn, {Probability = getProbability(1 / (rain.MaxTurnNumber - rain.MinTurnNumber + 1), 1 / (rain.RepeatAfterMax - rain.RepeatAfterMin + 1), TurnNumber - Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] - rain.RepeatAfterMin + 2) * 100, Name = rain.Name, StormType = "Doomsday", Data = rain})
                end
            end
        end

        stormsThisTurn = table.sort(stormsThisTurn, function(a, b) return a.Probability < b.Probability; end);
    end
    
    for _, rain in ipairs(stormsThisTurn or {}) do
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText(rain.Name .. ": ").SetColor(colors["Royal Blue"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        createProbabilityLine(line, rain.Probability);
        CreateEmpty(line).SetFlexibleWidth(1);
        if rain.StormType == "Normal" then
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showNormalStorm(rain.Data, showForecast, false); end);
        else
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showDoomsdayStorm(rain.Data, showForecast, false); end);
        end
    end
    
    CreateEmpty(root).SetPreferredHeight(20);
    
    CreateLabel(root).SetText("All upcoming storms").SetColor(colors.TextColor);

    if allUpcomingStorms == nil then
        allUpcomingStorms = {};
        for _, rain in ipairs(Mod.Settings.Data.Normal) do
            print(Mod.PublicGameData.NormalStormsStartTurn[rain.ID]);
            if rain.NotEveryTurn and (rain.StartStorm > TurnNumber or (Mod.PublicGameData.NormalStormsStartTurn[rain.ID] ~= 0 and TurnNumber < Mod.PublicGameData.NormalStormsStartTurn[rain.ID])) then
                table.insert(allUpcomingStorms, {TurnNumber = rain.StartStorm, Name = rain.Name, StormType = "Normal", Data = rain});
            end
        end
        for _, rain in ipairs(Mod.Settings.Data.Special) do
            if rain.RandomTurn then
                if rain.MinTurnNumber > TurnNumber then
                    table.insert(allUpcomingStorms, {TurnNumber = rain.MinTurnNumber, MaxTurnNumber = rain.MaxTurnNumber, Name = rain.Name, StormType = "Random Doomsday", Data = rain}); 
                elseif rain.Repeat and Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] ~= 0 and Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin > TurnNumber then
                    table.insert(allUpcomingStorms, {TurnNumber = Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin, MaxTurnNumber = Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMax, Name = rain.Name, StormType = "Random Doomsday", Data = rain}); 
                end
            else
                if rain.FixedTurn > TurnNumber then
                    table.insert(allUpcomingStorms, {TurnNumber = rain.FixedTurn, Name = rain.Name, StormType = "Fixed Doomsday", Data = rain});
                elseif rain.Repeat and Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] ~= 0 and Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin > TurnNumber then
                    if rain.RepeatAfterMin == rain.RepeatAfterMax then
                        table.insert(allUpcomingStorms, {TurnNumber = Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin, Name = rain.Name, StormType = "Fixed Doomsday", Data = rain});
                    else
                        table.insert(allUpcomingStorms, {TurnNumber = Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMin, MaxTurnNumber = Mod.PublicGameData.DoomsdaysLastTurn[rain.ID] + rain.RepeatAfterMax, Name = rain.Name, StormType = "Random Doomsday", Data = rain});
                    end
                end
            end
        end
        
        allUpcomingStorms = table.sort(allUpcomingStorms, function(a, b) return a.TurnNumber < b.TurnNumber; end);
    end
    
    for _, rain in ipairs(allUpcomingStorms or {}) do
        local line = CreateHorz(root).SetFlexibleWidth(1);
        CreateLabel(line).SetText(rain.Name .. ": ").SetColor(colors["Royal Blue"]);
        CreateEmpty(line).SetFlexibleWidth(1);
        if rain.StormType == "Normal" or rain.StormType == "Fixed Doomsday" then
            CreateLabel(line).SetText("T" .. rain.TurnNumber).SetColor(colors.TextColor);
        else
            CreateLabel(line).SetText("T" .. rain.TurnNumber .. "~" .. rain.MaxTurnNumber).SetColor(colors.TextColor);
        end
        CreateEmpty(line).SetFlexibleWidth(1);
        if rain.StormType == "Normal" then
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showNormalStorm(rain.Data, showForecast, false); end);
        else
            CreateButton(line).SetText("Learn more").SetColor(colors["Orange Red"]).SetOnClick(function() showDoomsdayStorm(rain.Data, showForecast, false); end);
        end
    end
end

function createProbabilityLine(line, p)
    -- Colors ranging from light green to dark red
    local arr = {"#00ff00", "#1ee130", "#97db24", "#d0c82f", "#cfa830", "#bc8232", "#bd6937", "#d64329", "#ea1515", "#d00000", "#bb0000"}
    CreateLabel(line).SetText(showDecimal(p, 2) .. "%").SetColor(arr[math.floor((p + 0.5) / 10) + 1]);
end

function getColorIfNil(color)
    if color == nil then return colors.TextColor; end
    return color;
end

function getProbability(p1, p2, x)
    local res = 0;
    local count = 0;
    local n1 = math.floor(1 / p1 + 0.5);
    local n2 = math.floor(1 / p2 + 0.5);
    for i = 1, x - 1 do
        local y = math.min(x - i, n1);
        local y2 = math.min(i, n2);
        if y + y2 == x then
            res = res + (p1 * y) * (p2 * y2);
            count = count + 1;
        end
    end
    return res / count;
end

function showDecimal(x, n)
    return math.floor((x * (10^n)) + 0.5) / (10^n);
end
