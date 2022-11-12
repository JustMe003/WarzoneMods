-- code
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
    Game.GetTurn(Game.Game.TurnNumber - 2, callback);
end

function callback(t)
    for i, v in pairs(t.Orders) do
        print(v.Message)
        if v.proxyType == "GameOrderEvent" then
            for _, k in pairs(v.readableKeys) do
                print(k, v[k]);
            end
        end
    end
end
