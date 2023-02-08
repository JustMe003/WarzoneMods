function Client_GameRefresh(game)
	if game.Settings.StartedBy == nil or game.Us == nil or game.Settings.StartedBy ~= game.Us.PlayerID or game.Game.TurnNumber < 1 or Mod.PlayerGameData.HasSeenNotification ~= nil then return; end
    if Mod.PublicGameData.Errors == nil or #Mod.PublicGameData.Errors == 0 then
        UI.Alert("Every Dragon was placed correctly!")
    else
        local alert = "";
        for _, v in pairs(Mod.PublicGameData.Errors) do
            alert = alert .. v .. "\n";
        end
        UI.Alert(alert);
    end
    game.SendGameCustomMessage("Updating mod...", {Type="updateNotification"}, function(t) end);
end