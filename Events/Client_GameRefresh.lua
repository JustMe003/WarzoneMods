require("Client_PresentMenuUI");

function Client_GameRefresh(game)
    if not game.Settings.MultiPlayer and GlobalRoot ~= nil then
        game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, true); end);
    end
end