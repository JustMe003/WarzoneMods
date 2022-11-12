-- code
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
    Game.GetTurn(Game.Game.TurnNumber - 1, callback);
end

function callback(t)
    for i, v in pairs(t.Orders) do
        print(i, v.proxyType);
    end
end
