function Client_GameRefresh(game)
	if game.Settings.StartedBy == nil or game.Us == nil or game.Settings.StartedBy ~= game.Us.PlayerID or game.Game.TurnNumber < 1 or Mod.PlayerGameData.HasSeenNotification ~= nil then return; end
    if Mod.PublicGameData.Errors == nil or #Mod.PublicGameData.Errors == 0 then
        if #Mod.Settings.DragonPlacements > 0 then
            UI.Alert("Every Dragon was placed correctly!")
        end
    else
        local alert = "";
        for _, v in pairs(Mod.PublicGameData.Errors) do
            alert = alert .. v .. "\n";
        end
        UI.Alert(alert);
    end
    game.SendGameCustomMessage("Updating mod...", {Type="updateNotification"}, function(t) end);
    if Mod.PlayerGameData ~= nil and Mod.PlayerGameData.HasSeenCrashMessage == nil then
        UI.Alert("Due to an bug somewhere in the mod I had to change the code slightly. By doing this, I accidentally made the mod crash in every game. This message is mostly here to let you all know it is fixed now, sorry for the inconvenience!\n\nJAD");
        game.SendGameCustomMessage("Updating mod...", {Type="hasSeenCrashMessage"}, function(t) end);
    end
end