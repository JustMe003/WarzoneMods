function Client_GameRefresh(game)
	if game.Us == nil then return; end
    if game.Game.TurnNumber == 1 and Mod.PlayerGameData.HasSeenMessage == nil and not Mod.Settings.AutoDistributeUnits then
        game.CreateDialog(function(rootParent, setMaxSize, setScrollable, Game, close) setMaxSize(100, 150); UI.CreateButton(UI.CreateVerticalLayoutGroup(rootParent)).SetText("Open Dialog").SetColor("#59009D").SetOnClick(function() require("Client_PresentMenuUI"); close(); game.CreateDialog(Client_PresentMenuUI); end); end)
        game.SendGameCustomMessage("Updating mod...", {}, function(t) end);
    end
end
