require("Client_PresentMenuUI")

function Client_GameRefresh(game)
    if Mod.Settings.Links ~= nil and Mod.PlayerGameData.HasSeenLinks == nil then
        game.SendGameCustomMessage("Updating...", {}, function(t)  end);
        game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, function() showDocumentLinks(true); end); end);
    end
end