require("Client_PresentMenuUI")

function Client_GameRefresh(game)
	if game.Us ~= nil then
        if TurnNumber ~= nil and TurnNumber ~= game.Game.TurnNumber and not UI.IsDestroyed(root) then
            Close();
            game.CreateDialog(Client_PresentMenuUI);
        end
    end
end