function Client_GameRefresh(game)
	if game.Us == nil then return; end
    if game.Game.TurnNumber == 1 and Mod.PlayerGameData.HasSeenMessage == nil and not Mod.Settings.AutoDistributeUnits then
        require("Client_PresentMenuUI");
        game.CreateDialog(Client_PresentMenuUI);
        game.SendGameCustomMessage("Updating mod...", {}, function(t) end);
    end
end
