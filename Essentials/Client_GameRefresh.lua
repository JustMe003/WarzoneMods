require("Client_PresentMenuUI")

function Client_GameRefresh(game)
    SpectatorHasSeenDocuments = SpectatorHasSeenDocuments or nil;
    if Mod.Settings.Links ~= nil and Mod.PlayerGameData.HasSeenLinks == nil and SpectatorHasSeenDocuments == nil then
        if game.Us ~= nil then
            game.SendGameCustomMessage("Updating...", {}, function(t)  end);
        else
            SpectatorHasSeenDocuments = true;
        end
        game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, function() showDocumentLinks(true); end); end);
    end
end