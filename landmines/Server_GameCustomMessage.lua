function Server_GameCustomMessage(game, playerID, payload, setReturn)
	if payload.Territory ~= nil then
        local armies = game.ServerGame.LatestTurnStanding.Territories[payload.Territory].NumArmies;
        local c = 0;
        if armies.SpecialUnits ~= nil and #armies.SpecialUnits > 0 then
            for _, sp in pairs(armies.SpecialUnits) do
                if isLandmine(sp) then
                    c = c + 1;
                end
            end
        end
        if c > 0 then
            local data = Mod.PublicGameData;
            if data.LandminesFound == nil then data.LandminesFound = {}; end
            table.insert(data.LandminesFound, {Player = playerID, TerrID = payload.Territory});
            Mod.PublicGameData = data;
            setReturn({Success = true, Text = "Success! " .. getNumLandmineString(c) .. " You can now take more guesses if you want", Color = "Lime"});
        else
            local data = Mod.PlayerGameData;
            if data == nil then data = {}; end
            if data[playerID] == nil then data[playerID] = {}; end
            data[playerID].GuessCooldown = game.Game.TurnNumber + Mod.Settings.GuessCooldown;
            Mod.PlayerGameData = data;
            setReturn({Success = false, Text = "Fail! The territory you chose did not have a landmine... Now you have to wait until turn " .. data[playerID].GuessCooldown .. " until you can guess again", Color = "Orange Red"});
        end
    end
end

function isLandmine(sp)
    return sp.proxyType == "CustomSpecialUnit" and sp.Name == "Landmine" and sp.ImageFilename ~= "Landmine.png";
end

function getNumLandmineString(c) 
    if c == 1 then
        return "A landmine was found!"
    else
        return c .. " landmines were found!"
    end
end
