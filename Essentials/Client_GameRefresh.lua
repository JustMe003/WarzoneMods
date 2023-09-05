function Client_GameRefresh(game)
    if Mod.Settings.Links ~= nil and Mod.PlayerGameData.HasSeenLinks == nil then
        game.SendGameCustomMessage("Updating...", {}, function(t)  end);
        UI.Alert("Test");
    end
end