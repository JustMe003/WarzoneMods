-- code
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
    Game.GetTurn(Game.Game.TurnNumber - 2, callback);
end

function callback(t)
    for i, v in pairs(t.Orders) do
        if v.proxyType == "GameOrderEvent" then
            print(v.ModID);
        end
    end
end
